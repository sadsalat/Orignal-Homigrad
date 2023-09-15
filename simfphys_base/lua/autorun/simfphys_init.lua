simfphys = istable( simfphys ) and simfphys or {}

AddCSLuaFile("simfphys/init.lua")
include("simfphys/init.lua")

function simfphys:GetVersion()
	return simfphys.VERSION or 1.2
end

function simfphys:CheckUpdates()
	http.Fetch("https://raw.githubusercontent.com/Blu-x92/simfphys_base/master/lua/simfphys/base_functions.lua", function(contents,size) 
		local Entry = string.match( contents, "simfphys.VERSION%s=%s%d+" )

		if Entry then
			simfphys.VERSION_GITHUB = tonumber( string.match( Entry , "%d+" ) ) or 0
		end

		if simfphys.VERSION_GITHUB == 0 then
			print("[simfphys] latest version could not be detected, You have Version: "..simfphys:GetVersion())
		else
			if simfphys:GetVersion() >= simfphys.VERSION_GITHUB then
				print("[simfphys] is up to date, Version: "..simfphys:GetVersion())
			else
				print("[simfphys] a newer version is available! Version: "..simfphys.VERSION_GITHUB..", You have Version: "..simfphys:GetVersion())
				print("[simfphys] get the latest version at https://github.com/Blu-x92/simfphys_base")

				if CLIENT then 
					timer.Simple(18, function() 
						chat.AddText( Color( 255, 0, 0 ), "[simfphys] a newer version is available!" )
					end)
				end
			end
		end
	end)
end

if CLIENT then
	hook.Add( "InitPostEntity", "!!!simfphyscheckupdates", function()
		timer.Simple(20, function() simfphys.CheckUpdates() end)
	end )

	return
end

resource.AddWorkshop("771487490")

hook.Add( "InitPostEntity", "!!!simfphyscheckupdates", function()
	timer.Simple(20, function()
		simfphys.CheckUpdates()
	end)
end )
