--!strict

local TowerTemplates = require(script.TowerTemplates)
local UnitService = require(script.UnitService)
local Tower = {}
Tower.__index = Tower

export type Tower = {
    --Properties
    Part: Part,
    Damage: number,
	Value: number,
	AttackType: string,
	AttackPrio: string,
	AttackSpeed: number,
	AttackTimer: number,
	Range: number,
    Angle: number, --If cone AOE
    Radius: number, --If circle AOE
    Width: number, --If rectangle AOE
    --Spawner Properties
    SpawnType: string,
    SpawnSpeed: number,
    SpawnTimer: number,
    Units: {UnitService.Unit},
    --Flags
	CanArmored: boolean,
	CanStealth: boolean,
	CanFlying: boolean,
    --Functions
    new: (towerName: string, position: Vector3) -> ({Tower}),
    Destroy: (self: Tower) -> (),
    Attack: (self: Tower, enemy: {}) -> ({}?),
    CheckRange: (self: Tower, enemy: {}) -> (boolean),
    SpawnUnit: (self: Tower) -> ({UnitService.Unit})
}

function Tower.new(towerName: string, position: Vector3)
	local self = table.clone(TowerTemplates[towerName])
    self.Part = game.ServerStorage.Towers[towerName]:Clone()
    self.Part.Position = position
    self.Part.Parent = workspace.Towers
    return setmetatable(self, Tower)
end

function Tower:Destroy()
	self.Part:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Tower:Attack(enemy: {})
    self.AttackTimer = tick()
    return enemy:ChangeHealth(-self.Damage)
end

function Tower:CheckRange(enemy: {})
    if (enemy.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
end

function Tower:SpawnUnit()
    self.SpawnTimer = tick()
    local unit = UnitService.new(self.SpawnType)
    table.insert(self.Units, unit)
    return unit
end

return Tower