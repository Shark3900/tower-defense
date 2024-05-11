--!strict
local UnitTemplates = {}
local MeleeDefaults = {
    MaxHealth = 30,
    Speed = 8,
	SpeedModifier = 1,
	Distance = 0
}
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

local function CreateMeleeUnit(name: string, customValues: {}?)
	local newUnit = {}

	for key, value in pairs(MeleeDefaults) do
		newUnit[key] = value
	end
	if customValues then
		for key, value in pairs(customValues) do
			newUnit[key] = value
		end
	end
	UnitTemplates[name] = newUnit

	return newUnit
end

local function CreateRangedUnit(name: string, customValues: {}?)
	local newUnit = {}

	for key, value in pairs(RangedDefaults) do
		newUnit[key] = value
	end
	if customValues then
		for key, value in pairs(customValues) do
			newUnit[key] = value
		end
	end
	UnitTemplates[name] = newUnit

	return newUnit
end

CreateMeleeUnit("Melee")
CreateRangedUnit("Ranged")
--CreateRangedUnit("Ranged", {AttackType = "Circle", Radius = 3, AttackSpeed = 3})

return UnitTemplates