
local mainWindow, createWindow, openMenu, isActiveEditBox, updateScrollList

local dataPlayers = {}
addEvent("myPlayersListLoad", true)
addEventHandler("myPlayersListLoad", localPlayer, function(msg)
	dataPlayers = fromJSON(msg)
	outputChatBox("Данные успешно загружены", 120, 230, 120)

	if mainWindow ~= nil then
		updateScrollList()
	else
		openMenu()
	end
end)

-- start -- повторяющиеся переменные для менюшек
local btn_height = 22
local startY = 30
local margin = 10
-- end -- повторяющиеся переменные для менюшек



-- start -- multi select window
local windowMultiSelect
local function destroyMultiSelect()
	if windowMultiSelect ~= nil then
		destroyElement(windowMultiSelect)
		windowMultiSelect = nil
	end
end

local function createMultiSelect(text, btns, tbl)
	destroyMultiSelect()

	if btns[#btns].name ~= "Отмена" then
		table.insert(btns, {
			name = "Отмена",
			func = destroyMultiSelect
		})
	end

	local width, height = 280, 30

	windowMultiSelect = createWindow(width, height + #btns * (btn_height + margin), text or "Выберите действие")

	for k, v in ipairs(btns) do
		local btn = guiCreateButton(margin, startY + (k - 1) * (btn_height + margin), width - margin * 2, btn_height, v.name, false, windowMultiSelect)

		addEventHandler("onClientGUIClick", btn, function()
			v.func(tbl, btn)
		end, false)
	end
end
-- end -- multi select window

-- фикс закрытия при нажатии кнопки L когда выбрано окно ввода текста
local function addEventHandlerFixClose(elements, block, otherEvent)
	if type(elements) ~= "table" then
		elements = {elements}
	end

	for i, el in ipairs(elements) do	
		addEventHandler(otherEvent or "onClientGUIClick", el, function() isActiveEditBox = block end, false)
	end
end



function createWindow(width, height, text)
	local sw, sh = guiGetScreenSize()

	local window = guiCreateWindow(sw * 0.5 - width * 0.5, sh * 0.5 - height * 0.5, width, height, text)

	guiFocus(window)
	guiSetInputEnabled(true)
	guiWindowSetSizable(window, false)

	return window
end

local currentPage = 1
local function closeWindow()
	destroyElement(mainWindow)
	guiSetInputEnabled(false)
	destroyMultiSelect()

	isActiveEditBox = false
	mainWindow = nil
	currentPage = 1
end


local function createOrEditCharacter(tbl, addUser)
	local id, name, surname, address
	if tbl then
		id, name, surname, address = tbl.id, tbl.name, tbl.surname, tbl.address
	end

	local width, height = 450, 210

	local title
	if id then
		title = "(" .. id .. ") " .. name .. " " .. surname
	else
		title = "Ввод данных"
	end

	mainWindow = createWindow(width, height, title)

	local leftSideWidth = width * 0.3

	local entryName = guiCreateEdit(margin + leftSideWidth, startY, width - margin * 2 - leftSideWidth, btn_height, name or "", false, mainWindow)
	local lblName = guiCreateLabel(margin, startY, leftSideWidth - margin, btn_height, "Имя", false, mainWindow)

	local pos2 = startY + btn_height + margin
	local entrySurname = guiCreateEdit(margin + leftSideWidth, pos2, width - margin * 2 - leftSideWidth, btn_height, surname or "", false, mainWindow)
	local lblSurname = guiCreateLabel(margin, pos2, leftSideWidth - margin, btn_height, "Фамилия", false, mainWindow)

	local pos3 = startY + (btn_height + margin) * 2
	local entryAddress = guiCreateEdit(margin + leftSideWidth, pos3, width - margin * 2 - leftSideWidth, btn_height, address or "", false, mainWindow)
	local lblAddress = guiCreateLabel(margin, pos3, leftSideWidth - margin, btn_height, "Адрес проживания", false, mainWindow)

	guiEditSetMaxLength(entryName, myConfig.maxNameLength)
	guiEditSetMaxLength(entrySurname, myConfig.maxNameLength)
	guiEditSetMaxLength(entryAddress, myConfig.maxAddressLength)

	guiLabelSetHorizontalAlign(lblName, "right")
	guiLabelSetHorizontalAlign(lblSurname, "right")
	guiLabelSetHorizontalAlign(lblAddress, "right")

	guiLabelSetVerticalAlign(lblName, "center")
	guiLabelSetVerticalAlign(lblSurname, "center")
	guiLabelSetVerticalAlign(lblAddress, "center")

	local function funcSave()
		local name = guiGetText(entryName)
		local surname = guiGetText(entrySurname)
		local address = guiGetText(entryAddress)

		local valid, msg = checkValidName(name)
		if valid then
			valid, msg = checkValidName(surname)
		end
		if valid then
			valid, msg = checkValidAddress(address)
		end
		if msg then
			outputChatBox(msg, 230, 120, 120)
			return
		end

		if addUser then
			-- по хорошему здесь не должно быть ввода id, но у меня не получилось сделать ячейку auto_increment с mysqlite, так что пришлось так
			triggerServerEvent("myPlayersListAddUser", localPlayer, #dataPlayers + 1, name, surname, address)
		else
			triggerServerEvent("myPlayersListSaveUser", localPlayer, id, name, surname, address)
		end
		
		closeWindow()
	end
	local saveBtn = guiCreateButton(margin, height - (btn_height + margin) * 2, width - margin * 2, btn_height, addUser and "Добавить" or "Сохранить", false, mainWindow)
	addEventHandler("onClientGUIClick", saveBtn, funcSave, false)

	local closeBtn = guiCreateButton(margin, height - btn_height - margin, width - margin * 2, btn_height, "Отмена", false, mainWindow)
	addEventHandler("onClientGUIClick", closeBtn, closeWindow, false)

	addEventHandlerFixClose({entryName, entrySurname, entryAddress}, true)
	addEventHandlerFixClose({entryName, entrySurname, entryAddress}, false, "onClientGUIAccepted")

	addEventHandlerFixClose(mainWindow, false)
end


local createScrollButton, scroll
function updateScrollList(searchText)
	for i, v in ipairs(getElementChildren(scroll)) do
		destroyElement(v)
	end

	for i, v in ipairs(dataPlayers) do
		createScrollButton(i, v)
	end
end

function openMenu()
	local width, height = 750, 800
	mainWindow = createWindow(width, height, "Список пользователей")
	
	scroll = guiCreateScrollPane(margin, startY + btn_height + margin, width - margin * 2, height - (btn_height + margin) * 3.2, false, mainWindow)

	local searchEntry = guiCreateEdit(margin, startY, width - btn_height * 8 - margin * 4, btn_height, "", false, mainWindow)
	guiEditSetMaxLength(searchEntry, myConfig.maxAddressLength)
	addEventHandlerFixClose(searchEntry, true)
	addEventHandlerFixClose(searchEntry, false, "onClientGUIAccepted")

	local searchCombo
	local function requestSearch()
		local text = guiGetText(searchEntry)

		if text == '' then
			triggerServerEvent("myPlayersListRequest", localPlayer, currentPage)
			return
		end

		local selected = guiComboBoxGetSelected(searchCombo)
		local findID = selected == 0
		-- local findName = selected == 1 -- не используется
		local findAddress = selected == 2

		local id, name, surname, address

		if findID then
			id = tonumber(text)
		else
			for k, v in ipairs(split(text, ' ')) do
				if findAddress then
					address = (address or '') .. v
				else
					if k == 1 then
						name = v
					elseif k == 2 then
						surname = v
					end
				end
			end
		end

		if not id and not name and not address then
			outputChatBox('Поиск пуст', 230, 120, 120)
			return
		end

		if id then
			triggerServerEvent("myPlayersListSearchUser", localPlayer, id)
		elseif name then
			triggerServerEvent("myPlayersListSearchUser", localPlayer, nil, name, surname)
		else
			triggerServerEvent("myPlayersListSearchUser", localPlayer, nil, nil, nil, address)
		end
	end
	addEventHandler("onClientGUIAccepted", searchEntry, requestSearch, false)


	
	searchCombo = guiCreateComboBox(width - btn_height * 8 - margin * 2, startY , btn_height * 5, btn_height * 4, "", false, mainWindow)
	guiComboBoxAddItem(searchCombo, "ID")
	guiComboBoxAddItem(searchCombo, "Имя и Фамилия")
	guiComboBoxAddItem(searchCombo, "Адрес")
	guiComboBoxSetSelected(searchCombo, 0)


	local searchBtn = guiCreateButton(width - btn_height * 3 - margin, startY, btn_height * 3, btn_height, "Поиск", false, mainWindow)
	addEventHandler("onClientGUIClick", searchBtn, requestSearch, false)



	local lblPage = guiCreateLabel(margin, height - btn_height - margin, btn_height * 4, btn_height, "Страница:", false, mainWindow)
	guiLabelSetVerticalAlign(lblPage, "center")

	local pageEntry = guiCreateEdit(btn_height * 3 + margin, height - btn_height - margin, btn_height * 3, btn_height, currentPage, false, mainWindow)
	guiEditSetMaxLength(pageEntry, 8)
	addEventHandlerFixClose(pageEntry, true)
	addEventHandlerFixClose(pageEntry, false, "onClientGUIAccepted")
	local function requestPage()
		local page = tonumber(guiGetText(pageEntry))
		if not page then return end

		if page < 1 then
			outputChatBox('Страницы начинаются с 1', 230, 120, 120)
			return
		end

		currentPage = page
		triggerServerEvent("myPlayersListRequest", localPlayer, page)
	end
	addEventHandler("onClientGUIAccepted", pageEntry, requestPage, false)



	local createBtn = guiCreateButton(margin * 2 + btn_height * 6, height - btn_height - margin, width - btn_height * 6 - margin * 2, btn_height, "Добавить нового пользователя", false, mainWindow)
	addEventHandler("onClientGUIClick", createBtn, function()
		closeWindow()
		createOrEditCharacter(nil, true)
	end, false)



	local pressedButton = 0
	local btns = {
		{
			name = "Редактировать",
			func = function(tbl)
				closeWindow()
				createOrEditCharacter(tbl)
			end,
		},
		{
			name = "Удалить",
			func = function(tbl, btn)
				if pressedButton < 3 then
					guiSetText(btn, "Нажмите еще " .. (3 - pressedButton) .. " раза")
					pressedButton = pressedButton + 1
					return
				end
				pressedButton = 0

				triggerServerEvent("myPlayersListDeleteUser", localPlayer, tbl.id)
				
				for k, v in ipairs(dataPlayers) do
					if v.id == tbl.id then
						table.remove(dataPlayers, k)
						break
					end
				end

				updateScrollList()

				destroyMultiSelect()
			end,
		}
	}

	function createScrollButton(idY, v)
		local nick = v.name .. " " .. v.surname
		local btn = guiCreateButton(margin, idY * (btn_height + margin * 0.25), width - margin * 2 - btn_height, btn_height, nick .. ", Адрес: " .. v.address, false, scroll)

		addEventHandler("onClientGUIClick", btn, function() createMultiSelect("(" .. v.id .. ") " .. nick, btns, v) end, false)
		
		local lbl = guiCreateLabel(margin, 0, dxGetTextWidth(v.id), btn_height, v.id, false, btn)
		guiLabelSetHorizontalAlign(lbl, "left")
		guiLabelSetVerticalAlign(lbl, "center")
	end

	updateScrollList()

	addEventHandlerFixClose(mainWindow, false)
end

-- guiSetInputEnabled(false) -- убрать потом, при upgrade test курсор оставался


function playerPressedKey(button, press)
	if button == "l" and (press) and not isMTAWindowActive() then
		if mainWindow == nil then
			triggerServerEvent("myPlayersListRequest", localPlayer)
		else
			if isActiveEditBox then return end
			closeWindow()
		end
	end
end
addEventHandler("onClientKey", root, playerPressedKey)
