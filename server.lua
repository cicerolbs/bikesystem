-- Servidor para o sistema de aluguel de bicicletas

local Config = {
    marker = {x = 1550.0, y = -1675.0, z = 13.5},
    bikes = {
        [1] = {model = 509, offset = {2, 0, 0}},
        [2] = {model = 481, offset = {2, -2, 0}},
    }
}

local rentMarker = createMarker(Config.marker.x, Config.marker.y, Config.marker.z - 1, "cylinder", 1.5, 255, 255, 0, 150)

addEventHandler("onMarkerHit", rentMarker, function(player, mDim)
    if not mDim or getElementType(player) ~= "player" then return end
    triggerClientEvent(player, "bikeRental:openPanel", player)
end)

addEventHandler("onMarkerLeave", rentMarker, function(player, mDim)
    if getElementType(player) ~= "player" then return end
    triggerClientEvent(player, "bikeRental:closePanel", player)
end)

addEvent("bikeRental:rentBike", true)
addEventHandler("bikeRental:rentBike", root, function(index)
    local player = client or source
    if not isElement(player) or isPedInVehicle(player) then return end
    local data = Config.bikes[index]
    if not data then return end
    local x, y, z = getElementPosition(rentMarker)
    local ox, oy, oz = unpack(data.offset)
    local bike = createVehicle(data.model, x + ox, y + oy, z + oz)
    if bike then
        warpPedIntoVehicle(player, bike)
    end
end)

