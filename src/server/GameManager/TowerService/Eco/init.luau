--!strict
--#region Requires & Types
local EcoData = require(script.EcoData)
local Eco = {}
Eco.__index = Eco

export type Eco = {
    --Properties
    Part: Part,
    Index: number,
    Owner: Player,
    --OwnerIndex: number,
    Level: number,
    Limit: number?,
    Cost: number,
    Income: number,
    --Functions
    new: (towerName: string) -> (Eco),
    Destroy: (self: Eco) -> (),
    Generate: (self: Eco) -> (number)
}
--#endregion

--#region Functions
function Eco.new(towerName: string, position: Vector3): (Eco)
	local self = table.clone(EcoData[towerName][1])
    self.Level = 1
    self.Part = game.ServerStorage.Towers[towerName]:Clone()
    self.Part.Position = position
    self.Part.Parent = workspace.Towers
    return setmetatable(self, Eco)
end

function Eco:Destroy(): ()
	self.Part:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Eco:Generate(): (number)
    return self.Income
end
--#endregion

return Eco