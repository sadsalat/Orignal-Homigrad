
include "shared.lua"
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:Initialize()
	self:SetNextShot(0)
	self:SetLastShot(0)
	self:SetAmmo(self.Ammo)
	self.sounds = {}
	for n, p in pairs(self.Sounds) do
		if n != "BaseClass" then
			self.sounds[n] = CreateSound(self, p)
		end
	end
end


function ENT:OnRemove()
	for _, s in pairs(self.sounds) do
		s:Stop()
	end
end


function ENT:getAttacker()
	if IsValid(self.seat) and IsValid(self.seat:GetDriver()) then
		return self.seat:GetDriver()
	end
	return self.aircraft
end


function ENT:trigger(b, seat)
	self.shouldShoot = b
	self.seat = seat
end


function ENT:canFire()
	return true
end


function ENT:fire()
end


function ENT:stop()
end


function ENT:select(bool)
	if !bool then
		self:stop()
	end
end


function ENT:takeAmmo(amount)
	if self:GetAmmo() < amount then return false end
	self:SetAmmo(self:GetAmmo() - amount)
	return true
end


function ENT:Think()
	if IsValid(self.seat) and self:canFire() and self.shouldShoot and self:GetNextShot() <= CurTime() and self:GetAmmo() > 0 then
		if !IsValid(self.seat:GetDriver()) then
			self.shouldShoot = false
		else
			self:fire()
			self:SetLastShot(CurTime())
			self:SetNextShot(self:GetLastShot() + 60/self.FireRate)
		end
	end
	if self:GetNextShot() <= CurTime() then
		self:stop()
	end
	self:NextThink(CurTime())
	return true
end
