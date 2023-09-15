
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("wac/aircraft.lua")


util.AddNetworkString("wac.aircraft.updateWeapons")


ENT.IgnoreDamage = true
ENT.wac_ignore = true

ENT.UsePhysRotor = true
ENT.Submersible = false
ENT.CrRotorWash = true
ENT.RotorWidth = 200

ENT.TopRotor = {
	dir = 1,
	pos = Vector(0,0,50),
	angles = Angle(0, 0, 0),
	model = "models/props_borealis/borealis_door001a.mdl",
	health = 100
}

ENT.BackRotor = {
	dir = 1,
	pos = Vector(-185,-3,13),
	angles = Angle(0, 0, 0),
	model = "models/props_borealis/borealis_door001a.mdl",
	health = 40
}

ENT.EngineHealth = 100

ENT.EngineForce	= 20
ENT.BrakeMul = 1
ENT.AngBrakeMul	= 0.01
ENT.Weight = 1000
ENT.SeatSwitcherPos = Vector(0,0,50)
ENT.BullsEyePos	= Vector(20,0,50)
ENT.MaxEnterDistance = 50
ENT.WheelStabilize = -400
ENT.HatingNPCs={
	"npc_strider",
	"npc_combinegunship",
	"npc_combinedropship",
	"npc_helicopter",
	"npc_hunter",
	"npc_ministrider",
	"npc_turret_ceiling",
	"npc_turret_floor",
	"npc_turret_ground",
	"npc_rollermine",
	"npc_sniper",
}


ENT.engineHealth = 100


--[[
	Defines how the aircraft handles depending on where wind is coming from.
	Rotation defines how it rotates,
	Lift how it rises, sinks or gets pushed right/left,
	Rail defines how stable it is on its path, the higher the less it drifts when turning
]]
ENT.Aerodynamics = {
	Rotation = {
		Front = Vector(0, 0.5, 0),
		Right = Vector(0, 0, 30), -- Rotate towards flying direction
		Top = Vector(0, -5, 0)
	},
	Lift = {
		Front = Vector(0, 0, 3), -- Go up when flying forward
		Right = Vector(0, 0, 0),
		Top = Vector(0, 0, -0.5)
	},
	Rail = Vector(0.3, 3, 2),
	RailRotor = 1, -- like Z rail but only active when moving and the rotor is turning
	AngleDrag = Vector(0.01, 0.01, 0.01),
}


ENT.Agility = {
	Rotate = Vector(1, 1, 1),
	Thrust = 1
}


ENT.Weapons = {}



function ENT:Initialize()
	wac.aircraft.initialize()
	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys = self:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:SetMass(self.Weight)
		self.phys:Wake()
	end
	
	self.entities = {}
	
	self.OnRemoveEntities={}
	self.OnRemoveFunctions={}
	self.wheels = {}
	
	self.nextUpdate = 0
	self.LastDamageTaken=0
	self.wac_seatswitch = true
	self.rotorRpm = 0
	self:SetNWFloat("health", 100)
	self.LastActivated = 0
	self.NextWepSwitch = 0
	self.NextCamSwitch = 0
	self.engineRpm = 0
	self.LastPhys=0
	self.passengers={}
	
	self.controls = {
		throttle = -1,
		pitch = 0,
		yaw = 0,
		roll = 0,
	}

	self:addRotors()
	self:addSounds()
	self:addWheels()
	self:addWeapons()
	self:addSeats()
	self:addStuff()
	self:addNpcTargets()

	self.phys:EnableDrag(false)
	
end

function ENT:addEntity(name)
	local e = ents.Create(name)
	if not IsValid(e) then return nil end
	table.insert(self.entities, e)
	e.Owner = self.Owner
	e:SetNWString("Owner", "World")
	return e
end


function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end


function ENT:addNpcTargets()
	--[[self.npcTargets = {}
	for x = -1, 1 do
		for y = -1, 1 do
			for z = -1, 1 do
				local traceData = {
					start = self:WorldToLocal(Vector(x,y,z)*self:BoundingRadius()),
					endpos = self:GetPos()
				}
				local tr = util.TraceLine(traceData)
				local e = self:addEntity("npc_bullseye")
				e:SetPos(tr.HitPos + tr.HitNormal * 10)
				e:SetParent(self.Entity)
				e:SetKeyValue("health", "10000")
				e:SetKeyValue("spawnflags", "256")
				e:SetNotSolid(true)
				e:Spawn()
				e:Activate()
				for _,s in pairs(self.HatingNPCs) do
					e:Fire("SetRelationShip", s.." D_HT 99")
				end
				table.insert(self.npcTargets, e)
			end
		end
	end]]
	for _,s in pairs(self.HatingNPCs) do
		self:Fire("SetRelationShip", s.." D_HT 99")
	end
end


function ENT:addRotors()
	if self.UsePhysRotor then
		self.topRotor = self:addEntity("prop_physics")
		self.topRotor:SetModel("models/props_junk/sawblade001a.mdl")
		self.topRotor:SetPos(self:LocalToWorld(self.TopRotor.pos))
		self.topRotor:SetAngles(self:LocalToWorldAngles(self.TopRotor.angles))
		self.topRotor:SetOwner(self.Owner)
		self.topRotor:SetNotSolid(true)
		self.topRotor:Spawn()
		self.topRotor.Phys = self.topRotor:GetPhysicsObject()
		self.topRotor.Phys:EnableGravity(false)
		self.topRotor.Phys:SetMass(5)
		self.topRotor.Phys:EnableDrag(false)
		self.topRotor:SetNoDraw(true)
		self.topRotor.fHealth = 100
		self.topRotor.wac_ignore = true
		if self.TopRotor.model then
			local e = self:addEntity("wac_hitdetector")
			self:SetNWEntity("wac_air_rotor_main", e)
			e:SetModel(self.TopRotor.model)
			e:SetPos(self.topRotor:GetPos())
			e:SetAngles(self.topRotor:GetAngles())
			
			e.TouchFunc = function(touchedEnt, pos)
				local ph = touchedEnt:GetPhysicsObject()
				if ph:IsValid() then
					if 
							not table.HasValue(self.passengers, touchedEnt)
							and !table.HasValue(self.entities, touchedEnt)
							and touchedEnt != self
							and !string.find(touchedEnt:GetClass(), "func*")
							and IsValid(self.topRotor)
							and touchedEnt:GetMoveType() != MOVETYPE_NOCLIP
					then
						local rotorVel = self.topRotor:GetPhysicsObject():GetAngleVelocity():Length()
						local dmg, mass;
						if touchedEnt:GetClass() == "worldspawn" then
							dmg = rotorVel*rotorVel/100000
							mass = 10000
						else
							dmg=(rotorVel*rotorVel + ph:GetVelocity():Length()*ph:GetVelocity():Length())/100000
							mass = touchedEnt:GetPhysicsObject():GetMass()
						end
						ph:AddVelocity((pos-self.topRotor:GetPos())*dmg/mass)
						self.phys:AddVelocity((self.topRotor:GetPos() - pos)*dmg/mass)
						self:DamageBigRotor(dmg)
						e.Entity:TakeDamage(dmg, IsValid(self.passengers[1]) and self.passengers[1] or self.Entity, self.Entity)
					end
				end
			end
			
			e:Spawn()
			e:SetNotSolid(true)
			e:SetParent(self.topRotor)
			e.wac_ignore = true
			local obb = e:OBBMaxs()
			self.RotorWidth = (obb.x>obb.y and obb.x or obb.y)
			self.RotorHeight = obb.z
			self.topRotor.vis = e
		end
		self.backRotor = self:addBackRotor()
		self:SetNWEntity("rotor_rear", self.backRotor)
		constraint.Axis(self.Entity, self.topRotor, 0, 0, self.TopRotor.pos, Vector(0,0,1), 0,0,0,1)
		if self.TwinBladed then
			constraint.Axis(self.Entity, self.backRotor, 0, 0, self.BackRotor.pos, Vector(0,0,1),0,0,0,1)
		else
			constraint.Axis(self.Entity, self.backRotor, 0, 0, self.BackRotor.pos, Vector(0, 1, 0), 0,0,0,1)
		end
		self:AddOnRemove(self.topRotor)
		self:AddOnRemove(self.backRotor)
	end
end


function ENT:addBackRotor()
	local e = self:addEntity("wac_hitdetector")
	e:SetModel(self.BackRotor.model)
	e:SetAngles(self:LocalToWorldAngles(self.BackRotor.angles))
	e:SetPos(self:LocalToWorld(self.BackRotor.pos))
	e.Owner = self.Owner
	e:SetNWFloat("rotorhealth", 100)
	e.wac_ignore = true
	e.TouchFunc = function(touchedEnt, pos) -- not colliding with world
		local ph = touchedEnt:GetPhysicsObject()
		if ph:IsValid() then
			if
					!table.HasValue(self.passengers, touchedEnt)
					and !table.HasValue(self.entities, touchedEnt)
					and touchedEnt != self
					and !string.find(touchedEnt:GetClass(), "func*")
					and IsValid(self.topRotor)
					and IsValid(self.backRotor)
					and touchedEnt:GetMoveType() != MOVETYPE_NOCLIP
			then
				local rotorVel = self.backRotor:GetPhysicsObject():GetAngleVelocity():Length()
				local dmg, mass;
				if touchedEnt:GetClass() == "worldspawn" then
					dmg = rotorVel*rotorVel/100000
					mass = 10000
				else
					dmg=(rotorVel*rotorVel + ph:GetVelocity():Length()*ph:GetVelocity():Length())/100000
					mass = touchedEnt:GetPhysicsObject():GetMass()
				end
				ph:AddVelocity((pos-self.backRotor:GetPos())*dmg/mass)
				self.phys:AddVelocity((self.backRotor:GetPos() - pos)*dmg/mass)
				self:DamageSmallRotor(dmg)
				touchedEnt:TakeDamage(dmg, IsValid(self.passengers[1]) and self.passengers[1] or self, self)
			end
		end
	end
	e.OnTakeDamage = function(e, dmg)
		if !dmg:IsExplosionDamage() then
			dmg:ScaleDamage(0.2)
		end
		self.LastAttacker = dmg:GetAttacker()
		self.LastDamageTaken = CurTime()
		self:DamageSmallRotor(dmg:GetDamage())
		e:TakePhysicsDamage(dmg)
	end
	e.Think = function(self) end
	e:Spawn()
	e.Phys=e:GetPhysicsObject()
	if e.Phys:IsValid() then
		e.Phys:Wake()
		e.Phys:EnableGravity(false)
		e.Phys:EnableDrag(false)
		e.Phys:SetMass(10)
	end
	e.fHealth = 40
	self:SetNWEntity("wac_air_rotor_rear", e)
	return e
end


function ENT:addStuff() end


function ENT:addWeapons()
	self.weapons = {}
	for i, w in pairs(self.Weapons) do
		if i != "BaseClass" then
			local pod = ents.Create(w.class)
			pod:SetPos(self:GetPos())
			pod:SetParent(self)
			for index, value in pairs(w.info) do
				pod[index] = value
			end
			pod.aircraft = self
			pod:Spawn()
			pod:Activate()
			pod:SetNoDraw(true)
			pod.podIndex = i
			self.weapons[i] = pod
			self:AddOnRemove(pod)
		end
	end

	if self.Camera then
		self.camera = ents.Create("prop_physics")
		self.camera:SetModel("models/props_junk/popcan01a.mdl")
		self.camera:SetNoDraw(true)
		self.camera:SetPos(self:LocalToWorld(self.Camera.pos))
		self.camera:SetParent(self)
		self.camera:Spawn()
	end
end

function ENT:addSeats()
	self.seats = {}
	local e = self:addEntity("wac_seat_connector")
	e:SetPos(self:LocalToWorld(self.SeatSwitcherPos))
	e:SetNoDraw(true)
	e:Spawn()
	e:Activate()
	e.wac_ignore = true
	e:SetNotSolid(true)
	e:SetParent(self)
	self:SetSwitcher(e)
	for k, v in pairs(self.Seats) do
		if k != "BaseClass" then
			local ang = self:GetAngles()
			self.seats[k] = self:addEntity("prop_vehicle_prisoner_pod")
			self.seats[k].activeProfile = 1
			self.seats[k]:SetModel("models/nova/airboat_seat.mdl") 
			self.seats[k]:SetPos(self:LocalToWorld(v.pos))
			self.seats[k]:Spawn()
			self.seats[k]:Activate()
			self.seats[k]:SetNWInt("selectedWeapon", 0)
			if v.ang then
				local a = self:GetAngles()
				a.y = a.y-90
				a:RotateAroundAxis(Vector(0,0,1), v.ang.y)
				self.seats[k]:SetAngles(a)
			else
				ang:RotateAroundAxis(self:GetUp(), -90)
				self.seats[k]:SetAngles(ang)
			end
			self.seats[k]:SetNoDraw(true)
			self.seats[k]:SetNotSolid(true)
			self.seats[k]:SetParent(self)
			self.seats[k].wac_ignore = true
			self.seats[k]:SetNWEntity("wac_aircraft", self)
			self.seats[k]:SetKeyValue("limitview","0")
			self:SetNWInt("seat_"..k.."_actwep", 1)
			e:addVehicle(self.seats[k])
		end
	end
end


function ENT:addWheels()
	for _,t in pairs(self.Wheels) do
		if t.mdl then
			local e=self:addEntity("prop_physics")
			e:SetModel(t.mdl)
			e:SetPos(self:LocalToWorld(t.pos))
			e:SetAngles(self:GetAngles())
			e:Spawn()
			e:Activate()
			local ph=e:GetPhysicsObject()
			if t.mass then
				ph:SetMass(t.mass)
			end
			ph:EnableDrag(false)
			constraint.Axis(e,self,0,0,Vector(0,0,0),self:WorldToLocal(e:LocalToWorld(Vector(0,1,0))),0,0,t.friction,1)
			table.insert(self.wheels,e)
			self:AddOnRemove(e)
		end
	end
end


function ENT:fireWeapon(bool, i)
	if !self.Seats[i].weapons then return end
	local pod = self.weapons[self.Seats[i].weapons[self.seats[i].activeProfile]]
	if !pod then return end
	pod.shouldFire = bool
	pod:trigger(bool, self.seats[i])
end


function ENT:nextWeapon(i, p)
	if !self.Seats[i].weapons then return end
	local seat = self.seats[i]
	local Seat = self.Seats[i]

	local pod = self.weapons[Seat.weapons[seat.activeProfile]]
	if pod then
		pod:select(false)
		pod.seat = nil
	end

	if seat.activeProfile == #Seat.weapons then
		seat.activeProfile = 0
	else
		seat.activeProfile = seat.activeProfile + 1
	end
	if Seat.weapons[seat.activeProfile] then
		local weapon = self.weapons[Seat.weapons[seat.activeProfile]]
		weapon:select(true)
		weapon.seat = seat
	end
	self:SetNWInt("seat_"..i.."_actwep", seat.activeProfile)
end


function ENT:EjectPassenger(ply,idx,t)
	if !idx then
		for k,p in pairs(self.passengers) do
			if p==ply then idx=k end
		end
		if !idx then
			return
		end
	end
	ply.LastVehicleEntered = CurTime()+0.5
	ply:ExitVehicle()
	ply:SetPos(self:LocalToWorld(self.Seats[idx].exit))
	ply:SetVelocity(self:GetPhysicsObject():GetVelocity()*1.2)
	ply:SetEyeAngles((self:LocalToWorld(self.Seats[idx].pos-Vector(0,0,40))-ply:GetPos()):Angle())
	self:updateSeats()
end


function ENT:Use(act, cal)
	if self.disabled then return end
	if act.wac and act.wac.lastEnter and act.wac.lastEnter+0.5 > CurTime() then return end
	local d = self.MaxEnterDistance
	local v
	for k, veh in pairs(self.seats) do
		if veh and veh:IsValid() then
			local psngr = veh:GetPassenger(0)
			if !psngr or !psngr:IsValid() then
				local dist = veh:GetPos():Distance(util.QuickTrace(act:GetShootPos(),act:GetAimVector()*self.MaxEnterDistance,act).HitPos)
				if dist < d then
					d = dist
					v = veh
				end
			end
		end
	end
	act.wac = act.wac or {}
	act.wac.lastEnter = CurTime()
	if v then
		act:EnterVehicle(v)
	end
	self:updateSeats()
end


function ENT:updateSeats()
	for k, veh in pairs(self.seats) do
		if !veh:IsValid() then return end
		local p = veh:GetPassenger(0)
		if self.passengers[k] != p then
			if IsValid(self.passengers[k]) then
				self.passengers[k]:SetNWEntity("wac_aircraft", NULL)
			end
			self:SetNWEntity("passenger_"..k, p)
			self.passengers[k] = p
			if IsValid(p) then
				p:SetNWInt("wac_passenger_id",k)
				p.wac = p.wac or {}
				p.wac.mouseInput = true
				net.Start("wac.aircraft.updateWeapons")
				net.WriteEntity(self)
				net.WriteInt(table.Count(self.weapons), 8)
				for name, weapon in pairs(self.weapons) do
					net.WriteString(name)
					net.WriteEntity(weapon)
				end
				net.Send(p)
			end
		end
	end
	if !IsValid(self.seats[1]:GetDriver()) then
		self.controls.pitch = 0
		self.controls.yaw = 0
		self.controls.roll = 0
	end
	self:GetSwitcher():updateSeats()
end


function ENT:StopAllSounds()
	for k, s in pairs(self.sounds) do
		s:Stop()
	end
end


function ENT:RocketAlert()
	if self.rotorRpm > 0.1 then
		local b=false
		local rockets = ents.FindByClass("rpg_missile")
		table.Merge(rockets, ents.FindByClass("wac_w_rocket"))
		for _, e in pairs(rockets) do
			if e:GetPos():Distance(self:GetPos()) < 2000 then b = true break end
		end
		if self.sounds.MissileAlert:IsPlaying() then
			if !b then
				self.sounds.MissileAlert:Stop()
			end
		elseif b then
			self.sounds.MissileAlert:Play()
		end
	end
end


function ENT:setVar(name, var)
	if self:GetNWFloat(name) != var then
		self:SetNWFloat(name, var)
	end
end


function ENT:Think()
	local crt = CurTime()
	if !self.disabled then
		if self.nextUpdate<crt then
			if self.phys and self.phys:IsValid() then
				self.phys:Wake()
			end

			--[[
			if IsValid(self.camera) then
				local p = self.seats[self.Camera.seat]:GetDriver()
				if IsValid(p) then
					local view = self:WorldToLocalAngles(p:GetAimVector():Angle())
					local ang = Angle(self.Camera.restrictPitch and 0 or view.p, self.Camera.restrictYaw and 0 or view.y, 0)
					if self.Camera.minAng then
						ang.p = (ang.p > self.Camera.minAng.p and ang.p or self.Camera.minAng.p)
						ang.y = (ang.y > self.Camera.minAng.y and ang.y or self.Camera.minAng.y)
					end
					if self.Camera.maxAng then
						ang.p = (ang.p < self.Camera.maxAng.p and ang.p or self.Camera.maxAng.p)
						ang.y = (ang.y < self.Camera.maxAng.y and ang.y or self.Camera.maxAng.y)
					end
					self.camera:SetAngles(self:LocalToWorldAngles(ang))
				end
			end
			]]

			local target = math.floor(math.Clamp(self.rotorRpm, 0, 0.99)*3)
			if self.bodyGroup != target then
				self.bodyGroup = target
				if self.topRotor and IsValid(self.topRotor.vis) then
					self.topRotor.vis:SetBodygroup(1, self.bodyGroup)
				end
				if IsValid(self.backRotor) then
					self.backRotor:SetBodygroup(1, self.bodyGroup)
				end
			end

			if self.skin != self:GetSkin() then
				self.skin = self:GetSkin()
				self:updateSkin(self.skin)
			end

			if self.Burning then
				self:DamageEngine(0.1)
			end
			if self.CrRotorWash then
				if self.rotorRpm > 0.6 then
					if !self.RotorWash then
						self.RotorWash = ents.Create("env_rotorwash_emitter")
						self.RotorWash:SetPos(self.Entity:GetPos())
						self.RotorWash:SetParent(self.Entity)
						self.RotorWash:Activate()
					end
				else
					if self.RotorWash then
						self.RotorWash:Remove()
						self.RotorWash = nil
					end
				end
			end
			self:RocketAlert()
			if self.Smoke then
				self.Smoke:SetKeyValue("renderamt", tostring(math.Clamp(self.rotorRpm*170, 0, 200)))
				self.Smoke:SetKeyValue("Speed", tostring(50+self.rotorRpm*50))
				self.Smoke:SetKeyValue("JetLength", tostring(50+self.rotorRpm*50))
			end
			self:updateSeats()
			self.nextUpdate = crt+0.1
		end
		
		self:setVar("rotorRpm", math.Clamp(self.rotorRpm, 0, 150))
		self:setVar("engineRpm", self.engineRpm)
		self:setVar("up", self.controls.throttle)

		if self.topRotor and self.topRotor:WaterLevel() > 0 then
			self:DamageEngine(FrameTime())
		end
	end
	self:NextThink(crt)
	return true
end


function ENT:receiveInput(name, value, seat)
	if seat == 1 then
		if name == "Start" and value>0.5 then
			self:setEngine(!self.active)
		elseif name == "Throttle" then
			self.controls.throttle = value
		elseif name == "Pitch" then
			self.controls.pitch = value
		elseif name == "Yaw" then
			self.controls.yaw = value
		elseif name == "Roll" then
			self.controls.roll = value
		elseif name == "Hover" and value>0.5 then
			self:SetHover(!self:GetHover())
		elseif name == "FreeView" then
			self.passengers[seat].wac.mouseInput = (value < 0.5)
		end
	end
	if name == "Exit" and value>0.5 and self.passengers[seat].wac.lastEnter<CurTime()-0.5 then
		self:EjectPassenger(self.passengers[seat])
	elseif name == "Fire" then
		self:fireWeapon(value > 0.5, seat)
	elseif name == "NextWeapon" and value > 0.5 then
		self:nextWeapon(seat, self.passengers[seat])
	end
end


function ENT:getSeat(player)
	for i, p in pairs(self.passengers) do
		if p == player then
			return self.seats[i]
		end
	end
end


function ENT:setEngine(b)
	if self.disabled or self.engineDead then b = false end
	if b then
		if self.active then return end
		self.active = true
	elseif self.active then
		self.active=false
	end
	self:SetNWBool("active", self.active)
end


function ENT:calcAerodynamics(ph)

	local dvel = self:GetVelocity():Length()
	local lvel = self:WorldToLocal(self:GetPos() + self:GetVelocity())

	local targetVelocity = (
		- self:LocalToWorld(self.Aerodynamics.Rail * lvel * dvel * dvel / 1000000000) + self:GetPos()
		+ self:LocalToWorld(
			self.Aerodynamics.Lift.Front * lvel.x * dvel / 10000000 +
			self.Aerodynamics.Lift.Right * lvel.y * dvel / 10000000 +
			self.Aerodynamics.Lift.Top * lvel.z * dvel / 10000000
		) - self:GetPos()
	) * (1 + self.arcade)

	local targetAngVel =
		(
			lvel.x*self.Aerodynamics.Rotation.Front +
			lvel.y*self.Aerodynamics.Rotation.Right +
			lvel.z*self.Aerodynamics.Rotation.Top
		) / 10000 / (1 + self.arcade)
		- ph:GetAngleVelocity()*self.Aerodynamics.AngleDrag*(1+self.arcade*2)

	return targetVelocity, targetAngVel
end


function ENT:calcHover(ph,pos,vel,ang)
	if self:GetHover() then
		local v=self:WorldToLocal(pos+vel)
		local av=ph:GetAngleVelocity()
		if !self.EasyMode then
			return{
				p = math.Clamp(-ang.p*0.6-av.y*0.6-v.x*0.025,-0.65,0.65),
				r = math.Clamp(-ang.r*0.6-av.x*0.6+v.y*0.025,-0.65,0.65),
				t = math.Clamp(-v.z*0.3, -0.65, 0.65)
			}
		else
			return{
				p = math.Clamp(-ang.p*0.3-av.y*0.1-v.x*0.005,-0.1,0.1),
				r = math.Clamp(-ang.r*0.6-av.x*0.8+v.y*0.045,-0.6,0.6),
				t = math.Clamp(-v.z*0.3, -0.65, 0.65)
			}
		end
	else
		return {p=0,r=0,t=0}
	end
end


function ENT:PhysicsUpdate(ph)
	if self.LastPhys == CurTime() then return end
	local vel = ph:GetVelocity()	
	local pos = self:GetPos()
	local ri = self:GetRight()
	local up = self:GetUp()
	local fwd = self:GetForward()
	local ang = self:GetAngles()
	local dvel = vel:Length()
	local lvel = self:WorldToLocal(pos+vel)

	local hover = self:calcHover(ph,pos,vel,ang)
	
	local rotateX = (self.controls.roll*1.5+hover.r)*self.rotorRpm
	local rotateY = (self.controls.pitch+hover.p)*self.rotorRpm
	local rotateZ = self.controls.yaw*1.5*self.rotorRpm

	self.arcade = (
		IsValid(self.passengers[1])
		and self.passengers[1]:GetInfo("wac_cl_air_arcade")
		or 0
	)

	--local phm = (wac.aircraft.cvars.doubleTick:GetBool() and 2 or 1)
	local phm = FrameTime()*66
	if self.UsePhysRotor then
	    
		if self.active and !self.engineDead then
			self.engineRpm = math.Clamp(self.engineRpm+FrameTime()*0.1*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
		else
			self.engineRpm = math.Clamp(self.engineRpm-FrameTime()*0.16*wac.aircraft.cvars.startSpeed:GetFloat(), 0, 1)
		end

	    
		if self.topRotor and self.topRotor.Phys and self.topRotor.Phys:IsValid() then
			if self.RotorBlurModel then
				self.topRotor.vis:SetColor(Color(255,255,255,math.Clamp(1.3-self.rotorRpm,0.1,1)*255))
			end

			-- top rotor physics
			local rotor = {}
			rotor.phys = self.topRotor.Phys
			rotor.angVel = rotor.phys:GetAngleVelocity()
			rotor.upvel = self.topRotor:WorldToLocal(self.topRotor:GetVelocity()+self.topRotor:GetPos()).z
			rotor.brake =
				math.Clamp(math.abs(rotor.angVel.z) - 2950, 0, 100)/10 -- RPM cap
				+ math.pow(math.Clamp(1500 - math.abs(rotor.angVel.z), 0, 1500)/900, 3)
				+ math.abs(rotor.angVel.z/10000)
				- (rotor.upvel - self.rotorRpm)*(self.controls.throttle - 0.5)/1000

			rotor.targetAngVel =
				Vector(0, 0, math.pow(self.engineRpm,2)*self.TopRotor.dir*10)
				- rotor.angVel*rotor.brake/200

			rotor.phys:AddAngleVelocity(rotor.targetAngVel)

			self.rotorRpm = math.Clamp(rotor.angVel.z/3000 * self.TopRotor.dir, -1, 1)

			-- body physics
			local mind = (100-self.topRotor.fHealth)/100
			ph:AddAngleVelocity(VectorRand()*self.rotorRpm*mind*phm)

			if IsValid(self.backRotor) and self.backRotor.Phys:IsValid() then
				--self.backRotor.Phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotor.dir-self.backRotor.Phys:GetAngleVelocity().y/10,0)*phm)
				if self.TwinBladed then
					self.backRotor.Phys:AddAngleVelocity(rotor.targetAngVel*phm)
				else
					self.backRotor.Phys:AddAngleVelocity(Vector(0,self.rotorRpm*300*self.BackRotor.dir-self.backRotor.Phys:GetAngleVelocity().y/10,0)*phm)
				end
			else
				ph:AddAngleVelocity((Vector(0,0,0-self.rotorRpm*self.TopRotor.dir/2))*phm)
				ph:AddAngleVelocity(VectorRand()*self.rotorRpm*mind*phm)
				if !self.sounds.CrashAlarm:IsPlaying() and !self.disabled then
					self.sounds.CrashAlarm:Play()
				end
			end

			local throttle = self.Agility.Thrust*up*((self.controls.throttle+hover.t)*self.rotorRpm*1.7*self.EngineForce/15+self.rotorRpm*9.15)
			local brakez = self:LocalToWorld(Vector(0, 0, lvel.z*dvel*self.rotorRpm/100000*self.Aerodynamics.RailRotor)) - pos
			ph:AddVelocity((throttle - brakez)*phm)
			
		elseif IsValid(self.backRotor) and self.backRotor.Phys:IsValid() then
			local backSpeed = (self.backRotor.Phys:GetAngleVelocity() - ph:GetAngleVelocity()).y
			ph:AddAngleVelocity(Vector(0,0,backSpeed/300))
			self.backRotor.Phys:AddAngleVelocity(self.backRotor.Phys:GetAngleVelocity()*-0.01)
		end
	else
		self.rotorRpm=math.Approach(self.rotorRpm, self.active and 1 or 0, self.EngineForce/1000)
		ph:SetVelocity(vel*0.999+(up*self.rotorRpm*(self.controls.throttle+1)*7 + (fwd*math.Clamp(ang.p*0.1, -2, 2) + ri*math.Clamp(ang.r*0.1, -2, 2))*self.rotorRpm)*phm)
	end

	local controlAng =
			Vector(rotateX, rotateY, IsValid(self.backRotor) and rotateZ or 0)
			* self.Agility.Rotate * (1+self.arcade)

	local aeroVelocity, aeroAng = self:calcAerodynamics(ph)

	ph:AddAngleVelocity((aeroAng + controlAng)*phm)
	ph:AddVelocity(aeroVelocity*phm)

	for _,e in pairs(self.wheels) do
		if IsValid(e) then
			local ph=e:GetPhysicsObject()
			if ph:IsValid() then
				local lpos=self:WorldToLocal(e:GetPos())
				e:GetPhysicsObject():AddVelocity((
						Vector(0,0,6)+self:LocalToWorld(Vector(
							0, 0, lpos.y*rotateX - lpos.x*rotateY
						)/4)-pos
				)*phm)
				e:GetPhysicsObject():AddVelocity(up*ang.r*lpos.y/self.WheelStabilize*phm)
				if self.controls.throttle < -0.8 then -- apply wheel brake
					ph:AddAngleVelocity(ph:GetAngleVelocity()*-0.5*phm)
				end
			end
		end
	end
	
	self.LastPhys = CurTime()
end


--[###########]
--[###] DAMAGE
--[###########]

-- wac_aircraft_maintenance within 500 units calls this every second
function ENT:maintenance()
    if self.disabled then return end
	local repaired = false
	local rearmed = false
	if IsValid(self.backRotor) and self.backRotor.fHealth < self.BackRotor.health then
		self.backRotor.fHealth = math.Approach(self.backRotor.fHealth, self.BackRotor.health, 5)
		repaired = true
	end
	if IsValid(self.topRotor) and self.topRotor.fHealth < self.BackRotor.health then
		self.topRotor.fHealth = math.Approach(self.topRotor.fHealth, self.TopRotor.health, 6)
		repaired = true
	end
	if self.engineHealth < self.EngineHealth then
		self.engineHealth = math.Approach(self.engineHealth, self.EngineHealth, 10)
		repaired = true
	end
	if self.weapons then
		for _, w in pairs(self.weapons) do
			if w:GetAmmo() != w.Ammo then
				w:SetAmmo(math.Approach(w:GetAmmo(), w.Ammo, w.FireRate/60))
				rearmed = true
			end
		end
    end
    if rearmed then
        self:EmitSound("items/ammo_pickup.wav", 100, 100)
    end
    if repaired then
        self:EmitSound("wac/repair_loop.wav", 100, 100)
    end
end


function ENT:PhysicsCollide(cdat, phys)
	if wac.aircraft.cvars.nodamage:GetInt() == 1 then
		return
	end
	if cdat.DeltaTime > 0.5 then
		local mass = cdat.HitObject:GetMass()
		if cdat.HitEntity:GetClass() == "worldspawn" then
			mass = 5000
		end
		local dmg = (cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 5000))/10000000
		if !dmg or dmg < 1 then return end
		self:TakeDamage(dmg*15)
		if dmg > 2 then
			self.Entity:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(1,4)..".wav")
			local lasta=(self.LastDamageTaken<CurTime()+6 and self.LastAttacker or self.Entity)
			for k, p in pairs(self.passengers) do
				if p and p:IsValid() then
					p:TakeDamage(dmg/5, lasta, self.Entity)
				end
			end
		end
	end
end

function ENT:DamageSmallRotor(amt)
	if wac.aircraft.cvars.nodamage:GetInt() == 1 then
		return
	end
	if amt < 1 then return end
	if self.backRotor and self.backRotor:IsValid() then
		self.backRotor:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(1,3)..".wav", math.Clamp(amt*40,20,200))
		self.backRotor.fHealth = self.backRotor.fHealth - amt
		self.backRotor.Phys:AddAngleVelocity(self.backRotor.Phys:GetAngleVelocity()*-amt/50)
		if self.backRotor.fHealth < 0 then
			self:KillBackRotor()
			if !self.sounds.CrashAlarm:IsPlaying() and !self.disabled then
				self.sounds.CrashAlarm:Play()
			end
		end
		if self.backRotor then
			self:SetNWFloat("rotorhealth", self.backRotor.fHealth)
		else
			self:SetNWFloat("rotorhealth", -1)
		end
		self:DamageEngine(amt/10)
	end
end

function ENT:KillBackRotor()
	if !self.backRotor then return end
	local e = self:addEntity("prop_physics")
	e:SetAngles(self.backRotor:GetAngles())
	e:SetPos(self.backRotor:GetPos())
	e:SetModel(self.backRotor:GetModel())
	e:SetSkin(self.backRotor:GetSkin())
	e:Spawn()
	e:SetVelocity(self.backRotor:GetVelocity())
	e:GetPhysicsObject():AddAngleVelocity(self.backRotor.Phys:GetAngleVelocity())
	e:GetPhysicsObject():SetMass(self.backRotor.Phys:GetMass())
	e:DrawShadow(false)
	self.backRotor:Remove()
	self.backRotor = nil
end

function ENT:DamageBigRotor(amt)
	if wac.aircraft.cvars.nodamage:GetInt() == 1 then
		return
	end
	if amt < 1 then return end
	self.Entity:EmitSound("physics/metal/metal_box_impact_bullet"..math.random(1,3)..".wav", math.Clamp(amt*40,0,100))
	if self.topRotor and self.topRotor:IsValid() then
		self.topRotor.fHealth = self.topRotor.fHealth - amt
		self.topRotor.Phys:AddAngleVelocity((self.topRotor.Phys:GetAngleVelocity()*-amt)*0.001)
		if self.topRotor.fHealth < 0 then
			self:KillTopRotor()
			if !self.sounds.CrashAlarm:IsPlaying() and !self.disabled then
				self.sounds.CrashAlarm:Play()
			end
		elseif self.topRotor.fHealth < 50 and !self.sounds.MinorAlarm:IsPlaying() and !self.disabled then
			self.sounds.MinorAlarm:Play()
		end
		if self.topRotor then
			self:SetNWFloat("rotorhealth", self.topRotor.fHealth)
		else
			self:SetNWFloat("rotorhealth", -1)
		end
		self:DamageEngine(amt/10)
	end
end

function ENT:KillTopRotor()
	if !self.topRotor then return end
	self:setEngine(false)
	local e = self:addEntity("prop_physics")
	e:SetPos(self.topRotor:GetPos())
	e:SetAngles(self.topRotor:GetAngles())
	e:SetModel(self.TopRotor.model)
	e:SetSkin(self.topRotor.vis:GetSkin())
	e:Spawn()
	self:SetNWFloat("up",0)
	self:SetNWFloat("uptime",0)
	self.rotorRpm = 0
	local ph = e:GetPhysicsObject()
	e.wac_ignore=true
	if ph:IsValid() then
		ph:SetMass(1000)
		ph:EnableDrag(false)
		ph:AddAngleVelocity(self.topRotor.Phys:GetAngleVelocity())
		ph:SetVelocity(self.topRotor.Phys:GetAngleVelocity():Length()*self.topRotor:GetUp()*0.5 + self.topRotor:GetVelocity())
	end
	self.topRotor:Remove()
	self.topRotor = nil
	e:SetNotSolid(true)
	e:DrawShadow(false)
end
--[###] Rotor Damage


function ENT:OnTakeDamage(dmg)
	if wac.aircraft.cvars.nodamage:GetInt() == 1 then
		return
	end

	if not dmg:IsExplosionDamage() then
		dmg:ScaleDamage(0.10)
	end
	
	if dmg:IsBulletDamage() then
		dmg:ScaleDamage(0.10)
	end

	local rdmg = dmg:GetDamage()
	self:DamageEngine(rdmg/3)
	local pos=self:WorldToLocal(dmg:GetDamagePosition())
	if pos:Distance(self.TopRotor.pos)<40 then
		self:DamageBigRotor(rdmg/15)	
	end
	if pos:Distance(self.BackRotor.pos)<70 then
		self:DamageSmallRotor(rdmg/2)
	end
	self.LastAttacker=dmg:GetAttacker()
	self.LastDamageTaken=CurTime()
	self:TakePhysicsDamage(dmg)
end

function ENT:DamageEngine(amt)
	if wac.aircraft.cvars.nodamage:GetInt() == 1 then
		return
	end
	if self.disabled then return end
	self.engineHealth = self.engineHealth - amt

	if self.engineHealth < 80  then
		if !self.sounds.MinorAlarm:IsPlaying() then
			self.sounds.MinorAlarm:Play()
		end
		if !self.Smoke and self.engineHealth>0 then
			self.Smoke = self:CreateSmoke()
		end

		if self.engineHealth < 50 then
			if !self.sounds.LowHealth:IsPlaying() then
				self.sounds.LowHealth:Play()
			end
			self:setEngine(false)
			self.engineDead = true

			if self.engineHealth < 20 and !self.EngineFire then
				local fire = ents.Create("env_fire_trail")
				fire:SetPos(self:LocalToWorld(self.FirePos))
				fire:Spawn()
				fire:SetParent(self.Entity)
				self.Burning = true
				self.sounds.LowHealth:Play()
				self.EngineFire = fire
			end

			if self.engineHealth < 0 and !self.disabled then
				self.disabled = true
				self.engineRpm = 0
				self.rotorRpm = 0
				local lasta=(self.LastDamageTaken<CurTime()+6 and self.LastAttacker or self.Entity)
				for k, p in pairs(self.passengers) do
					if p and p:IsValid() then
						p:TakeDamage(p:Health() + 20, lasta, self.Entity)
					end
				end

				for k,v in pairs(self.seats) do
					v:Remove()
				end
				self.passengers={}
				self:StopAllSounds()

				self:setVar("rotorRpm", 0)
				self:setVar("engineRpm", 0)
				self:setVar("up", 0)

				self.IgnoreDamage = false
				--[[ this affects the base class
					for name, vec in pairs(self.Aerodynamics.Rotation) do
						vec = VectorRand()*100
					end
					for name, vec in pairs(self.Aerodynamics.Lift) do
						vec = VectorRand()
					end
					self.Aerodynamics.Rail = Vector(0.5, 0.5, 0.5)
				]]
				local effectdata = EffectData()
				effectdata:SetStart(self.Entity:GetPos())
				effectdata:SetOrigin(self.Entity:GetPos())
				effectdata:SetScale(1)
				util.Effect("Explosion", effectdata)
				util.Effect("HelicopterMegaBomb", effectdata)
				util.Effect("cball_explode", effectdata)
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 300)
				self:setEngine(false)
				if self.Smoke then
					self.Smoke:Remove()
					self.Smoke=nil
				end
				if self.RotorWash then
					self.RotorWash:Remove()
					self.RotorWash=nil
				end
				self:SetNWBool("locked", true)
			end
		end
	end
	if self.Smoke then
		local rcol = math.Clamp(self.engineHealth*3.4, 0, 170)
		self.Smoke:SetKeyValue("rendercolor", rcol.." "..rcol.." "..rcol)
	end
	self:SetNWFloat("health", self.engineHealth)
end

function ENT:CreateSmoke()
	local smoke = ents.Create("env_smokestack")
	smoke:SetPos(self:LocalToWorld(self.SmokePos))
	smoke:SetAngles(self:GetAngles()+Angle(-90,0,0))
	smoke:SetKeyValue("InitialState", "1")
	smoke:SetKeyValue("WindAngle", "0 0 0")
	smoke:SetKeyValue("WindSpeed", "0")
	smoke:SetKeyValue("rendercolor", "170 170 170")
	smoke:SetKeyValue("renderamt", "170")
	smoke:SetKeyValue("SmokeMaterial", "particle/smokesprites_0001.vmt")
	smoke:SetKeyValue("BaseSpread", "2")
	smoke:SetKeyValue("SpreadSpeed", "2")
	smoke:SetKeyValue("Speed", "50")
	smoke:SetKeyValue("StartSize", "10")
	smoke:SetKeyValue("EndSize", "50")
	smoke:SetKeyValue("roll", "10")
	smoke:SetKeyValue("Rate", "15")
	smoke:SetKeyValue("JetLength", "50")
	smoke:SetKeyValue("twist", "5")
	smoke:Spawn()
	smoke:SetParent(self.Entity)
	smoke:Activate()
	return smoke
end

function ENT:AddOnRemove(f)
	if type(f)=="function" then
		table.insert(self.OnRemoveFunctions,f)	
	elseif type(f)=="Entity" or type(f)=="Vehicle" then
		table.insert(self.OnRemoveEntities,f)
	end
end

function ENT:OnRemove()
	self:StopAllSounds()
	for _,p in pairs(self.passengers) do
		if IsValid(p) then
			p:SetNWInt("wac_passenger_id",0)
		end
	end
	for _,f in pairs(self.OnRemoveFunctions) do
		f()
	end
	for _,e in pairs(self.OnRemoveEntities) do
		if IsValid(e) then e:Remove() end
	end
end



