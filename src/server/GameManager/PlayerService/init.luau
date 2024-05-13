local Players = game:GetService("Players")
--!strict
--#region Requires & Types
local Player = require(script.Player)

type PlayerService = {
    --Variables
    Players: {Player.PlayerData},
    CashPending: number,
    --Functions
    newPlayer: (player: Player) -> (Player.PlayerData),
    distributeCash: () -> ()
}
--#endregion

--#region Variables
local PlayerService = {} :: PlayerService
PlayerService.Players = {}
PlayerService.CashPending = 0
--#endregion

--#region Functions
function PlayerService.newPlayer(player: Player)
    local newPlayer = player
    table.insert(PlayerService.Players, Player.new(newPlayer))
    return newPlayer
end

function PlayerService.distributeCash(): ()
    local players = PlayerService.Players
    local disbursement = PlayerService.CashPending / #players
    
    for _, player in players do
        player:ChangeCash(disbursement)
    end

    PlayerService.CashPending = 0

    return
end
--#endregion

Players.PlayerAdded:Connect(PlayerService.newPlayer)

return PlayerService