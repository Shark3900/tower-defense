--!strict
--#region Requires & Types
local BuyTower = game.ReplicatedStorage.Events.BuyTower
local TowerService = require(script.Parent.TowerService)
local Tower = require(script.Parent.TowerService.Tower)
local Players = game:GetService("Players")
local Player = require(script.Player)

type PlayerService = {
    --Variables
    Players: {Player.PlayerData},
    CashPending: number,
    --Functions
    newPlayer: (player: Player) -> (Player.PlayerData),
    distributeCash: () -> (),
    buyTower: (player: Player, towerName: string, position: Vector3) -> ()
}
--#endregion

--#region Variables
local PlayerService = {} :: PlayerService
PlayerService.Players = {}
PlayerService.CashPending = 0
--#endregion

local function validTower(): (boolean)
    
end

--#region Functions
function PlayerService.newPlayer(player: Player): (Player.PlayerData)
    PlayerService.Players[player] = Player.new(player)
    return PlayerService.Players[player]
end

function PlayerService.distributeCash(): ()
    local disbursement = PlayerService.CashPending / #Players:GetPlayers()

    for _, player in PlayerService.Players do
        player:ChangeCash(disbursement)
    end

    PlayerService.CashPending = 0

    return
end

function PlayerService.buyTower(playerArg: Player, towerName: string, position: Vector3): (Tower.Tower?)
    local player = table.find(PlayerService.Players, playerArg)
    local towerCost = Tower.getCost(towerName)
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