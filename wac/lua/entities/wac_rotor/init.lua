
include "shared.lua"

AddCSLuaFile "shared.lua"
AddCSLuaFile "cl_init.lua"

ENT.throttle = 0
ENT.dir = 1
ENT.targetVel = 400

function ENT:Initialize()
	self.Entity:SetModel(self.model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
end


function ENT:PhysicsUpdate(ph)
	local diff = self.targetVel - ph:GetAngleVelocity().z*self.dir
	ph:AddVelocity(self:GetUp()*math.Clamp(diff, 0, 1)*self.throttle/200*self.force)
end

