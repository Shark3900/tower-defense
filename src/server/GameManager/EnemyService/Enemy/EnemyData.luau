--!strict
--#region Defintions and Declaration
local EnemyData = {}

type EnemyData = {
	MaxHealth: number,
	Speed: number,
	SpeedModifier: number,
	Value: number,
	Waypoint: number,
	Distance: number
}
--#endregion

--#region Enemies
EnemyData["Basic"] = {MaxHealth = 6, Speed = 8, SpeedModifier = 1, Value = 6, Waypoint = 1, Distance = 0}
EnemyData["Fast"] = {MaxHealth = 3, Speed = 16, SpeedModifier = 1, Value = 3, Waypoint = 1, Distance = 0}
EnemyData["Big"] = {MaxHealth = 18, Speed = 4, SpeedModifier = 1, Value = 18, Waypoint = 1, Distance = 0}
--#endregion

return EnemyData