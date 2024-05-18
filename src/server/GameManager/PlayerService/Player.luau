--!strict
--#region Requires & Types
local Tower = require(script.Parent.Parent.TowerService.Tower)
export type PlayerData = {
    --Properties
    User: Player,
    Cash: number,
    Equipped: {string},
    Towers: {Tower.Tower},
    --Functions
    new: (playerName: string) -> (PlayerData),
    ChangeCash: (self: PlayerData, value: number) -> (PlayerData),
    CheckCash: (self: PlayerData, value: number) -> (boolean),
    CheckEquipped: (self: PlayerData, towerName: string) -> (boolean),
    CheckTowerLim: (self: PlayerData) -> (boolean)
}

local Player = {}
Player.__index = Player
--#endregion

--#region Functions
function Player.new(player: Player, equipped: {towerName: string}?): (PlayerData)
    local self = {
        User = player,
        Cash = 100,
        Equipped = equipped,
        Towers = {}
    }
    self.User:SetAttribute("Cash", self.Cash)

    return setmetatable(self, Player)
end

function Player:ChangeCash(value: number): (PlayerData)
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