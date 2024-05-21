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
PlayerService.Players = {} --TODO: Convert to dictionary?
PlayerService.CashPending = 0
--#endregion

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
    local towerCost: number? = TowerService.getCost(towerName)
    if towerCost and player:ValidTower(towerName, towerCost) then
        local newTower = TowerService.newTower(towerName, position)
        newTower.Owner = playerArg
        newTower.Part:SetAttribute("Owner", playerArg.Name)
        player:AddTower(newTower)
        return newTower
    else
        return nil
    end
end

--vv Intellisense, make sure to double check
function PlayerService.sellTower(playerArg: Player, tower: Tower.Tower): ()
    local player: Player.PlayerData = PlayerService.Players[playerArg.Name]
    player:ChangeCash(tower.Cost)
    tower:Destroy()
    return
end

function PlayerService.upgradeTower(playerArg: Player, tower: Tower.Tower): ()
    local player: Player.PlayerData = PlayerService.Players[playerArg.Name]
    local upgradeCost: number? = Tower.getUpgradeCost(tower.Name)
    if player:CheckCash(upgradeCost) then
        player:ChangeCash(-upgradeCost)
        tower:Upgrade()
    end
    return
end
--^^ Intellisense, make sure to double check

function PlayerService.runEcoTowers()
    for _, player in PlayerService.Players do
        local income: number = 0
        for _, ecoTower in player.EcoTowers do
            income += ecoTower:Generate()
        end
        player:ChangeCash(income)
    end
end
--#endregion

Players.PlayerAdded:Connect(PlayerService.newPlayer)
BuyTower.OnServerEvent:Connect(PlayerService.buyTower)

return PlayerService