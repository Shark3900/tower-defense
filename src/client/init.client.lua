--!strict
--#region Variables
local UIHandler = require(script.UIHandler)
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
mouse.TargetFilter = workspace.Previews

local buyTowerEvent: RemoteEvent = game.ReplicatedStorage.Events.BuyTower
local setTowersEvent: RemoteEvent = game.ReplicatedStorage.Events.SetTowers

local towers: {string} = {}
local previewTower: Part? = nil
local selectedTowerToPlace: string? = nil
local selectedTower: Part? = nil
--#endregion

--#region Functions
local function setTowers(newTowers: {string}): ({string})
    towers = newTowers
    return towers
end

local function selectPlacedTower(actionName, inputState, _inputObject): ()
    if actionName == "SelectPlacedTower" and inputState == Enum.UserInputState.Begin then
        local target = mouse.Target
        if target and target.Parent.Name == "Towers" and target:GetAttribute("Owner") == player.Name then
            selectedTower = target
            --TODO: Add UI for selected tower
            print(`Selected tower {selectedTower}`)
        end
    end

    return
end

local function deselect(actionName, inputState, _inputObject): ()
    if actionName == "Deselect" and inputState == Enum.UserInputState.Begin then
        if selectedTowerToPlace then
            selectedTowerToPlace = nil
            previewTower:Destroy()
            previewTower = nil
            ContextActionService:UnbindAction("PlaceTower")
            ContextActionService:BindAction("SelectPlacedTower", selectPlacedTower, true, Enum.UserInputType.MouseButton1)
        end
        if selectedTower then
            --TODO: Delete UI for selected tower
            selectedTower = nil
        end
    end

    return
end

local function placeTower(actionName, inputState, _inputObject): ()
    if actionName == "PlaceTower" and inputState == Enum.UserInputState.Begin then
        local position = mouse.Hit.Position + Vector3.new(0, 0.6, 0)
        buyTowerEvent:FireServer(selectedTowerToPlace, position)
        --print(`Place {selectedTowerToPlace} at {position}`)
    end

    return
end

local function setTowerPlacement(key: number): ()
    if selectedTowerToPlace == towers[key] then
        return
    end

    if selectedTowerToPlace then
        previewTower:Destroy()
        previewTower = nil
    end

    ContextActionService:UnbindAction("selectPlacedTower")
    ContextActionService:BindAction("PlaceTower", placeTower, true, Enum.UserInputType.MouseButton1)
    selectedTowerToPlace = towers[key]
    previewTower = game.ReplicatedStorage.Towers[selectedTowerToPlace]:Clone()
    previewTower.Position = mouse.Hit.Position + Vector3.new(0, 0.6, 0)
    previewTower.Parent = workspace.Previews
    print(`Selected {selectedTowerToPlace}`)

    return
end

local function selectTowerToPlace(actionName, inputState, _inputObject): ()
    if actionName == "SelectOne" and inputState == Enum.UserInputState.Begin then
        setTowerPlacement(1)
    elseif actionName == "SelectTwo" and inputState == Enum.UserInputState.Begin then
        setTowerPlacement(2)
    elseif actionName == "SelectThree" and inputState == Enum.UserInputState.Begin then
        setTowerPlacement(3)
    elseif actionName == "SelectFour" and inputState == Enum.UserInputState.Begin then
        setTowerPlacement(4)
    end

    return
end

local function drawPreviewTower(position: Vector3): ()
    previewTower.Position = Vector3.new(position.X, position.Y+0.6, position.Z)

    return
end

local function setControls(): ()
    ContextActionService:BindAction("SelectOne", selectTowerToPlace, true, Enum.KeyCode.One)
    ContextActionService:BindAction("SelectTwo", selectTowerToPlace, true, Enum.KeyCode.Two)
    ContextActionService:BindAction("SelectThree", selectTowerToPlace, true, Enum.KeyCode.Three)
    ContextActionService:BindAction("SelectFour", selectTowerToPlace, true, Enum.KeyCode.Four)
    ContextActionService:BindAction("Deselect", deselect, true, Enum.KeyCode.Q)
    ContextActionService:BindAction("SelectPlacedTower", selectPlacedTower, true, Enum.UserInputType.MouseButton1)

    return
end

local function onCharacterAdded(): ()
    UIHandler.update(towers)
    setControls()
    return
end
--#endregion

--#region Listeners
setTowersEvent.OnClientEvent:Connect(setTowers)

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
	onCharacterAdded()
end

game:GetService("RunService").Heartbeat:Connect(function()
    if selectedTowerToPlace then
        drawPreviewTower(mouse.Hit.Position)
    end
end)
--#endregion