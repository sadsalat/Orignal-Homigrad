
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Black Hawk UH-60"

ENT.Model = "models/bf2/helicopters/uh-60 blackhawk/uh60_b.mdl"

ENT.TopRotor = {
	dir = -1,
	pos = Vector(0, 0, 100),
	model = "models/bf2/helicopters/uh-60 blackhawk/uh60_r.mdl",
}

ENT.BackRotor = {
	pos = Vector(-400,17,134),
	model = "models/bf2/helicopters/uh-60 blackhawk/uh60_rr.mdl",
	angles = Angle(0, 0, 192)
}


ENT.SmokePos = Vector(-80,40,90)--{Vector(-80,40,90), Vector(-80,-40,90)}
ENT.FirePos = Vector(-25,0,130)

ENT.Seats = {
	{
		pos = Vector(110,-31,30),
		exit = Vector(140,-100,3),
		NoHud = true,
	},
	{
		pos = Vector(110,31,30),
		exit = Vector(140,100,3),
		NoHud = true,
	},
	{
		pos = Vector(65,-24,33),
		ang = Angle(0,-90,0),
		exit = Vector(33,-100,3),
		NoHud = true,
	},
	{
		pos = Vector(65,24,33),
		ang = Angle(0,90,0),
		exit = Vector(33,101.04,3),
		NoHud=true,
	},
	{
		pos = Vector(34.5,34,33),
		ang= Angle(0,180,0),
		exit = Vector(33,100,3),
		NoHud=true,
	},
	{
		pos = Vector(-48,34,33),
		exit = Vector(-20,100,3),
		NoHud = true,
	},
	{
		pos = Vector(-48,-34,33),
		exit = Vector(-20,-100,3),
		NoHud = true,
	},
}


ENT.Sounds = {
	Start = "WAC/Heli/h6_start.wav",
	Blades = "WAC/Heli/uh60_loop.wav",
	Engine = "",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MissileShoot = "HelicopterVehicle/MissileShoot.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
	Radio =  "HelicopterVehicle/MissileNearby.mp3",
}
