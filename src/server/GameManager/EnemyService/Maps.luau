--!strict
export type Map = {
    [string]: {
        ["Map"]: {},
        ["Waypoints"]: {Part},
    }
}

local Maps = {
    ["TestMap"] = {
        ["Map"] = game.ServerStorage.Maps["TestMap"],
        ["Waypoints"] = {}
    }
}

for mapName, map in Maps do
    for _, waypoint in game.ServerStorage.Maps[mapName].Waypoints:GetChildren() do
        map.Waypoints[tonumber(waypoint.Name)] = waypoint.Position
    end
end

function Maps.set(name: string)
    Maps[name].Map.Parent = workspace
    Maps.Waypoints = Maps[name].Waypoints
    return Maps[name]
end

return Maps