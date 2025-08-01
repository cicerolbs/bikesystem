local screenW, screenH = guiGetScreenSize()

local showing = false
local selected = 1

local textures = {
    fundo = dxCreateTexture('Fundo.png'),
    base = dxCreateTexture('Base.png'),
    slot = dxCreateTexture('Slot.png'),
    bike1 = dxCreateTexture('Bike.png'),
    bike2 = dxCreateTexture('Bike2.png'),
    alugar = dxCreateTexture('Alugar.png'),
    sair = dxCreateTexture('Sair.png')
}

local fonts = {
    regular = dxCreateFont('SFPRODISPLAYREGULAR.OTF', 16),
    medium = dxCreateFont('SFPRODISPLAYMEDIUM.OTF', 20)
}

local bikes = {
    {model = 509, name = 'Bike'},
    {model = 481, name = 'BMX'}
}

local function isCursorOnElement(x, y, w, h)
    local cx, cy = getCursorPosition()
    if not cx or not cy then
        return false
    end
    cx, cy = cx * screenW, cy * screenH
    return (cx >= x and cx <= x + w and cy >= y and cy <= y + h)
end

local function drawPanel()
    local fundoW, fundoH = dxGetMaterialSize(textures.fundo)
    local fundoX, fundoY = (screenW - fundoW) / 2, (screenH - fundoH) / 2
    dxDrawImage(fundoX, fundoY, fundoW, fundoH, textures.fundo)

    local baseW, baseH = dxGetMaterialSize(textures.base)
    local baseX, baseY = (screenW - baseW) / 2, (screenH - baseH) / 2
    dxDrawImage(baseX, baseY, baseW, baseH, textures.base)

    local slotW, slotH = dxGetMaterialSize(textures.slot)
    local slot1X, slot1Y = baseX + 40, baseY + 60
    local slot2X, slot2Y = baseX + baseW - slotW - 40, slot1Y
    dxDrawImage(slot1X, slot1Y, slotW, slotH, textures.slot)
    dxDrawImage(slot2X, slot2Y, slotW, slotH, textures.slot)

    if selected == 1 then
        dxDrawRectangle(slot1X, slot1Y, slotW, slotH, tocolor(255,255,0,100))
    else
        dxDrawRectangle(slot2X, slot2Y, slotW, slotH, tocolor(255,255,0,100))
    end

    local bike1W, bike1H = dxGetMaterialSize(textures.bike1)
    local bike2W, bike2H = dxGetMaterialSize(textures.bike2)
    dxDrawImage(slot1X + (slotW - bike1W)/2, slot1Y + (slotH - bike1H)/2, bike1W, bike1H, textures.bike1)
    dxDrawImage(slot2X + (slotW - bike2W)/2, slot2Y + (slotH - bike2H)/2, bike2W, bike2H, textures.bike2)

    local alugarW, alugarH = dxGetMaterialSize(textures.alugar)
    local alugarX, alugarY = baseX + (baseW - alugarW) / 2, baseY + baseH - alugarH - 20
    dxDrawImage(alugarX, alugarY, alugarW, alugarH, textures.alugar)

    local sairW, sairH = dxGetMaterialSize(textures.sair)
    local sairX, sairY = baseX + baseW - sairW - 10, baseY + 10
    dxDrawImage(sairX, sairY, sairW, sairH, textures.sair)

    dxDrawText(bikes[1].name, slot1X, slot1Y + slotH + 5, slot1X + slotW, slot1Y + slotH + 25, tocolor(255,255,255,255), 1, fonts.medium, 'center', 'top')
    dxDrawText(bikes[2].name, slot2X, slot2Y + slotH + 5, slot2X + slotW, slot2Y + slotH + 25, tocolor(255,255,255,255), 1, fonts.medium, 'center', 'top')

    -- store positions for click checks
    panelData = {slot1={slot1X,slot1Y,slotW,slotH}, slot2={slot2X,slot2Y,slotW,slotH}, alugar={alugarX,alugarY,alugarW,alugarH}, sair={sairX,sairY,sairW,sairH}}
end

function openBikePanel()
    if showing then return end
    showing = true
    showCursor(true)
    addEventHandler('onClientRender', root, drawPanel)
end
addCommandHandler('bike', openBikePanel)

local function closeBikePanel()
    if not showing then return end
    showing = false
    showCursor(false)
    removeEventHandler('onClientRender', root, drawPanel)
end

addEventHandler('onClientClick', root, function(button, state)
    if button ~= 'left' or state ~= 'down' or not showing then return end
    local slot1 = panelData.slot1
    local slot2 = panelData.slot2
    local alugar = panelData.alugar
    local sair = panelData.sair
    if isCursorOnElement(slot1[1], slot1[2], slot1[3], slot1[4]) then
        selected = 1
    elseif isCursorOnElement(slot2[1], slot2[2], slot2[3], slot2[4]) then
        selected = 2
    elseif isCursorOnElement(alugar[1], alugar[2], alugar[3], alugar[4]) then
        triggerServerEvent('rentBike', localPlayer, bikes[selected].model)
        closeBikePanel()
    elseif isCursorOnElement(sair[1], sair[2], sair[3], sair[4]) then
        closeBikePanel()
    end
end)
