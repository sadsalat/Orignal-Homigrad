
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Sounds = {
	shoot1p = "WAC/cannon/viper_cannon_1p.wav",
	shoot3p = "WAC/cannon/viper_cannon_3p.wav",
	spin = "WAC/cannon/viper_cannon_rotate.wav"
}


function ENT:Initialize()
	self:base("wac_pod_base").Initialize(self)
	self.sounds.spin:ChangePitch(0,0.1)
	self.sounds.spin:ChangeVolume(0,0.1)
	self.sounds.spin:Play()
	self:SetSpinSpeed(0)
	self.basePodThink = self:base("wac_pod_base").Think
end

local empty = {}

function ENT:fire()
	if not self:takeAmmo(1) then return end

	--[[local dir = self.aircraft:getCameraAngles():Forward()
	local pos = self.aircraft:LocalToWorld(self.ShootPos) + dir*self.ShootOffset.x
	local tr = util.QuickTrace(self:LocalToWorld(self.aircraft.Camera.pos) + dir*20, dir*999999999, {self, self.aircraft})
	local ang = (tr.HitPos - pos):Angle()
	
	local b = ents.Create("wac_hc_hebullet")
	ang = ang + Angle(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1))*self.Spray
	b:SetPos(pos)
	b:SetAngles(ang)
	b.col = Color(255,200,100)
	b.Speed = 400
	b.Size = 0
	b.Width = 0
	b:Spawn()
	b.Owner = self:getAttacker()
	b.Explode = function(self,tr)
		if self.Exploded then return end
		self.Exploded = true
		if not tr.HitSky then
			local bt = {}
			bt.Src 		= self:GetPos()
			bt.Dir 		= tr.Normal
			bt.Force	= 30
			bt.Damage	= 60
			bt.Tracer	= 0
			b.Owner:FireBullets(bt)
			local explode = ents.Create("env_physexplosion")
			explode:SetPos(tr.HitPos)
			explode:Spawn()
			explode:SetKeyValue("magnitude", 60)
			explode:SetKeyValue("radius", 10)
			explode:SetKeyValue("spawnflags", "19")
			explode:Fire("Explode", 0, 0)
			timer.Simple(5,function() explode:Remove() end)
			util.BlastDamage(self, self.Owner, tr.HitPos, 40, 20)
			local ed = EffectData()
			ed:SetEntity(self)
			ed:SetAngles(tr.HitNormal:Angle())
			ed:SetOrigin(tr.HitPos)
			ed:SetScale(30)
			util.Effect("wac_impact_m197",ed)
		end
		self.Entity:Remove()
	end]]--

	self.sounds.shoot1p:Stop()
	self.sounds.shoot1p:Play()
	self.sounds.shoot3p:Stop()
	self.sounds.shoot3p:Play()

	local dir = self.aircraft:getCameraAngles():Forward()
	local pos = self.aircraft:LocalToWorld(self.ShootPos) + dir*self.ShootOffset.x
	local tr = util.QuickTrace(self:LocalToWorld(self.aircraft.Camera.pos) + dir*20, dir*999999999, {self, self.aircraft})
	local ang = (tr.HitPos - pos):Angle()

	empty[1] = self
	gred.CreateBullet(self:getAttacker(),pos,dir:Angle(),"wac_base_40mm",empty,nil,false,"white",false,nil,nil,false)

	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetAngles(ang)
	effectdata:SetScale(3)
	util.Effect("MuzzleEffect", effectdata)
end


function ENT:canFire()
	return self:GetSpinSpeed() > 0.8
end


function ENT:Think()
	local s = math.Clamp(self:GetSpinSpeed() + (self.shouldShoot and FrameTime() or -FrameTime())*6, 0, 1)
	self:SetSpinSpeed(s)
	self.sounds.spin:ChangeVolume(s*100, 0.1)
	self.sounds.spin:ChangePitch(s*100, 0.1)
	return self:basePodThink()
end