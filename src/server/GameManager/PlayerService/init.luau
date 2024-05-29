--!strict
--#region Requires & Types
local Events = game.ReplicatedStorage.Events
local TowerService = require(script.Parent.TowerService)
local TowerData = require(script.Parent.TowerService.TowerData)
local Tower = require(script.Parent.TowerService.Tower)
local Players = game:GetService("Players")
local Player = require(script.Player)

export type PlayerService = {
    --Variables
    Players: {[string]: Player.PlayerClass},
    CashPending: number,
    --Functions
    newPlayer: (player: Player) -> (Player.PlayerClass),
    distributeCash: () -> (),
    buyTower: (playerArg: Player, towerName: string, position: Vector3) -> (Tower.Tower?),
    sellTower: (playerArg: Player, tower: Tower.Tower) -> (),
    upgradeTower: (playerArg: Player, tower: Tower.Tower) -> (),
    runEcoTowers: () -> ()
}
--#endregion

--#region Variables
local PlayerService = {} :: PlayerService
PlayerService.Players = {} --TODO: Convert to dictionary?
PlayerService.CashPending = 0
--#endregion

--#region Functions
function PlayerService.newPlayer(player: Player): (Player.PlayerClass)
    PlayerService.Players[player.Name] =  Player.new(player, {"Basic", "Mortar", "Glue Gunner", "Farm"})
    Events.SetTowers:FireClient(player, PlayerService.Players[player.Name].Equipped)
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
    local player: Player.PlayerClass = PlayerService.Players[playerArg.Name]
    local tower: TowerData.TowerTemplate? = TowerService.getTower(towerName, 1)
    if tower and player:ValidTower(tower) then
        local newTower: Tower.Tower = TowerService.newTower(towerName, position)
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
    local player: Player.PlayerClass = PlayerService.Players[playerArg.Name]
    player:ChangeCash(tower.Cost)
    tower:Destroy()
    return
end

function PlayerService.upgradeTower(playerArg: Player, tower: Tower.Tower): ()
    local player: Player.PlayerClass = PlayerService.Players[playerArg.Name]
    local upgrade: TowerData.TowerTemplate? = TowerService.getTower(tower.Name, tower.Level + 1)
    if upgrade and player:CheckCash(upgrade.Cost) then
        player:ChangeCash(-upgrade.Cost)
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
Events.BuyTower.OnServerEvent:Connect(PlayerService.buyTower)

return PlayerService