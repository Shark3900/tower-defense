--!strict
--#region Requires & Types
local TowerData = require(script.Parent.TowerData)
local Eco = {}
Eco.__index = Eco

export type Eco = {
    --Properties
    Part: Part,
    Index: number,
    Owner: Player,
    Name: string,
    Level: number,
    Limit: number?,
    Cost: number,
    Income: number,
    --Functions
    new: (ecoTemplate: {TowerData.EcoTemplate}, position: Vector3) -> (Eco),
    Destroy: (self: Eco) -> (),
    Generate: (self: Eco) -> (number)
}
--#endregion

--#region Functions
function Eco.new(ecoTemplate: {TowerData.EcoTemplate}, position: Vector3): (Eco)
	local self = table.clone(ecoTemplate)
    self.Part = game.ServerStorage.Towers[self.Name]:Clone()
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