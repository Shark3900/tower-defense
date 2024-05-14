--!strict
--#region Defaults
local EnemyData = {}
local Defaults = {
    MaxHealth = 5,
    Speed = 8,
	SpeedModifier = 1,
    Value = 1,
    Waypoint = 2,
	Distance = 0
}
--#endregion

--#region Functions
local function CreateEnemy(name: string, customValues: {}?)
	local newEnemy = {}

	for key, value in pairs(Defaults) do
		newEnemy[key] = value
	end
	if customValues then
		for key, value in pairs(customValues) do
			newEnemy[key] = value
		end
	end
	EnemyData[name] = newEnemy

	return newEnemy
end
--#endregion

--#region Registers
CreateEnemy("Basic")
CreateEnemy("Fast", {MaxHealth = 3, Speed = 16})
CreateEnemy("Big", {MaxHealth = 20, Speed = 5})
--#endregion

return EnemyData