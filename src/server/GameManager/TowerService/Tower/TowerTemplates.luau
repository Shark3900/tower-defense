--!strict
--#region Defaults
local TowerTemplates = {}
local Defaults = {
	Damage = 1,
	AttackSpeed = 0.6,
	AttackType = "Direct",
	AttackPrio = "First",
	AttackTimer = 0,
	AttackQueue = {},
	Range = 10,
	Value = 1
}
local SpawnerDefaults = {
	Range = 0,
	Value = 1,
	AttackSpeed = 0,
	AttackTimer = 0,
	SpawnTimer = 0,
	SpawnSpeed = 10,
	Units = {}
}
--#endregion

--#region Functions
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
--#endregion

--#region Registers
CreateTower("Basic")
CreateTower("Cone", {AttackType = "Cone", AttackPrio = "Last", Range = 6, Angle = 45})
CreateTower("Circle", {AttackType = "Circle", AttackPrio = "Strong", Range = 10, Radius = 3})
CreateTower("Box", {AttackType = "Box", AttackPrio = "First", Range = 10, Width = 4})
CreateTower("Chain", {Chain = 5})
CreateSpawner("MeleeSpawner", {AttackType = "Melee", SpawnType = "Melee"})
CreateSpawner("RangedSpawner", {AttackType = "Direct", SpawnType = "Ranged"})
--#endregion

return TowerTemplates