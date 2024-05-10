--!strict

local TowerTemplates = {}
local Defaults = {
	Damage = 1,
	AttackSpeed = 0.6,
	AttackTimer = 0,
	AttackType = "Single",
	AttackPrio = "First",
	Range = 10,
	Value = 1
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

CreateTower("Basic")
CreateTower("Cone", {AttackType = "Cone", AttackPrio = "Last", Range = 6, Angle = 45})
CreateTower("Circle", {AttackType = "Circle", AttackPrio = "Strong", Range = 10, Radius = 3})
CreateTower("Box", {AttackType = "Box", AttackPrio = "First", Range = 10, Width = 4})
CreateTower("MeleeSpawner", {AttackType = "Melee", SpawnType = "Melee", Range = 0, SpawnTimer = 0, SpawnSpeed = 10, Units = {}})
CreateTower("RangedSpawner", {AttackType = "First", SpawnType = "Ranged", Range = 0, SpawnTimer = 0, SpawnSpeed = 20, Units = {}})

return TowerTemplates