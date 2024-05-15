--#region Variables
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerHUD = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD")
local cashCounter = playerHUD:WaitForChild("CashGUI").Counter
local healthCounter = playerHUD:WaitForChild("HealthGUI").Counter
local towerGUI = playerHUD:WaitForChild("Towers")
local towers = {"Basic", "Sniper", "Tesla", "Mortar"}
local selectedTower
--#endregion
--TODO: Not hardcode this
towerGUI.TowerOne.TextButton.Text, towerGUI.TowerTwo.TextButton.Text, towerGUI.TowerThree.TextButton.Text, towerGUI.TowerFour.TextButton.Text = towers[1], towers[2], towers[3], towers[4]

--#region Functions
local function updateCash()
    cashCounter.Text = player:GetAttribute("Cash")
end

local function updateHealth()
    healthCounter.Text = workspace:GetAttribute("Health")
end

local function selectTower(actionName, inputState, _inputObject)
    if actionName == "SelectOne" and inputState == Enum.UserInputState.Begin then
        print(`Selected {towers[1]}`)
        selectedTower = towers[1]
    elseif actionName == "SelectTwo" and inputState == Enum.UserInputState.Begin then
        print(`Selected {towers[2]}`)
        selectedTower = towers[2]
    elseif actionName == "SelectThree" and inputState == Enum.UserInputState.Begin then
        print(`Selected {towers[3]}`)
        selectedTower = towers[3]
    elseif actionName == "SelectFour" and inputState == Enum.UserInputState.Begin then
        print(`Selected {towers[4]}`)
        selectedTower = towers[4]
    end
end
--#endregion

--#region Listeners
player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
workspace:GetAttributeChangedSignal("Health"):Connect(updateHealth) --TODO: Move from ScreenGUI to End part?
player.CharacterAdded:Connect(function()
    print("Character added")
    ContextActionService:BindAction("SelectOne", selectTower, true, Enum.KeyCode.One)
    ContextActionService:BindAction("SelectTwo", selectTower, true, Enum.KeyCode.Two)
    ContextActionService:BindAction("SelectThree", selectTower, true, Enum.KeyCode.Three)
    ContextActionService:BindAction("SelectFour", selectTower, true, Enum.KeyCode.Four)
end)
--#endregion