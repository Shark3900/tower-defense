--!strict

local EnemyService = require(script.EnemyService)
local TowerService = require(script.TowerService)
local UnitService = require(script.TowerService.UnitService)
local PlayerService = require(script.PlayerService) --TODO
local Waves = require(script.EnemyService.Waves)
local Maps = require(script.EnemyService.Maps)
local GameManager = {}
GameManager.__index = GameManager

export type GameManager = {
    --Properties
	Map: {Maps.Map},
    Towers: {TowerService.Tower},
    Spawners: {TowerService.Tower},
    Units: {UnitService.Unit},
    UnitRemoveQueue: {UnitService.Unit},
	Enemies: {EnemyService.Enemy},
    HealthSort: {EnemyService.Enemy},
    DistanceSort: {EnemyService.Enemy},
    EnemyQueue: {EnemyService.Enemy},
    EnemyRemoveQueue: {EnemyService.Enemy},
    AttackQueue: {EnemyService.Enemy},
    SpawnTimer: number,
	WaveIndex: number,
    Benchmark: {number},
    --Functions
    new: (map: string) -> ({GameManager}),
	NextWave: (self: GameManager) -> ({EnemyService.Enemy}),
    SpawnEnemy: (self: GameManager) -> (),
    MoveEnemies: (self: GameManager, deltaTime: number) -> (),
    SpawnUnits: (self: GameManager) -> (),
    MoveUnits: (self: GameManager, deltaTime: number) -> (),
    CheckUnitCollision: (self:GameManager) -> (),
    AttackEnemies: (self: GameManager) -> (),
    AttackLoop: (self: GameManager, tower: {TowerService.Tower}) -> (),
    ConeAttack: (self: GameManager, tower: {TowerService.Tower}, target: {EnemyService.Enemy}) -> (),
    CircleAttack: (self: GameManager, tower: {TowerService.Tower}, target: {EnemyService.Enemy}) -> (),
    BoxAttack: (self: GameManager, tower: {TowerService.Tower}, target: {EnemyService.Enemy}) -> (),
    FindFirst: (self: GameManager, tower: {TowerService.Tower}) -> ({EnemyService.Enemy}?),
    FindStrong: (self: GameManager, tower: {TowerService.Tower}) -> ({EnemyService.Enemy}?),
    FindLast: (self: GameManager, tower: {TowerService.Tower}) -> ({EnemyService.Enemy}?),
    SortHealth: (self: GameManager) -> ({EnemyService.Enemy}),
    SortDistance: (self: GameManager) -> ({EnemyService.Enemy}),
    SortEnemies: (self: GameManager) -> ({EnemyService.Enemy}),
    SortUnits: (self: GameManager) -> ({UnitService.Unit}),
    RemoveEnemies: (self: GameManager) -> (),
    RemoveUnits: (self: GameManager) -> (),
    UpdateLoop: (self: GameManager) -> (),
    GetAverageBenchmark: (self: GameManager) -> ()
}

function GameManager.new(map: string)
	local self = {
        Map = Maps.set(map),
        Towers = {},
        Spawners = {},
        Units = {},
        UnitRemoveQueue = {},
        Enemies = {},
        HealthSort = {},
        DistanceSort = {},
        EnemyQueue = {},
        EnemyRemoveQueue = {},
        AttackQueue = {},
        Benchmark = {}, --For Debugging/Benchmarking Only
        SpawnTimer = 0,
        WaveIndex = 2
    }

    --I'm sinning, don't forget about this
	table.insert(self.Spawners, TowerService.new("MeleeSpawner", Vector3.new(-1, 0.6, 81)))

	return setmetatable(self, GameManager)
end

function GameManager:NextWave()
	self.WaveIndex += 1
	local wave: Waves.Wave = Waves[self.WaveIndex]

	for _, v in wave do
		for x = 1, v.Amount do
            if x == 1 then
                table.insert(self.EnemyQueue, {v.Name, v.UnitDelay + v.GroupDelay})
            else
                table.insert(self.EnemyQueue, {v.Name, v.UnitDelay})
            end
		end
	end

	return self.EnemyQueue
end

function GameManager:SpawnEnemy()
	local enemy: {} = self.EnemyQueue[1]
    local debounce: number = enemy[2]

    if tick() - self.SpawnTimer > debounce then
        self.SpawnTimer = tick()
        local newEnemy = EnemyService.new(enemy[1])
        table.insert(self.Enemies, newEnemy)
        newEnemy.Index = #self.Enemies
        table.insert(self.HealthSort, newEnemy)
        newEnemy.HealthIndex = newEnemy.Index
        table.insert(self.DistanceSort, newEnemy)
        newEnemy.DistanceIndex = newEnemy.Index
        table.remove(self.EnemyQueue, 1)
    end

    return
end

function GameManager:MoveEnemies(deltaTime: number)
	for _, v in self.Enemies do
		local result = v:Move(deltaTime)
		if result == nil then
            table.insert(self.EnemyRemoveQueue, v)
        end
	end

    self:SortDistance()

    return
end

function GameManager:SpawnUnits()
    for _, tower in self.Spawners do
        local debounce: number = tower.SpawnSpeed
        if tick() - tower.SpawnTimer > debounce then
            if tower.AttackType == "Melee" then
                table.insert(self.Units, tower:SpawnUnit())
            else
                local unit = tower:SpawnUnit()
                table.insert(self.Units, unit)
                table.insert(self.Towers, unit)
                unit.Index = #self.Towers
            end
        end
    end

    return
end

function GameManager:MoveUnits(deltaTime: number)
    for _, v in self.Units do
        local result = v:Move(deltaTime)
        if result == nil then
            table.insert(self.UnitRemoveQueue, v)
        end
    end

    self:SortUnits()

    return
end

function GameManager:CheckUnitCollision()
    local unit = self.Units[1]
    for _, v in self.DistanceSort do
        if unit.Waypoint == v.Waypoint - 1 and unit.Distance > v.Distance then
            self:Collide(unit, v)
        elseif unit.Waypoint < v.Waypoint - 1 then
            self:Collide(unit, v)
        else
            break
        end
    end

    return
end

function GameManager:Collide(unit: {UnitService.Unit}, enemy: {EnemyService.Enemy})
    local result = unit:Collide(enemy)
    print(`result: {result}`)
    if result == true then
        table.insert(self.EnemyRemoveQueue, enemy)
    elseif result == false then
        table.insert(self.UnitRemoveQueue, unit)
        if unit.AttackType == not "Melee" then
            table.remove(self.Towers, unit.Index)
        end
    elseif result == nil then
        table.insert(self.EnemyRemoveQueue, enemy)
        table.insert(self.UnitRemoveQueue, unit)
        if unit.AttackType == not "Melee" then
            table.remove(self.Towers, unit.Index)
        end
    end
end

function GameManager:AttackEnemies()
    for _, tower in self.Towers do
        local debounce: number = tower.AttackSpeed

        if tick() - tower.AttackTimer > debounce then
            local target: {EnemyService.Enemy?}
            local attackPrio: string = tower.AttackPrio

            if attackPrio == "First" then
                target = self:FindFirst(tower)
            elseif attackPrio == "Strong" then
                target = self:FindStrong(tower)
            else
                target = self:FindLast(tower)
            end

            if target then
                tower.Part.CFrame = CFrame.lookAt(tower.Part.Position, target.Part.Position)
                if tower.AttackType == "Single" then
                    local result = tower:Attack(target)
			    	if result == nil then
                        table.insert(self.EnemyRemoveQueue, target)
                    end
                elseif tower.AttackType == "Box" then
                    self:BoxAttack(tower, target)
                elseif tower.AttackType == "Circle" then
                    self:CircleAttack(tower, target)
                else
                    table.insert(self.Benchmark, self:ConeAttack(tower, target))
                end
            end
        end
    end

    self:SortHealth()

    return
end

function GameManager:AttackLoop(tower: {TowerService.Tower})
    for _, v in self.AttackQueue do
        local result = tower:Attack(v)
        if result == nil then
            table.insert(self.EnemyRemoveQueue, v)
        end
    end

    table.clear(self.AttackQueue)
    return
end

function GameManager:ConeAttack(tower: {TowerService.Tower}, target: {EnemyService.Enemy})
    local towerPos: Vector3 = tower.Part.Position
    local direction: Vector3 = (target.Part.Position - towerPos).Unit

    for _, enemy in self.Enemies do
        if tower:CheckRange(enemy) then
            local enemyDirection: Vector3 = (enemy.Part.Position - towerPos).Unit
            local angleToEnemy: number = math.deg(math.acos(direction:Dot(enemyDirection)))
            
            if angleToEnemy <= tower.Angle / 2 then
                table.insert(self.AttackQueue, enemy)
            end
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop(tower)
    end

    return
end

function GameManager:CircleAttack(tower: {TowerService.Tower}, target: {EnemyService.Enemy})
    for _, enemy in self.Enemies do
        if tower:CheckRange(enemy) then
            table.insert(self.AttackQueue, enemy)
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop(tower)
    end

    return
end

function GameManager:BoxAttack(tower: {TowerService.Tower}, target: {EnemyService.Enemy})
    local halfWidth: number = tower.Width / 2

    for _, enemy in self.Enemies do
        local toEnemy: Vector3 = enemy.Part.Position - target.Part.Position
        local distanceAlongDirection: number = toEnemy:Dot(tower.Part.CFrame.LookVector)
        local distancePerpendicular: number = math.abs(toEnemy:Dot(tower.Part.CFrame.RightVector))

        if distanceAlongDirection >= 0 and distanceAlongDirection <= tower.Range and distancePerpendicular <= halfWidth then
            table.insert(self.AttackQueue, enemy)
        end
    end

    if #self.AttackQueue > 0 then
        self:AttackLoop(tower)
    end

    return
end

function GameManager:FindFirst(tower: {TowerService.Tower})
    for _, v in self.DistanceSort do
        if v.Health > 0 and tower:CheckRange(v) then
            return v
        end
    end

    return nil
end

function GameManager:FindStrong(tower: {TowerService.Tower})
    for _, v in self.HealthSort do
        if v.Health > 0 and tower:CheckRange(v) then
            return v
        end
    end

    return nil
end

function GameManager:FindLast(tower: {TowerService.Tower})
    for i = #self.DistanceSort, 1, -1 do
        local v = self.DistanceSort[i]
        if v.Health > 0 and tower:CheckRange(v) then
            return v
        end
    end

    return nil
end

function GameManager:SortHealth()
    table.sort(self.HealthSort, function(a, b)
        return a.Health > b.Health
    end)

    if #self.HealthSort > 0 then
        for i, enemy in self.HealthSort do
            enemy.HealthIndex = i
        end
    end

    return self.HealthSort
end

function GameManager:SortDistance()
    table.sort(self.DistanceSort, function(a, b)
        if a.Waypoint ~= b.Waypoint then
            return a.Waypoint > b.Waypoint
        else
            return a.Distance < b.Distance
        end
    end)

    if #self.DistanceSort > 0 then
        for i, enemy in self.DistanceSort do
            enemy.DistanceIndex = i
        end
    end

    return self.DistanceSort
end

function GameManager:SortEnemies()
    for i, v in self.Enemies do
        v.Index = i
    end

    return self.Enemies
end

function GameManager:SortUnits()
    table.sort(self.Units, function(a, b)
        if a.Waypoint ~= b.Waypoint then
            return a.Waypoint < b.Waypoint
        else
            return a.Distance > b.Distance
        end
    end)

    return self.Units
end

function GameManager:RemoveEnemies()
    for _, v in self.EnemyRemoveQueue do
        --local v = self.EnemyRemoveQueue[i]
        table.remove(self.HealthSort, v.HealthIndex)
        self:SortHealth()
        table.remove(self.DistanceSort, v.DistanceIndex)
        self:SortDistance()
        table.remove(self.Enemies, v.Index)
        self:SortEnemies()
        --print(self.Enemies, self.EnemyRemoveQueue, v)
        v:Destroy()
    end

    table.clear(self.EnemyRemoveQueue)
    return
end

function GameManager:RemoveUnits()
    --print(self.Units, self.UnitRemoveQueue)
    for i, v in self.UnitRemoveQueue do
        table.remove(self.Units, i)
        v:Destroy()
    end

    --print(self.Units, self.UnitRemoveQueue)
    table.clear(self.UnitRemoveQueue)
    return
end

function GameManager:UpdateLoop()
	self.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function(dt)
        if #self.Enemies == 0 and #self.EnemyQueue == 0 then
            if Waves[self.WaveIndex + 1] then
                self:NextWave()
            else
                print("woooo you won!!")
                self.Heartbeat:Disconnect()
            end
        end
        if #self.EnemyQueue > 0 then
            self:SpawnEnemy()
        end
        self:MoveEnemies(dt)
        if #self.Enemies > 0 and #self.Towers > 0 then
            self:AttackEnemies()
        end
        if #self.Spawners > 0 then
            self:SpawnUnits()
            if #self.Units > 0 then
                self:MoveUnits(dt)
                self:CheckUnitCollision()
            end
        end
        if #self.EnemyRemoveQueue > 0 then
            self:RemoveEnemies()
        end
        if #self.UnitRemoveQueue > 0 then
            self:RemoveUnits()
        end
    end)
end

function GameManager:GetAverageBenchmark()
    local total = 0
    for _, v in self.Benchmark do
        total += v
    end
    print(`# of calls: {#self.Benchmark}`)
    print(`average time: {total / #self.Benchmark}`)
    return
end

return GameManager