
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:SpawnFunction(p, tr)
	if (!tr.Hit) then return end
	local e = ents.Create(ClassName)
	e:SetPos(tr.HitPos + tr.HitNormal*60)
	e.Owner = p
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Initialize()
	self:base("wac_pl_base").Initialize(self)
	self.basePhysicsUpdate = self:base("wac_pl_base").PhysicsUpdate
end

function ENT:PhysicsUpdate(ph)
	self:basePhysicsUpdate(ph)
	local lvel = self:WorldToLocal(self:GetPos() + self:GetVelocity())
	self:GetPhysicsObject():AddAngleVelocity(Vector(
		0, 5-math.Clamp(math.abs(lvel.x)/100, 0, 5), 0
	)*FrameTime()*60)
end
