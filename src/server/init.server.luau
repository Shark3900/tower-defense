--!strict

local GameManager = require(script.GameManager)

GameManager.start("TestMap")
task.wait(3)
GameManager.updateLoop()
--task.wait(240)
--GameManager.getAverageBenchmark()