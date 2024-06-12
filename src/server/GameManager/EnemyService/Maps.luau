--!strict
export type Map = {
    [string]: {
        ["Map"]: {},
        ["Paths"]: number,
        [number]: {
            ["Waypoints"]: {Part},
        }
    }
}

local Maps = {
    ["TestMap"] = {
        ["Map"] = game.ServerStorage.Maps["TestMap"],
        ["Paths"] = 1,
        [1] = {
            ["Waypoints"] = {}
        }
    },
    ["TestMap2"] = {
        ["Map"] = game.ServerStorage.Maps["TestMap2"],
        ["Paths"] = 2,
        [1] = {
            ["Waypoints"] = {}
        },
        [2] = {
            ["Waypoints"] = {}
        }
    }
}

for mapName, map in Maps do
    for i, path in game.ServerStorage.Maps[mapName].Paths:GetChildren() do
        for _, waypoint in path:GetChildren() do
            map[tonumber(path.Name)].Waypoints[tonumber(waypoint.Name)] = waypoint.Position
        end
    end
end

function Maps.set(name: string)
    Maps[name].Map.Parent = workspace
    Maps.Map = Maps[name]
    return Maps[name]
end

return Maps