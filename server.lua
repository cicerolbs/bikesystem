addEvent('rentBike', true)
addEventHandler('rentBike', root, function(model)
    local player = client or source
    if not isElement(player) then return end
    if isPedInVehicle(player) then return end
    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)
    local bike = createVehicle(model, x + 2, y, z, 0, 0, rz)
    if bike then
        warpPedIntoVehicle(player, bike)
    end
end)
