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
		--phys:SetMass(150)
	end

	self:GetOwner().wep = self

end

function ENT:Use(taker)

	local ply = self:GetOwner()
	local phys = self:GetPhysicsObject()
	
	local lootInfo = IsValid(ply) and ply.Info or IsValid(self.rag) and self.rag.Info
	if (ply.Otrub or not ply:IsPlayer() or not ply:Alive()) then
		local rag = self.rag
		
		if taker:HasWeapon(self.curweapon) then
			if lootInfo then
				taker:GiveAmmo(lootInfo.Weapons[self.curweapon].Clip1, lootInfo.Weapons[self.curweapon].AmmoType)
				lootInfo.Weapons[self.curweapon].Clip1 = 0
			else
				taker:GiveAmmo(self.Clip, self.AmmoType)
				self.Clip = 0
			end
		else
			--taker.slots = taker.slots or {}
			--if not taker.slots[weapons.Get(self.curweapon).TwoHands and 3 or 2] then
				self:Remove()
				taker:Give(self.curweapon, true):SetClip1(lootInfo and lootInfo.Weapons[self.curweapon].Clip1 or self.Clip or 0)
				if lootInfo then lootInfo.Weapons[self.curweapon] = nil end
				if IsValid(ply) then ply:StripWeapon(ply.curweapon) SavePlyInfo(ply) end
			--end
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