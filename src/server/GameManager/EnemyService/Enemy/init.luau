--!strict
--#region Requires & Types
local EnemyData = require(script.EnemyData)
local Maps = require(script.Parent.Maps)
local Enemy = {}
Enemy.__index = Enemy

type EnemyFunctions = {
	__index: EnemyFunctions,
	new: (enemyName: string) -> (Enemy),
	Destroy: (self: Enemy) -> (),
	Move: (self: Enemy, deltaTime: number) -> (Enemy?),
	ChangeHealth: (self: Enemy, value: number) -> (Enemy?, number)
}

type EnemyData = {
	Part: Part,
	MaxHealth: number,
	Health: number,
	Speed: number,
	SpeedModifier: number,
	Value: number,
	Waypoint: number,
	Distance: number,
	Index: number,
	HealthIndex: number,
	DistanceIndex: number,
	StunTimer: number?,
	SlowTimer: number?,
	Boss: boolean?,
	Armored: boolean?,
	Stealth: boolean?,
	Flying: boolean?
}

export type Enemy = typeof(setmetatable({} :: EnemyData, {} :: EnemyFunctions))
--#endregion

--#region Functions
function Enemy.new(enemyName: string): (Enemy)
	local self = table.clone(EnemyData[enemyName])
	self.Health = self.MaxHealth
	self.Part = game.ServerStorage.Enemies[enemyName]:Clone()
	self.Part:SetAttribute("Health", self.Health)
	self.Part.Healthbar.Health.Text = self.Health
	self.Part.Healthbar.Enabled = true
	self.Part.Position = Maps.Waypoints[1]
	self.Part.Parent = workspace.Enemies

	self.Part:GetAttributeChangedSignal("Health"):Connect(function()
		self.Part.Healthbar.Health.Text = self.Health
	end)

	return setmetatable(self, Enemy)
end

function Enemy:Destroy(): ()
    self.Part:Destroy()
    setmetatable(self, nil)
    table.clear(self)
    table.freeze(self)
	return
end

function Enemy:Move(deltaTime: number): (Enemy?)
	local waypoint: Vector3 = Maps.Waypoints[self.Waypoint]
	local moveDistance: number = deltaTime * self.Speed * self.SpeedModifier
	local direction: Vector3 = waypoint - self.Part.Position
	local waypointDistance: number = direction.Magnitude
	local normalized: Vector3 = direction / waypointDistance

	if self.SpeedModifier ~= 1 then
		if self.SlowTimer and tick() - self.SlowTimer > 0 then
			self.SlowTimer = nil
			self.SpeedModifier = 1
		end
		if self.StunTimer and tick() - self.StunTimer > 0 then
			self.StunTimer = nil
			self.SpeedModifier = 1
		end
	end

	if moveDistance < waypointDistance then
		self.Part.Position = self.Part.Position + normalized * moveDistance
		self.Distance = waypointDistance
		return self
	else
		if Maps.Waypoints[self.Waypoint + 1] then
			self.Waypoint += 1
			self.Part.Position = waypoint

			local waypoint: Vector3 = Maps.Waypoints[self.Waypoint]
			local moveDistance = moveDistance - waypointDistance
			local direction: Vector3 = waypoint - self.Part.Position
			local waypointDistance: number = direction.Magnitude
			local normalized: Vector3 = direction / waypointDistance
			
			self.Part.Position = self.Part.Position + normalized * moveDistance
			self.Distance = waypointDistance
			return self
		else
			self.Part.Position = waypoint
			return nil
		end
	end
end

function Enemy:ChangeHealth(value): (Enemy?, number)
	if value >= self.Health then
		value = self.Health
		return nil, value
	else
		self.Health -= value
		self.Part:SetAttribute("Health", self.Health)
		return self, value
	end
end
--#endregion

return Enemy