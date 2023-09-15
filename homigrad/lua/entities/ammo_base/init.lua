AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel(self.Model)
	self.Entity:SetMaterial(self.ModelMaterial or "")
	self.Entity:SetColor(self.Color or Color(255,255,255))
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self:SetModelScale(self:GetModelScale()*self.ModelScale,0)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(20)
		phys:Wake()
		phys:EnableMotion(true)
	end

end

function ENT:Use( activator )
    if activator:IsPlayer() then 

		activator:GiveAmmo( self.AmmoCount, self.AmmoType, true )
        self:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(90,110), 1, CHAN_ITEM )
        self:Remove()
	end
end