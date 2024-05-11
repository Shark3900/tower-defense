--!strict
--#region Requires & Types
local Enemy = require(script.Enemy)
local Waves = require(script.Waves)
type EnemyService = {
	--Variables
	Enemies: {Enemy.Enemy},
	HealthSort: {Enemy.Enemy},
	DistanceSort: {Enemy.Enemy},
	EnemyQueue: {Enemy.Enemy},
	EnemyRemoveQueue: {Enemy.Enemy},
	--Local Functions
	sortEnemies: () -> ({Enemy.Enemy}),
	sortHealth: () -> ({Enemy.Enemy}),
	sortDistance: () -> ({Enemy.Enemy}),
	--Functions
	nextWave: () -> ({Enemy.Enemy}?),
	spawnEnemy: () -> (),
	moveEnemies: (deltaTime: number) -> (),
	removeEnemies: () -> ()
}
--#endregion

--#region Variables
local EnemyService = {} :: EnemyService
EnemyService.Enemies = {}
EnemyService.HealthSort = {}
EnemyService.DistanceSort = {}
EnemyService.EnemyQueue = {}
EnemyService.EnemyRemoveQueue = {}
local waveIndex = 0
local spawnTimer = 0
--#endregion

--#region Functions
function EnemyService.nextWave()
	waveIndex += 1
	if Waves[waveIndex] then
		local wave: Waves.Wave = Waves[waveIndex]

		for _, v in wave do
			for x = 1, v.Amount do
    	        if x == 1 then
    	            table.insert(EnemyService.EnemyQueue, {v.Name, v.UnitDelay + v.GroupDelay})
    	        else
    	            table.insert(EnemyService.EnemyQueue, {v.Name, v.UnitDelay})
    	        end
			end
		end

		return EnemyService.EnemyQueue
	else
		return nil
	end
end

function EnemyService.spawnEnemy()
	local enemy: {} = EnemyService.EnemyQueue[1]
    local debounce: number = enemy[2]

    if tick() - spawnTimer > debounce then
        spawnTimer = tick()
        local newEnemy = Enemy.new(enemy[1])
        table.insert(EnemyService.Enemies, newEnemy)
        newEnemy.Index = #EnemyService.Enemies
        table.insert(EnemyService.HealthSort, newEnemy)
        newEnemy.HealthIndex = newEnemy.Index
        table.insert(EnemyService.DistanceSort, newEnemy)
        newEnemy.DistanceIndex = newEnemy.Index
        table.remove(EnemyService.EnemyQueue, 1)
    end

    return
end

function EnemyService.sortEnemies()
    for i, v in EnemyService.Enemies do
        v.Index = i
    end

    return EnemyService.Enemies
end

function EnemyService.sortHealth()
	table.sort(EnemyService.HealthSort, function(a, b)
        return a.Health > b.Health
    end)

    if #EnemyService.HealthSort > 0 then
        for i, enemy in EnemyService.HealthSort do
            enemy.HealthIndex = i
        end
    end

    return EnemyService.HealthSort
end

function EnemyService.sortDistance()
	table.sort(EnemyService.DistanceSort, function(a, b)
        if a.Waypoint ~= b.Waypoint then
            return a.Waypoint > b.Waypoint
        else
            return a.Distance < b.Distance
        end
    end)

    if #EnemyService.DistanceSort > 0 then
        for i, enemy in EnemyService.DistanceSort do
            enemy.DistanceIndex = i
        end
    end

    return EnemyService.DistanceSort
end

function EnemyService.moveEnemies(deltaTime: number)
	for _, v in EnemyService.Enemies do
		local result = v:Move(deltaTime)
		if result == nil then
            table.insert(EnemyService.EnemyRemoveQueue, v)
        end
	end

    EnemyService.sortDistance()

    return
end

function EnemyService.removeEnemies()
    for _, v in EnemyService.EnemyRemoveQueue do
        table.remove(EnemyService.HealthSort, v.HealthIndex)
        EnemyService.sortHealth()
        table.remove(EnemyService.DistanceSort, v.DistanceIndex)
        EnemyService.sortDistance()
        table.remove(EnemyService.Enemies, v.Index)
        EnemyService.sortEnemies()
        v:Destroy()
    end

    table.clear(EnemyService.EnemyRemoveQueue)

    return
end
--#endregion

return EnemyService