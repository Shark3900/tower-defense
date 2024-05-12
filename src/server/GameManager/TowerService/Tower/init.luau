--!strict
--#region Requires & Types
local TowerTemplates = require(script.TowerTemplates)
local EnemyService = require(script.Parent.Parent.EnemyService)
local Enemy = require(script.Parent.Parent.EnemyService.Enemy)
local Unit = require(script.Parent.Parent.UnitService.Unit)
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
    AttackQueue: {Enemy.Enemy},
	Range: number,
    Chain: number, --If chain attack
    Angle: number, --If cone AOE
    Radius: number, --If circle AOE
    Width: number, --If rectangle AOE
    --Spawner Properties
    SpawnType: string,
    SpawnSpeed: number,
    SpawnTimer: number,
    Units: {Unit.Unit},
    --Flags
	CanArmored: boolean,
	CanStealth: boolean,
	CanFlying: boolean,
    --Functions
    new: (towerName: string, position: Vector3) -> ({Tower}),
    Destroy: (self: Tower) -> (),
    Attack: (self: Tower, enemy: {Enemy.Enemy}) -> ({Enemy.Enemy}?),
    AttackLoop: (self: Tower) -> (),
    CheckRange: (self: Tower, enemy: {Enemy.Enemy}) -> (boolean),
    FindTarget: (self: Tower) -> ({Enemy.Enemy}?),
    FindFirst: (self: Tower) -> ({Enemy.Enemy}?),
    FindStrong: (self: Tower) -> ({Enemy.Enemy}?),
    FindLast: (self: Tower) -> ({Enemy.Enemy}?),
    DirectAttack: (self: Tower, target: {Enemy.Enemy}) -> (),
    ConeAttack: (self: Tower, target: {Enemy.Enemy}) -> (),
    CircleAttack: (self: Tower, target: {Enemy.Enemy}) -> (),
    BoxAttack: (self: Tower, target: {Enemy.Enemy}) -> (),
    SpawnUnit: (self: Tower) -> ({Unit.Unit}) --Probably doesn't need self, move to UnitService?
}
--#endregion

--#region Functions
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

function Tower:Attack(enemy: {Enemy.Enemy})
    self.AttackTimer = tick()
    return enemy:ChangeHealth(-self.Damage)
end

function Tower:AttackLoop()
    for _, v in self.AttackQueue do
        local result = self:Attack(v)
        if result == nil then
            table.insert(EnemyService.EnemyRemoveQueue, v)
        end
    end

    table.clear(self.AttackQueue)

    return
end

function Tower:CheckRange(enemy: {Enemy.Enemy})
    if (enemy.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
end

function Tower:FindTarget()
    local target

    if self.AttackPrio == "Melee" then
        return nil
    elseif self.AttackPrio == "First" then
        target = self:FindFirst()
    elseif self.AttackPrio == "Strong" then
        target = self:FindStrong()
    else
        target = self:FindLast()
    end

    return target
end

function Tower:FindFirst()
    for _, enemy in EnemyService.DistanceSort do
        if enemy.Health > 0 and self:CheckRange(enemy) then
            return enemy
        end
    end

    return nil
end

function Tower:FindStrong()
    for _, enemy in EnemyService.HealthSort do
        if enemy.Health > 0 and self:CheckRange(enemy) then
            return enemy
        end
    end

    return nil
end

function Tower:FindLast()
    for i = #EnemyService.DistanceSort, 1, -1 do
        local enemy = EnemyService.DistanceSort[i]
        if enemy.Health > 0 and self:CheckRange(enemy) then
            return enemy
        end
    end

    return nil
end

--TODO: Chain might be inconsistent
function Tower:DirectAttack(target: {Enemy.Enemy})
    table.insert(self.AttackQueue, target)
    if self.Chain then
        for i = target.DistanceIndex + 1, self.Chain do
            if EnemyService.DistanceSort[i] then
                local enemyOne = EnemyService.DistanceSort[i - 1]
                local enemyTwo = EnemyService.DistanceSort[i]
                if EnemyService.getDistance(enemyOne, enemyTwo) < self.ChainRange then
                    table.insert(self.AttackQueue, EnemyService.DistanceSort[i])
                else
                    break
                end
            end
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop()
    end

    return
end

function Tower:ConeAttack(target: {Enemy.Enemy})
    local towerPos: Vector3 = self.Part.Position
    local direction: Vector3 = (target.Part.Position - towerPos).Unit

    for _, enemy in self.Enemies do
        if self:CheckRange(enemy) then
            local enemyDirection: Vector3 = (enemy.Part.Position - towerPos).Unit
            local angleToEnemy: number = math.deg(math.acos(direction:Dot(enemyDirection)))

            if angleToEnemy <= self.Angle / 2 then
                table.insert(self.AttackQueue, enemy)
            end
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop()
    end

    return
end

function Tower:CircleAttack(target: {Enemy.Enemy})
    for _, enemy in self.Enemies do
        if (enemy.Part.Position - target.Part.Position).Magntiude <= self.Range then
            table.insert(self.AttackQueue, enemy)
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop()
    end

    return
end

function Tower:BoxAttack(target: {Enemy.Enemy})
    local halfWidth: number = self.Width / 2

    for _, enemy in self.Enemies do
        local toEnemy: Vector3 = enemy.Part.Position - target.Part.Position
        local distanceAlongDirection: number = toEnemy:Dot(self.Part.CFrame.LookVector)
        local distancePerpendicular: number = math.abs(toEnemy:Dot(self.Part.CFrame.RightVector))

        if distanceAlongDirection >= 0 and distanceAlongDirection <= self.Range and distancePerpendicular <= halfWidth then
            table.insert(self.AttackQueue, enemy)
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop()
    end

    return
end

function Tower:SpawnUnit()
    self.SpawnTimer = tick()
    local unit = Unit.new(self.SpawnType)
    table.insert(self.Units, unit) --TODO: Delete units when tower is sold/destroyed
    return unit
end
--#endregion

return Tower