--!strict
--#region Requires & Types
local EnemyService = require(script.Parent.EnemyService)
local Enemy = require(script.Parent.EnemyService.Enemy)
local Tower = require(script.Tower)
local Spawner = require(script.Spawner)
local Unit = require(script.Spawner.Unit)
type TowerService = {
    --Properties
    Towers: {Tower.Tower},
    Spawners: {Spawner.Spawner},
    Units: {Unit.Unit},
    UnitRemoveQueue: {Unit.Unit},
    --Functions
    newTower: (towerType: string, position: Vector3) -> (Tower.Tower),
    newSpawner: (spawnerType: string, position: Vector3) -> (Tower.Tower),
    attackEnemies: () -> (),
    spawnUnits: () -> (),
    removeUnits: () -> (),
    moveUnits: (deltaTime: number) -> (),
    checkUnitCollision: () -> (),
    collide: (unit: Unit.Unit, enemy: Enemy.Enemy) -> ()
}
--#endregion

--#region Variables
local TowerService = {} :: TowerService
TowerService.Towers = {}
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

    return TowerService.Units
end
--#endregion

--#region Functions
function TowerService.newTower(towerType: string, position: Vector3): (Tower.Tower)
    --TODO: Implement economy
    local tower = Tower.new(towerType, position)
    table.insert(TowerService.Towers, tower)
    return tower
end

function TowerService.newSpawner(spawnerType: string, position: Vector3): (Spawner.Spawner)
    local spawner = Spawner.new(spawnerType, position)
    table.insert(TowerService.Spawners, spawner)
    return spawner
end

--function TowerService.sellTower()
--function TowerService.sellSpawner()

function TowerService.attackEnemies(): ()
    for _, tower in TowerService.Towers do
        print(TowerService.Towers)
        local debounce: number = tower.AttackSpeed

        if tick() - tower.AttackTimer > debounce then
            local target = tower:FindTarget()

            if target then
                tower.Part.CFrame = CFrame.lookAt(tower.Part.Position, target.Part.Position)
                if tower.AttackType == "Direct" then
                    tower:DirectAttack(target)
                elseif tower.AttackType == "Circle" then
                    tower:CircleAttack(target)
                elseif tower.AttackType == "Box" then
                    tower:BoxAttack(target)
                elseif tower.AttackType == "Cone" then
                    tower:ConeAttack(target)
                else
                    tower:ChainAttack(target)
                end
                EnemyService.sortHealth()
            end
        end
    end

    return
end

function TowerService.spawnUnits(): ()
    for _, spawner in TowerService.Spawners do
        local debounce: number = spawner.SpawnSpeed
        if tick() - spawner.SpawnTimer > debounce then
            if spawner.AttackType == "Melee" then
                table.insert(TowerService.Units, spawner:SpawnUnit())
            else
                local unit: Unit.Unit = spawner:SpawnUnit()
                table.insert(TowerService.Units, unit)
                table.insert(TowerService.Towers, unit)
                unit.Index = #TowerService.Towers
            end
        end
    end

    return
end

function TowerService.removeUnits(): ()
    for i, v in TowerService.UnitRemoveQueue do
        table.remove(TowerService.Units, i)
        v:Destroy()
    end

    table.clear(TowerService.UnitRemoveQueue)

    return
end

function TowerService.moveUnits(deltaTime: number): ()
    for _, unit in TowerService.Units do
        local result: boolean? = unit:Move(deltaTime)
        if result == nil then
            table.insert(TowerService.UnitRemoveQueue, unit)
        end
    end

    sortUnits()

    return
end

function TowerService.checkUnitCollision(): ()
    local unit: Unit.Unit = TowerService.Units[1]
    for _, enemy in EnemyService.DistanceSort do
        if unit.Waypoint == enemy.Waypoint - 1 and unit.Distance > enemy.Distance then
            TowerService.collide(unit, enemy)
        elseif unit.Waypoint < enemy.Waypoint - 1 then
            TowerService.collide(unit, enemy)
        else
            break
        end
    end

    return
end

function TowerService.collide(unit: Unit.Unit, enemy: Enemy.Enemy): (boolean?)
    local result: boolean? = unit:Collide(enemy)
    if result == true then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
    elseif result == false then
        table.insert(TowerService.UnitRemoveQueue, unit)
        if unit.AttackType ~= "Melee" then
            table.remove(TowerService.Towers, unit.Index)
        end
    elseif result == nil then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
        table.insert(TowerService.UnitRemoveQueue, unit)
        if unit.AttackType ~= "Melee" then
            table.remove(TowerService.Towers, unit.Index)
        end
    end

    return result
end
--#endregion

return TowerService