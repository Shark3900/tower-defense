--!strict
type UIHandler = {
    updateTowers: (towers: {string}) -> ()
}

local UIHandler = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerHUD = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD")
local cashCounter = playerHUD:WaitForChild("CashGUI").Counter
local healthCounter = playerHUD:WaitForChild("HealthGUI").Counter
local towerGUI = playerHUD:WaitForChild("Towers")

local function updateCash()
    cashCounter.Text = player:GetAttribute("Cash")
end

local function updateHealth()
    healthCounter.Text = workspace:GetAttribute("Health")
end

function UIHandler.updateTowers(towers: {string})
    towerGUI.TowerOne.TextButton.Text = towers[1]
    towerGUI.TowerTwo.TextButton.Text = towers[2]
    towerGUI.TowerThree.TextButton.Text = towers[3]
    towerGUI.TowerFour.TextButton.Text = towers[4]
    return
end

player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
workspace:GetAttributeChangedSignal("Health"):Connect(updateHealth) --TODO: Move from ScreenGUI to End part?

return UIHandler