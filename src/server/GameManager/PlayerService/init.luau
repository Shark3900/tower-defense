--!strict

local Player = {}
Player.__index = Player

export type PlayerData = {
    --Properties
    User: Player,
    --Functions
    new: (playerName: string) -> ()
}

function Player.new(playerName: string)
    local self = {
        User = game.Players:GetPlayers()[playerName]
    }

    return setmetatable(self, Player)
end

return Player