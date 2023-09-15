
AddCSLuaFile("shared.lua")

ENT.Base = "wac_pod_base"
ENT.Type = "anim"

ENT.PrintName = "Hydra 70 Pod"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Ammo = 14
ENT.FireRate = 120
ENT.Sequential = true
ENT.Pods = {
	Vector(40.25, 36.33, 32.93),
	Vector(40.25, -36.33, 32.93)
}


function ENT:Initialize()
	self:base("wac_pod_base").Initialize(self)
	self.sounds = {
		fire = CreateSound(self, "HelicopterVehicle/MissileShoot.mp3")
	}
end


function ENT:fireRocket(pos, ang)
	if !self:takeAmmo(1) then return end
	local rocket = ents.Create("wac_hc_rocket")
	rocket:SetPos(self:LocalToWorld(pos))
	rocket:SetAngles(ang)
	rocket.Owner = self.seat:GetDriver() or self.aircraft
	rocket.Damage = 150
	rocket.Radius = 200
	rocket.Speed = 750
	rocket.Drag = Vector(0,1,1)
	rocket.TrailLength = 200
	rocket.Scale = 15
	rocket.SmokeDens = 1
	rocket.Launcher = self.aircraft
	rocket:Spawn()
	rocket:Activate()
	rocket:StartRocket()
	local ph = rocket:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetVelocity(self:GetVelocity())
		ph:AddAngleVelocity(Vector(30,0,0))
	end
	self.sounds.fire:Stop()
	self.sounds.fire:Play()
	constraint.NoCollide(self.aircraft, rocket, 0, 0)
end



function ENT:fire()
	if self.Sequential then
		self.currentPod = self.currentPod or 1
		self:fireRocket(self.Pods[self.currentPod], self:GetAngles())
		self.currentPod = (self.currentPod == #self.Pods and 1 or self.currentPod + 1)
	else
		for _, pos in pairs(self.Pods) do
			self:fireRocket(pos, self:GetAngles())
		end
	end
end



