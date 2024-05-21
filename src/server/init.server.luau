--!strict

local GameManager = require(script.GameManager)

GameManager.start("TestMap")
task.wait(6)
GameManager.updateLoop()
--task.wait(90)
--GameManager.getAverageBenchmark()