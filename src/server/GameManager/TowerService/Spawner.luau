--!strict
--#region Requires & Types
local TowerData = require(script.Parent.TowerData)
local Unit = require(script.Parent.Unit)

type SpawnerFunctions = {
    __index: SpawnerFunctions,
    new: (spawnerTemplate: TowerData.SpawnerTemplate, position: Vector3) -> (Spawner),
    Destroy: (self: Spawner) -> (),
    SpawnUnit: (self: Spawner) -> (Unit.Unit),
    RemoveUnit: (self: Spawner) -> ()

}

type SpawnerData = {
    Type: string,
    Part: Part,
    Owner: Player,
    Name: string,
    Level: number,
    Limit: number?,
    Cost: number,
    Value: number,
    DamageDealt: number,
    AttackType: string,
    SpawnType: string,
    SpawnSpeed: number,
    SpawnTimer: number,
    Units: {Unit.Unit},
}

export type Spawner = typeof(setmetatable({} :: SpawnerData, {} :: SpawnerFunctions))

local Spawner = {} :: SpawnerFunctions
Spawner.__index = Spawner
--#endregion

--#region Functions
function Spawner.new(spawnerTemplate: TowerData.SpawnerTemplate, position: Vector3): (Spawner)
	local self = table.clone(spawnerTemplate)
    self.Part = game.ServerStorage.Towers[self.Name]:Clone()
    self.Part.Position = position
    self.Part.Parent = workspace.Towers
    return setmetatable(self, Spawner)
end

function Spawner:Destroy(): ()
    for _, unit in self.Units do
        unit:Destroy()
    end
	self.Part:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Spawner:SpawnUnit(): (Unit.Unit)
    self.SpawnTimer = tick()
    local unit: Unit.Unit = Unit.new(self.SpawnType, self.Level)
    unit.Spawner = self
    table.insert(self.Units, unit)
    return unit
end

function Spawner:RemoveUnit(): ()
    local unit: Unit.Unit = self.Units[1]
    table.remove(self.Units, 1)
    self.DamageDealt += unit.DamageDealt
    self.Part:SetAttribute("DamageDealt", self.DamageDealt)
    unit:Destroy()
    return
end
--#endregion

return Spawner