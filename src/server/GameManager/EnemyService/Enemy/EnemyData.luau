--!strict
--#region Defintions and Declaration
type EnemyData = {
	Enemy: {
		MaxHealth: number,
		Speed: number,
		SpeedModifier: number,
		Value: number,
		Waypoint: number,
		Distance: number
	}
}

local defaults = {
	MaxHealth = 6,
	Speed = 6,
	SpeedModifier = 1,
	Value = 6,
	Waypoint = 1,
	Distance = 0
}

local EnemyData = {}
--#endregion

--#region Functions
local function CreateEnemy(name: string, customValues: {}?)
	local newEnemy = {}

	for key, value in pairs(defaults) do
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

--#region Enemies
CreateEnemy("Basic")
CreateEnemy("Fast", {MaxHealth = 3, Speed = 12, Value = 3})
CreateEnemy("Big", {MaxHealth = 18, Speed = 3, Value = 18})
--#endregion

return EnemyData