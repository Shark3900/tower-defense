--!strict
--#region Definitions and Declaration
export type Buff = {
    DamageModifier: number?,
    SpeedModifier: number?,
    RangeModifier: number?,
    SpawnModifier: number? --Should Spawns be a separate buff?
}

export type TowerTemplate = {
    --All Tower Properties
    Type: string,
    Part: Part,
    Owner: Player,
    Name: string,
    Level: number,
    Limit: number?, --TODO: Implement tower limit
    Cost: number,
    Value: number,
    --Normal, Support, and Unit Properties
    AttackPrio: string?,
    AttackSpeed: number?,
    AttackTimer: number?,
    AttackType: string?,
    Damage: number?,
    DamageDealt: number?,
    Range: number?,
    ReloadSpeed: number?,
    MaxAmmo: number?,
    Ammo: number?,
    SlowModifier: number?,
    SlowTimer: number?,
    StunTimer: number?,
    BuffedTowers: {}?, --If support tower
    Buffs: Buff?, --If support tower
    Angle: number?, --If cone AOE
    Chain: number?, --If chain attack
    ChainRange: number?, --If chain attack
    Radius: number?, --If circle AOE
    Width: number?, --If rectangle AOE
    Targets: {}?, --If ramping tower
    TargetArmored: boolean?,
    TargetFlying: boolean?,
    TargetStealth: boolean?,
    --Eco Tower Properties
    IncomeGenerated: number?,
    Income: number?,
    --Spawner Tower Properties
    Path: number?,
    SpawnSpeed: number?,
    SpawnTimer: number?,
    SpawnType: string?,
    Units: {}?,
    --Unit Properties
    Path: number?,
    Distance: number?,
    Health: number?,
    MaxHealth: number?,
    Spawner: {}?,
    Speed: number?,
    SpeedModifier: number?,
    Waypoint: number?,
    Flying: boolean?,
    Slowed: boolean?,
    Stunned: boolean?
}

local towerDefaults = {
    Type = "Tower",
    Level = 1,
	DamageDealt = 0,
	AttackType = "Direct",
	AttackPrio = "First",
	AttackSpeed = 0.68,
	AttackTimer = 0,
	AttackQueue = {}
}

local spawnerDefaults = {
    Type = "Spawner",
    Level = 1,
    Path = 1,
    DamageDealt = 0,
    SpawnTimer = 0,
    Units = {}
}

local ecoDefaults = {
    Type = "Eco",
    Level = 1,
    IncomeGenerated = 0
}

local unitDefaults = {
    Type = "Unit",
    Level = 1,
	SpeedModifier = 1,
	Distance = 0,
	DamageDealt = 0,
    AttackType = "Nah"
}

local rangedUnitDefaults = {
	AttackType = "Direct",
	AttackPrio = "First",
	AttackSpeed = 0.68,
	AttackTimer = 0,
	AttackQueue = {}
}

local TowerData = {}
--#endregion

--#region Functions
local function createTower(name: string, customValues: {TowerTemplate}?)
    local newTower = {}
	local newTowerDefaults = TowerData[name]["Defaults"]

    for key, value in pairs(towerDefaults) do
        newTower[key] = value
    end

	for key, value in pairs(newTowerDefaults) do
        newTower[key] = value
    end

    if customValues then
        for key, value in pairs(customValues) do
            newTower[key] = value
        end
    end

    TowerData[name][#TowerData[name] + 1] = newTower

    return newTower
end

local function createSpawner(name: string, customValues: {TowerTemplate}?)
    local newSpawner = {}
	local newSpawnerDefaults = TowerData[name]["Defaults"]

    for key, value in pairs(spawnerDefaults) do
        newSpawner[key] = value
    end

	for key, value in pairs(newSpawnerDefaults) do
        newSpawner[key] = value
    end

    if customValues then
        for key, value in pairs(customValues) do
            newSpawner[key] = value
        end
    end

    TowerData[name][#TowerData[name] + 1] = newSpawner

    return newSpawner
end

local function createEcoTower(name: string, customValues: {TowerTemplate}?)
    local newEco = {}
    local newEcoDefaults = TowerData["Farm"]["Defaults"]

    for key, value in pairs(ecoDefaults) do
        newEco[key] = value
    end

    for key, value in pairs(newEcoDefaults) do
        newEco[key] = value
    end

    if customValues then
        for key, value in pairs(customValues) do
            newEco[key] = value
        end
    end

    TowerData[name][#TowerData[name] + 1] = newEco

    return newEco
end

local function createUnit(name: string, customValues: {TowerTemplate}?)
    local newUnit = {}
    local newUnitDefaults = TowerData[name]["Defaults"]

    for key, value in pairs(unitDefaults) do
        newUnit[key] = value
    end

    for key, value in pairs(newUnitDefaults) do
        newUnit[key] = value
    end

    if customValues then
        for key, value in pairs(customValues) do
            newUnit[key] = value
        end
    end

    TowerData[name][#TowerData[name] + 1] = newUnit

    return newUnit
end

local function createRangedUnit(name: string, customValues: {TowerTemplate}?)
    local newUnit = {}
    local newUnitDefaults = TowerData[name]["Defaults"]

    for key, value in pairs(unitDefaults) do
        newUnit[key] = value
    end

    for key, value in pairs(rangedUnitDefaults) do
        newUnit[key] = value
    end

    for key, value in pairs(newUnitDefaults) do
        newUnit[key] = value
    end

    if customValues then
        for key, value in pairs(customValues) do
            newUnit[key] = value
        end
    end

    TowerData[name][#TowerData[name] + 1] = newUnit

    return newUnit
end
--#endregion

--#region Towers
TowerData["Basic"] = {
	["Defaults"] = {
        Name = "Basic",
		Cost = 100,
		Value = 100,
		Damage = 2,
		Range = 10,
	}
}
TowerData["Sniper"] = {
	["Defaults"] = {
        Name = "Sniper",
		Cost = 200,
		Value = 200,
		Damage = 10,
		Range = 20,
		AttackSpeed = 3
	}
}
TowerData["Tesla"] = {
	["Defaults"] = {
        Name = "Tesla",
		Cost = 150,
		Value = 150,
		Damage = 1,
		Range = 10,
		Chain = 3,
		ChainRange = 5,
        AttackSpeed = 1.36,
		AttackType = "Chain"
	},
}
TowerData["Mortar"] = {
	["Defaults"] = {
        Name = "Mortar",
		Cost = 200,
		Value = 200,
		Damage = 3,
		Range = 10,
		Radius = 3,
        AttackSpeed = 2.5,
		AttackType = "Circle"
	}
}
TowerData["Commander"] = {
	["Defaults"] = {
        Type = "Support",
        Name = "Commander",
		Cost = 300,
		Value = 300,
		Damage = 2,
		Range = 10,
		AttackSpeed = 1.36,
        AttackType = "Nah",
        Buffs = {
                Damage = 2,
                AttackSpeed = 2,
                Range = 2,
                SpawnSpeed = 2
        },
        BuffedTowers = {}
	}
}
TowerData["Glue Gunner"] = {
    ["Defaults"] = {
        Name = "Glue Gunner",
        Cost = 150,
        Value = 150,
        Damage = 0,
        Range = 10,
        AttackSpeed = 1.36,
        AttackType = "Circle",
        Radius = 1,
        SlowModifier = 0.5,
        SlowTimer = 2,
    }

}
--#endregion
--#region Spawners
TowerData["Melee Spawner"] = {
	["Defaults"] = {
        Name = "Melee Spawner",
		Cost = 200,
        Value = 200,
        AttackType = "Nah",
        SpawnType = "Melee",
        SpawnSpeed = 20,
	}
}
TowerData["Rifle Spawner"] = {
	["Defaults"] = {
        Name = "Rifle Spawner",
		Cost = 200,
        Value = 200,
        AttackType = "Ranged",
        SpawnType = "Rifles",
        SpawnSpeed = 30,
	}
}
--#endregion
--#region Eco Towers
TowerData["Farm"] = {
	["Defaults"] = {
        Name = "Farm",
		Cost = 200,
        Income = 50
	}
}
--#endregion
--#region Units
TowerData["Melee"] = {
	["Defaults"] = {
        Name = "Melee",
		MaxHealth = 30,
		Speed = 8
	}
}
TowerData["Rifles"] = {
	["Defaults"] = {
        Name = "Rifles",
		MaxHealth = 20,
		Speed = 6,
		Damage = 1,
		Range = 10,
	}
}
--#endregion

--#region Tower Creation
createTower("Basic")
createTower("Basic", {Level = 2, Cost = 200, Value = 300, Damage = 3, Range = 12, AttackSpeed = 0.5})

createTower("Sniper")
createTower("Sniper", {Level = 2, Cost = 400, Value = 600,Damage = 20, Range = 25, AttackSpeed = 2.7})

createTower("Tesla")
createTower("Tesla", {Level = 2, Cost = 300, Value = 450, Damage = 2, Chain = 4})

createTower("Mortar")
createTower("Mortar", {Level = 2, Cost = 400, Value = 600, Damage = 8, Radius = 4})

createTower("Commander")
createTower("Commander", {Level = 2, Cost = 400, Value = 700, Buffs = {Damage = 1.2, AttackSpeed = 1.2, Range = 1.2, SpawnSpeed = 1.2}})

createTower("Glue Gunner")
createTower("Glue Gunner", {Level = 2, Cost = 300, Value = 450, Radius = 2, Slow = 0.45, SlowTimer = 3})
--#endregion

--#region Spawner Creation
createSpawner("Melee Spawner")
createSpawner("Melee Spawner", {Level = 2, Cost = 200, Value = 400})

createSpawner("Rifle Spawner")
createSpawner("Rifle Spawner", {Level = 2, Cost = 400, Value = 600})
--#endregion

--#region Eco Tower Creation
createEcoTower("Farm")
createEcoTower("Farm", {Level = 2, Cost = 400, Value = 600, Income = 125})
--#endregion

--#region Unit Creation
createUnit("Melee")
createUnit("Melee", {MaxHealth = 45})

createRangedUnit("Rifles")
createRangedUnit("Rifles", {Damage = 2, Range = 12, AttackSpeed = 0.6})
--#endregion

return TowerData