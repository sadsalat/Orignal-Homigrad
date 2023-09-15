ENT.Type 		="anim"
ENT.Base 		="base_gmodentity" 
ENT.PrintName 	="Seat Connector"
ENT.Author 	=wac.author
ENT.Category 	=wac.menu.category

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:wacLink(e)
	if type(e) == "Vehicle" then
		if SERVER then
			self:addVehicle(e)
		end
		return true
	end
end
