
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


ENT.Sounds = {
	shoot = "Warkanum/minigun_shoot.wav",
	stop = "Warkanum/minigun_wind_stop.wav",
}

local empty = {}

function ENT:fireBullet(pos)
	if !self:takeAmmo(1) then return end
	--[[local bullet = {}
	bullet.Num = 1
	bullet.Src = self.aircraft:LocalToWorld(pos)
	bullet.Dir = self:GetForward()
	bullet.Spread = Vector(0.015,0.015,0)
	bullet.Tracer = self.Tracer
	bullet.Force = self.Force
	bullet.Damage = self.Damage
	bullet.Attacker = self:getAttacker()
	local effectdata = EffectData()
	effectdata:SetOrigin(bullet.Src)
	effectdata:SetAngles(self:GetAngles())
	effectdata:SetScale(1.5)
	util.Effect("MuzzleEffect", effectdata)
	self.aircraft:FireBullets(bullet)]]--

	local origin = self.aircraft:LocalToWorld(pos)
	local dir = self:GetForward()
	empty[1] = self
	gred.CreateBullet(self:getAttacker(),origin,dir:Angle(),"wac_base_20mm",empty,nil,false,"white",false,nil,nil,false)

	local effectdata = EffectData()
	effectdata:SetOrigin(origin)
	effectdata:SetAngles(self:GetAngles())
	effectdata:SetScale(3)
	util.Effect("MuzzleEffect",effectdata)
end

function ENT:fire()
	if !self.shooting then
		self.shooting = true
		self.sounds.stop:Stop()
		self.sounds.shoot:Play()
	end

	if self.Sequential then
		self.currentPod = self.currentPod or 1
		self:fireBullet(self.Pods[self.currentPod], self:GetAngles())
		self.currentPod = (self.currentPod == #self.Pods and 1 or self.currentPod + 1)
	else
		for _, pos in pairs(self.Pods) do
			self:fireBullet(pos, self:GetAngles())
		end
	end

	self:SetNextShot(self:GetLastShot() + 60/self.FireRate)
end

function ENT:stop()
	if self.shooting then
		self.sounds.shoot:Stop()
		self.sounds.stop:Play()
		self.shooting = false
	end				
end
