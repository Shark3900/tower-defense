--!strict
--#region Requires & Types
local Tower = require(script.Tower)
local EnemyService = require(script.Parent.EnemyService)
type TowerService = {
    --Properties
    Towers: {Tower.Tower},
    Spawners: {Tower.Tower},
    --Functions
    newTower: (towerType: string, position: Vector3) -> (Tower.Tower),
    newSpawner: (spawnerType: string, position: Vector3) -> (Tower.Tower),
    attackEnemies: () -> ()
}
--#endregion

--#region Variables
local TowerService = {} :: TowerService
TowerService.Towers = {}
TowerService.Spawners = {}
--#endregion

--#region Functions
function TowerService.newTower(towerType: string, position: Vector3): (Tower.Tower)
    --TODO: Implement economy
    local tower = Tower.new(towerType, position)
    table.insert(TowerService.Towers, tower)
    return tower
end

function TowerService.newSpawner(spawnerType: string, position: Vector3): (Tower.Tower)
    local spawner = Tower.new(spawnerType, position)
    table.insert(TowerService.Spawners, spawner)
    return spawner
end

--function TowerService.sellTower()?

function TowerService.attackEnemies(): ()
    for _, tower in TowerService.Towers do
        local debounce: number = tower.AttackSpeed

        if tick() - tower.AttackTimer > debounce then
            local target = tower:FindTarget()

            if target then
                tower.Part.CFrame = CFrame.lookAt(tower.Part.Position, target.Part.Position)
                if tower.AttackType == "Direct" then
                    tower:DirectAttack(target)
                elseif tower.AttackType == "Box" then
                    tower:BoxAttack(target)
                elseif tower.AttackType == "Circle" then
                    tower:CircleAttack(target)
                else
                    tower:ConeAttack(target)
                end
                EnemyService.sortHealth()
            end
        end
    end

    return
end
--#endregion

return TowerService