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
    Towers: {Tower.Tower | Eco.EcoTower | Spawner.Spawner | Unit.Unit},
    --Functions
    newTower: (towerType: string, position: Vector3) -> (Tower.Tower | Eco.EcoTower | Spawner.Spawner),
    newNormalTower: (towerTemplate: {TowerData.TowerTemplate}, position: Vector3) -> (Tower.Tower),
    newEcoTower: (ecoTemplate: {TowerData.EcoTemplate}, position: Vector3) -> (Eco.EcoTower),
    newSpawnerTower: (spawnerTemplate: {TowerData.SpawnerTemplate}, position: Vector3) -> (Spawner.Spawner),
    sellTower: () -> (),
    getTower: (towerName: string, towerLevel: number) -> (TowerData.TowerTemplate | TowerData.EcoTemplate | TowerData.SpawnerTemplate | nil),
    iterateTowers: (deltaTime: number) -> (number)
}
--#endregion

--#region Variables
local TowerService = {} :: TowerService
TowerService.Towers = {}
--#endregion

--#region Local Functions
local function attack(tower: Tower.Tower): (number)
    local damage = 0

    if tick() - tower.AttackTimer > tower.AttackSpeed then
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
    if tick() - spawner.SpawnTimer > spawner.SpawnSpeed then
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

local function collide(unit: Unit.Unit, enemy: Enemy.Enemy): (boolean?, number)
    local result: boolean?, value: number = unit:Collide(enemy)
    if result == true then
        if table.find(EnemyService.EnemyRemoveQueue, enemy) == nil then
            table.insert(EnemyService.EnemyRemoveQueue, enemy)
        end
    elseif result == false then
        removeUnit(unit)
    elseif result == nil then
        if table.find(EnemyService.EnemyRemoveQueue, enemy) == nil then
            table.insert(EnemyService.EnemyRemoveQueue, enemy)
        end
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
function TowerService.newTower(towerName: string, position: Vector3): (Tower.Tower | Eco.EcoTower | Spawner.Spawner)
    local newTower = TowerData[towerName][1]
    if newTower.Type == "Tower" then
        return TowerService.newNormalTower(newTower, position)
    elseif newTower.Type == "Eco" then
        return TowerService.newEcoTower(newTower, position)
    elseif newTower.Type == "Spawner" then
        return TowerService.newSpawnerTower(newTower, position)
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

function TowerService.sellTower(): ()

end

function TowerService.getTower(towerName: string, towerLevel: number): (TowerData.TowerTemplate | TowerData.EcoTemplate | TowerData.SpawnerTemplate | nil)
    return TowerData[towerName][towerLevel]
end

function TowerService.iterateTowers(deltaTime: number): (number)
    local damage = 0

    for _, tower in TowerService.Towers do
        if tower.Type == "Tower" then
            damage += attack(tower)
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