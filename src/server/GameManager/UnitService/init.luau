--!strict
--#region Requires & Types
local Unit = require(script.Unit)
local TowerService = require(script.Parent.TowerService)
local EnemyService = require(script.Parent.EnemyService)
local Enemy = require(script.Parent.EnemyService.Enemy)

type UnitService = {
    --Properties
    Units: {Unit.Unit},
    UnitRemoveQueue: {Unit.Unit},
    --Functions
    spawnUnits: () -> (),
    removeUnits: () -> (),
    moveUnits: (deltaTime: number) -> (),
    checkUnitCollision: () -> (),
    collide: (unit: Unit.Unit, enemy: Enemy.Enemy) -> ()
}
--#endregion

--#region Variables
local UnitService = {} :: UnitService
UnitService.Units = {}
UnitService.UnitRemoveQueue = {}
--#endregion

--#region Local Functions
local function sortUnits()
    table.sort(UnitService.Units, function(a, b)
        if a.Waypoint ~= b.Waypoint then
            return a.Waypoint < b.Waypoint
        else
            return a.Distance > b.Distance
        end
    end)

    return UnitService.Units
end
--#endregion

--#region Functions
function UnitService.spawnUnits(): ()
    for _, tower in TowerService.Spawners do
        local debounce: number = tower.SpawnSpeed
        if tick() - tower.SpawnTimer > debounce then
            if tower.AttackType == "Melee" then
                table.insert(UnitService.Units, tower:SpawnUnit())
            else
                local unit: Unit.Unit = tower:SpawnUnit()
                table.insert(UnitService.Units, unit)
                table.insert(TowerService.Towers, unit)
                unit.Index = #TowerService.Towers
            end
        end
    end

    return
end

function UnitService.removeUnits(): ()
    for i, v in UnitService.UnitRemoveQueue do
        table.remove(UnitService.Units, i)
        v:Destroy()
    end

    table.clear(UnitService.UnitRemoveQueue)

    return
end

function UnitService.moveUnits(deltaTime: number): ()
    for _, v in UnitService.Units do
        local result: boolean? = v:Move(deltaTime)
        if result == nil then
            table.insert(UnitService.UnitRemoveQueue, v)
        end
    end

    sortUnits()

    return
end

function UnitService.checkUnitCollision(): ()
    local unit: Unit.Unit = UnitService.Units[1]
    for _, v in EnemyService.DistanceSort do
        if unit.Waypoint == v.Waypoint - 1 and unit.Distance > v.Distance then
            UnitService.collide(unit, v)
        elseif unit.Waypoint < v.Waypoint - 1 then
            UnitService.collide(unit, v)
        else
            break
        end
    end

    return
end

function UnitService.collide(unit: {Unit.Unit}, enemy: {Enemy.Enemy}): (boolean?)
    local result: boolean? = unit:Collide(enemy)
    if result == true then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
    elseif result == false then
        table.insert(UnitService.UnitRemoveQueue, unit)
        if unit.AttackType == not "Melee" then
            table.remove(TowerService.Towers, unit.Index)
        end
    elseif result == nil then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
        table.insert(UnitService.UnitRemoveQueue, unit)
        if unit.AttackType == not "Melee" then
            table.remove(TowerService.Towers, unit.Index)
        end
    end

    return result
end
--#endregion

return UnitService