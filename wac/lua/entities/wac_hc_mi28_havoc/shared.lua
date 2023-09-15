
ENT.Base = "wac_hc_base"
ENT.Type = "anim"
ENT.Author = wac.author
ENT.Category = wac.aircraft.spawnCategory
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Havoc Mi-28"

ENT.Model = "models/bf2/helicopters/mil mi-28/mi28_b.mdl"

ENT.TopRotor = {
	pos = Vector(0,0,119),
	model = "models/bf2/helicopters/mil mi-28/mi28_r.mdl",
}

ENT.BackRotor = {
	pos = Vector(-435.09,18.46,164.91),
	model = "models/bf2/helicopters/mil mi-28/mi28_tr.mdl",
}

ENT.SmokePos = Vector(-80,0,50)
ENT.FirePos = Vector(-50,0,100)
ENT.MaxEnterDistance = 100
ENT.EngineForce	= 30
ENT.Weight = 9000

ENT.Seats = {
	{
		pos = Vector(54.74,0,85.22),
		exit = Vector(54.74,80,5),
		weapons = {"S-8"}
	},
	{
		pos = Vector(115.3,0,61),
		exit = Vector(115.3,60,5),
		weapons = {"2A42", "9M120"}
	},
}


ENT.Weapons = {
	["2A42"] = {
		class = "wac_pod_aimedgun",
		info = {
			ShootPos = Vector(120, 0, 20),
			ShootOffset = Vector(100, 0, 0),
			FireRate = 300,
			Sounds = {
				spin = "",
				shoot1p = "WAC/cannon/havoc_cannon_1p.wav",
				shoot3p = "WAC/cannon/havoc_cannon_3p.wav"
			}
		}
	},
	["S-8"] = {
		class = "wac_pod_hydra",
		info = {
			Pods = {
				Vector(3.22,72.94,49),
				Vector(3.22,-72.94,49),
			},
			Ammo = 40,
			FireRate = 300,
		}
	},
	["9M120"] = {
		class = "wac_pod_hellfire",
		info = {
			Pods = {
				Vector(3.22,102.38,59.59),
				Vector(3.22,-102.38,59.59),
			}
		}
	}
}


ENT.Sounds = {
	Start = "WAC/Heli/ah1_start.wav",
	Blades = "npc/attack_helicopter/aheli_rotor_loop1.wav",
	Engine = "WAC/heli/bellinternal.wav",
	MissileAlert = "HelicopterVehicle/MissileNearby.mp3",
	MissileShoot = "HelicopterVehicle/MissileShoot.mp3",
	MinorAlarm = "HelicopterVehicle/MinorAlarm.mp3",
	LowHealth = "HelicopterVehicle/LowHealth.mp3",
	CrashAlarm = "HelicopterVehicle/CrashAlarm.mp3",
}


ENT.Camera = {
	model = "models/bf2/helicopters/mil mi-28/mi28_w2.mdl",
	pos = Vector(181.44,0,42),
	offset = Vector(1,0,0),
	viewPos = Vector(7, 0, 3.5),
	maxAng = Angle(50, 90, 0),
	minAng = Angle(-5, -90, 0),
	seat = 2
}


ENT.WeaponAttachments = {

	gunMount1 = {
		model = "models/bf2/helicopters/mil mi-28/mi28_g2.mdl",
		pos = Vector(120,0,33),
		restrictPitch = true
	},
	
	gunMount2 = {
		model = "models/bf2/helicopters/mil mi-28/mi28_g1.mdl",
		pos = Vector(120,0,20),
		offset = Vector(2,0,0)
	},

	gun = {
		model = "models/bf2/helicopters/mil mi-28/mi28_g1.mdl",
		pos = Vector(120,0,20),
		offset = Vector(2,0,0)
	},
	
	radar1 = {
		model = "models/bf2/helicopters/mil mi-28/mi28_radar1.mdl",
		pos = Vector(181.44,0,56.65),
		restrictPitch = true
	},

}

