--!strict

local GameManager = require(script.GameManager)
local Game = GameManager.new("TestMap")

task.wait(3)
workspace:SetAttribute("Playing", true)
Game:UpdateLoop()
--task.wait(30)
--Game:GetAverageBenchmark()