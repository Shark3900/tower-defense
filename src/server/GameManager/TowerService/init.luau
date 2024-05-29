--!strict
--#region Requires & Types
local EnemyService = require(script.Parent.EnemyService)
local Enemy = require(script.Parent.EnemyService.Enemy)
local TowerData = require(script.TowerData)
local Tower = require(script.Tower)

export type TowerService = {
    --Properties
    Towers: {Tower.Tower},
    --Functions
    newTower: (towerType: string, position: Vector3) -> (Tower.Tower),
    sellTower: () -> (),
    getTower: (towerName: string, towerLevel: number) -> (TowerData.TowerTemplate?),
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

local function spawnUnit(spawner: Tower.Tower): ()
    if tick() - spawner.SpawnTimer > spawner.SpawnSpeed then
        local unit: Tower.Tower = spawner:SpawnUnit()
        table.insert(TowerService.Towers, unit)
    end

    return
end

local function removeUnit(unit: Tower.Tower): ()
    table.remove(TowerService.Towers, table.find(TowerService.Towers, unit))
    unit.Spawner:RemoveUnit()
    return
end

local function collide(unit: Tower.Tower, enemy: Enemy.Enemy): (boolean?, number)
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

local function checkUnitCollision(unit: Tower.Tower): (number)
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

local function iterateUnit(unit: Tower.Tower, deltaTime: number): (number)
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
function TowerService.newTower(towerName: string, position: Vector3): (Tower.Tower)
    local towerTemplate = TowerData[towerName][1]
    local tower = Tower.new(towerTemplate, position)
    table.insert(TowerService.Towers, tower)
    return tower
end

function TowerService.sellTower(): ()

end

function TowerService.getTower(towerName: string, towerLevel: number): (TowerData.TowerTemplate?)
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

function TowerService.updatePreviews()
    for _, data in TowerData do
        if data[1].Type ~= "Unit" then
            game.ReplicatedStorage.Towers[data[1].Name]:SetAttribute("Cost", data[1].Cost)
        end
        if data[1].Type == "Tower" then
            game.ReplicatedStorage.Towers[data[1].Name].Range.Size = Vector3.new(0.1, data[1].Range * 2, data[1].Range * 2)
        end
    end
end
--#endregion

return TowerService