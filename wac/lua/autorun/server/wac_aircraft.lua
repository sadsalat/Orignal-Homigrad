
include "wac/aircraft.lua"

AddCSLuaFile("autorun/client/wac_aircraft.lua");
AddCSLuaFile("autorun/client/wac_aircraft_dev.lua");


wac.aircraft.cvars = {
	startSpeed = CreateConVar("wac_air_startspeed", 1, {FCVAR_ARCHIVE}),
	nodamage = CreateConVar("wac_air_nodamage", 0, {FCVAR_ARCHIVE}),
}


if not game.SinglePlayer() then
	util.AddNetworkString("wac_admin_setting")
	net.Receive("wac_admin_setting", function(len,pl)
		if pl:IsAdmin() or pl:IsSuperAdmin() then
			local name=net.ReadString()
			local found=false
			for k,v in pairs(wac.aircraft.cvars) do
				if v:GetName()==name then
					found=true
					break
				end
			end
			if found then
				local val=net.ReadFloat()
				RunConsoleCommand(name,val)
			end
		end
	end)
end


wac.hook("SetPlayerAnimation", "wac_cl_heliseat_animation", function(pl, anim)
	 if pl:InVehicle() then
	 local v = pl:GetVehicle()
		if string.find(v:GetModel(), "models/nova/airboat_seat") and v:GetNWEntity("wac_aircraft"):IsValid() then 
			local seq = pl:LookupSequence("sit")	
			pl:SetPlaybackRate(1.0)
			pl:ResetSequence(seq)
			pl:SetCycle(0)
			return true
		end
	end
end)


wac.hook("PlayerLeaveVehicle", "wac_aircraft_leavevehicle", function(player, vehicle)
	if IsValid(vehicle.wac_aircraft) then
		vehicle.wac_aircraft:playerExit(player, vehicle)
	end
end)

