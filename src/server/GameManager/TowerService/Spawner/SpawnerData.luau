--!strict
--#region Defintions and Declaration
local SpawnerData = {} :: SpawnerData

export type SpawnerData = {
	Tower: {
		{
			Cost: number,
			Damage: number,
            AttackType: string,
            SpawnType: string,
            SpawnSpeed: number,
            SpawnTimer: number,
            Units: {},
		}
	}
}
--#endregion

--#region Spawners
SpawnerData["Melee"] = {
    {Cost = 100, Damage = 1, AttackType = "Melee", SpawnType = "Melee", SpawnSpeed = 20, SpawnTimer = 0, Units = {}},
    {Cost = 200, Damage = 3, AttackType = "Melee", SpawnType = "Melee", SpawnSpeed = 20, SpawnTimer = 0, Units = {}}
}
SpawnerData["Rifles"] = {
    {Cost = 200, Damage = 10, AttackType = "Ranged", SpawnType = "Rifles", SpawnSpeed = 30, SpawnTimer = 0, Units = {}},
    {Cost = 400, Damage = 20, AttackType = "Ranged", SpawnType = "Rifles", SpawnSpeed = 30, SpawnTimer = 0, Units = {}}
}
--#endregion

return SpawnerData