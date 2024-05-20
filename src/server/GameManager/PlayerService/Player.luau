--!strict
--#region Requires & Types
local Tower = require(script.Parent.Parent.TowerService.Tower)
local Spawner = require(script.Parent.Parent.TowerService.Spawner)
local Eco = require(script.Parent.Parent.TowerService.Eco)

export type PlayerData = {
    --Properties
    User: Player,
    Cash: number,
    Equipped: {string},
    Towers: {Tower.Tower},
    EcoTowers: {Eco.Eco},
    Spawners: {Spawner.Spawner},
    Limit: number,
    --Functions
    new: (playerName: string) -> (PlayerData),
    AddTower: (self: PlayerData, tower: Tower.Tower) -> (),
    AddEcoTower: (self: PlayerData, tower: Eco.Eco) -> (),
    ChangeNumTowers: (self: PlayerData) -> (),
    ChangeCash: (self: PlayerData, value: number) -> (PlayerData),
    CheckCash: (self: PlayerData, value: number) -> (boolean),
    CheckEquipped: (self: PlayerData, towerName: string) -> (boolean),
    CheckTowerLim: (self: PlayerData) -> (boolean),
    ValidTower: (self: PlayerData, towerName: string, towerCost: number) -> (boolean)
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
        Towers = {},
        EcoTowers = {},
        Spawners = {},
        Limit = 20
    }
    self.User:SetAttribute("Cash", self.Cash)
    self.User:SetAttribute("Towers", #self.Towers + #self.EcoTowers)
    self.User:SetAttribute("Limit", self.Limit)

    return setmetatable(self, Player)
end

function Player:AddTower(tower: Tower.Tower?, ecoTower: Eco.Eco?, spawner: Spawner.Spawner?): ()
    if tower then
        self:ChangeCash(-tower.Cost)
        table.insert(self.Towers, tower)
        tower.Owner = self.User
    elseif ecoTower then
        self:ChangeCash(-ecoTower.Cost)
        table.insert(self.EcoTowers, ecoTower)
        ecoTower.Owner = self.User
    elseif spawner then
        self:ChangeCash(-spawner.Cost)
        table.insert(self.Spawners, spawner)
        spawner.Owner = self.User
    end
    self:ChangeNumTowers()
    return
end

function Player:SellTower(tower: {Tower.Tower | Spawner.Spawner | Eco.Eco}): ()
    if table.find(self.Towers, tower) then
        self:ChangeCash(tower.Value * 0.75)
        table.remove(self.Towers, table.find(self.Towers, tower))
    elseif table.find(self.EcoTowers, tower) then
        self:ChangeCash(tower.Value * 0.75)
        table.remove(self.EcoTowers, table.find(self.EcoTowers, tower))
    end
    self:ChangeNumTowers()
    return
end

function Player:ChangeNumTowers(): ()
    self.User:SetAttribute("Towers", #self.Towers + #self.EcoTowers)
    return
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
    return #self.Towers + #self.EcoTowers < self.Limit
end

function Player:ValidTower(towerName: string, towerCost: number): (boolean)
    if self:CheckEquipped(towerName) and self:CheckCash(towerCost) and self:CheckTowerLim() then
        return true
    else
        return false
    end
end
--#endregion

return Player