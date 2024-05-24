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

--#region Local Functions
local function setAttributes(self: EcoTower)
    self.Part:SetAttribute("Income", self.Income)
    self.Part:SetAttribute("IncomeGenerated", self.IncomeGenerated)
    self.Part:SetAttribute("Level", self.Level)
    self.Part:SetAttribute("Value", self.Value)
    self.Part:SetAttribute("Cost", self.Cost)
end
--#endregion

--#region Functions
function Eco.new(ecoTemplate: TowerData.EcoTemplate, position: Vector3): (EcoTower)
	local self = table.clone(ecoTemplate)

    self.Part = game.ServerStorage.Towers[self.Name]:Clone()
    self.Part.Range.Size = Vector3.new(self.Range * 2, 0.1, self.Range * 2)
    self.Part.Parent = workspace.Towers
    self.Part.CFrame = CFrame.new(position)
    setAttributes(self)

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