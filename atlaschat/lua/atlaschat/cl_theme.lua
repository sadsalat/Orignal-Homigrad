atlaschat.theme = {}

local stored = {}

if (CLIENT) then
	atlaschat.themeConfig = atlaschat.config.New("Chatbox theme", "theme", "default", true)
	
	local skin = {}
	
	skin.colTextEntryText = color_white
	skin.Colours = {Label = {}}
	skin.Colours.Label.Default = color_white
	
	derma.DefineSkin("atlaschat", "", skin)
	
	function atlaschat.themeConfig:OnChange(value, previous)
		if (previous) then
			local data = stored[previous]
			
			if (data) then
				for k, v in pairs(data) do
					local type = type(v)
					
					if (type == "Panel") then
						stored[value][k] = v
					end
				end
			end
		end
		
		if (stored[value] and ValidPanel(stored[value].panel)) then
			skin.colTextEntryText = stored[value].color.generic_label
			skin.Colours.Label.Default = stored[value].color.generic_label
			
			atlaschat.theme.Call("OnThemeChange")
		end
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function atlaschat.theme.Set(field, value)
	local current = atlaschat.themeConfig:GetString()
	
	stored[current][field] = value
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function atlaschat.theme.GetCurrent()
	local current = atlaschat.themeConfig:GetString()
	
	return stored[current]
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function atlaschat.theme.GetStored()
	return stored
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function atlaschat.theme.GetValue(field)
	local current = atlaschat.themeConfig:GetString()
	
	if (stored[current]) then
		local value = stored[current][field]

		return value
	end
end

----------------------------------------------------------------------		
-- Purpose:
--		
----------------------------------------------------------------------

function atlaschat.theme.Call(name, ...)
	local current = atlaschat.themeConfig:GetString()
	local data = stored[current]
	
	if (data) then
		local callback = data[name]
		
		if (callback) then
			local a, b, c, d, e, f, g = callback(data, ...)
			
			return a, b, c, d, e, f, g
		end
	else
		ErrorNoHalt("Missing function \"" .. name .. "\" for theme \"" .. current .. "\". Reverting to default.\n")
		
		atlaschat.themeConfig:SetString("default")
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function atlaschat.theme.Register(theme)
	stored[theme.unique] = theme
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------
 
local files = file.Find("atlaschat/themes/*.lua", "LUA")
local compat = theme

for k, file in pairs(files) do
	if (SERVER) then
		AddCSLuaFile("themes/" .. file)
	elseif (CLIENT) then
		theme = {}
		
		include("themes/" .. file)
		
		atlaschat.theme.Register(theme)
		
		theme = nil
	end
end

if (CLIENT) then
	local istable = istable
	
	local function getData(destination, data)
		for k, v in pairs(data) do
			if (istable(v) and istable(destination[k])) then
				getData(destination[k], v)
			else
				if (destination[k] == nil) then
					destination[k] = v
				end
			end
		end
	end
	
	local function derive(unique, from)
		local base = stored[from]

		if (base.base and !base.derived) then
			derive(base.unique, base.base)
		end
		
		getData(stored[unique], base)
		
		stored[unique].derived = true
		stored[unique].baseClass = base
	end
	
	function atlaschat.theme.DeriveThemes()
		for unique, data in pairs(stored) do
			if (data.base) then
				derive(unique, data.base)
			end
		end
	end
end

theme = compat
timer.Simple(0.5, function() atlaschat.theme.loaded = true end)

-- vk.com/urbanichka