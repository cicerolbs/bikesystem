-- Server-side logic for bike rental system

-- marker position (adjust to desired location in the world)
local markerPos = { x = 1550.0, y = -1675.0, z = 13.5 }
local rentMarker = createMarker(markerPos.x, markerPos.y, markerPos.z - 1, "cylinder", 1.5, 255, 255, 0, 150)

-- notify client when player enters or leaves the marker
addEventHandler("onMarkerHit", rentMarker, function(player, mDim)
    if not mDim or getElementType(player) ~= "player" then return end
    triggerClientEvent(player, "bikeRental:openPanel", player)
end)

addEventHandler("onMarkerLeave", rentMarker, function(player, mDim)
    if getElementType(player) ~= "player" then return end
    triggerClientEvent(player, "bikeRental:closePanel", player)
end)

-- event to spawn selected bike near the marker
addEvent("bikeRental:rentBike", true)
addEventHandler("bikeRental:rentBike", root, function(model)
    local player = client or source
    if not isElement(player) or isPedInVehicle(player) then return end
    local x, y, z = getElementPosition(rentMarker)
    local bike = createVehicle(model, x + 2, y, z)
    if bike then
        warpPedIntoVehicle(player, bike)
    end
end)

