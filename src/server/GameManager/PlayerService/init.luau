--!strict
--#region Requires & Types
local BuyTower = game.ReplicatedStorage.Events.BuyTower
local TowerService = require(script.Parent.TowerService)
local Tower = require(script.Parent.TowerService.Tower)
local Players = game:GetService("Players")
local Player = require(script.Player)

export type PlayerService = {
    --Variables
    Players: {Name: Player.PlayerData},
    CashPending: number,
    --Functions
    newPlayer: (player: Player) -> (Player.PlayerData),
    distributeCash: () -> (),
    buyTower: (playerArg: Player, towerName: string, position: Vector3) -> (Tower.Tower?)
}
--#endregion

--#region Variables
local PlayerService = {} :: PlayerService
PlayerService.Players = {} --TODO: Convert to dictionary
PlayerService.CashPending = 0
--#endregion

local function validTower(): (boolean)

end

--#region Functions
function PlayerService.newPlayer(player: Player): (Player.PlayerData)
    PlayerService.Players[player.Name] =  Player.new(player, {"Basic", "Sniper", "Mortar", "Tesla"})
    return PlayerService.Players[player.Name]
end

function PlayerService.distributeCash(): ()
    local disbursement: number = PlayerService.CashPending / #Players:GetPlayers()

    for _, player in PlayerService.Players do
        player:ChangeCash(disbursement)
    end

    PlayerService.CashPending = 0

    return
end

function PlayerService.buyTower(playerArg: Player, towerName: string, position: Vector3): (Tower.Tower?)
    local player: Player.PlayerData = PlayerService.Players[playerArg.Name]
    local towerCost: number? = Tower.getCost(towerName)
    if player:CheckEquipped(towerName) and towerCost and player:CheckCash(towerCost) and player:CheckTowerLim() then
        return TowerService.newTower(towerName, position)
    else
        return nil
    end
end
--#endregion

Players.PlayerAdded:Connect(PlayerService.newPlayer)
BuyTower.OnServerEvent:Connect(PlayerService.buyTower)

return PlayerService