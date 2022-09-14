
local config = {
	databaseType = "sqlite",
	host = "file.db", -- "localhost",
	-- username = "test",
	-- password = "123",
	-- options = ""
}

if not MyTestSQL then MyTestSQL = {} end

function MyTestSQL.connect()
	local db = dbConnect(config.databaseType, config.host, config.username, config.password, config.options)

	if db == false then
		outputDebugString("SQL not connected")
	end

	MyTestSQL._db = db
	return db
end

function MyTestSQL.getDB()
	return MyTestSQL._db
end

local function standartCallback(queryHandle, callback, ...)
	local result, num_affected_rows, last_insert_id = dbPoll(queryHandle, 30)

	if result == nil then
		outputConsole("dbPoll result not ready yet")
	elseif result == false then
		local error_code, error_msg = num_affected_rows, last_insert_id
		outputConsole("dbPoll failed. Error code: " .. tostring(error_code) .. "  Error message: " .. tostring(error_msg))
	-- else
	-- 	outputConsole("dbPoll succeeded. Number of affected rows: " .. tostring(num_affected_rows) .. "  Last insert id: " .. tostring(last_insert_id))
	end

	if callback then
		return callback(result, ...)
	end
end
function MyTestSQL.query(query, callback, argsCallback, ...)
	return dbQuery(function(queryHandle, ...) standartCallback(queryHandle, callback, ...) end, argsCallback or {}, MyTestSQL.getDB(), query, ...)
end
function MyTestSQL.queryExec(query, ...)
	return dbExec(MyTestSQL.getDB(), query, ...)
end

