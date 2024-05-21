--!strict
--#region Definitions and Declaration
export type Buff = {
    DamageModifier: number?,
    SpeedModifier: number?,
    RangeModifier: number?,
    SpawnModifier: number? --Should Spawns be a separate buff?
}

export type TowerTemplate = {
    Type: "Tower",
    Name: string,
    Level: number,
	Limit: number?,
	Cost: number,
	Value: number,
	Damage: number,
	DamageDealt: number,
	Range: number,
	AttackType: string, --Direct, Circle, Box, Cone
	AttackPrio: string,
	AttackSpeed: number,
	AttackTimer: number,
	AttackQueue: {},
	CanArmored: boolean?,
	CanStealth: boolean?,
	CanFlying: boolean?,
	Chain: number?, --If chain attack
	ChainRange: number?, --If chain attack
	Angle: number?, --If cone AOE
	Radius: number?, --If circle AOE
	Width: number?, --If rectangle AOE
	Buffs: {Buff}?, --If support tower
	BuffedTowers: {}?, --If support tower
}

export type SpawnerTemplate = {
    Type: "Spawner",
    Name: string,
    Level: number,
    Limit: number?,
    Cost: number,
    Value: number,
    DamageDealt: number,
    AttackType: string,
    SpawnType: string,
    SpawnSpeed: number,
    SpawnTimer: number,
    Units: {},
}

export type EcoTemplate = {
    Type: "Eco",
    Name: string,
    Level: number,
    Limit: number?,
    Cost: number,
    Value: number,
    Income: number,
    IncomeGenerated: number
}

export type UnitTemplate = {
    Name: string,
    Level: number,
    Limit: number?,
    MaxHealth: number,
    Speed: number,
    SpeedModifier: number,
    Distance: number,
    DamageDealt: number,
    Damage: number?,
    Range: number?,
    AttackType: string?, --Direct, Circle, Box, Cone
    AttackPrio: string?,
    AttackSpeed: number?,
    AttackTimer: number?,
    AttackQueue: {}?,
    CanArmored: boolean?,
    CanStealth: boolean?,
    CanFlying: boolean?,
    Chain: number?, --If chain attack
    ChainRange: number?, --If chain attack
    Angle: number?, --If cone AOE
    Radius: number?, --If circle AOE
    Width: number?, --If rectangle AOE
    Stunned: boolean?,
    Slowed: boolean?,
    Flying: boolean?
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
    AttackType = "Melee"
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

local function createSpawner(name: string, customValues: {SpawnerTemplate}?)
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

local function createEcoTower(name: string, customValues: {EcoTemplate}?)
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

local function createUnit(name: string, customValues: {UnitTemplate}?)
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

local function createRangedUnit(name: string, customValues: {UnitTemplate}?)
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
		AttackType = "Chain"
	},
}
TowerData["Mortar"] = {
	["Defaults"] = {
        Name = "Mortar",
		Cost = 200,
		Value = 200,
		Damage = 5,
		Range = 10,
		Radius = 3,
		AttackType = "Circle"
	}
}
TowerData["Commander"] = {
	["Defaults"] = {
        Name = "Commander",
		Cost = 300,
		Value = 300,
		Damage = 2,
		Range = 10,
		AttackSpeed = 1.36
	}
}
--#endregion
--#region Spawners
TowerData["MeleeSpawner"] = {
	["Defaults"] = {
        Name = "MeleeSpawner",
		Cost = 100,
        Value = 100,
        AttackType = "Melee",
        SpawnType = "Melee",
        SpawnSpeed = 20,
	}
}
TowerData["RifleSpawner"] = {
	["Defaults"] = {
        Name = "RifleSpawner",
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
		Speed = 8,
		Damage = 2,
		Range = 10,
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
--#endregion

--#region Spawner Creation
createSpawner("MeleeSpawner")
createSpawner("MeleeSpawner", {Level = 2, Cost = 200, Value = 400})

createSpawner("RifleSpawner")
createSpawner("RifleSpawner", {Level = 2, Cost = 400, Value = 600})
--#endregion

--#region Eco Tower Creation
createEcoTower("Farm")
createEcoTower("Farm", {Level = 2, Cost = 400, Income = 125})
--#endregion

--#region Unit Creation
createUnit("Melee")
createUnit("Melee", {MaxHealth = 45})

createRangedUnit("Rifles")
createRangedUnit("Rifles", {Damage = 2, Range = 12, AttackSpeed = 0.6})
--#endregion

return TowerData