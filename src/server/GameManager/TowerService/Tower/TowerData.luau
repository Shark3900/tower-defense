--!strict
--#region Definitions and Declaration
type TowerData = {
	Tower: {
		{
			Cost: number,
			Damage: number,
			Range: number,
			AttackType: string,
			AttackPrio: string,
			AttackSpeed: number,
			AttackTimer: number,
			AttackQueue: {},
			Chain: number?,
			ChainRange: number?,
			Angle: number?,
			Radius: number?,
			Width: number?,
			CanArmored: boolean,
			CanStealth: boolean,
			CanFlying: boolean
		}
	}
}

local TowerData = {} :: TowerData
--#endregion

--#region Towers
TowerData["Basic"] = {
	--Level 1
	{Damage = 1, Cost = 100, Range = 10,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {}},
	--Level 2
	{Damage = 3, Cost = 200, Range = 12,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.8, AttackTimer = 0, AttackQueue = {}}
}
TowerData["Sniper"] = {
	--Level 1
	{Damage = 10, Cost = 200, Range = 20,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.3, AttackTimer = 0, AttackQueue = {}},
	--Level 2
	{Damage = 20, Cost = 400, Range = 25,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.3, AttackTimer = 0, AttackQueue = {}}
}
TowerData["Tesla"] = {
	--Level 1
	{Damage = 1, Cost = 150, Range = 10,
	AttackType = "Chain", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Chain = 3, ChainRange = 5},
	--Level 2
	{Damage = 2, Cost = 300, Range = 10,
	AttackType = "Chain", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Chain = 4, ChainRange = 5}
}
TowerData["Mortar"] = {
	--Level 1
	{Damage = 5, Cost = 200, Range = 10,
	AttackType = "Circle", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Radius = 3},
	--Level 2
	{Damage = 8, Cost = 400, Range = 10,
	AttackType = "Circle", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Radius = 4}
}
--#endreigon

return TowerData