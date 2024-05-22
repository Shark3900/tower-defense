--!strict
type UIHandler = {
    update: (towers: {string}) -> ()
}

local UIHandler = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerHUD = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD")
local cashCounter = playerHUD.CashCounter.Counter
local healthCounter = playerHUD.HealthCounter.Counter
local towerCounter = playerHUD.TowerCounter.Counter
local towerSelect = playerHUD.Towers

local function updateCashCounter()
    cashCounter.Text = player:GetAttribute("Cash")
end

local function updateTowerCounter()
    towerCounter.Text = `{player:GetAttribute("Towers")} / {player:getAttribute("Limit")}`
end

local function updateHealthCounter()
    healthCounter.Text = workspace:GetAttribute("Health")
end

local function updateTowers(towers: {string})
    towerSelect.TowerOne.TextButton.Text = towers[1]
    towerSelect.TowerTwo.TextButton.Text = towers[2]
    towerSelect.TowerThree.TextButton.Text = towers[3]
    towerSelect.TowerFour.TextButton.Text = towers[4]
    return
end

function UIHandler.update(towers: {string})
    updateTowers(towers)
    updateTowerCounter()
    updateCashCounter()
    return
end

player:GetAttributeChangedSignal("Cash"):Connect(updateCashCounter)
player:GetAttributeChangedSignal("Towers"):Connect(updateTowerCounter)
workspace:GetAttributeChangedSignal("Health"):Connect(updateHealthCounter) --TODO: Move from ScreenGUI to End part?

return UIHandler