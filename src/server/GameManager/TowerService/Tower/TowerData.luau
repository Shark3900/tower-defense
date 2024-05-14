--!strict
--#region Declarations
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

TowerData["Basic"] = {
	{Damage = 1, Cost = 100, Range = 10,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {}},
	{Damage = 3, Cost = 200, Range = 12,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.8, AttackTimer = 0, AttackQueue = {}}
}
TowerData["Sniper"] = {
	{Damage = 10, Cost = 200, Range = 20,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.3, AttackTimer = 0, AttackQueue = {}},
	{Damage = 20, Cost = 400, Range = 25,
	AttackType = "Direct", AttackPrio = "First", AttackSpeed = 0.3, AttackTimer = 0, AttackQueue = {}}
}
TowerData["Tesla"] = {
	{Damage = 1, Cost = 150, Range = 10,
	AttackType = "Chain", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Chain = 3, ChainRange = 5},
	{Damage = 2, Cost = 300, Range = 10,
	AttackType = "Chain", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Chain = 4, ChainRange = 5}
}
TowerData["Mortar"] = {
	{Damage = 5, Cost = 200, Range = 10,
	AttackType = "Circle", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Radius = 3},
	{Damage = 8, Cost = 400, Range = 10,
	AttackType = "Circle", AttackPrio = "First", AttackSpeed = 0.6, AttackTimer = 0, AttackQueue = {},
	Radius = 4}
}

return TowerData

--[[
local Defaults = {
	Level = 1,
	Damage = 1,
	Value = 1,
	AttackType = "Direct",
	AttackPrio = "First",
	AttackSpeed = 0.6,
	AttackTimer = 0,
	AttackQueue = {},
	Range = 10
}
local SpawnerDefaults = {
	Level = 1,
	Damage = 0,
	Range = 0,
	Value = 1,
	AttackType = "Melee",
	AttackPrio = "Melee",
	AttackSpeed = 0,
	AttackTimer = 0,
	SpawnType = "Melee",
	SpawnSpeed = 10,
	SpawnTimer = 0,
	Units = {}
}

local function CreateTower(name: string, customValues: {}?)
	local newTower = {}

	for key, value in pairs(Defaults) do
		newTower[key] = value
	end
	if customValues then
		for key, value in pairs(customValues) do
			newTower[key] = value
		end
	end
	TowerTemplates[name] = newTower

	return newTower
end

local function CreateSpawner(name: string, customValues: {}?)
	local newSpawner = {}

	for key, value in SpawnerDefaults do
		newSpawner[key] = value
	end
	if customValues then
		for key, value in customValues do
			newSpawner[key] = value
		end
	end
	TowerTemplates[name] = newSpawner

	return newSpawner
end

CreateTower("Basic")
CreateTower("Cone", {AttackType = "Cone", AttackPrio = "Last", Range = 6, Angle = 45})
CreateTower("Circle", {AttackType = "Circle", AttackPrio = "Strong", Range = 10, Radius = 3})
CreateTower("Box", {AttackType = "Box", AttackPrio = "First", Range = 10, Width = 4})
CreateTower("Chain", {AttackType = "Chain", Chain = 5, ChainRange = 4})
CreateSpawner("MeleeSpawner", {AttackType = "Melee", SpawnType = "Melee"})
CreateSpawner("RangedSpawner", {AttackType = "Direct", SpawnType = "Ranged"})
]]