
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/popcan01a.mdl")		
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self.Entity:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:SetMass(5)
	end	
	if (self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:EnableGravity(true)
	end
	self.oldpos=self:GetPos()-self:GetAngles():Forward()*self.Speed
	self:SetNotSolid(true)
	self.cbt={}
	self.cbt.health=5000
	self.cbt.armor=500
	self.cbt.maxhealth=5000
	self:SetNWInt("size", self.Size)
	self:SetNWFloat("width", self.Width)
	local col=Color(self.col.r,self.col.g,self.col.b,255)
	self:SetColor(col)
	col.a=50
	local trail=util.SpriteTrail(self.Entity, 0, col, false, self.Size/2, self.Size/8, self.Size/40, 1/self.Size/2*0.5, "trails/smoke.vmt")	
	self.startTime=CurTime()
	self.canThink=true
	self.IsBullet=true
	self:NextThink(CurTime())
end

ENT.Damage = 100
ENT.Radius = 125

ENT.Explode=function(self,tr)
	if self.Exploded then return end
	self.Exploded = true
	if !tr.HitSky then
		self:GetOwner() = self:GetOwner() or self.Entity
		local explode=ents.Create("env_physexplosion")
		explode:SetPos(tr.HitPos)
		explode:SetOwner(self:GetOwner())
		explode:Spawn()
		explode:SetKeyValue("magnitude", self.Damage/4)
		explode:SetKeyValue("radius", self.Radius)
		explode:Fire("Explode", 0, 0)
		timer.Simple(5,function() explode:Remove() end)
		util.BlastDamage(self, self:GetOwner(), tr.HitPos, self.Radius, self.Damage)

		--[[net.Start("gred_net_createparticle")
		
		if self:WaterLevel() >= 1 then
			net.WriteString("ins_water_explosion") -- FIXME : Optimize
			net.WriteVector(tr.HitPos)
			net.WriteAngle(tr.HitNormal:Angle())
			net.WriteBool(false)
		else
			net.WriteString("doi_artillery_explosion") -- FIXME : Optimize
			net.WriteVector(tr.HitPos)
			net.WriteAngle(tr.HitNormal:Angle() or angle_zero)
			net.WriteBool(tr.HitNormal:Angle() and true or false)
		end
		
		net.Broadcast()]]--

		local fx = EffectData()
		fx:SetNormal(tr.HitNormal)

		fx:SetOrigin(tr.HitPos)
		fx:SetScale(self.Radius / 10)
		fx:SetStart(Vector(0,0,0))
		fx:SetSurfaceProp(tr.SurfaceProps)
		util.Effect("chloeimpact_groundcrack",fx,true,true)
	end

	self.Entity:Remove()
end

function ENT:PhysicsUpdate(ph)
	if !util.IsInWorld(self:GetPos()) then self:Remove() end
	local speed=self.Speed
	if !self.oldpos then self:Remove() return end
	local pos=self:GetPos()
	local difference = (pos - self.oldpos)
	if !self.canThink or speed<50 or self.NoTele then
		self:SetVelocity(difference*1000)
	end
	self.oldpos = pos
	local trace = {}
	trace.start = pos
	trace.endpos = pos+difference
	trace.filter = self.Entity
	trace.mask=CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER + CONTENTS_WINDOW + CONTENTS_WATER
	local tr = util.TraceLine(trace)
	if tr.Hit then
		self.Explode(self,tr)
	elseif (self.canThink or speed>50) and !self.NoTele then
		self.Entity:SetPos(pos + difference)
	end
end

function ENT:Think()
	self.phys:Wake()
end
