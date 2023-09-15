
if !wac or !wac.aircraft then
	error("WAC scripts not loaded.")
end

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Base Helicopter"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.isWacAircraft = true

ENT.SmokePos = Vector(-75,0,20)
ENT.FirePos = Vector(-60,0,60)

ENT.Seats = {
	{
		pos = Vector(68, 0, 48),
		exit = Vector(72,70,0),
	},
}


ENT.Sounds = {
	Start = "HelicopterVehicle/HeliStart.mp3",
	Blades = "vehicles/Airboat/fan_blade_idle_loop1.wav",
	Engine = "WAC/Heli/heli_loop_int.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

ENT.Wheels = {}


function ENT:addSounds()
	self.sounds = {}
	for name, value in pairs(self.Sounds) do
		if name != "BaseClass" then
			sound.Add({
				name = "wac."..self.ClassName.."."..name,
				channel = CHAN_STATIC,
				soundlevel = (name == "Blades" or name == "Engine") and 200 or 100,
				sound = value
			})
			self.sounds[name] = CreateSound(self, "wac."..self.ClassName.."."..name)
			if name == "Blades" then
				self.sounds[name]:SetSoundLevel(120)
			elseif name == "Engine" then
				self.sounds[name]:SetSoundLevel(110)
			end
		end
	end
end


function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Hover")
	self:NetworkVar("Entity", 0, "Switcher")
end


function ENT:base(name)
	local current = self
	while current do
		if current.ClassName == name then
			return current
		end
		current = current.BaseClass
	end
	error("No base class with name \"" .. name .. "\"", 2)
end


function ENT:updateSkin(n)
	if SERVER then
		for _, e in pairs(self.entities) do
			if IsValid(e) then
				e:SetSkin(n)
			end
		end
	else
		for _,e in pairs(self.weaponAttachments) do
			e.model:SetSkin(n)
		end
	end
end


function ENT:getPassenger(seat)
	if !IsValid(self:GetSwitcher()) then return end
	local s = self:GetSwitcher().seats[seat]
	if IsValid(s) then
		return s:GetDriver()
	end
end


function ENT:getCameraAngles()
	local ang = Angle(0, 0, 0)
	if !self.Camera then return ang end
	local p = self:getPassenger(self.Camera.seat)
	if IsValid(p) then
		local view = self:WorldToLocalAngles(p:GetAimVector():Angle())
		ang = Angle(self.Camera.restrictPitch and 0 or view.p, self.Camera.restrictYaw and 0 or view.y, 0)
		if self.Camera.minAng then
			ang.p = (ang.p > self.Camera.minAng.p and ang.p or self.Camera.minAng.p)
			ang.y = (ang.y > self.Camera.minAng.y and ang.y or self.Camera.minAng.y)
		end
		if self.Camera.maxAng then
			ang.p = (ang.p < self.Camera.maxAng.p and ang.p or self.Camera.maxAng.p)
			ang.y = (ang.y < self.Camera.maxAng.y and ang.y or self.Camera.maxAng.y)
		end
	end
	return self:LocalToWorldAngles(ang)
end


