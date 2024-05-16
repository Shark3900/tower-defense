--#region Variables
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
mouse.TargetFilter = workspace.Previews
local playerHUD = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD")
local cashCounter = playerHUD:WaitForChild("CashGUI").Counter
local healthCounter = playerHUD:WaitForChild("HealthGUI").Counter
local towerGUI = playerHUD:WaitForChild("Towers")
local towers = {"Basic", "Sniper", "Tesla", "Mortar"}
local selectedTower = nil
local previewTower = nil
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

local function setTower(key: number)
    if selectedTower == towers[key] then
        return
    end

    if selectedTower then
        previewTower:Destroy()
        previewTower = nil
    end

    selectedTower = towers[key]
    previewTower = game.ReplicatedStorage.Towers[selectedTower]:Clone()
    previewTower.Parent = workspace.Previews
    print(`Selected {selectedTower}`)
end

local function deselect(actionName, inputState, _inputObject)
    if actionName == "Deselect" and inputState == Enum.UserInputState.Begin then
        selectedTower = nil
        previewTower:Destroy()
        previewTower = nil
    end
end

local function selectTower(actionName, inputState, _inputObject)
    if actionName == "SelectOne" and inputState == Enum.UserInputState.Begin then
        setTower(1)
    elseif actionName == "SelectTwo" and inputState == Enum.UserInputState.Begin then
        setTower(2)
    elseif actionName == "SelectThree" and inputState == Enum.UserInputState.Begin then
        setTower(3)
    elseif actionName == "SelectFour" and inputState == Enum.UserInputState.Begin then
        setTower(4)
    end
end

local function setControls()
    ContextActionService:BindAction("SelectOne", selectTower, true, Enum.KeyCode.One)
    ContextActionService:BindAction("SelectTwo", selectTower, true, Enum.KeyCode.Two)
    ContextActionService:BindAction("SelectThree", selectTower, true, Enum.KeyCode.Three)
    ContextActionService:BindAction("SelectFour", selectTower, true, Enum.KeyCode.Four)
    ContextActionService:BindAction("Deselect", deselect, true, Enum.KeyCode.Q)
end

local function onCharacterAdded()
    setControls()
end

local function drawPreviewTower(position: Vector3)
    previewTower.Position = Vector3.new(position.X, position.Y+0.6, position.Z)
end
--#endregion

--#region Listeners and Hearbeat
player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
workspace:GetAttributeChangedSignal("Health"):Connect(updateHealth) --TODO: Move from ScreenGUI to End part?
player.CharacterAdded:Connect(onCharacterAdded)

game:GetService("RunService").Heartbeat:Connect(function()
    if selectedTower then
        drawPreviewTower(mouse.Hit.Position)
    end
end)
--#endregion