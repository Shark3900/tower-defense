--!strict
--#region Requires & Types
local Tower = require(script.Parent.Parent.TowerService.Tower)
local Player = {}
Player.__index = Player

export type PlayerData = {
    --Properties
    User: Player,
    Cash: number,
    Equipped: {string},
    Towers: {Tower.Tower},
    --Functions
    new: (playerName: string) -> (PlayerData),
    ChangeCash: (self: PlayerData, value: number) -> (number)
}
--#endregion

--#region Functions
function Player.new(player: Player, equipped: {towerName: string}?): (PlayerData)
    local self = {
        User = player,
        Cash = 100,
        --TODO: Hardcoded, don't leave this
        Equipped = {
          "Basic", "Sniper", "Mortar", "Tesla"
        },
        Towers = {}
    }
    self.User:SetAttribute("Cash", self.Cash)

    return setmetatable(self, Player)
end

function Player:ChangeCash(value: number): (number)
    self.Cash += value
    self.User:SetAttribute("Cash", self.Cash)
    return self
end

function Player:CheckCash(value: number): (boolean)
    return self.Cash >= value
end

function Player:CheckEquipped(towerName: string): (boolean)
    return table.find(self.Equipped, towerName)
end

function Player:CheckTowerLim(): (boolean)
    return #self.Towers < 20
end
--#endregion

return Player