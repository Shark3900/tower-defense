--!strict
--#region Requires & Types
local TowerData = require(script.Parent.TowerData)
local EnemyService = require(script.Parent.Parent.EnemyService)
local Enemy = require(script.Parent.Parent.EnemyService.Enemy)
local Tower = {} :: TowerFunctions
Tower.__index = Tower

type TowerFunctions = {
    __index: TowerFunctions,
    new: (towerTemplate: {TowerData.TowerTemplate}, position: Vector3) -> (Tower),
    Destroy: (self: Tower) -> (),
    Attack: (self: Tower, enemy: Enemy.Enemy) -> (number),
    CheckRange: (self: Tower, enemy: Enemy.Enemy) -> (boolean),
    FindFirst: (self: Tower) -> (Enemy.Enemy?),
    FindStrong: (self: Tower) -> (Enemy.Enemy?),
    FindLast: (self: Tower) -> (Enemy.Enemy?),
    FindTarget: (self: Tower) -> (Enemy.Enemy?),
    DirectAttack: (self: Tower, target: Enemy.Enemy) -> (number),
    BoxAttack: (self: Tower, target: Enemy.Enemy) -> (number),
    CircleAttack: (self: Tower, target: Enemy.Enemy) -> (number),
    ConeAttack: (self: Tower, target: Enemy.Enemy) -> (number),
    ChainAttack: (self: Tower, target: Enemy.Enemy) -> (number)
}

type TowerData = {
    --Properties
    Part: Part,
    Index: number,
    Owner: Player,
    Name: string,
    Level: number,
    Limit: number?, --TODO: Implement tower limit
    Cost: number,
    Value: number,
    Damage: number,
    DamageDealt: number,
	Range: number,
	AttackType: string,
	AttackPrio: string,
	AttackSpeed: number,
	AttackTimer: number,
    Chain: number?, --If chain attack
    ChainRange: number?, --If chain attack
    Angle: number?, --If cone AOE
    Radius: number?, --If circle AOE
    Width: number?, --If rectangle AOE
    Buffs: {TowerData.Buff}?, --If support tower
    BuffedTowers: {Tower}?, --If support tower
    --Flags
	CanArmored: boolean?,
	CanStealth: boolean?,
	CanFlying: boolean?
    --Functions
}

export type Tower = typeof(setmetatable({} :: TowerData, {} :: TowerFunctions))
--#endregion

--#region Functions
function Tower.new(towerTemplate: {TowerData.TowerTemplate}, position: Vector3): (Tower)
	local self = table.clone(towerTemplate)
    self.Part = game.ServerStorage.Towers[self.Name]:Clone()
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

function Tower:Attack(enemy: Enemy.Enemy): (number)
    self.AttackTimer = tick()
    local result: Enemy.Enemy?, value: number = enemy:ChangeHealth(self.Damage)
    if result == nil then
        table.insert(EnemyService.EnemyRemoveQueue, enemy)
    end
    self.DamageDealt += value
    self.Part:SetAttribute("DamageDealt", self.DamageDealt)
    return value
end

function Tower:CheckRange(enemy: Enemy.Enemy): (boolean)
    if (enemy.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
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

function Tower:DirectAttack(target: Enemy.Enemy): (number)
    table.insert(self.AttackQueue, target)
    return self:Attack(target)
end

function Tower:CircleAttack(target: Enemy.Enemy): ()
    local damage: number = 0
    for _, enemy in EnemyService.Enemies do
        if (enemy.Part.Position - target.Part.Position).Magnitude <= self.Radius then
            damage += self:Attack(enemy)
        end
    end

    return damage
end

function Tower:BoxAttack(target: Enemy.Enemy): (number)
    local damage: number = 0
    local halfWidth: number = self.Width / 2

    for _, enemy in EnemyService.Enemies do
        local toEnemy: Vector3 = enemy.Part.Position - target.Part.Position
        local distanceAlongDirection: number = toEnemy:Dot(self.Part.CFrame.LookVector)
        local distancePerpendicular: number = math.abs(toEnemy:Dot(self.Part.CFrame.RightVector))

        if distanceAlongDirection >= 0 and distanceAlongDirection <= self.Range and distancePerpendicular <= halfWidth then
            damage += self:Attack(enemy)
        end
    end

    return damage
end

function Tower:ConeAttack(target: Enemy.Enemy): (number)
    local damage: number = 0
    local towerPos: Vector3 = self.Part.Position
    local direction: Vector3 = (target.Part.Position - towerPos).Unit

    for _, enemy in EnemyService.Enemies do
        if self:CheckRange(enemy) then
            local enemyDirection: Vector3 = (enemy.Part.Position - towerPos).Unit
            local angleToEnemy: number = math.deg(math.acos(direction:Dot(enemyDirection)))

            if angleToEnemy <= self.Angle / 2 then
                damage += self:Attack(enemy)
            end
        end
    end

    return damage
end

--TODO: Chain might be inconsistent towards behind targets -- Possibly inconsistent DistanceSort?
function Tower:ChainAttack(target: Enemy.Enemy): (number)
    local damage: number = 0
    damage += self:Attack(target)
    for i = target.DistanceIndex + 1, self.Chain do
        if EnemyService.DistanceSort[i] then
            local enemyOne: Enemy.Enemy = EnemyService.DistanceSort[i - 1]
            local enemyTwo: Enemy.Enemy = EnemyService.DistanceSort[i]
            if (enemyOne.Part.Position - enemyTwo.Part.Position).Magnitude < self.ChainRange then
                damage += self:Attack(EnemyService.DistanceSort[i])
            else
                break
            end
        end
    end

    return damage
end
--#endregion

return Tower