local Players = game:GetService("Players")
local player = Players.LocalPlayer
local cashCounter = player:WaitForChild("PlayerGui"):WaitForChild("PlayerHUD").CashCounter

local function updateCash()
    cashCounter.Counter.Text = player:GetAttribute("Cash")
end

player:GetAttributeChangedSignal("Cash"):Connect(updateCash)