-- Sistema de aluguel de bicicletas com painel responsivo

-- RespC - Responsividade Completa para MTA
local sx, sy = guiGetScreenSize()
local baseX, baseY = 1920, 1080 -- base do Figma

-- Calcula zoom mantendo proporção
local zoom = sx / baseX
if sy / baseY < zoom then
    zoom = sy / baseY
end

-- Tamanho do painel base (fundo preto)
local baseWidth, baseHeight = 800, 500

-- Centraliza o painel base
local all = {
    x = (sx - baseWidth * zoom) / 2,
    y = (sy - baseHeight * zoom) / 2,
    w = baseWidth * zoom,
    h = baseHeight * zoom
}

-- Função para desenhar elemento escalado e centralizado
function dxDrawRespImage(px, py, w, h, img, r, g, b, a)
    dxDrawImage(all.x + px * zoom, all.y + py * zoom, w * zoom, h * zoom, img, 0, 0, 0, tocolor(r or 255, g or 255, b or 255, a or 255))
end

-- Configuração das bicicletas
local Config = {
    bikes = {
        {model = 509, name = "BMX",  img = "Bike.png",  imgW = 34, imgH = 27, offset = {2, 0, 0}},
        {model = 481, name = "Bike", img = "Bike2.png", imgW = 56, imgH = 37, offset = {2, -2, 0}},
    }
}

-- Texturas principais
local textures = {
    base   = dxCreateTexture("Base.png"),
    slot   = dxCreateTexture("Slot.png"),
    alugar = dxCreateTexture("Alugar.png"),
    sair   = dxCreateTexture("Sair.png"),
}
for i, bike in ipairs(Config.bikes) do
    bike.tex = dxCreateTexture(bike.img)
end

-- Fontes personalizadas
local fontRegular = dxCreateFont("SFPRODISPLAYREGULAR.OTF", 16 * zoom)
local fontMedium  = dxCreateFont("SFPRODISPLAYMEDIUM.OTF", 20 * zoom)

-- Variáveis de controle
local showing = false
local selected = nil
local areas = {}

-- Desenho do painel
local function renderPanel()
    dxDrawRespImage(0, 0, baseWidth, baseHeight, textures.base)

    -- slots
    local slotW, slotH = 384, 93
    local slotPos = {
        {x = 40, y = 60},
        {x = baseWidth - slotW - 40, y = 60},
    }
    areas.slots = {}

    for i, pos in ipairs(slotPos) do
        local alpha = selected == i and 255 or 120
        dxDrawRespImage(pos.x, pos.y, slotW, slotH, textures.slot, 255, 255, 255, alpha)
        local bike = Config.bikes[i]
        local bx = pos.x + (slotW - bike.imgW) / 2
        local by = pos.y + (slotH - bike.imgH) / 2
        dxDrawRespImage(bx, by, bike.imgW, bike.imgH, bike.tex)
        dxDrawText(bike.name,
            all.x + pos.x * zoom, all.y + (pos.y + slotH + 5) * zoom,
            all.x + (pos.x + slotW) * zoom, all.y + (pos.y + slotH + 25) * zoom,
            tocolor(255, 255, 255), 1, fontMedium, "center", "top", false, false, false, true)
        areas.slots[i] = {all.x + pos.x * zoom, all.y + pos.y * zoom, slotW * zoom, slotH * zoom}
    end

    -- botão alugar
    local alugarW, alugarH = 384, 72
    local alugarX, alugarY = (baseWidth - alugarW) / 2, baseHeight - alugarH - 20
    local alpha = selected and 255 or 120
    dxDrawRespImage(alugarX, alugarY, alugarW, alugarH, textures.alugar, 255, 255, 255, alpha)
    areas.alugar = {all.x + alugarX * zoom, all.y + alugarY * zoom, alugarW * zoom, alugarH * zoom}

    -- botão fechar
    local sairW, sairH = 18, 18
    local sairX, sairY = baseWidth - sairW - 10, 10
    dxDrawRespImage(sairX, sairY, sairW, sairH, textures.sair)
    areas.close = {all.x + sairX * zoom, all.y + sairY * zoom, sairW * zoom, sairH * zoom}
end

-- Utilitário de detecção de clique
local function isCursorOn(x, y, w, h)
    local cx, cy = getCursorPosition()
    if not cx then return false end
    cx, cy = cx * sx, cy * sy
    return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

-- Abertura e fechamento do painel
local function openPanel()
    if showing then return end
    showing = true
    selected = nil
    showCursor(true)
    addEventHandler("onClientRender", root, renderPanel)
end
addEvent("bikeRental:openPanel", true)
addEventHandler("bikeRental:openPanel", root, openPanel)

local function closePanel()
    if not showing then return end
    showing = false
    showCursor(false)
    removeEventHandler("onClientRender", root, renderPanel)
end
addEvent("bikeRental:closePanel", true)
addEventHandler("bikeRental:closePanel", root, closePanel)

-- Clique do mouse
addEventHandler("onClientClick", root, function(button, state)
    if button ~= "left" or state ~= "down" or not showing then return end
    for i, rect in ipairs(areas.slots) do
        if isCursorOn(unpack(rect)) then
            selected = i
            return
        end
    end
    if selected and areas.alugar and isCursorOn(unpack(areas.alugar)) then
        triggerServerEvent("bikeRental:rentBike", localPlayer, selected)
        closePanel()
        return
    end
    if areas.close and isCursorOn(unpack(areas.close)) then
        closePanel()
    end
end)

