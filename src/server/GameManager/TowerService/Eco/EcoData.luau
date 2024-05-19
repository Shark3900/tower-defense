--!strict
--#region Definitions and Declaration
export type EcoData = {
	EcoTower: {
		{
			Limit: number?,
			Cost: number,
            Income: number
		}
	}
}

local defaults = {}

local EcoData = {} :: EcoData
--#endregion

--#region Functions
local function CreateTower(name: string, customValues: {}?)
    local newTower = {}
	local towerDefaults = EcoData[name]["Defaults"]

    for key, value in pairs(defaults) do
        newTower[key] = value
    end

	for key, value in pairs(towerDefaults) do
        newTower[key] = value
    end
    
    if customValues then
        for key, value in pairs(customValues) do
            newTower[key] = value
        end
    end

    EcoData[name][#EcoData[name] + 1] = newTower

    return newTower
end
--#endregion

--#region Towers
EcoData["Farm"] = {
	["Defaults"] = {
		Cost = 200,
        Income = 50
	}
}
--#endreigon

CreateTower("Farm")
CreateTower("Farm", {Cost = 400, Income = 125})

return EcoData