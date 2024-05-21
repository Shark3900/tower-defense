--!strict
--#region Requires & Types
local EnemyService = require(script.Parent.EnemyService)
local Enemy = require(script.Parent.EnemyService.Enemy)
local TowerData = require(script.TowerData)
local Tower = require(script.Tower)
local Eco = require(script.Eco)
local Spawner = require(script.Spawner)
local Unit = require(script.Unit)

export type TowerService = {
    --Properties
    Towers: {Tower.Tower},
    EcoTowers: {Eco.EcoTower},
    Spawners: {Spawner.Spawner},
    Units: {Unit.Unit},
    UnitRemoveQueue: {Unit.Unit},
    --Functions
    newTower: (towerType: string, position: Vector3) -> (Tower.Tower | Eco.EcoTower | Spawner.Spawner | nil),
    newNormalTower: (towerTemplate: {TowerData.TowerTemplate}, position: Vector3) -> (Tower.Tower),
    newEcoTower: (towerTemplate: {TowerData.EcoTemplate}, position: Vector3) -> (Eco.EcoTower),
    newSpawner: (towerTemplate: {TowerData.SpawnerTemplate}, position: Vector3) -> (Spawner.Spawner),
    attackEnemies: () -> (number),
    spawnUnits: () -> (),
    removeUnits: () -> (),
    moveUnits: (deltaTime: number) -> (),
    checkUnitCollision: () -> (number),
    collide: (unit: Unit.Unit, enemy: Enemy.Enemy) -> (number),
    getCost: (towerName: string) -> (number?)
}
--#endregion

--#region Variables
local TowerService = {} :: TowerService
TowerService.Towers = {}
TowerService.EcoTowers = {}
TowerService.Spawners = {}
TowerService.Units = {}
TowerService.UnitRemoveQueue = {}
--#endregion

--#region Local Functions
local function sortUnits()
    table.sort(TowerService.Units, function(a, b)
        if a.Waypoint ~= b.Waypoint then
            return a.Waypoint < b.Waypoint
        else
            return a.Distance > b.Distance
        end
    end)

    if #TowerService.Units > 0 then
        for i = 1, #TowerService.Units do
            TowerService.Units[i].UnitIndex = i
        end
    end

    return TowerService.Units
end
--#endregion

--#region Functions
function TowerService.newTower(towerName: string, position: Vector3): (Tower.Tower | Eco.EcoTower | Spawner.Spawner | nil)
    local newTower = TowerData[towerName][1]
    if newTower.Type == "Tower" then
        return TowerService.newNormalTower(newTower, position)
    elseif newTower.Type == "Eco" then
        return TowerService.newEcoTower(newTower, position)
    elseif newTower.Type == "Spawner" then
        return TowerService.newSpawner(newTower, position)
    else
        return nil
    end
end

function TowerService.newNormalTower(towerTemplate: {TowerData.TowerTemplate}, position: Vector3): (Tower.Tower)
    local tower = Tower.new(towerTemplate, position)
    table.insert(TowerService.Towers, tower)
    tower.Index = #TowerService.Towers
    return tower
end

function TowerService.newEcoTower(towerTemplate: {TowerData.EcoTemplate}, position: Vector3): (Eco.EcoTower)
    local eco = Eco.new(towerTemplate, position)
    table.insert(TowerService.EcoTowers, eco)
    eco.Index = #TowerService.EcoTowers
    return eco
end

function TowerService.newSpawner(towerTemplate: {TowerData.SpawnerTemplate}, position: Vector3): (Spawner.Spawner)
    local spawner = Spawner.new(towerTemplate, position)
    table.insert(TowerService.Spawners, spawner)
    spawner.Index = #TowerService.Spawners
    return spawner
end

function TowerService.sellTower()

end
--function TowerService.sellSpawner()

function TowerService.attackEnemies(): (number)
    local damage = 0

    for _, tower in TowerService.Towers do
        local debounce: number = tower.AttackSpeed

        if tick() - tower.AttackTimer > debounce then
            local target = tower:FindTarget()

            if target then
                tower.Part.CFrame = CFrame.lookAt(tower.Part.Position, target.Part.Position)
                if tower.AttackType == "Direct" then
                    damage += tower:DirectAttack(target)
                elseif tower.AttackType == "Circle" then
                    damage += tower:CircleAttack(target)
                elseif tower.AttackType == "Box" then
                    damage += tower:BoxAttack(target)
                elseif tower.AttackType == "Cone" then
                    damage += tower:ConeAttack(target)
                else
                    damage += tower:ChainAttack(target)
                end
                EnemyService.sortHealth()
            end
        end
    end

    return damage
end

function TowerService.spawnUnits(): ()
    for _, spawner in TowerService.Spawners do
        local debounce: number = spawner.SpawnSpeed
        if tick() - spawner.SpawnTimer > debounce then
            if spawner.AttackType == "Melee" then
                local unit: Unit.Unit = spawner:SpawnUnit()
                table.insert(TowerService.Units, unit)
                unit.UnitIndex = #TowerService.Units
            else
                local unit: Unit.Unit = spawner:SpawnUnit()
                table.insert(TowerService.Units, unit)
                table.insert(TowerService.Towers, unit)
                unit.Index = #TowerService.Towers
                unit.UnitIndex = #TowerService.Units
            end
        end
    end

    return
end

function TowerService.removeUnits(): ()
    for _, unit in TowerService.UnitRemoveQueue do
        if unit.AttackType ~= "Melee" then
            table.remove(TowerService.Towers, unit.Index)
        end
        table.remove(TowerService.Units, unit.UnitIndex)
        unit.Spawner:RemoveUnit()
        sortUnits()
    end

    table.clear(TowerService.UnitRemoveQueue)

    return
end

function TowerService.moveUnits(deltaTime: number): ()
    for _, unit in TowerService.Units do
        local result: Unit.Unit? = unit:Move(deltaTime)
        if result == nil then
            table.insert(TowerService.UnitRemoveQueue, unit)
        end
    end

    sortUnits()

    return
end

function TowerService.checkUnitCollision(): (number)
    local unit: Unit.Unit = TowerService.Units[1]
    local damage = 0
    for _, enemy in EnemyService.DistanceSort do
        if unit.Waypoint == enemy.Waypoint - 1 and unit.Distance > enemy.Distance then
            damage += TowerService.collide(unit, enemy)
        elseif unit.Waypoint < enemy.Waypoint - 1 then
            damage += TowerService.collide(unit, enemy)
        else
            break
        end
    end

    return damage
end

function TowerService.collide(unit: Unit.Unit, enemy: Enemy.Enemy): (number)
    local result: boolean, value: number = unit:Collide(enemy)
    if result == true then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
    elseif result == false then
        table.insert(TowerService.UnitRemoveQueue, unit)
    elseif result == nil then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
        table.insert(TowerService.UnitRemoveQueue, unit)
    end

    return value
end

function TowerService.getCost(towerName: string): (number?)
    if TowerData[towerName] then
        return TowerData[towerName][1].Cost
    else
        return nil
    end
end
--#endregion

return TowerService