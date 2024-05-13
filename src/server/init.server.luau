--!strict

local GameManager = require(script.GameManager)

GameManager.start("TestMap")
task.wait(3)
GameManager.updateLoop()
--task.wait(60)
--GameManager.getAverageBenchmark()