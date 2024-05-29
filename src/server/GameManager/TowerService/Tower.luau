--!strict
--#region Requires & Types
local TowerData = require(script.Parent.TowerData)
local EnemyService = require(script.Parent.Parent.EnemyService)
local Enemy = require(script.Parent.Parent.EnemyService.Enemy)
local Maps = require(script.Parent.Parent.EnemyService.Maps)

type TowerFunctions = {
    __index: TowerFunctions,
    new: (towerTemplate: TowerData.TowerTemplate, position: Vector3) -> (Tower),
    Destroy: (self: Tower) -> (),
    Attack: (self: Tower, target: Enemy.Enemy) -> (number),
    CheckRange: (self: Tower, object: (Enemy.Enemy | Tower)) -> (boolean),
    FindTarget: (self: Tower) -> (Enemy.Enemy?),
    ChangeTargetType: (self: Tower, attackPrio: string) -> (),
    SpawnUnit: (self: Tower) -> (Tower),
    RemoveUnit: (self: Tower) -> (),
    Move: (self: Tower, deltaTime: number) -> (Tower?),
    Collide: (self: Tower, enemy: Enemy.Enemy) -> (boolean?, number),
    Generate: (self: Tower) -> (number),
    BuffTower: (self: Tower, tower: Tower) -> (),
    UnbuffTower: (self: Tower, tower: Tower) -> ()
}

type TowerData = {
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
    MaxAmmo: number?,
    Ammo: number?,
    SlowModifier: number?,
    SlowTimer: number?,
    StunTimer: number?,
    BuffedTowers: {Tower}?, --If support tower
    Buffs: {TowerData.Buff}?, --If support tower
    Angle: number?, --If cone AOE
    Chain: number?, --If chain attack
    ChainRange: number?, --If chain attack
    Radius: number?, --If circle AOE
    Width: number?, --If rectangle AOE
    Targets: {Enemy.Enemy}?, --If ramping tower
    TargetArmored: boolean?,
    TargetFlying: boolean?,
    TargetStealth: boolean?,
    --Eco Tower Properties
    IncomeGenerated: number?,
    Income: number?,
    --Spawner Tower Properties
    SpawnSpeed: number?,
    SpawnTimer: number?,
    SpawnType: string?,
    Units: {Tower}?,
    --Unit Properties
    Distance: number?,
    Health: number?,
    --Index: number?,
    MaxHealth: number?,
    Spawner: Tower?,
    Speed: number?,
    SpeedModifier: number?,
    --UnitIndex: number?,
    Waypoint: number?,
    Flying: boolean?,
    Slowed: boolean?,
    Stunned: boolean?
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

    if self.SlowTimer then
        enemy.SlowTimer = tick() + self.SlowTimer
        enemy.SpeedModifier = self.SlowModifier
    end
    
    if self.StunTimer then
        enemy.StunTimer = tick() + self.StunTimer
        enemy.SpeedModifier = 0
    end

    return value
end

local function updateAmmo(self: Tower)
    if self.Ammo == 0 then
        self.AttackTimer = tick() + self.ReloadTime
        self.Ammo = self.MaxAmmo
    else
        self.Ammo -= 1
    end
end

local function setAttributes(self: Tower)
    self.Part:SetAttribute("Type", self.Type)
    self.Part:SetAttribute("Value", self.Value)
    self.Part:SetAttribute("Cost", self.Cost)
    self.Part:SetAttribute("Level", self.Level)
    if self.Type == "Spawner" then
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)
    elseif self.Type == "Eco" then
        self.Part:SetAttribute("Income", self.Income)
        self.Part:SetAttribute("IncomeGenerated", self.IncomeGenerated)
    else
        self.Part:SetAttribute("AttackSpeed", self.AttackSpeed)
        self.Part:SetAttribute("Damage", self.Damage)
        self.Part:SetAttribute("DamageDealt", self.DamageDealt)
        self.Part:SetAttribute("Range", self.Range)
        self.Part:SetAttribute("AttackPrio", self.AttackPrio)
    end
end

local targetFunctions = {
    Nah = function() return nil end,

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
    Nah = function() return 0 end,

    Direct = function(self: Tower, target: Enemy.Enemy)
        self.AttackTimer = tick()
        if self.Ammo then
            updateAmmo(self)
        end
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
        if self.Ammo then
            updateAmmo(self)
        end
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
        if self.Ammo then
            updateAmmo(self)
        end
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
        if self.Ammo then
            updateAmmo(self)
        end
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
    if self.Type == "Tower" then
        self.Part.Range.Size = Vector3.new(0.1, self.Range * 2, self.Range * 2)
    end
    self.Part.Parent = workspace.Towers
    self.Part.CFrame = CFrame.new(position)
    setAttributes(self)

    return self
end

function Tower:Destroy(): ()
	self.Part:Destroy()
    if self.BuffedTowers then
        for i = #self.BuffedTowers, 1, -1 do
            local tower = self.BuffedTowers[i]
            self:UnbuffTower(tower)
        end
    end
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
	return
end

function Tower:CheckRange(object: (Enemy.Enemy | Tower) ): (boolean)
    if (object.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
end

function Tower:ChangeTargetType(attackPrio: string): ()
    self.FindTarget = targetFunctions[attackPrio]
    return
end

function Tower:SpawnUnit(): (Tower)
    self.SpawnTimer = tick()
    local unit: Tower = Tower.new(self.SpawnType, self.Level)
    unit.Spawner = self
    table.insert(self.Units, unit)
    return unit
end

function Tower:RemoveUnit(): ()
    local unit: Tower = self.Units[1]
    table.remove(self.Units, 1)
    self.DamageDealt += unit.DamageDealt
    self.Part:SetAttribute("DamageDealt", self.DamageDealt)
    unit:Destroy()
    return
end

function Tower:Move(deltaTime: number): (Tower?)
	local waypoint: Vector3 = Maps.Waypoints[self.Waypoint]
	local moveDistance: number = deltaTime * self.Speed * self.SpeedModifier
	local direction: Vector3 = waypoint - self.Part.Position
	local waypointDistance: number = direction.Magnitude
	local normalized: Vector3 = direction / waypointDistance

	if moveDistance < waypointDistance then
		self.Part.Position = self.Part.Position + normalized * moveDistance
		self.Distance = (Maps.Waypoints[self.Waypoint + 1] - self.Part.Position).Magnitude
		return self
	else
		if Maps.Waypoints[self.Waypoint - 1] then
			self.Waypoint -= 1
			self.Part.Position = waypoint

			local waypoint: Vector3 = Maps.Waypoints[self.Waypoint]
			local moveDistance: number = moveDistance - waypointDistance
			local direction: Vector3 = waypoint - self.Part.Position
			local waypointDistance: number = direction.Magnitude
			local normalized: Vector3 = direction / waypointDistance
			
			self.Part.Position = self.Part.Position + normalized * moveDistance
			self.Distance = (Maps.Waypoints[self.Waypoint + 1] - self.Part.Position).Magnitude
			return self
		else
			self.Part.Position = waypoint
			return nil
		end
	end
end

function Tower:Collide(enemy: Enemy.Enemy): (boolean?, number)
	if self.Health > enemy.Health then
		local value: number = enemy.Health
		self.Health -= value
		self.DamageDealt += value
		enemy:ChangeHealth(enemy.Health)
		self.Part:SetAttribute("Health", self.Health)
		return true, value
	else
		local result: Enemy.Enemy?, value: number = enemy:ChangeHealth(self.Health)
		self.DamageDealt += self.Health
		self.Health = 0
		if result == nil then
			return nil, value
		else
			return false, value
		end
	end
end

function Tower:Generate(): (number)
    self.IncomeGenerated += self.Income
    self.Part:SetAttribute("IncomeGenerated", self.IncomeGenerated)
    return self.Income
end

function Tower:BuffTower(tower: Tower)
    for _, buff in self.Buffs do
        if tower[buff] then
            tower[buff] *= self.Buffs[buff]
        end
    end
    table.insert(self.BuffedTowers, tower)
    return
end

function Tower:UnbuffTower(tower: Tower)
    for _, buff in self.Buffs do
        if tower[buff] then
            tower[buff] /= self.Buffs[buff]
        end
    end
    table.remove(self.BuffedTowers, table.find(self.BuffedTowers, tower))
    return
end
--#endregion

return Tower