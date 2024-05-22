--!strict
--#region Requires & Types
local EnemyService = require(script.EnemyService)
local TowerService = require(script.TowerService)
local PlayerService = require(script.PlayerService)
local Maps = require(script.EnemyService.Maps)

type GameManager = {
    --Properties
	Map: {Maps.Map},
    Health: number,
    Benchmark: {number},
    Heartbeat: RBXScriptConnection,
    --Functions
    start: (map: string) -> (),
    updateLoop: () -> (),
    getAverageBenchmark: () -> ()
}
--#endregion

local GameManager = {} :: GameManager
GameManager.Health = 100
GameManager.Benchmark = {}

local function changeHealth(value: number)
    GameManager.Health += value
    workspace:SetAttribute("Health", GameManager.Health)
    return GameManager.Health
end

--#functions
function GameManager.start(map: string): ()
    GameManager.Map = Maps.set(map)
    return
end

function GameManager.updateLoop(): ()
	GameManager.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function(dt)
        --local startTime: number = os.clock()
        if #EnemyService.Enemies == 0 and #EnemyService.EnemyQueue == 0 and (tick() - EnemyService.WaveDebounce > 5) then
            local result: {{Name: string, Delay: number}}? = EnemyService.nextWave()
            if result == nil then
                print("woooo you won!!")
                GameManager.Heartbeat:Disconnect()
            end
            PlayerService.runEcoTowers()
        end
        if #EnemyService.EnemyQueue > 0 then
            EnemyService.spawnEnemy()
        end
        changeHealth(-EnemyService.moveEnemies(dt))
        if GameManager.Health <= 0 then
            print("you lose :(")
            GameManager.Heartbeat:Disconnect()
        end
        if #TowerService.Towers > 0 then
            PlayerService.CashPending += TowerService.iterateTowers(dt)
        end
        if #EnemyService.EnemyRemoveQueue > 0 then
            EnemyService.removeEnemies()
        end
        if PlayerService.CashPending > 0 then
            PlayerService.distributeCash()
        end
        --local endTime: number = os.clock()
        --table.insert(GameManager.Benchmark, (endTime - startTime) * 1000)
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