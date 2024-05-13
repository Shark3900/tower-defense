local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerHUD = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD")
local cashCounter = playerHUD.CashGUI.Counter
local healthCounter = playerHUD.HealthGUI.Counter

local function updateCash()
    cashCounter.Text = player:GetAttribute("Cash")
end

local function updateHealth()
    healthCounter.Text = workspace:GetAttribute("Health")
end

player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
workspace:GetAttributeChangedSignal("Health"):Connect(updateHealth)