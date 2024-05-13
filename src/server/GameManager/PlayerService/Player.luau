--!strict
--#region Requires & Types
local Tower = require(script.Parent.Parent.TowerService.Tower)
local Player = {}
Player.__index = Player

export type PlayerData = {
    --Properties
    User: Player,
    Cash: number,
    --Equipped: {string},
    --Towers: {Tower.Tower},
    --Functions
    new: (playerName: string) -> (),
    ChangeMoney: (value: number) -> (number)
}
--#endregion

--#region Functions
function Player.new(player: Player, equipped: {towerName: string}?)
    local self = {
        User = player,
        --Equipped = equipped,
        Cash = 100
    }
    self.User:SetAttribute("Cash", self.Cash)

    return setmetatable(self, Player)
end
--#endregion

function Player:ChangeCash(value: number): (number)
    self.Cash += value
    self.User:SetAttribute("Cash", self.Cash)
    return self
end

return Player