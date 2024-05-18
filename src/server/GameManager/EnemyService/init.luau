--!strict
--#region Requires & Types
local Enemy = require(script.Enemy)
local Waves = require(script.Waves)
type EnemyService = {
	--Variables
	Enemies: {Enemy.Enemy},
	HealthSort: {Enemy.Enemy},
	DistanceSort: {Enemy.Enemy},
    EnemyQueue: {{Name: string, Delay: number}},
	EnemyRemoveQueue: {Enemy.Enemy},
    WaveDebounce: number,
	--Functions
	nextWave: () -> ({{Name: string, Delay: number}}?),
	spawnEnemy: () -> (),
	removeEnemies: () -> (),
	moveEnemies: (deltaTime: number) -> (number),
    sortEnemies: () -> ({Enemy.Enemy}),
    sortHealth: () -> ({Enemy.Enemy}),
    sortDistance: () -> ({Enemy.Enemy})
}
--#endregion

--#region Variables
local EnemyService = {} :: EnemyService
EnemyService.Enemies = {}
EnemyService.HealthSort = {}
EnemyService.DistanceSort = {}
EnemyService.EnemyQueue = {}
EnemyService.EnemyRemoveQueue = {}
EnemyService.WaveDebounce = 0
local waveIndex: number = 0
local spawnTimer: number = 0
--#endregion

--#region Functions
function EnemyService.nextWave(): ({{Name: string, Delay: number}}?)
	waveIndex += 1
	if Waves[waveIndex] then
		local wave: {Waves.Group} = Waves[waveIndex]

		for _, group in wave do
			for x = 1, group.Amount do
    	        if x == 1 then
    	            table.insert(EnemyService.EnemyQueue, {[1] = group.Name, [2] = group.UnitDelay + group.GroupDelay})
    	        else
    	            table.insert(EnemyService.EnemyQueue, {[1] = group.Name, [2] = group.UnitDelay})
    	        end
			end
		end

		return EnemyService.EnemyQueue
	else
		return nil
	end
end

function EnemyService.spawnEnemy(): ()
	local enemy: {string | number} = EnemyService.EnemyQueue[1]
    local debounce = enemy[2] :: number

    if tick() - spawnTimer > debounce then
        spawnTimer = tick()
        local newEnemy: Enemy.Enemy = Enemy.new(enemy[1] :: string)
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

function EnemyService.removeEnemies(): ()
    EnemyService.WaveDebounce = tick()

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

function EnemyService.moveEnemies(deltaTime: number): (number)
    local pendingDamage: number = 0

	for _, enemy in EnemyService.Enemies do
		local result: Enemy.Enemy? = enemy:Move(deltaTime)
		if result == nil then
            pendingDamage += enemy.Health
            table.insert(EnemyService.EnemyRemoveQueue, enemy)
        end
	end

    EnemyService.sortDistance()

    return pendingDamage
end

function EnemyService.sortEnemies(): ({Enemy.Enemy})
    for i, v in EnemyService.Enemies do
        v.Index = i
    end

    return EnemyService.Enemies
end

function EnemyService.sortHealth(): ({Enemy.Enemy})
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

function EnemyService.sortDistance(): ({Enemy.Enemy})
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
--#endregion

return EnemyService