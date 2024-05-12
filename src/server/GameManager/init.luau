--!strict
--#region Requires & Types
local EnemyService = require(script.EnemyService)
local TowerService = require(script.TowerService)
local UnitService = require(script.UnitService)
--local PlayerService = require(script.PlayerService) --TODO: Implement
local Maps = require(script.EnemyService.Maps)

type GameManager = {
    --Properties
	Map: {Maps.Map},
    Benchmark: {number},
    --Functions
    start: (map: string) -> (),
    updateLoop: () -> (),
    getAverageBenchmark: () -> ()
}
--#endregion

local GameManager = {} :: GameManager
GameManager.Benchmark = {}

--#functions
function GameManager.start(map: string): ()
    GameManager.Map = Maps.set(map)
    --I'm sinning, don't forget about this
	TowerService.newTower("Chain", Vector3.new(-1, 0.6, 81))
    
    return
end

function GameManager.updateLoop(): ()
	GameManager.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function(dt)
        local startTime: number = os.clock()
        if #EnemyService.Enemies == 0 and #EnemyService.EnemyQueue == 0 then
            local result: {{Name: string, Delay: number}}? = EnemyService.nextWave()
            if result == nil then
                print("woooo you won!!")
                GameManager.Heartbeat:Disconnect()
            end
        end
        if #EnemyService.EnemyQueue > 0 then
            EnemyService.spawnEnemy()
        end
        EnemyService.moveEnemies(dt)
        if #EnemyService.Enemies > 0 and #TowerService.Towers > 0 then
            TowerService.attackEnemies()
        end
        if #TowerService.Spawners > 0 then
            UnitService.spawnUnits()
            if #UnitService.Units > 0 then
                UnitService.moveUnits(dt)
                UnitService.checkUnitCollision()
            end
        end
        if #EnemyService.EnemyRemoveQueue > 0 then
            EnemyService.removeEnemies()
        end
        if #UnitService.UnitRemoveQueue > 0 then
            UnitService.removeUnits()
        end
        local endTime: number = os.clock()
        table.insert(GameManager.Benchmark, (endTime - startTime) * 1000)
    end)
end

function GameManager.getAverageBenchmark(): ()
    local total: number = 0
    for _, v in GameManager.Benchmark do
        total += v
    end
    print(`# of frames: {#GameManager.Benchmark}`)
    print(`average frame time: {total / #GameManager.Benchmark}`)
    return
end
--#endregion

return GameManager