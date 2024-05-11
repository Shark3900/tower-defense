--!strict
--#region Requires & Types
local UnitTemplates = require(script.UnitTemplates)
local Maps = require(script.Parent.Parent.EnemyService.Maps)
local Unit = {}
Unit.__index = Unit

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
    Damage: number,
	AttackType: string,
	AttackPrio: string,
	AttackSpeed: number,
	AttackTimer: number,
	Range: number,
    Angle: number, --If cone AOE
    Radius: number, --If circle AOE
    Width: number, --If rectangle AOE
	--Flags
	Stunned: boolean,
	Slowed: boolean,
	Flying: boolean,
	--Functions
	new: (unitName: string) -> ({Unit}),
	Destroy: (self: Unit) -> (),
	Move: (self: Unit, deltaTime: number) -> ({Unit}?),
	Collide: (self: Unit, enemy: {}) -> (boolean?),
	Attack: (self: Unit, enemy: {}) -> ({}?),
	CheckRange: (self: Unit, enemy: {}) -> (boolean)
}
--#endregion

--#region Functions
function Unit.new(unitName: string)
	local self = table.clone(UnitTemplates[unitName])
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

function Unit:Destroy()
    self.Part:Destroy()
    setmetatable(self, nil)
    table.clear(self)
    table.freeze(self)
	return
end

function Unit:Move(deltaTime: number)
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
			local moveDistance = moveDistance - waypointDistance
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

function Unit:Collide(enemy)
	if self.Health > enemy.Health then
		self.Health -= enemy.Health
		enemy:ChangeHealth(-enemy.Health)
		self.Part:SetAttribute("Health", self.Health)
		return true
	else
		local result = enemy:ChangeHealth(-self.Health)
		self.Health = 0
		if result == nil then
			return nil
		else
			return false
		end
	end
end

function Unit:Attack(enemy)
    self.AttackTimer = tick()
    return enemy:ChangeHealth(-self.Damage)
end

function Unit:CheckRange(enemy: {})
    if (enemy.Part.Position - self.Part.Position).Magnitude <= self.Range then
        return true
    else
        return false
    end
end
--#endregion

return Unit