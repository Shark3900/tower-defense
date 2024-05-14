--!strict
--#region Requires & Types
local SpawnerData = require(script.SpawnerData)
local Unit = require(script.Unit)
local Spawner = {}
Spawner.__index = Spawner

export type Spawner = {
    --Properties
    Part: Part,
    Level: number,
    Cost: number,
    SpawnType: string,
    SpawnSpeed: number,
    SpawnTimer: number,
    Units: {Unit.Unit},
    --Functions
    new: (towerName: string, position: Vector3) -> (Spawner),
    Destroy: (self: Spawner) -> (),
    SpawnUnit: (self: Spawner) -> (Unit.Unit)
}
--#endregion

--#region Functions
function Spawner.new(spawnerName: string, position: Vector3): Spawner
	local self = table.clone(SpawnerData[spawnerName][1])
    self.Level = 1
    self.Part = game.ServerStorage.Spawners[spawnerName]:Clone()
    self.Part.Position = position
    self.Part.Parent = workspace.Towers
    return setmetatable(self, Spawner)
end

function Spawner:Destroy(): ()
	self.Part:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Spawner:SpawnUnit(): Unit.Unit
    self.SpawnTimer = tick()
    local unit: Unit.Unit = Unit.new(self.SpawnType, self.Level)
    table.insert(self.Units, unit) --TODO: Delete units when tower is sold/destroyed
    return unit
end
--#endregion

return Spawner