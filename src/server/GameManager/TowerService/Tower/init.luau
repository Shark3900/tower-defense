--!strict
--#region Requires & Types
local TowerData = require(script.TowerData)
local EnemyService = require(script.Parent.Parent.EnemyService)
local Enemy = require(script.Parent.Parent.EnemyService.Enemy)
local Tower = {}
Tower.__index = Tower

export type Tower = {
    --Properties
    Part: Part,
    Level: number,
    Cost: number,
    Damage: number,
	Range: number,
	AttackType: string,
	AttackPrio: string,
	AttackSpeed: number,
	AttackTimer: number,
    AttackQueue: {Enemy.Enemy},
    Chain: number?, --If chain attack
    ChainRange: number?, --If chain attack
    Angle: number?, --If cone AOE
    Radius: number?, --If circle AOE
    Width: number?, --If rectangle AOE
    --Flags
	CanArmored: boolean?,
	CanStealth: boolean?,
	CanFlying: boolean?,
    --Functions
    new: (towerName: string, position: Vector3) -> (Tower),
    Destroy: (self: Tower) -> (),
    Attack: (self: Tower, enemy: Enemy.Enemy) -> ({result: (Enemy.Enemy?), value: number}),
    AttackLoop: (self: Tower) -> (),
    CheckRange: (self: Tower, enemy: Enemy.Enemy) -> (boolean),
    FindTarget: (self: Tower) -> (Enemy.Enemy?),
    FindFirst: (self: Tower) -> (Enemy.Enemy?),
    FindStrong: (self: Tower) -> (Enemy.Enemy?),
    FindLast: (self: Tower) -> (Enemy.Enemy?),
    DirectAttack: (self: Tower, target: Enemy.Enemy) -> (),
    BoxAttack: (self: Tower, target: Enemy.Enemy) -> (),
    CircleAttack: (self: Tower, target: Enemy.Enemy) -> (),
    ConeAttack: (self: Tower, target: Enemy.Enemy) -> (),
    ChainAttack: (self: Tower, target: Enemy.Enemy) -> ()
}
--#endregion

--#region Functions
function Tower.new(towerName: string, position: Vector3): (Tower)
	local self = table.clone(TowerData[towerName][1])
    self.Level = 1
    self.Part = game.ServerStorage.Towers[towerName]:Clone()
    self.Part.Position = position
    self.Part.Parent = workspace.Towers
    return setmetatable(self, Tower)
end

function Tower:Destroy(): ()
	self.Part:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Tower:Attack(enemy: Enemy.Enemy): ({result: Enemy.Enemy?, value: number})
    self.AttackTimer = tick()
    return enemy:ChangeHealth(self.Damage)
end

function Tower:AttackLoop(): (number)
    local damage = 0

    for _, v in self.AttackQueue do
        local result: {Enemy.Enemy?}, value: {number} = self:Attack(v)
        if result == nil then
            table.insert(EnemyService.EnemyRemoveQueue, v)
        end
        damage += value
    end

    table.clear(self.AttackQueue)

    return damage
end

function Tower:CheckRange(enemy: Enemy.Enemy): (boolean)
    if (enemy.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
end

function Tower:FindTarget(): (Enemy.Enemy?)
    local target: Enemy.Enemy?

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

function Tower:FindFirst(): (Enemy.Enemy?)
    for _, enemy in EnemyService.DistanceSort do
        if enemy.Health > 0 and self:CheckRange(enemy) then
            return enemy
        end
    end

    return nil
end

function Tower:FindStrong(): (Enemy.Enemy?)
    for _, enemy in EnemyService.HealthSort do
        if enemy.Health > 0 and self:CheckRange(enemy) then
            return enemy
        end
    end

    return nil
end

function Tower:FindLast(): (Enemy.Enemy?)
    for i = #EnemyService.DistanceSort, 1, -1 do
        local enemy: Enemy.Enemy = EnemyService.DistanceSort[i]
        if enemy.Health > 0 and self:CheckRange(enemy) then
            return enemy
        end
    end

    return nil
end

function Tower:DirectAttack(target: Enemy.Enemy): (number)
    table.insert(self.AttackQueue, target)
    return self:AttackLoop()
end

function Tower:CircleAttack(target: Enemy.Enemy): (number)
    for _, enemy in self.Enemies do
        if (enemy.Part.Position - target.Part.Position).Magntiude <= self.Range then
            table.insert(self.AttackQueue, enemy)
        end
    end

    return self:AttackLoop()
end

function Tower:BoxAttack(target: Enemy.Enemy): (number)
    local halfWidth: number = self.Width / 2

    for _, enemy in self.Enemies do
        local toEnemy: Vector3 = enemy.Part.Position - target.Part.Position
        local distanceAlongDirection: number = toEnemy:Dot(self.Part.CFrame.LookVector)
        local distancePerpendicular: number = math.abs(toEnemy:Dot(self.Part.CFrame.RightVector))

        if distanceAlongDirection >= 0 and distanceAlongDirection <= self.Range and distancePerpendicular <= halfWidth then
            table.insert(self.AttackQueue, enemy)
        end
    end

    return self:AttackLoop()
end

function Tower:ConeAttack(target: Enemy.Enemy): (number)
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

    return self:AttackLoop()
end

--TODO: Chain might be inconsistent towards behind targets -- Possibly inconsistent DistanceSort?
function Tower:ChainAttack(target: Enemy.Enemy): (number)
    table.insert(self.AttackQueue, target)
    for i = target.DistanceIndex + 1, self.Chain do
        if EnemyService.DistanceSort[i] then
            local enemyOne: Enemy.Enemy = EnemyService.DistanceSort[i - 1]
            local enemyTwo: Enemy.Enemy = EnemyService.DistanceSort[i]
            if (enemyOne.Part.Position - enemyTwo.Part.Position).Magnitude < self.ChainRange then
                table.insert(self.AttackQueue, EnemyService.DistanceSort[i])
            else
                break
            end
        end
    end

    return self:AttackLoop()
end

function Tower.getCost(towerName: string): (number?)
    if TowerData[towerName] then
        return TowerData[towerName][1].Cost
    else
        return nil
    end
end
--#endregion

return Tower