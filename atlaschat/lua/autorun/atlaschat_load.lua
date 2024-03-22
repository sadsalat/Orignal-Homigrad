AddCSLuaFile()

ATLASCHAT_VERSION = 239

if (SERVER) then
	AddCSLuaFile("atlaschat/cl_init.lua")
	
	include("atlaschat/init.lua")
else
	include("atlaschat/cl_init.lua")
end

if (atlaschat) then
	local version = ""
	
	string.gsub(tostring(ATLASCHAT_VERSION), "(%d)", function(text) version = version .. text .. "." end)
	
	function atlaschat:GetVersion()
		return version:sub(0, 5)
	end
	
	if (CLIENT) then
		MsgC(color_green, "Atlas chat")
	else
		MsgC(color_green, "Atlas chat")
	end
else
	MsgC(color_red, "Atlas chat failed to load!\n")
end

-- vk.com/urbanichka