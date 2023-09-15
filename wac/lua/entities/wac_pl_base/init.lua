
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.IgnoreDamage = true
ENT.UsephysRotor = true
ENT.Submersible	= false
ENT.CrRotorWash	= true
ENT.RotorWidth = 10
ENT.rotorDir	= 1
ENT.BackRotorDir = 1
ENT.rotorPos	= Vector(83, 0, 0.5)
ENT.BackRotorPos = Vector(-400,5,137)
ENT.Weight = 800
ENT.CrRotorWash = false

ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, 0, 0),
		Right = Vector(0, 0, 50), -- Rotate towards flying direction
		Top = Vector(0, -50, 0)
	},
	Lift = {
		Front = Vector(0, 0, 50), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.5)
	},
	Rail = Vector(1, 5, 30),
	AngleDrag = Vector(0.01, 0.01, 0.01),
}

ENT.Agility = {
	Thrust = 5.7
}


function ENT:addRotors()
	self.rotor = ents.Create("prop_physics")
	self.rotor:SetModel("models/props_junk/sawblade001a.mdl")
	self.rotor:SetPos(self:LocalToWorld(self.rotorPos))
	self.rotor:SetAngles(self:GetAngles() + Angle(90, 0, 0))
	self.rotor:SetOwner(self.Owner)
	self.rotor:Spawn()
	self.rotor:SetNotSolid(true)
	self.rotor.phys = self.rotor:GetPhysicsObject()
	self.rotor.phys:EnableGravity(false)
	self.rotor.phys:SetMass(5)
	--self.rotor.phys:EnableDrag(false)
	self.rotor:SetNoDraw(true)
	self.rotor.health = 100
	self.rotor.wac_ignore = true
	if self.RotorModel then
		local e = ents.Create("wac_hitdetector")
		e:SetModel(self.RotorModel)
		e:SetPos(self:LocalToWorld(self.rotorPos))
		e:SetAngles(self:GetAngles())
		
		e.TouchFunc = function(e)
			local ph = e:GetPhysicsObject()
			if ph:IsValid() then
				local pass=true
				for k,p in pairs(self.passengers) do
					if p==e then pass=false end
				end
				for _, ent in pairs(self.entities) do
					if ent == e then pass = false end
				end
				if pass and e != self and !string.find(e:GetClass(), "func*") and IsValid(self.rotor) and e:GetMoveType() != MOVETYPE_NOCLIP then
					local rotorVel = self.rotor:GetPhysicsObject():GetAngleVelocity():Length()
					local dmg=(rotorVel*rotorVel + ph:GetVelocity():Length()*ph:GetVelocity():Length())/100000
					ph:AddVelocity((e:GetPos()-self.rotor:GetPos())*dmg/e:GetPhysicsObject():GetMass()*10)
					self:DamageBigRotor(dmg)
					e:TakeDamage(dmg, IsValid(self.passengers[1]) and self.passengers[1] or self.Entity, self.Entity)
				end
			end
		end
		
		e:Spawn()
		e:SetOwner(self.Owner)
		e:SetParent(self.rotor)
		e.wac_ignore = true
		local obb=e:OBBMaxs()
		self.RotorWidth=(obb.x>obb.y and obb.x or obb.y)
		self.RotorHeight=obb.z
		self.rotorModel=e
		self:AddOnRemove(e)
	end
	constraint.Axis(self.Entity, self.rotor, 0, 0, self.rotorPos, Vector(0,0,1), 0,0,0.01,1)
	self:AddOnRemove(self.rotor)
	
end

function ENT:PhysicsUpdate(ph)
	if self.Lastphys==CurTime() then return end
	local vel = ph:GetVelocity()	
	local pos = self:GetPos()
	local ri = self:GetRight()
	local up = self:GetUp()
	local fwd = self:GetForward()
	local ang = self:GetAngles()
	local dvel = vel:Length()
	local lvel = self:WorldToLocal(pos+vel)
	
	local hover = self:calcHover(ph,pos,vel,ang)

	local throttle = self.controls.throttle/2 + 0.5

	local phm = FrameTime()*66 --(wac.aircraft.cvars.doubleTick:GetBool() and 2 or 1)
	
	self.arcade = (
		IsValid(self.passengers[1])
		and self.passengers[1]:GetInfo("wac_cl_air_arcade")
		or 0
	)

	if !self.disabled then
	
		if self.rotor and self.rotor.phys and self.rotor.phys:IsValid() then
			self.rotorRpm = math.Clamp(self.rotor.phys:GetAngleVelocity().z/3500*self.rotorDir,-1,1)
			if self.active and self.rotor:WaterLevel() <= 0 then
				self.engineRpm = math.Clamp(self.engineRpm+FrameTime(),0,1)
				self.rotor.phys:AddAngleVelocity(Vector(0,0,self.engineRpm*30 + throttle*self.engineRpm*20)*self.rotorDir*phm)
			else
				self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
			end
		end
	end
	
	if self.rotor then
		local brake = (throttle+1)*self.rotorRpm/900+self.rotor.phys:GetAngleVelocity().z/100
		self.rotor.phys:AddAngleVelocity(Vector(0,0,-brake + lvel.x*lvel.x/500000)*self.rotorDir*phm)
	end

	local aeroVelocity, aeroAng = self:calcAerodynamics(ph)

	local controlAng =
		Vector(
			(self.controls.roll+hover.r)*lvel.x/400,
			(self.controls.pitch+hover.p)*lvel.x/400,
			self.controls.yaw*1.5*math.Clamp(lvel.x/20, 0, 1)
		) * self.Agility.Rotate * (1+self.arcade)

	local controlThrottle = fwd * (throttle * self.rotorRpm + self.rotorRpm/10) * self.Agility.Thrust
	
	ph:AddAngleVelocity((aeroAng + controlAng)*phm)
	ph:AddVelocity((aeroVelocity + controlThrottle)*phm)

	for _,e in pairs(self.wheels) do
		if IsValid(e) and e:GetPhysicsObject():IsValid() then
		local ph=e:GetPhysicsObject()
			local wpos = self:WorldToLocal(e:GetPos())
			
			local xpositive = (wpos.x >= 0 and 1 or -1)
			local ypositive = (wpos.y >= 0 and 1 or -1)

			e:GetPhysicsObject():AddVelocity(
				(self:LocalToWorld(Vector(0, 0,
					(math.abs(wpos.y) ^ (1/3))*ypositive*controlAng.x
					- (math.abs(wpos.x) ^ (1/3))*xpositive*controlAng.y
					+ 7
				)/4)-pos --+ up*ang.r*lpos.y/self.WheelStabilize
				+ aeroVelocity*0.8
				+ controlThrottle*0.8
			)*phm)

			if throttle < 0.5 then
				ph:AddAngleVelocity(ph:GetAngleVelocity()*(throttle-0.5)*phm)
			end
		end
	end
	--[[


	for _, e in pairs(self.wheels) do
		if IsValid(e) then
			local ph = e:GetPhysicsObject()
			if ph:IsValid() then
				if self.controls.throttle < -0.8 then
					ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5*phm)
				end
			end
		end
	end
	

	for _,e in pairs(self.wheels) do
		if IsValid(e) then
			local ph=e:GetPhysicsObject()
			if ph:IsValid() then
				local lpos = self:WorldToLocal(e:GetPos())
				local mass = e:GetPhysicsObject():GetMass()
				e:GetPhysicsObject():AddVelocity(
						Vector(0,0,6)+self:LocalToWorld(Vector(
							0, 0, lpos.x*controlAng.x/mass*10 + lpos.y*controlAng.y/mass*10
						)/4)-pos
				)
				--e:GetPhysicsObject():AddVelocity(up*ang.r*lpos.y/self.WheelStabilize/mass*10)
				if self.controls.throttle < -0.8 then -- apply wheel brake
					ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5)
				end
			end
		end
	end
	]]
	
	--[[ old
	for _,e in pairs(self.wheels) do
		if IsValid(e) and e:GetPhysicsObject():IsValid() then
		local ph=e:GetPhysicsObject()
			local lpos=self:WorldToLocal(e:GetPos())
			
			e:GetPhysicsObject():AddVelocity((self:LocalToWorld(Vector(0, 0,
					math.abs(lpos.y)*controlAng.x -
					math.abs(lpos.x)*controlAng.y
			)/4)-pos --+ up*ang.r*lpos.y/self.WheelStabilize
			+ aeroVelocity)*phm)

			if throttle < 0.5 then
				ph:AddAngleVelocity(ph:GetAngleVelocity()*(throttle-0.5)*phm)
			end
		end
	end
	]]
	
	self.Lastphys = CurTime()
end

