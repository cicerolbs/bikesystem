-- Client-side bike rental system using dxDraw for UI and responsive scaling

-- screen size and zoom calculation (RespC)
local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1920
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX / sx)
end

-- textures used in the panel
local textures = {
    fundo = dxCreateTexture("Fundo.png"),
    base = dxCreateTexture("Base.png"),
    slot = dxCreateTexture("Slot.png"),
    bike1 = dxCreateTexture("Bike.png"),
    bike2 = dxCreateTexture("Bike2.png"),
    alugar = dxCreateTexture("Alugar.png"),
    sair = dxCreateTexture("Sair.png")
}

-- fonts for panel texts
local fonts = {
    regular = dxCreateFont("SFPRODISPLAYREGULAR.OTF", 16 / zoom),
    medium = dxCreateFont("SFPRODISPLAYMEDIUM.OTF", 20 / zoom)
}

-- available bikes
local bikes = {
    { model = 509, name = "Bike" },
    { model = 481, name = "BMX" }
}

-- calculate base panel size for responsive positions
local baseW, baseH = dxGetMaterialSize(textures.base)
local all = {
    x = (sx - (baseW) / zoom) / 2,
    y = (sy - (baseH) / zoom) / 2,
    w = (baseW) / zoom,
    h = (baseH) / zoom
}

local showing = false
local selected = nil
local panelData = {}

-- helper to check cursor over element
local function isCursorOnElement(x, y, w, h)
    local cx, cy = getCursorPosition()
    if not cx or not cy then
        return false
    end
    cx, cy = cx * sx, cy * sy
    return (cx >= x and cx <= x + w and cy >= y and cy <= y + h)
end

-- draw the selection panel
local function drawPanel()
    -- background images
    dxDrawImage(all.x, all.y, all.w, all.h, textures.fundo)
    dxDrawImage(all.x, all.y, all.w, all.h, textures.base)

    -- slot positions
    local slotW, slotH = dxGetMaterialSize(textures.slot)
    slotW, slotH = slotW / zoom, slotH / zoom
    local slot1X, slot1Y = all.x + 40 / zoom, all.y + 60 / zoom
    local slot2X, slot2Y = all.x + all.w - slotW - 40 / zoom, slot1Y
    dxDrawImage(slot1X, slot1Y, slotW, slotH, textures.slot)
    dxDrawImage(slot2X, slot2Y, slotW, slotH, textures.slot)

    -- highlight selected slot
    if selected == 1 then
        dxDrawRectangle(slot1X, slot1Y, slotW, slotH, tocolor(255, 255, 0, 100))
    elseif selected == 2 then
        dxDrawRectangle(slot2X, slot2Y, slotW, slotH, tocolor(255, 255, 0, 100))
    end

    -- bike icons
    local bike1W, bike1H = dxGetMaterialSize(textures.bike1)
    local bike2W, bike2H = dxGetMaterialSize(textures.bike2)
    bike1W, bike1H = bike1W / zoom, bike1H / zoom
    bike2W, bike2H = bike2W / zoom, bike2H / zoom
    dxDrawImage(slot1X + (slotW - bike1W) / 2, slot1Y + (slotH - bike1H) / 2, bike1W, bike1H, textures.bike1)
    dxDrawImage(slot2X + (slotW - bike2W) / 2, slot2Y + (slotH - bike2H) / 2, bike2W, bike2H, textures.bike2)

    -- bike names
    dxDrawText(bikes[1].name, slot1X, slot1Y + slotH + 5 / zoom, slot1X + slotW, slot1Y + slotH + 25 / zoom,
               tocolor(255, 255, 255), 1, fonts.medium, "center", "top")
    dxDrawText(bikes[2].name, slot2X, slot2Y + slotH + 5 / zoom, slot2X + slotW, slot2Y + slotH + 25 / zoom,
               tocolor(255, 255, 255), 1, fonts.medium, "center", "top")

    -- rent button (only active when a bike is selected)
    local alugarW, alugarH = dxGetMaterialSize(textures.alugar)
    alugarW, alugarH = alugarW / zoom, alugarH / zoom
    local alugarX, alugarY = all.x + (all.w - alugarW) / 2, all.y + all.h - alugarH - 20 / zoom
    if selected then
        dxDrawImage(alugarX, alugarY, alugarW, alugarH, textures.alugar)
    else
        dxDrawImage(alugarX, alugarY, alugarW, alugarH, textures.alugar, 0, 0, 0, tocolor(255, 255, 255, 120))
    end

    -- close button
    local sairW, sairH = dxGetMaterialSize(textures.sair)
    sairW, sairH = sairW / zoom, sairH / zoom
    local sairX, sairY = all.x + all.w - sairW - 10 / zoom, all.y + 10 / zoom
    dxDrawImage(sairX, sairY, sairW, sairH, textures.sair)

    -- store interactive areas for clicks
    panelData.slot1 = { slot1X, slot1Y, slotW, slotH }
    panelData.slot2 = { slot2X, slot2Y, slotW, slotH }
    panelData.alugar = { alugarX, alugarY, alugarW, alugarH }
    panelData.sair = { sairX, sairY, sairW, sairH }
end

-- open/close handlers triggered by server when entering/leaving the marker
addEvent("bikeRental:openPanel", true)
addEvent("bikeRental:closePanel", true)

local function openBikePanel()
    if showing then return end
    selected = nil
    showing = true
    showCursor(true)
    addEventHandler("onClientRender", root, drawPanel)
end
addEventHandler("bikeRental:openPanel", root, openBikePanel)

local function closeBikePanel()
    if not showing then return end
    showing = false
    showCursor(false)
    removeEventHandler("onClientRender", root, drawPanel)
end
addEventHandler("bikeRental:closePanel", root, closeBikePanel)

-- mouse click handling
addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "down" or not showing then return end

    if isCursorOnElement(unpack(panelData.slot1)) then
        selected = 1
        return
    end
    if isCursorOnElement(unpack(panelData.slot2)) then
        selected = 2
        return
    end

    if isCursorOnElement(unpack(panelData.alugar)) and selected then
        triggerServerEvent("bikeRental:rentBike", localPlayer, bikes[selected].model)
        closeBikePanel()
        return
    end

    if isCursorOnElement(unpack(panelData.sair)) then
        closeBikePanel()
    end
end)

