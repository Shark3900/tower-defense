--!strict
type UIHandler = {
    updateTowers: (towers: {string}) -> ()
}

local UIHandler = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerHUD = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD")
local cashCounter = playerHUD.CashCounter.Counter
local healthCounter = playerHUD.HealthCounter.Counter
local towerCounter = playerHUD.TowerCounter.Counter
local towerSelect = playerHUD.Towers

local function updateCash()
    cashCounter.Text = player:GetAttribute("Cash")
end

local function updateTowers()
    towerCounter.Text = `{player:GetAttribute("Towers")} / {player:getAttribute("Limit")}`
end

local function updateHealth()
    healthCounter.Text = workspace:GetAttribute("Health")
end

function UIHandler.updateTowers(towers: {string})
    towerSelect.TowerOne.TextButton.Text = towers[1]
    towerSelect.TowerTwo.TextButton.Text = towers[2]
    towerSelect.TowerThree.TextButton.Text = towers[3]
    towerSelect.TowerFour.TextButton.Text = towers[4]
    return
end

player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
player:GetAttributeChangedSignal("Towers"):Connect(updateTowers)
workspace:GetAttributeChangedSignal("Health"):Connect(updateHealth) --TODO: Move from ScreenGUI to End part?

return UIHandler