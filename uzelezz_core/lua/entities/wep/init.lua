AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("weps.lua")
function ENT:Initialize()
	self:SetUseType( SIMPLE_USE )
	local ply = self:GetOwner()
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	
	if(IsValid(phys))then
		phys:Wake()
	end
	
end

function ENT:Use(taker)
	
	local ply = self:GetOwner()
	local phys = self:GetPhysicsObject()
	
	if (ply:GetNWInt("Otrub") or !IsValid(ply)) then

		if taker:HasWeapon(self.curweapon) then
			taker:GiveAmmo(self.Clip, self.AmmoType)
			self.Clip=0
		else
			taker:Give(self.curweapon, true):SetClip1(self.Clip)
			self:Remove()
			if IsValid(ply) then DespawnWeapon(ply) ply:StripWeapon(ply.curweapon) SavePlyInfo(ply) end
			
		end
		if self.Clip == 0 then
			if self:IsPlayerHolding() then
				taker:DropObject()
			else
				taker:PickupObject(self)
			end
		end
	end
	
end