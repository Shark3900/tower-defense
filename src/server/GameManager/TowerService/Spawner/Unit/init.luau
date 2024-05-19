--!strict
--#region Requires & Types
local UnitData = require(script.UnitData)
local Maps = require(script.Parent.Parent.Parent.EnemyService.Maps)
local Enemy = require(script.Parent.Parent.Parent.EnemyService.Enemy)
local Tower = require(script.Parent.Parent.Tower)
local Unit = {}
Unit.__index = Unit
setmetatable(Unit, Tower)

export type Unit = {
    --Properties
	Part: Part,
	MaxHealth: number,
	Health: number,
	Speed: number,
	SpeedModifier: number,
	Waypoint: number,
	Distance: number,
	Index: number,
	--Ranged Properties
    Damage: number?,
	Range: number?,
	AttackType: string?,
	AttackPrio: string?,
	AttackSpeed: number?,
	AttackTimer: number?,
    AttackQueue: {Enemy.Enemy}?,
    Chain: number?, --If chain attack
    ChainRange: number?, --If chain attack
    Angle: number?, --If cone AOE
    Radius: number?, --If circle AOE
    Width: number?, --If rectangle AOE
	--Flags
	Stunned: boolean,
	Slowed: boolean,
	Flying: boolean,
	--Functions
	new: (unitName: string) -> (Unit),
	Move: (self: Unit, deltaTime: number) -> (Unit?),
	Collide: (self: Unit, enemy: Enemy.Enemy) -> ({result: boolean?, value: number}),
}
--#endregion

--#region Functions
function Unit.new(unitName: string, unitLevel: number): (Unit)
	local self = table.clone(UnitData[unitName][unitLevel])
	self.Health = self.MaxHealth
	self.Waypoint = #Maps.Waypoints - 1
	self.Part = game.ServerStorage.Units[unitName]:Clone()
	self.Part:SetAttribute("Health", self.Health)
	self.Part.Healthbar.Health.Text = self.Health
	self.Part.Healthbar.Enabled = true
	self.Part.Position = Maps.Waypoints[#Maps.Waypoints]
	self.Part.Parent = workspace.Units

	self.Part:GetAttributeChangedSignal("Health"):Connect(function()
		self.Part.Healthbar.Health.Text = self.Health
	end)

	return setmetatable(self, Unit)
end

function Unit:Move(deltaTime: number): (Unit?)
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

function Unit:Collide(enemy: Enemy.Enemy): ({result: boolean?, value: number})
	if self.Health > enemy.Health then
		local value = enemy.Health
		self.Health -= value
		enemy:ChangeHealth(enemy.Health)
		self.Part:SetAttribute("Health", self.Health)
		return true, value
	else
		local result: {Enemy.Enemy}, value: number = enemy:ChangeHealth(self.Health)
		self.Health = 0
		if result == nil then
			return nil, value
		else
			return false, value
		end
	end
end
--#endregion

return Unit