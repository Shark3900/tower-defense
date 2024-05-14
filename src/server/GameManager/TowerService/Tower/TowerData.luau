--!strict
--#region Definitions and Declaration
type TowerData = {
	Tower: {
		{
			Cost: number,
			Damage: number,
			Range: number,
			Chain: number?,
			ChainRange: number?,
			Angle: number?,
			Radius: number?,
			Width: number?,
			AttackType: string,
			AttackPrio: string,
			AttackSpeed: number,
			AttackTimer: number,
			AttackQueue: {},
			CanArmored: boolean,
			CanStealth: boolean,
			CanFlying: boolean
		}
	}
}

local defaults = {
	AttackType = "Direct",
	AttackPrio = "First",
	AttackSpeed = 0.68,
	AttackTimer = 0,
	AttackQueue = {}
}

local TowerData = {} :: TowerData
--#endregion

--#region Functions
local function CreateTower(name: string, customValues: {}?)
    local newTower = {}
	local towerDefaults = TowerData[name]["Defaults"]

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

    TowerData[name][#TowerData[name] + 1] = newTower

    return newTower
end
--#endregion

--#region Towers
TowerData["Basic"] = {
	["Defaults"] = {
		Cost = 100,
		Damage = 2,
		Range = 10,
	}
}
TowerData["Sniper"] = {
	["Defaults"] = {
		Cost = 200,
		Damage = 10,
		Range = 20,
		AttackSpeed = 3
	}
}
TowerData["Tesla"] = {
	["Defaults"] = {
		Cost = 150,
		Damage = 1,
		Range = 10,
		Chain = 3,
		ChainRange = 5,
		AttackType = "Chain"
	},
}
TowerData["Mortar"] = {
	["Defaults"] = {
		Cost = 200,
		Damage = 5,
		Range = 10,
		Radius = 3,
		AttackType = "Circle"
	}
}
--#endreigon

CreateTower("Basic")
CreateTower("Basic", {Cost = 200, Damage = 3, Range = 12, AttackSpeed = 0.5})

CreateTower("Sniper")
CreateTower("Sniper", {Cost = 400, Damage = 20, Range = 25, AttackSpeed = 2.7})

CreateTower("Tesla")
CreateTower("Tesla", {Cost = 300, Damage = 2, Chain = 4})

CreateTower("Mortar")
CreateTower("Mortar", {Cost = 400, Damage = 8, Radius = 4})


return TowerData