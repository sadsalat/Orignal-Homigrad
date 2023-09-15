atlaschat.sql = {}
atlaschat.sql.remote = {}

local queue = {}
local firstTime = true
local tableName = "atlaschat_remote"

----------------------------------------------------------------------	
-- Purpose:
--		Initializes the database object.
----------------------------------------------------------------------

function atlaschat.sql.Initialize(callback_success, callback_failed)
	local exists = sql.TableExists(tableName)
	
	if (!exists) then
		sql.Query("CREATE TABLE " .. tableName .. "(address TEXT DEFAULT \"\" NOT NULL UNIQUE, port INTEGER DEFAULT 3306 NOT NULL UNIQUE, user TEXT DEFAULT \"\" NOT NULL UNIQUE, password TEXT DEFAULT \"\" NOT NULL UNIQUE, database TEXT DEFAULT \"atlaschat\" NOT NULL UNIQUE)")
	else
		-- Compatibility operations for sql tables are done here.
		if (!ATLASCHAT_VERSION_PREVIOUS or ATLASCHAT_VERSION_PREVIOUS != ATLASCHAT_VERSION) then
			
			if (ATLASCHAT_VERSION_PREVIOUS) then
			
				-- Insert the "database" field if we're upgrading from version 2.2.0
				if (ATLASCHAT_VERSION_PREVIOUS == 220) then
					sql.Query("ALTER TABLE " .. tableName .. " ADD database TEXT DEFAULT \"atlaschat\" NOT NULL")
					sql.Query("UPDATE " .. tableName .. " SET database = 'atlaschat'")
				end
			end
		end
	end
	
	local data = sql.Query("SELECT address, port, user, password, database FROM " .. tableName)
	
	if (data) then
		data = data[1]
		
		atlaschat.sql.remote = data
		
		if (!mysqloo) then
			local success, message = pcall(require, "mysqloo")
			
			if (!success) then
				ErrorNoHalt("[atlaschat] Could not find the mysqloo module: " .. tostring(message) .. "\n")
			end
		end
		
		if (mysqloo) then
			if (atlaschat.sql.remote.object) then atlaschat.sql.remote.object = nil end
			
			local database = mysqloo.connect(data.address, data.user, data.password, data.database or "atlaschat", tonumber(data.port))

			ServerLog("[atlaschat] Connecting to database...\n")
			
			function database:onConnected()
				ServerLog("[atlaschat] Connection to database established.\n")
				
				atlaschat.sql.remote.object = self
				
				hook.Call("atlaschat.DatabaseConnected", nil, true, firstTime)
				
				firstTime = false
				
				if (callback_success) then
					callback_success()
				end
				
				for k, info in pairs(queue) do
					local queryObject = atlaschat.sql.remote.object:query(info.query)
		
					function queryObject:onSuccess(data)
						if (info.callback_success) then
							info.callback_success(data, self)
						end
					end
					
					function queryObject:onError(message, queryString)
						ServerLog("[atlaschat] The query \"" .. queryString .. "\" failed: " .. message .. "\n")
						
						if (info.callback_failed) then
							info.callback_failed(self, message, queryString)
						end
					end
					
					queryObject:start()
				end
				
				queue = {}
			end
			
			function database:onConnectionFailed(message)
				ServerLog("[atlaschat] MySQL connection failed: " .. tostring(message) .. "\n")
				
				if (callback_failed) then
					callback_failed(message)
				end
				
				-- Fallback to SQLite.
				hook.Call("atlaschat.DatabaseConnected", nil, false, firstTime)
				
				firstTime = false
			end

			database:connect()
		else
			atlaschat.sql.remote = {}
			
			ServerLog("[atlaschat] The module \"gmsv_mysqloo\" was not found. ( Failed to load? )\n")
			ServerLog("[atlaschat] Download and install the module: http://goo.gl/4A4ekH\n")
		end
	else
		hook.Call("atlaschat.DatabaseConnected", nil, false, firstTime)
		
		firstTime = false
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		Initializes a query to the database.
----------------------------------------------------------------------

function atlaschat.sql.Query(query, callback_success, callback_failed)
	if (atlaschat.sql.remote.object) then
		local queryObject = atlaschat.sql.remote.object:query(query)
		
		function queryObject:onSuccess(data)
			if (callback_success) then
				callback_success(data, self)
			end
		end
		
		function queryObject:onError(message, queryString)
			ServerLog("[atlaschat] The query \"" .. queryString .. "\" failed: " .. message .. "\n")
			
			local status = atlaschat.sql.remote.object:status()
			
			if (status == mysqloo.DATABASE_NOT_CONNECTED) then
				table.insert(queue, {query = query, callback_success = callback_success, callback_failed = callback_failed})
				
				atlaschat.sql.Initialize()
			end
			
			if (callback_failed) then
				callback_failed(self, message, queryString)
			end
		end
		
		queryObject:start()
	else
		local data = sql.Query(query)
		
		if (data == false) then
			ServerLog("[atlaschat] The query \"" .. query .. "\" failed: " .. sql.LastError() .. "\n")
			
			if (callback_failed) then
				callback_failed()
			end
		else
			if (callback_success) then
				callback_success(data)
			end
		end
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		Returns true if we're using mysql.
----------------------------------------------------------------------

function atlaschat.sql.IsRemote()
	return atlaschat.sql.remote.object != nil
end

----------------------------------------------------------------------	
-- Purpose:
--		Sends & changes information for mysql.
----------------------------------------------------------------------

util.AddNetworkString("atlaschat.myin")

net.Receive("atlaschat.myin", function(bits, player)
	local isAdmin = player:IsSuperAdmin()
	
	if (isAdmin) then
		local option = util.tobool(net.ReadBit())
		
		if (option) then
			local status = atlaschat.sql.remote.object and atlaschat.sql.remote.object:status() or -1
			local address = atlaschat.sql.remote.address or ""
			local port = tonumber(atlaschat.sql.remote.port) or 3306
			local username = atlaschat.sql.remote.user or ""
			local database = atlaschat.sql.remote.database or "atlaschat"
			
			net.Start("atlaschat.myin")
				net.WriteInt(status, 8)
				net.WriteString("")
				net.WriteString(address)
				net.WriteUInt(port, 16)
				net.WriteString(username)
				net.WriteString(database)
			net.Send(player)
		else
			local address = net.ReadString()
			local port = net.ReadUInt(16)
			local username = net.ReadString()
			local password = net.ReadString()
			local database = net.ReadString()
			
			if (atlaschat.sql.remote.address) then
				sql.Query("UPDATE " .. tableName .. " SET address = " .. sql.SQLStr(address) .. ", port = " .. port .. ", user = " .. sql.SQLStr(username) .. ", password = " .. sql.SQLStr(password) .. ", database = " .. sql.SQLStr(database))
			else
				sql.Query("INSERT INTO " .. tableName .. "(address, port, user, password, database) VALUES(" .. sql.SQLStr(address) .. ", " .. port .. ", " .. sql.SQLStr(username) .. ", " .. sql.SQLStr(password) .. ", " .. sql.SQLStr(database) .. ")")
			end
			
			if (!mysqloo) then
				local success, message = pcall(require, "mysqloo")
				
				if (!success) then
					ErrorNoHalt("[atlaschat] Could not find the mysqloo module: " .. tostring(message) .. "\n")
				end
			end

			net.Start("atlaschat.myin")
				net.WriteInt(mysqloo.DATABASE_CONNECTING, 8)
				net.WriteString("")
				net.WriteString(address)
				net.WriteUInt(port, 16)
				net.WriteString(username)
				net.WriteString(database)
			net.Send(player)
			
			-- Reconnect with the new information.
			atlaschat.sql.Initialize(function()
				net.Start("atlaschat.myin")
					net.WriteInt(mysqloo.DATABASE_CONNECTED, 8)
					net.WriteString("")
					net.WriteString(address)
					net.WriteUInt(port, 16)
					net.WriteString(username)
					net.WriteString(database)
				net.Send(player)
			end,
			
			function(message)
				net.Start("atlaschat.myin")
					net.WriteInt(mysqloo.DATABASE_NOT_CONNECTED, 8)
					net.WriteString(message)
					net.WriteString(address)
					net.WriteUInt(port, 16)
					net.WriteString(username)
					net.WriteString(database)
				net.Send(player)
			end)
		end
	end
end)

-- vk.com/urbanichka