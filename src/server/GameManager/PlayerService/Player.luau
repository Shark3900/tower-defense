--!strict
--#region Requires & Types
local Tower = require(script.Parent.Parent.TowerService.Tower)

type PlayerFunctions = {
    __index: PlayerFunctions,
    new: (player: Player, equipped: {string}) -> (PlayerClass),
    AddTower: (self: PlayerClass, tower: Tower.Tower) -> (),
    SellTower: (self: PlayerClass, tower: Tower.Tower) -> (),
    ChangeNumTowers: (self: PlayerClass) -> (),
    ChangeCash: (self: PlayerClass, value: number) -> (PlayerClass),
    CheckCash: (self: PlayerClass, value: number) -> (boolean),
    CheckEquipped: (self: PlayerClass, towerName: string) -> (boolean),
    CheckTowerLim: (self: PlayerClass) -> (boolean),
    ValidTower: (self: PlayerClass, tower: Tower.Tower) -> (boolean)
}

type PlayerData = {
    --Properties
    User: Player,
    Cash: number,
    Equipped: {string},
    Towers: {Tower.Tower},
    EcoTowers: {Tower.Tower},
    Limit: number,
}

export type PlayerClass = typeof(setmetatable({} :: PlayerData, {} :: PlayerFunctions))

local Player = {} :: PlayerFunctions
Player.__index = Player
--#endregion

--#region Functions
function Player.new(player: Player, equipped: {string}): (PlayerClass)
    local self = {
        User = player,
        Cash = 400, --TODO: Divide by # players
        Equipped = equipped,
        Towers = {},
        EcoTowers = {},
        Limit = 60 --TODO: Divide by # players
    }
    self.User:SetAttribute("Cash", self.Cash)
    self.User:SetAttribute("Towers", #self.Towers + #self.EcoTowers)
    self.User:SetAttribute("Limit", self.Limit)

    return setmetatable(self, Player)
end

function Player:AddTower(tower: Tower.Tower): ()
    self:ChangeCash(-tower.Cost)
    if tower.Type == "Eco" then
        table.insert(self.EcoTowers, tower)
    else
        table.insert(self.Towers, tower)
    end
    self:ChangeNumTowers()
    return
end

function Player:SellTower(tower: Tower.Tower): ()
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

function Player:ChangeCash(value: number): (PlayerClass)
    self.Cash += value
    self.User:SetAttribute("Cash", self.Cash)
    return self
end

function Player:CheckCash(value: number): (boolean)
    return self.Cash >= value
end

function Player:CheckEquipped(towerName: string): (boolean)
    if table.find(self.Equipped, towerName) then
        return true
    else
        return false
    end
end

function Player:CheckTowerLim(): (boolean)
    return #self.Towers + #self.EcoTowers < self.Limit
end

function Player:ValidTower(tower: Tower.Tower): (boolean)
    if self:CheckEquipped(tower.Name) and self:CheckCash(tower.Cost) and self:CheckTowerLim() then
        return true
    else
        return false
    end
end
--#endregion

return Player