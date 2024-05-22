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
    --attackEnemies: () -> (number),
    --spawnUnits: () -> (),
    --removeUnits: () -> (),
    --moveUnits: (deltaTime: number) -> (),
    --checkUnitCollision: () -> (number),
    --collide: (unit: Unit.Unit, enemy: Enemy.Enemy) -> (number),
    getCost: (towerName: string) -> (number?)
}
--#endregion

--#region Variables
local TowerService = {} :: TowerService
TowerService.Towers = {}
--TowerService.EcoTowers = {}
--TowerService.Spawners = {}
--TowerService.Units = {}
--TowerService.UnitRemoveQueue = {}
--#endregion

--#region Local Functions
local function attack(tower: Tower.Tower): (number)
    local damage = 0
    local debounce: number = tower.AttackSpeed

    if tick() - tower.AttackTimer > debounce then
        local target = tower:FindTarget()
        if target then
            tower.Part.CFrame = CFrame.lookAt(tower.Part.Position, target.Part.Position)
            damage += tower:Attack(target)
            EnemyService.sortHealth()
        end
    end
    
    return damage
end

local function spawnUnit(spawner: Spawner.Spawner): ()
    local debounce: number = spawner.SpawnSpeed
    if tick() - spawner.SpawnTimer > debounce then
        local unit: Unit.Unit = spawner:SpawnUnit()
        table.insert(TowerService.Towers, unit)
    end

    return
end

local function removeUnit(unit: Unit.Unit): ()
    table.remove(TowerService.Towers, table.find(TowerService.Towers, unit))
    unit.Spawner:RemoveUnit()
    return
end

local function collide(unit: Unit.Unit, enemy: Enemy.Enemy): (number)
    local result: boolean?, value: number = unit:Collide(enemy)
    if result == true then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
    elseif result == false then
        removeUnit(unit)
    elseif result == nil then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
        removeUnit(unit)
    end

    return result, value
end

local function checkUnitCollision(unit: Unit.Unit): (number)
    local damage = 0
    for _, enemy in EnemyService.DistanceSort do
        if unit.Waypoint == enemy.Waypoint - 1 and unit.Distance > enemy.Distance then
            local result: boolean?, value: number = collide(unit, enemy)
            damage += value
            if result ~= true then
                break
            end
        elseif unit.Waypoint < enemy.Waypoint - 1 then
            local result: boolean?, value: number = collide(unit, enemy)
            damage += value
            if result ~= true then
                break
            end
        else
            break
        end
    end

    return damage
end

local function iterateUnit(unit: Unit.Unit, deltaTime: number): (number)
    local damage = 0
    local result = unit:Move(deltaTime)

    if unit.AttackType ~= "Melee" then
        attack(unit)
    end

    if result == nil then
        removeUnit(unit)
    else
        damage += checkUnitCollision(unit)
    end

    return damage
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
        return TowerService.newSpawnerTower(newTower, position)
    else
        return nil
    end
end

function TowerService.newNormalTower(towerTemplate: {TowerData.TowerTemplate}, position: Vector3): (Tower.Tower)
    local tower = Tower.new(towerTemplate, position)
    table.insert(TowerService.Towers, tower)
    return tower
end

function TowerService.newEcoTower(ecoTemplate: {TowerData.EcoTemplate}, position: Vector3): (Eco.EcoTower)
    local ecoTower = Eco.new(ecoTemplate, position)
    table.insert(TowerService.Towers, ecoTower)
    return ecoTower
end

function TowerService.newSpawnerTower(spawnerTemplate: {TowerData.SpawnerTemplate}, position: Vector3): (Spawner.Spawner)
    local spawner = Spawner.new(spawnerTemplate, position)
    table.insert(TowerService.Towers, spawner)
    return spawner
end

function TowerService.sellTower()

end

function TowerService.getCost(towerName: string): (number?)
    if TowerData[towerName] then
        return TowerData[towerName][1].Cost
    else
        return nil
    end
end

function TowerService.iterateTowers(deltaTime: number): (number)
    local damage = 0

    for _, tower in TowerService.Towers do
        if tower.Type == "Tower" then
            damage += attack(tower)
        elseif tower.Type == "Eco" then
            --Rewrite PlayerService dependence so that this isn't a problem
        elseif tower.Type == "Spawner" then
            spawnUnit(tower)
        elseif tower.Type == "Unit" then
            damage += iterateUnit(tower, deltaTime)
        end
    end

    return damage
end
--#endregion

return TowerService