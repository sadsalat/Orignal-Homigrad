
local PLAYER = FindMetaTable("Player")
function PLAYER:GetViewEntity()
	return GetViewEntity()
end


local VEHICLE = FindMetaTable("Vehicle")

function VEHICLE:GetPassenger()
	for _,p in pairs(player.GetAll()) do
		if p:GetVehicle()==self then
			return p
		end
	end
end

