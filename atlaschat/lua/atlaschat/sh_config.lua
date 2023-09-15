atlaschat.config = {}

local stored = {}
local objects = {}
local config = {}
config.__index = config

local saved = file.Read("atlaschat_config.txt", "DATA")
local nextSave = nil

saved = saved and von.deserialize(saved) or {}

----------------------------------------------------------------------
-- Purpose:
--		 Creates a new config.
----------------------------------------------------------------------

function atlaschat.config.New(text, name, default, save, disableCommand, server, force)
	local object
	local exists = false
	
	if (stored[name]) then
		object = stored[name]
		exists = true
	else
		object = {}
	end
	
	if (!exists) then
		setmetatable(object, config)
	end
	
	object.text = text
	object.name = name
	object.value = default
	object.save = save
	object.default = default
	object.server = server
	object.force = force
	
	stored[name] = object
	
	if (!disableCommand) then
		concommand.Add("atlaschat_" .. name, function(player, command, arguments)
			local value = arguments[1]
			
			if (value) then
				local config = stored[string.sub(command, string.len("atlaschat") +2)]
				local previous = config.value
				
				config.value = value
				
				if (config.save) then
					saved[config.name] = config.value
					
					nextSave = CurTime() +0.5
				end
				
				if (config.OnChange) then
					config:OnChange(config.value, previous)
				end
			end
		end)
	end
	
	-- Load saved value.
	if (!force) then
		if (save and saved[name] != nil) then
			object.value = saved[name]
		end
		
		saved[name] = object.value
	end
	
	if (!exists) then
		object.index = table.insert(objects, object)
	end
	
	return object
end

----------------------------------------------------------------------
-- Purpose:
--		 Returns all of the config stuff.
----------------------------------------------------------------------

function atlaschat.config.GetStored()
	return stored
end

----------------------------------------------------------------------
-- Purpose:
--		 Returns a config.
----------------------------------------------------------------------

function atlaschat.config.Get(name)
	return stored[name]
end

----------------------------------------------------------------------
-- Purpose:
--		 Resets all values to their defaults.
----------------------------------------------------------------------

function atlaschat.config.ResetValues()
	for i = 1, #objects do
		local object = objects[i]
		
		object:SetValue(object.default)
	end
end

----------------------------------------------------------------------
-- Purpose:
--		 Quick Set and Get functions.
----------------------------------------------------------------------

local SetGet = function(object, type, mod)
	object["Get" .. type] = function(self) if (mod) then return mod(self.value) else return self.value end end
	object["Set" .. type] = function(self, argument, noSave)
		local previous = self.value
		
		if (mod) then
			self.value = mod(argument)
		else
			self.value = argument
		end
		
		if (!self.force and self.save and !noSave) then
			saved[self.name] = self.value
			
			nextSave = CurTime() +0.5
		end
		
		if (self.OnChange) then
			self:OnChange(self.value, previous)
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		 Quick Set and Get functions.
----------------------------------------------------------------------

local tobool, tonumber, tostring = tobool, tonumber, tostring

SetGet(config, "Value")
SetGet(config, "Bool", tobool)
SetGet(config, "Int", tonumber)
SetGet(config, "String", tostring)

----------------------------------------------------------------------
-- Purpose:
--		 Returns the text of this config.
----------------------------------------------------------------------

function config:GetText()
	return self.text
end

----------------------------------------------------------------------
-- Purpose:
--		 Returns the name of this config.
----------------------------------------------------------------------

function config:GetName()
	return self.name
end

----------------------------------------------------------------------
-- Purpose:
--		 This is just so it doesn't write as soon as the value
-- 		 changes, aka 1000 times.
----------------------------------------------------------------------

hook.Add("Tick", "atlaschat.config.Tick", function()
	if (nextSave and nextSave <= CurTime()) then
		file.Write("atlaschat_config.txt", von.serialize(saved), "DATA")

		nextSave = nil
	end
end)

if (CLIENT) then

	----------------------------------------------------------------------
	-- Purpose:
	--		 Receive a config value from the server.
	----------------------------------------------------------------------
	
	net.Receive("atlaschat.sndcfg", function(bits)
		local unique = net.ReadString()
		local type = net.ReadUInt(8)
		local value = net.ReadType(type)
		local object = stored[unique]

		if (object and object.server) then
			object:SetValue(value, true)
		end
	end)
end

if (SERVER) then

	----------------------------------------------------------------------
	-- Purpose:
	--		 Serverside config values.
	----------------------------------------------------------------------
	
	util.AddNetworkString("atlaschat.gtcfg")
	util.AddNetworkString("atlaschat.sndcfg")
	
	net.Receive("atlaschat.gtcfg", function(bits, player)
		local isAdmin = player:IsAdmin()
		
		if (isAdmin) then
			local unique = net.ReadString()
			local type = net.ReadUInt(8)
			local value = net.ReadType(type)
			local object = stored[unique]
			
			if (object and object.server) then
				object:SetValue(value, !game.IsDedicated())
	
				net.Start("atlaschat.sndcfg")
					net.WriteString(unique)
					net.WriteType(value)
				net.Broadcast()
			end
		end
	end)
	
	----------------------------------------------------------------------
	-- Purpose:
	--		 Syncs the variables.
	----------------------------------------------------------------------
	
	function atlaschat.config.SyncVariables(player)
		for unique, object in pairs(stored) do
			if (object.server and !object.force) then
				local value = object:GetValue()
				
				net.Start("atlaschat.sndcfg")
					net.WriteString(unique)
					net.WriteType(value)
				net.Send(player)
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		 Default global configuration variables.
----------------------------------------------------------------------

atlaschat.enableAvatars = atlaschat.config.New("Enable avatars", "avatars", true, true, true, true)
atlaschat.enableWyoziteTags = atlaschat.config.New("Enable wyozite tags", "wyozite_tags", true, true, true, true)
atlaschat.enableRankIcons = atlaschat.config.New("Enable usergroup icon", "rank_icons", true, true, true, true)
atlaschat.enableRankTitle = atlaschat.config.New("Enable usergroup title", "rank_title", true, true, true, true)
atlaschat.darkrpChat = atlaschat.config.New("Show titles & icons everywhere (DARKRP)", "tidarkrp", false, true, true, true)

-- vk.com/urbanichka