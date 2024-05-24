--!strict
--#region Requires & Types
local TowerData = require(script.Parent.TowerData)
local EnemyService = require(script.Parent.Parent.EnemyService)
local Enemy = require(script.Parent.Parent.EnemyService.Enemy)

type TowerFunctions = {
    __index: TowerFunctions,
    new: (towerTemplate: TowerData.TowerTemplate, position: Vector3) -> (Tower),
    Destroy: (self: Tower) -> (),
    Attack: (self: Tower, target: Enemy.Enemy) -> (number),
    CheckRange: (self: Tower, object: (Enemy.Enemy | Tower)) -> (boolean),
    FindTarget: (self: Tower) -> (Enemy.Enemy?),
    ChangeTargetType: (self: Tower, attackPrio: string) -> ()
}

type TowerData = {
    Type: string,
    Part: Part,
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
	CanArmored: boolean?,
	CanStealth: boolean?,
	CanFlying: boolean?
}

export type Tower = typeof(setmetatable({} :: TowerData, {} :: TowerFunctions))

local Tower = {} :: TowerFunctions
Tower.__index = Tower
--#endregion

--#region Local Functions
local function attack(self: Tower, enemy: Enemy.Enemy): (number)
    local result: Enemy.Enemy?, value: number = enemy:ChangeHealth(self.Damage)
    if result == nil then
        if table.find(EnemyService.EnemyRemoveQueue, enemy) == nil then
            table.insert(EnemyService.EnemyRemoveQueue, enemy)
        end
    end
    return value
end

local function setAttributes(self: Tower)
    self.Part:SetAttribute("AttackSpeed", self.AttackSpeed)
    self.Part:SetAttribute("Damage", self.Damage)
    self.Part:SetAttribute("DamageDealt", self.DamageDealt)
    self.Part:SetAttribute("Level", self.Level)
    self.Part:SetAttribute("Range", self.Range)
    self.Part:SetAttribute("Value", self.Value)
    self.Part:SetAttribute("Cost", self.Cost)
    self.Part:SetAttribute("AttackPrio", self.AttackPrio)
end

local targetFunctions = {
    Melee = function() return nil end,

    First = function(self: Tower)
        for _, enemy in EnemyService.DistanceSort do
            if enemy.Health > 0 and self:CheckRange(enemy) then
                return enemy
            end
        end

        return nil
    end,

    Strong = function(self: Tower)
        for _, enemy in EnemyService.HealthSort do
            if enemy.Health > 0 and self:CheckRange(enemy) then
                return enemy
            end
        end

        return nil
    end,

    Last = function(self: Tower)
        for i = #EnemyService.DistanceSort, 1, -1 do
            local enemy: Enemy.Enemy = EnemyService.DistanceSort[i]
            if enemy.Health > 0 and self:CheckRange(enemy) then
                return enemy
            end
        end

        return nil
    end
}

local attackFunctions = {
    Support = function() return 0 end,

    Direct = function(self: Tower, target: Enemy.Enemy)
        self.AttackTimer = tick()
        local damage = attack(self, target)
        self.DamageDealt += damage
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)
        return damage
    end,

    Circle = function(self: Tower, target: Enemy.Enemy)
        self.AttackTimer = tick()
        local damage: number = 0

        for _, enemy in EnemyService.Enemies do
            if (enemy.Part.Position - target.Part.Position).Magnitude <= self.Radius then
                damage += attack(self, enemy)
            end
        end

        self.DamageDealt += damage
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)

        return damage
    end,

    Box = function(self: Tower, target: Enemy.Enemy)
        self.AttackTimer = tick()
        local damage: number = 0
        local halfWidth: number = self.Width / 2

        for _, enemy in EnemyService.Enemies do
            local toEnemy: Vector3 = enemy.Part.Position - target.Part.Position
            local distanceAlongDirection: number = toEnemy:Dot(self.Part.CFrame.LookVector)
            local distancePerpendicular: number = math.abs(toEnemy:Dot(self.Part.CFrame.RightVector))

            if distanceAlongDirection >= 0 and distanceAlongDirection <= self.Range and distancePerpendicular <= halfWidth then
                damage += attack(self, enemy)
            end
        end

        self.DamageDealt += damage
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)

        return damage
    end,

    Cone = function(self: Tower, target: Enemy.Enemy)
        self.AttackTimer = tick()
        local damage: number = 0
        local towerPos: Vector3 = self.Part.Position
        local direction: Vector3 = (target.Part.Position - towerPos).Unit

        for _, enemy in EnemyService.Enemies do
            if self:CheckRange(enemy) then
                local enemyDirection: Vector3 = (enemy.Part.Position - towerPos).Unit
                local angleToEnemy: number = math.deg(math.acos(direction:Dot(enemyDirection)))

                if angleToEnemy <= self.Angle / 2 then
                    damage += attack(self, enemy)
                end
            end
        end

        self.DamageDealt += damage
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)

        return damage
    end,

    --TODO: Chain might be inconsistent towards behind targets -- Possibly inconsistent DistanceSort?
    Chain = function(self: Tower, target: Enemy.Enemy)
        self.AttackTimer = tick()
        local damage: number = 0
        damage += attack(self, target)

        for i = target.DistanceIndex + 1, self.Chain do
            if EnemyService.DistanceSort[i] then
                local enemyOne: Enemy.Enemy = EnemyService.DistanceSort[i - 1]
                local enemyTwo: Enemy.Enemy = EnemyService.DistanceSort[i]
                if (enemyOne.Part.Position - enemyTwo.Part.Position).Magnitude < self.ChainRange then
                    damage += attack(self, EnemyService.DistanceSort[i])
                else
                    break
                end
            end
        end

        self.DamageDealt += damage
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)

        return damage
    end
}
--#endregion

--#region Functions
function Tower.new(towerTemplate: TowerData.TowerTemplate, position: Vector3): (Tower)
    local self =  setmetatable(table.clone(towerTemplate), Tower) :: Tower

    self.Attack = attackFunctions[self.AttackType]
    self.FindTarget = targetFunctions[self.AttackPrio]
    self.Part = game.ServerStorage.Towers[self.Name]:Clone()
    self.Part.Range.Size = Vector3.new(self.Range * 2, 0.1, self.Range * 2)
    self.Part.Parent = workspace.Towers
    self.Part.CFrame = CFrame.new(position)
    setAttributes(self)

    return self
end

function Tower:Destroy(): ()
	self.Part:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Tower:Attack(enemy: Enemy.Enemy): (number)
    local value: number = attackFunctions[self.AttackType](self, enemy)
    return value
end

function Tower:CheckRange(object: (Enemy.Enemy | Tower) ): (boolean)
    if (object.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
end

function Tower:FindTarget(): (Enemy.Enemy?)
    return targetFunctions[self.AttackPrio](self)
end

function Tower:ChangeTargetType(attackPrio: string): ()
    self.FindTarget = targetFunctions[attackPrio]
    return
end
--#endregion

return Tower