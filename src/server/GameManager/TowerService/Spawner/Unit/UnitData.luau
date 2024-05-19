--!strict
--#region Definitions and Declaration
export type UnitData = {
	Unit: {
		{
			--Properties
			Limit: number?,
			MaxHealth: number,
			Speed: number,
			SpeedModifier: number,
			Distance: number,
			--Ranged Properties
			Damage: number?,
			Range: number?,
			AttackType: string?, --Direct, Circle, Box, Cone
			AttackPrio: string?,
			AttackSpeed: number?,
			AttackTimer: number?,
			AttackQueue: {}?,
			CanArmored: boolean?,
			CanStealth: boolean?,
			CanFlying: boolean?,
			Chain: number?, --If chain attack
			ChainRange: number?, --If chain attack
			Angle: number?, --If cone AOE
			Radius: number?, --If circle AOE
			Width: number?, --If rectangle AOE
			--Flags
			Stunned: boolean,
			Slowed: boolean,
			Flying: boolean
		}
	}
}

local defaults = {
	SpeedModifier = 1,
	Distance = 0,
	Stunned = false,
	Slowed = false,
	Flying = false
}

local UnitData = {} :: UnitData
--#endregion

--#region Functions
local function CreateUnit(name: string, customValues: {}?)
    local newUnit = {}
	local unitDefaults = UnitData[name]["Defaults"]

    for key, value in pairs(defaults) do
        newUnit[key] = value
    end

	for key, value in pairs(unitDefaults) do
        newUnit[key] = value
    end
	
    if customValues then
        for key, value in pairs(customValues) do
            newUnit[key] = value
        end
    end

    UnitData[name][#UnitData[name] + 1] = newUnit

    return newUnit
end
--#endregion

--#region Towers
UnitData["Melee"] = {
	["Defaults"] = {
		MaxHealth = 30,
		Speed = 8,
		Damage = 2,
		Range = 10,
	}
}
UnitData["Rifles"] = {
	["Defaults"] = {
		MaxHealth = 20,
		Speed = 6,
		Damage = 1,
		Range = 10,
		AttackType = "Direct",
		AttackPrio = "First",
		AttackSpeed = 0.68,
		AttackTimer = 0,
		AttackQueue = {},
	}
}
--#endreigon

CreateUnit("Melee")
CreateUnit("Melee", {MaxHealth = 45})

CreateUnit("Rifles")
CreateUnit("Rifles", {Damage = 2, Range = 12, AttackSpeed = 0.6})

return UnitData