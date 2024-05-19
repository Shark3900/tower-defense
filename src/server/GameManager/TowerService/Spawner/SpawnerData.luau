--!strict
--#region Definitions and Declaration
export type SpawnerData = {
	Spawner: {
		{
            Limit: number?,
			Cost: number,
            AttackType: string,
            SpawnType: string,
            SpawnSpeed: number,
            SpawnTimer: number,
            Units: {},
		}
	}
}

local defaults = {
    SpawnTimer = 0,
    Units = {}
}

local SpawnerData = {} :: SpawnerData
--#endregion

--#region Functions
local function CreateTower(name: string, customValues: {}?)
    local newTower = {}
	local towerDefaults = SpawnerData[name]["Defaults"]

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

    SpawnerData[name][#SpawnerData[name] + 1] = newTower

    return newTower
end
--#endregion

--#region Towers
SpawnerData["Melee"] = {
	["Defaults"] = {
		Cost = 100,
        AttackType = "Melee",
        SpawnType = "Melee",
        SpawnSpeed = 20,
	}
}
SpawnerData["Rifles"] = {
	["Defaults"] = {
		Cost = 200,
        AttackType = "Ranged",
        SpawnType = "Rifles",
        SpawnSpeed = 30,
	}
}
--#endreigon

CreateTower("Melee")
CreateTower("Melee", {Cost = 200})

CreateTower("Rifles")
CreateTower("Rifles", {Cost = 400})

return SpawnerData