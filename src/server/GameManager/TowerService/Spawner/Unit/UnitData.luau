--!strict
--#region Defintions and Declaration
type UnitData = {
	Unit: {
		MaxHealth: number,
		Speed: number,
		SpeedModifier: number,
		Distance: number,
		Damage: number?,
		AttackType: string?,
		AttackPrio: string?,
		AttackSpeed: number?,
		AttackTimer: number?,
		Range: number?
	}
}

local UnitData = {} :: UnitData
--#endregion

--#region Units
UnitData["Melee"] = {
	{MaxHealth = 30, Speed = 8, SpeedModifier = 1, Distance = 0},
	{MaxHealth = 45, Speed = 8, SpeedModifier = 1, Distance = 0}
}
--#endregion

return UnitData

--[[
local RangedDefaults = {
    MaxHealth = 20,
    Speed = 6,
	SpeedModifier = 1,
	Distance = 0,
    Damage = 1,
	AttackType = "Single",
	AttackPrio = "First",
	AttackSpeed = 0.6,
	AttackTimer = 0,
	Range = 10
}
]]