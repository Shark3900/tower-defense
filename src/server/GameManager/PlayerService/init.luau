--!strict
--#region Requires & Types
local Player = require(script.Player)
--#endregion

--#region Variables
local PlayerService = {}
PlayerService.Players = {} :: Player.PlayerData
--#endregion

--#region Functions
function PlayerService.distributeMoney(money: number): ()
    local players = PlayerService.Players
    local disbursement = money / players
    for i, player in players do
        
    end
end
--#endregion

return PlayerService