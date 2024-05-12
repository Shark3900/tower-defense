--!strict
--#region Requires & Types
local Tower = require(script.Parent.Parent.TowerService.Tower)
local Player = {}
Player.__index = Player

export type PlayerData = {
    --Properties
    User: Player,
    Money: number,
    Equipped: {string},
    Towers: {Tower.Tower},
    --Functions
    new: (playerName: string) -> ()
}
--#endregion

--#region Functions
function Player.new(playerName: string, equipped: {towerName: string})
    local self = {
        User = game.Players:GetPlayers()[playerName],
        Equipped = equipped,
        Money = 100
    }

    return setmetatable(self, Player)
end
--#endregion

return Player