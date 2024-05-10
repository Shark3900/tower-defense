--!strict

local EnemyTemplates = require(script.EnemyTemplates)
local Maps = require(script.Maps)
local Enemy = {}
Enemy.__index = Enemy

export type Enemy = {
	--Properties
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
	--Flags
	Stunned: boolean,
	StunTimer: number,
	Slowed: boolean,
	SlowTimer: number,
	Boss: boolean,
	Armored: boolean,
	Stealth: boolean,
	Flying: boolean,
	--Functions
	new: (enemyName: string) -> ({Enemy}),
	Destroy: (self: Enemy) -> (),
	Move: (self: Enemy, deltaTime: number) -> ({Enemy}?),
	ChangeHealth: (self: Enemy, value: number) -> ({Enemy}?)
}

function Enemy.new(enemyName: string)
	local self = table.clone(EnemyTemplates[enemyName])
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

function Enemy:Destroy()
    self.Part:Destroy()
    setmetatable(self, nil)
    table.clear(self)
    table.freeze(self)
	return
end

function Enemy:Move(deltaTime: number)


	local waypoint: Vector3 = Maps.Waypoints[self.Waypoint]
	local moveDistance: number = deltaTime * self.Speed * self.SpeedModifier
	local direction: Vector3 = waypoint - self.Part.Position
	local waypointDistance: number = direction.Magnitude
	local normalized: Vector3 = direction / waypointDistance

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

function Enemy:ChangeHealth(value)
	self.Health += value
	self.Part:SetAttribute("Health", self.Health)
	if self.Health > 0 then
		return self
	else
		return nil
	end
end

function Enemy:SetStun()
	
end

return Enemy