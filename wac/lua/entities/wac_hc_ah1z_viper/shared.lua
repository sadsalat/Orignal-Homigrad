
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName		= "Viper AH-1Z"

ENT.TopRotor = {
	dir = -1,
	pos = Vector(0,0,120),
	model = "models/bf2/helicopters/ah-1 cobra/ah1z_r.mdl",
}

ENT.BackRotor = {
	dir = -1,
	pos = Vector(-362.61,22.06,107.22),
	model = "models/bf2/helicopters/ah-1 cobra/ah1z_tr.mdl"
}

ENT.Model			= "models/bf2/helicopters/ah-1 cobra/ah1z_b.mdl"
ENT.RotorPhModel	= "models/props_junk/sawblade001a.mdl"

ENT.SmokePos		= Vector(-116.21,0,79.51)
ENT.FirePos			= Vector(-89.17,0,92.37)

ENT.Seats = {
	{
		pos = Vector(70, 0, 48),
		exit = Vector(72,70,0),
		weapons = {"Hydra 70"}
	},
	{
		pos = Vector(120, 0, 42),
		exit = Vector(120,70,0),
		weapons = {"M197", "Hellfire"}
	},
}


ENT.Weapons = {
	["Hydra 70"] = {
		class = "wac_pod_hydra",
		info = {
			Sequential = false,
			Pods = {
				Vector(40.25, 36.33, 32.93),
				Vector(40.25, -36.33, 32.93)
			}
		}
	},
	["Hellfire"] = {
		class = "wac_pod_hellfire",
		info = {
			Pods = {
				Vector(50, 60, 40),
				Vector(50, -60, 40),
			}
		}
	},
	["M197"] = {
		class = "wac_pod_aimedgun",
		info = {
			ShootPos = Vector(137, 0, 23),
			ShootOffset = Vector(60, 0, 0),
		}
	},
}


ENT.Camera = {
	model = "models/bf2/helicopters/ah-1 cobra/ah1z_radar1.mdl",
	pos = Vector(175,0,42),
	offset = Vector(-1,0,0),
	viewPos = Vector(2, 0, 3.5),
	maxAng = Angle(45, 90, 0),
	minAng = Angle(-2, -90, 0),
	seat = 2
}


ENT.WeaponAttachments = {

	gunMount1 = {
		model = "models/bf2/helicopters/ah-1 cobra/ah1z_g1.mdl",
		pos = Vector(137,0,29),
		restrictPitch = true
	},
	
	gunMount2 = {
		model = "models/bf2/helicopters/ah-1 cobra/ah1z_g2.mdl",
		pos = Vector(137,0,23),
		offset = Vector(2,0,0)
	},

	gun = {
		model = "models/bf2/helicopters/ah-1 cobra/ah1z_g.mdl",
		pos = Vector(137, 0, 23),
		offset = Vector(2,0,0)
	},
	
	radar1 = {
		model = "models/bf2/helicopters/ah-1 cobra/ah1z_radar2.mdl",
		pos = Vector(175,0,52),
		restrictPitch = true
	},

}


ENT.Sounds = {
	Start = "wac/Heli/ah1_start.wav",
	Blades = "npc/attack_helicopter/aheli_rotor_loop1.wav",
	Engine = "wac/heli/bellinternal.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MissileShoot = "HelicopterVehicle/MissileShoot.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}

