
local function createIdleScreen(startX, startY, screenWidth, screenHeight, width, height)
	local halfWidth, halfHeight = width * 0.5, height * 0.5
	local color = tocolor(255, 255, 255)
	local posX, posY = math.random(halfWidth, screenWidth - halfWidth), math.random(halfHeight, screenHeight - halfHeight)
	local sideX, sideY = 1, 1

	local function random()
		return math.random(0, 255)
	end

	local function handlerPos()
		posX = posX + sideX
		posY = posY + sideY

		if (posX + halfWidth) >= screenWidth or (posX + halfWidth * sideX) <= 0 then
			sideX = -sideX

			color = tocolor(random(), random(), random())
		end
		if (posY + halfHeight) >= screenHeight or (posY + halfHeight * sideY) <= 0 then
			sideY = -sideY

			color = tocolor(random(), random(), random())
		end
	end

	local function renderDisplay()
		handlerPos()

		dxDrawImage(startX + posX - halfWidth, startY + posY - halfHeight, width, width, "arrow.png", 0, 0, 0, color)
	end

	addEventHandler("onClientRender", root, renderDisplay)
end

local function startIdleScreen()
	local sw, sh = guiGetScreenSize()
	local half_sw = sw * 0.5
	createIdleScreen(0, 0, half_sw, sh, 50, 50)
	createIdleScreen(half_sw, 0, half_sw, sh, 50, 50)
end
addEventHandler("onClientResourceStart", resourceRoot, startIdleScreen)