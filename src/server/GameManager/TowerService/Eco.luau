--!strict
--#region Requires & Types
local TowerData = require(script.Parent.TowerData)

type EcoFunctions = {
    __index: EcoFunctions,
    new: (ecoTemplate: TowerData.EcoTemplate, position: Vector3) -> (EcoTower),
    Destroy: (self: EcoTower) -> (),
    Generate: (self: EcoTower) -> (number)
}

type EcoData = {
    Type: string,
    Part: Part,
    Owner: Player,
    Name: string,
    Level: number,
    Limit: number?,
    Cost: number,
    Value: number,
    Income: number,
    IncomeGenerated: number
}

export type EcoTower = typeof(setmetatable({} :: EcoData, {} :: EcoFunctions))

local Eco = {} :: EcoFunctions
Eco.__index = Eco
--#endregion

--#region Functions
function Eco.new(ecoTemplate: TowerData.EcoTemplate, position: Vector3): (EcoTower)
	local self = table.clone(ecoTemplate)
    self.Part = game.ServerStorage.Towers[self.Name]:Clone()
    self.Part:SetAttribute("IncomeGenerated", self.IncomeGenerated)
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
    self.IncomeGenerated += self.Income
    self.Part:SetAttribute("IncomeGenerated", self.IncomeGenerated)
    return self.Income
end
--#endregion

return Eco