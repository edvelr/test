
MyTestSQL.connect()

-- setTimer(function()
-- 	MyTestSQL.query("DROP TABLE `player_data`;")

-- 	setTimer(function()
-- 		MyTestSQL.query("CREATE TABLE IF NOT EXISTS `player_data` (`id` int(11) NOT NULL, `name` varchar(50) NOT NULL, `surname` varchar(50) NOT NULL, `address` varchar(100) NOT NULL);")
-- 		-- MyTestSQL.query("ALTER TABLE `player_data` ADD PRIMARY KEY (`id`);") -- не работает на mysqlite
-- 		-- MyTestSQL.query("ALTER TABLE `player_data` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;") -- не работает на mysqlite
-- 	end, 1000, 1)
-- 		setTimer(function()
-- 			local function randomString(length)
-- 				local s = ""
-- 				for i = 1, math.random(3, length or 12) do
-- 					s = s .. utf8.char(i == 1 and math.random(65, 90) or math.random(97, 122))
-- 				end
-- 				return s
-- 			end
-- 			for i = 1, 10000 do
-- 				MyTestSQL.queryExec("INSERT INTO player_data (id, name, surname, address) VALUES(?, ?, ?, ?);", i, randomString(), randomString(), randomString(50))
-- 			end
-- 		end, 1000, 1)
-- end, 1000, 1)






local delayUse = {}
local function delay(player, cd)
	local serial = player -- getAccountSerial(getPlayerAccount(player)) or 0
	local rt = getRealTime().timestamp
	if (delayUse[serial] or 0) > rt then
		outputChatBox("Попробуйте чуть позже", client, 230, 120, 120)
		return true
	end
	delayUse[serial] = rt + (cd or 2)
end

-- очистка таблицы
setTimer(function()
	local rt = getRealTime().timestamp

	for serial, time in pairs(delayUse) do
		if rt > time then
			delayUse[serial] = nil
		end
	end
end, 120000, 0)



local function callbackRequest(data, player)
	if data then
		triggerClientEvent(player, "myPlayersListLoad", player, toJSON(data))
	else
		outputChatBox("Данные отсутствуют", player, 230, 230, 230)
	end
end

local function myPlayersListRequest(page)
	if delay(client) then return end

	local start = 0

	page = tonumber(page)

	if page and page > 1 then
		start = (page - 1) * 100 - 1
	end

	MyTestSQL.query("SELECT * FROM `player_data` LIMIT " .. start .. ", 100;", callbackRequest, {client})
end
addEvent("myPlayersListRequest", true)
addEventHandler("myPlayersListRequest", root, myPlayersListRequest)



local function myPlayersListDeleteUser(id)
	if delay(client, 1) then return end

	id = tonumber(id)
	if not id or id < 1 then return end

	outputChatBox("Пользователь успешно удалён", client, 120, 120, 230)
	MyTestSQL.queryExec("DELETE FROM `player_data` WHERE `id` = ?;", id)
end
addEvent("myPlayersListDeleteUser", true)
addEventHandler("myPlayersListDeleteUser", root, myPlayersListDeleteUser)



local function myPlayersListSaveUser(id, name, surname, address)
	if delay(client, 1) then return end

	id = tonumber(id)
	if not id or id < 1 then return end

	if not checkValidName(name) then return end
	if not checkValidName(surname) then return end
	if not checkValidAddress(address) then return end

	outputChatBox("Пользователь успешно сохранён", client, 120, 230, 120)
	MyTestSQL.queryExec("UPDATE `player_data` SET `name` = ?, `surname` = ?, `address` = ? WHERE `id` = ?;", name, surname, address, id)
end
addEvent("myPlayersListSaveUser", true)
addEventHandler("myPlayersListSaveUser", root, myPlayersListSaveUser)

local function myPlayersListAddUser(id, name, surname, address)
	if delay(client, 1) then return end

	id = tonumber(id) -- оставил id потому что auto_increment не заработал
	if not id or id < 1 then return end

	if not checkValidName(name) then return end
	if not checkValidName(surname) then return end
	if not checkValidAddress(address) then return end

	outputChatBox("Пользователь успешно добавлен", client, 120, 230, 120)
	MyTestSQL.queryExec("INSERT INTO player_data (id, name, surname, address) VALUES(?, ?, ?, ?);", id, name, surname, address)
end
addEvent("myPlayersListAddUser", true)
addEventHandler("myPlayersListAddUser", root, myPlayersListAddUser)



local function myPlayersListSearchUser(id, name, surname, address)
	if delay(client) then return end

	if id then
		MyTestSQL.query("SELECT * FROM `player_data` WHERE `id` = ?;", callbackRequest, {client}, id)
	elseif address then
		address = '%' .. address .. '%'
		MyTestSQL.query("SELECT * FROM `player_data` WHERE `address` LIKE ?;", callbackRequest, {client}, address)
	elseif name and surname then
		name = '%' .. name .. '%'
		surname = '%' .. surname .. '%'

		MyTestSQL.query("SELECT * FROM `player_data` WHERE `name` LIKE ? AND `surname` LIKE ?;", callbackRequest, {client}, name, surname)
	elseif name then
		name = '%' .. name .. '%'

		MyTestSQL.query("SELECT * FROM `player_data` WHERE `name` LIKE ? OR `surname` LIKE ?;", callbackRequest, {client}, name, name)
	end
end
addEvent("myPlayersListSearchUser", true)
addEventHandler("myPlayersListSearchUser", root, myPlayersListSearchUser)