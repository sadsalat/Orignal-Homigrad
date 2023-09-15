local light_table = {
	L_HeadLampPos = Vector(-26,106,30.3),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(26,106,30.3),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(-28.5,-109.63,49.5),
	L_RearLampAng = Angle(40,-90,0),
	R_RearLampPos = Vector(28.5,-109.63,49.5),
	R_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		{pos = Vector(-23,106,30.23),size = 60, color = Color( 220,220,220,50)},
		{pos = Vector(-30,106,30.36),size = 60, color = Color( 220,220,220,50)},
		{pos = Vector(23,106,30.23),size = 60, color = Color( 220,220,220,50)},
		{pos = Vector(30,106,30.36),size = 60, color = Color( 220,220,220,50)},
	},
	
	Headlamp_sprites = { 
		{pos = Vector(-26,106,30.23),material = "sprites/light_ignorez",size = 80, color = Color( 220,220,220,120)},
		{pos = Vector(26,106,30.23),material = "sprites/light_ignorez",size = 80, color = Color( 220,220,220,120)},
	},
	
	Rearlight_sprites = {
		{pos = Vector(-35.5,-109.63,40.75),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		{pos = Vector(-35.5,-109.63,38),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		
		{pos = Vector(-24.5,-109.63,40.75),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		{pos = Vector(-24.5,-109.63,38),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		
		
		{pos = Vector(35.5,-109.63,40.75),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		{pos = Vector(35.5,-109.63,38),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		
		{pos = Vector(24.5,-109.63,40.75),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
		{pos = Vector(24.5,-109.63,38),material = "sprites/light_ignorez",size = 30,color = Color( 255, 0, 0,  50)},
	},
	Brakelight_sprites = {
		{pos = Vector(-35.5,-109.63,40.75),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		{pos = Vector(-35.5,-109.63,38),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		
		{pos = Vector(-24.5,-109.63,40.75),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		{pos = Vector(-24.5,-109.63,38),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		
		
		{pos = Vector(35.5,-109.63,40.75),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		{pos = Vector(35.5,-109.63,38),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		
		{pos = Vector(24.5,-109.63,40.75),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
		{pos = Vector(24.5,-109.63,38),material = "sprites/light_ignorez",size = 33,color = Color( 255, 0, 0,  50)},
	},
	RearMarker_sprites = {
		Vector(-42.87,-101.7,35.71),
		Vector(42.87,-101.7,35.71)
	},
	--[[
	FogLight_sprites = {
		{pos = Vector(-26.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(-27.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(-28.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(-29.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(-30.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(-31.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(-32.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		
		{pos = Vector(26.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(27.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(28.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(29.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(30.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(31.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
		{pos = Vector(32.06,109.39,15.74),material = "sprites/light_ignorez",size = 12, color = Color( 220,220,220,100)},
	},
	]]--
	
	Turnsignal_sprites = {
		Left = {
			Vector(-30,-109.16,40.87),
			Vector(-30,-109.31,38.06),
			
			{pos = Vector(-26.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(-27.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(-28.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(-29.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(-30.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(-31.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(-32.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
		},
		Right = {
			Vector(29.5,-109.16,40.87),
			Vector(29.5,-109.31,38.06),
			
			{pos = Vector(26.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(27.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(28.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(29.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(30.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(31.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
			{pos = Vector(32.06,109.39,15.74),material = "sprites/light_ignorez",size = 20},
		},
	},

	
	ems_sounds = {"simulated_vehicles/police/siren_madmax.wav","common/null.wav"},
	ems_sprites = {
		{
			pos = Vector(15.89,20.46,55.79),
			material = "sprites/light_glow02_add_noz",
			size = 60,
			Colors = {Color(0,0,250,250),Color(0,0,255,255),Color(0,0,250,250),Color(0,0,200,200),Color(0,0,150,150),Color(0,0,100,100),Color(0,0,50,50),Color(0,0,0,0)}, -- the script will go from color to color
			Speed = 0.05,
		}
	},
	
	SubMaterials = {
		off = {
			Base = {
				[1] = "",
				[3] = ""
			},
			Brake = {
				[1] = "models/madmax/lights/brake_1",
				[3] = ""
			},
		},
		on_lowbeam = {
			Base = {
				[1] = "models/madmax/lights/brake_1",
				[3] = "models/madmax/lights/lowbeam"
			},
			Brake = {
				[1] = "models/madmax/lights/brake_2",
				[3] = "models/madmax/lights/lowbeam"
			},
		},
		on_highbeam = {
			Base = {
				[1] = "models/madmax/lights/brake_1",
				[3] = "models/madmax/lights/highbeam"
			},
			Brake = {
				[1] = "models/madmax/lights/brake_2",
				[3] = "models/madmax/lights/highbeam"
			},
		},
	}
}
list.Set( "simfphys_lights", "madmax", light_table)

local light_table = {
	L_HeadLampPos = Vector( 115, 20, 0 ),
	L_HeadLampAng = Angle(10,5,0),
	R_HeadLampPos = Vector( 115, -20, 0 ),
	R_HeadLampAng = Angle(10,-5,0),
	
	L_RearLampPos = Vector(-115,20,5),
	L_RearLampAng = Angle(25,180,0),
	R_RearLampPos = Vector(-115,-20,5),
	R_RearLampAng = Angle(25,180,0),
	
	Headlight_sprites = {
		{pos = Vector(102,27.5,-1),material = "sprites/light_ignorez",size = 20, color = Color( 220,205,160,120)},
		{pos = Vector(102,-27.5,-1),material = "sprites/light_ignorez",size = 20, color = Color( 220,205,160,120)},
		{pos = Vector(102,21,-1),material = "sprites/light_ignorez",size = 20, color = Color( 220,205,160,120)},
		{pos = Vector(102,-21,-1),material = "sprites/light_ignorez",size = 20, color = Color( 220,205,160,120)},
		
		{pos = Vector(102,27.5,-1),size = 60, color = Color( 220,205,160,50)},
		{pos = Vector(102,-27.5,-1),size = 60, color = Color( 220,205,160,50)},
		{pos = Vector(102,21,-1),size = 60, color = Color( 220,205,160,50)},
		{pos = Vector(102,-21,-1),size = 60, color = Color( 220,205,160,50)},
	},
	Headlamp_sprites = {
		{pos = Vector(102,27.5,-1),material = "sprites/light_ignorez",size = 80, color = Color( 220,205,160,70)},
		{pos = Vector(102,-27.5,-1),material = "sprites/light_ignorez",size = 80, color = Color( 220,205,160,70)},
		{pos = Vector(102,21,-1),material = "sprites/light_ignorez",size = 80, color = Color( 220,205,160,70)},
		{pos = Vector(102,-21,-1),material = "sprites/light_ignorez",size = 80, color = Color( 220,205,160,70)},
	},
	Rearlight_sprites = {
		{pos = Vector(-121,25.5,5),material = "sprites/light_ignorez",size = 45,color = Color( 255, 0, 0,  150)},
		{pos = Vector(-121,-25.5,5),material = "sprites/light_ignorez",size = 45,color = Color( 255, 0, 0,  150)},
	},
	Brakelight_sprites = {
		{pos = Vector(-121,13.5,5),material = "sprites/light_ignorez",size = 45,color = Color( 255, 0, 0,  150)},
		{pos = Vector(-121,-13.5,5),material = "sprites/light_ignorez",size = 45,color = Color( 255, 0, 0,  150)},
	},
	Reverselight_sprites = {
		{pos = Vector(-121,19.5,5),material = "sprites/light_ignorez",size = 25,color = Color( 255, 255, 255, 100)},
		{pos = Vector(-121,-19.5,5),material = "sprites/light_ignorez",size = 25,color = Color( 255, 255, 255, 100)},
	},
	
	DelayOn = 0.5,
	DelayOff = 0.25,
	BodyGroups = {
		On = {8,0},
		Off = {8,1}
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(103.28,27,-9.54),
			Vector(103.28,28.5,-9.54),
			{pos = Vector(-121,25.5,5),material = "sprites/light_ignorez",size = 55,color = Color( 255, 0, 0,  165)},
		},
		Right = {
			Vector(103.28,-27,-9.54),
			Vector(103.28,-28.5,-9.54),
			{pos = Vector(-121,-25.5,5),material = "sprites/light_ignorez",size = 55,color = Color( 255, 0, 0,  165)},
		},
	},
	
	SubMaterials = {
		off = {
			Base = {
				[10] = ""
			},
			Brake = {
				[10] = "models/gtav/dukes/lights/brake"
			},
			Reverse = {
				[10] = "models/gtav/dukes/lights/reverse"
			},
			Brake_Reverse = {
				[10] = "models/gtav/dukes/lights/brake_reverse"
			},
		},
		on_lowbeam = {
			Base = {
				[10] = "models/gtav/dukes/lights/lowbeam"
			},
			Brake = {
				[10] = "models/gtav/dukes/lights/lowbeam_brake"
			},
			Reverse = {
				[10] = "models/gtav/dukes/lights/lowbeam_reverse"
			},
			Brake_Reverse = {
				[10] = "models/gtav/dukes/lights/lowbeam_brake_reverse"
			},
		},
		on_highbeam = {
			Base = {
				[10] = "models/gtav/dukes/lights/highbeam"
			},
			Brake = {
				[10] = "models/gtav/dukes/lights/highbeam_brake"
			},
			Reverse = {
				[10] = "models/gtav/dukes/lights/highbeam_reverse"
			},
			Brake_Reverse = {
				[10] = "models/gtav/dukes/lights/highbeam_brake_reverse"
			},
		},
	}
}
list.Set( "simfphys_lights", "dukes", light_table)

local light_table = {
	L_HeadLampPos = Vector( 28.5, 122, 31.5 ),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector( -28.5, 120, 31.5 ),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(23,-120,36),
	L_RearLampAng = Angle(25,-90,0),
	R_RearLampPos = Vector(-23,-120,36),
	R_RearLampAng = Angle(25,-90,0),

	Headlight_sprites = { 
		{pos = Vector(-33,121.5,31.5),material = "sprites/light_ignorez",size = 28, color = Color( 220,205,160,255)},
		{pos = Vector(-33,121.5,31.5),size = 64, color = Color( 220,205,160,100)},
		
		{pos = Vector(33,121.5,31.5),material = "sprites/light_ignorez",size = 28, color = Color( 220,205,160,255)},
		{pos = Vector(33,121.5,31.5),size = 64, color = Color( 220,205,160,100)},
	},
	Headlamp_sprites = { 
		{pos = Vector(-24,121.5,31.5),material = "sprites/light_ignorez",size = 28, color = Color( 220,205,160,255)},
		{pos = Vector(-24,121.5,31.5),size = 64, color = Color( 220,205,160,100)},
		
		{pos = Vector(24,121.5,31.5),material = "sprites/light_ignorez",size = 28, color = Color( 220,205,160,255)},
		{pos = Vector(24,121.5,31.5),size = 64, color = Color( 220,205,160,100)},
	},
	Rearlight_sprites = {
		Vector(33.5,-120,36),Vector(31.9,-120,36),Vector(30.3,-120,36),Vector(28.7,-120,36),Vector(27.1,-120,36),Vector(25.5,-120,36),Vector(23.9,-120,36),Vector(22.3,-120,36),Vector(20.7,-120,36),Vector(19.1,-120,36),Vector(17.5,-120,36),Vector(15.9,-120,36),Vector(14.3,-120,36),Vector(12.7,-120,36),Vector(11.1,-120,36),Vector(9.5,-120,36),Vector(7.9,-120,36),
		Vector(-33.5,-120,36),Vector(-31.9,-120,36),Vector(-30.3,-120,36),Vector(-28.7,-120,36),Vector(-27.1,-120,36),Vector(-25.5,-120,36),Vector(-23.9,-120,36),Vector(-22.3,-120,36),Vector(-20.7,-120,36),Vector(-19.1,-120,36),Vector(-17.5,-120,36),Vector(-15.9,-120,36),Vector(-14.3,-120,36),Vector(-12.7,-120,36),Vector(-11.1,-120,36),Vector(-9.5,-120,36),Vector(-7.9,-120,36)
	},
	Reverselight_sprites = {
		Vector(-17.6,-121.1,23.1),
		Vector(17.6,-121.1,23.1)
	},
	FrontMarker_sprites = {
		Vector(-30,120.5,18),
		Vector(30,120.5,18),
		Vector(-42.5,110.3,24.4),
		Vector(42.5,110.3,24.4)
	},
	RearMarker_sprites = {
		Vector(-41.5,-113,28),
		Vector(41.5,-113,28)
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(-30,120.5,18),
			Vector(-42.5,110.3,24.4),
		},
		Right = {
			Vector(30,120.5,18),
			Vector(42.5,110.3,24.4)
		},
		
		TurnBrakeLeft = {
			Vector(-33.5,-120,36),Vector(-31.9,-120,36),Vector(-30.3,-120,36),Vector(-28.7,-120,36),Vector(-27.1,-120,36),Vector(-25.5,-120,36),Vector(-23.9,-120,36),Vector(-22.3,-120,36),Vector(-20.7,-120,36),Vector(-19.1,-120,36),Vector(-17.5,-120,36),Vector(-15.9,-120,36),
		},
		
		TurnBrakeRight = {
			Vector(33.5,-120,36),Vector(31.9,-120,36),Vector(30.3,-120,36),Vector(28.7,-120,36),Vector(27.1,-120,36),Vector(25.5,-120,36),Vector(23.9,-120,36),Vector(22.3,-120,36),Vector(20.7,-120,36),Vector(19.1,-120,36),Vector(17.5,-120,36),Vector(15.9,-120,36),
		},
	},
	
	DelayOn = 2.1,
	DelayOff = 2.1,
	Animation = {
		On = "lightcoveropenreal",
		Off = "lightcoverclosereal"
	}
}
list.Set( "simfphys_lights", "charger", light_table)


local light_table = {
	ModernLights = true,
	
	L_HeadLampPos = Vector(87.8,24.1,22.7),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(87.8,-24.1,22.7),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-88,24.5,31.2),
	L_RearLampAng = Angle(25,180,0),
	R_RearLampPos = Vector(-88,-24.5,31.2),
	R_RearLampAng = Angle(25,180,0),
	
	Headlight_sprites = { 
		{pos = Vector(84.2,29.4,22.3),material = "sprites/light_ignorez",size = 18, color = Color(215,240,255,255)},
		{pos = Vector(84.2,29.4,22.3),size = 64, color = Color( 215,240,255,50)},
		
		{pos = Vector(84.2,-29.4,22.3),material = "sprites/light_ignorez",size = 18, color = Color(215,240,255,255)},
		{pos = Vector(84.2,-29.4,22.3),size = 64, color = Color( 215,240,255,50)},
		
		{pos = Vector(87.8,24.1,22.3),material = "sprites/light_ignorez",size = 18, color = Color(215,240,255,255)},
		{pos = Vector(87.8,24.1,22.3),size = 64, color = Color( 215,240,255,50)},
		
		{pos = Vector(87.8,-24.1,22.3),material = "sprites/light_ignorez",size = 18, color = Color(215,240,255,255)},
		{pos = Vector(87.8,-24.1,22.3),size = 64, color = Color( 215,240,255,50)},

	},
	Headlamp_sprites = { 
		{pos = Vector(90,-19,21.9),material = "sprites/light_ignorez",size = 18, color = Color(215,240,255,255)},
		{pos = Vector(90,-19,21.9),size = 64, color = Color( 215,240,255,50)},
		
		{pos = Vector(90,19,21.9),material = "sprites/light_ignorez",size = 18, color = Color(215,240,255,255)},
		{pos = Vector(90,19,21.9),size = 64, color = Color( 215,240,255,50)},
	},
	Rearlight_sprites = {
		Vector(-88,22.2,31.2),Vector(-86.2,26.9,30.9),
		Vector(-88,-22.2,31.2),Vector(-86.2,-26.9,30.9)
	},
	Brakelight_sprites = {
		Vector(-88,22.2,31.2),Vector(-86.2,26.9,30.9),
		Vector(-88,-22.2,31.2),Vector(-86.2,-26.9,30.9),
		
		Vector(-70,5.9,49.8),Vector(-70,4.425,49.85),Vector(-70,2.95,49.9),Vector(-70,1.475,49.95),Vector(-70,0,50),Vector(-70,-5.9,49.8),Vector(-70,-4.425,49.85),Vector(-70,-2.95,49.9),Vector(-70,-1.475,49.95),
	},
	Reverselight_sprites = {
		Vector(-90,16.6,30.9),
		Vector(-90,-16.6,30.9)
	},
	FogLight_sprites = {
		{pos = Vector(87.79,26.65,9.62),material = "sprites/light_ignorez",size = 16, color = Color(215,240,255,255)},
		{pos = Vector(87.79,26.65,9.62),size = 32, color = Color( 215,240,255,50)},
		
		{pos = Vector(87.79,-26.65,9.62),material = "sprites/light_ignorez",size = 16, color = Color(215,240,255,255)},
		{pos = Vector(87.79,-26.65,9.62),size = 32, color = Color( 215,240,255,50)},
	}
}
list.Set( "simfphys_lights", "alfons", light_table)

local light_table = {
	L_HeadLampPos = Vector(0,66.3,21.84),
	L_HeadLampAng = Angle(20,90,0),
	
	R_HeadLampPos = Vector(0,-58.01,70.71),
	R_HeadLampAng = Angle(0,90,0),

	L_RearLampPos = Vector(-14.9,-99.9,39.13),
	L_RearLampAng = Angle(40,-90,0),
	
	Headlight_sprites = { 
		Vector(-12.25,67.23,22.33),
		Vector(-3.91,67.03,22.14),
		Vector(4.63,66.33,21.96),
		Vector(13.4,66.72,22.16)
	},
	Headlamp_sprites = { 
		Vector(14.3,-59.87,70.12),
		Vector(7.34,-58.62,70.32),
		Vector(-7.79,-58.55,70.09),
		Vector(-14.97,-60.01,69.99)
	},
	Rearlight_sprites = {
		Vector(-14.9,-99.9,39.13)
	},
	Brakelight_sprites = {
		Vector(-14.9,-99.9,39.1)
	},
}
list.Set( "simfphys_lights", "elitejeep", light_table)


local V = {
	Name = "Synergy Elite Jeep",
	Model = "models/vehicles/buggy_elite.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",

	Members = {
		Mass = 1700,
		
		LightsTable = "elitejeep",
		
		FrontWheelRadius = 18,
		RearWheelRadius = 20,
		
		SeatOffset = Vector(0,0,-3),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
			pos = Vector(16,-35,21),
			ang = Angle(0,0,9)
			}
		},
		
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-15.69,-105.94,14.94),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(16.78,-105.46,14.35),
				ang = Angle(90,-90,0)
			}
		},
		
		StrengthenSuspension = true,
		
		FrontHeight = 13.5,
		FrontConstant = 27000,
		FrontDamping = 2200,
		FrontRelativeDamping = 1500, 
		
		RearHeight = 13.5,
		RearConstant = 32000,
		RearDamping = 2200,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.4,
		GripOffset = 0,
		BrakePower = 40,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 100,
		PowerbandStart = 2500,
		PowerbandEnd = 7300,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(20.92,6.95,26.83),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 0.6,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/v8elite/v8elite_idle.wav",
		
		snd_low = "simulated_vehicles/v8elite/v8elite_low.wav",
		snd_low_revdown = "simulated_vehicles/v8elite/v8elite_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/v8elite/v8elite_mid.wav",
		snd_mid_gearup = "simulated_vehicles/v8elite/v8elite_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_4.wav",
		
		DifferentialGear = 0.38,
		Gears = {-0.1,0,0.1,0.18,0.25,0.31,0.40}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_v8elite", V )

local V = {
	Name = "Synergy Van",
	Model = "models/vehicles/7seatvan.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Half Life 2 / Synergy",

	Members = {
		Mass = 2500,
		
		FrontWheelRadius = 15.5,
		RearWheelRadius = 15.5,
		
		SeatOffset = Vector(0,0,-5),
		SeatPitch = 6,
		
		PassengerSeats = {
			{
				pos = Vector(27,60,33),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(0,60,33),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(30,-25,37.5),
				ang = Angle(0,90,0)
			},
			{
				pos = Vector(-30,-25,37.5),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(-30,-60,37.5),
				ang = Angle(0,-90,0)
			},
			{
				pos = Vector(30,-60,37.5),
				ang = Angle(0,90,0)
			}
		},
		
		FrontHeight = 12,
		FrontConstant = 45000,
		FrontDamping = 2500,
		FrontRelativeDamping = 2500,
		
		RearHeight = 12,
		RearConstant = 45000,
		RearDamping = 2500,
		RearRelativeDamping = 2500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 350,
		
		TurnSpeed = 8,
		
		MaxGrip = 45,
		Efficiency = 1.8,
		GripOffset = 0,
		BrakePower = 55,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 80,
		PowerbandStart = 1000,
		PowerbandEnd = 5500,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-47.65,-76.59,47.43),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",
		
		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.8,
		
		DifferentialGear = 0.52,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_van", V )


local V = {
	Name = "1969 Dodge Charger",
	Model = "models/vehicles/cars/69charger.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	Members = {
		Mass = 1700,
		
		LightsTable = "charger",
		
		FrontWheelRadius = 15,
		RearWheelRadius = 15,
		
		SeatOffset = Vector(0,0,-2.5),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
				pos = Vector(20,0,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(20,-30,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(-20,-30,20),
				ang = Angle(0,0,9)
			}
		},
		
		ExhaustPositions = {
			{
				pos = Vector(17.7,-121,17.5),
				ang = Angle(90,-90,0)
			},
			{
				pos = Vector(-17.7,-121,17.5),
				ang = Angle(90,-90,0)
			}
		},
		
		FrontHeight = 13,	
		FrontConstant = 28000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 12,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 43,
		Efficiency = 1.45,
		GripOffset = -2,
		BrakePower = 50,
		
		IdleRPM = 750,
		LimitRPM = 5600,
		PeakTorque = 230,
		PowerbandStart = 1000,
		PowerbandEnd = 5400,
		Turbocharged = false,
		Supercharged = false,
		
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 80,
		FuelFillPos = Vector(-37.29,-92.65,46.53),
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.95,
		snd_idle = "simulated_vehicles/master_chris_charger69/charger_idle.wav",
		
		snd_low = "simulated_vehicles/master_chris_charger69/charger_low.wav",
		snd_low_revdown = "simulated_vehicles/master_chris_charger69/charger_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/master_chris_charger69/charger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/master_chris_charger69/charger_second.wav",
		snd_mid_geardown = "simulated_vehicles/master_chris_charger69/charger_shiftdown.wav",
		snd_mid_pitch = 1.15,
		
		snd_horn = "simulated_vehicles/horn_3.wav",
		
		DifferentialGear = 0.7, 
		Gears = {-0.12,0,0.12,0.21,0.32,0.42}
	}
}
if (file.Exists( "models/vehicles/cars/69charger.mdl", "GAME" )) then
	list.Set( "simfphys_vehicles", "sim_fphys_charger", V )
end



local V = {
	Name = "Mad Max Interceptor",
	Model = "models/vehicles/madmax/interceptordrive.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",

	Members = {
		Mass = 1385,
		AirFriction = -1500,
		
		LightsTable = "madmax",
		
		FrontWheelRadius = 14.6,
		RearWheelRadius = 15.6,
		
		SeatOffset = Vector(-4,0,-4),
		SeatPitch = 0,
		
		PassengerSeats = {
			{
				pos = Vector(21,0,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(21,-30,20),
				ang = Angle(0,0,9)
			},
			{
				pos = Vector(-21,-30,20),
				ang = Angle(0,0,9)
			}
		},
		
				
		ExhaustPositions = {
			{
				pos = Vector(49,-38,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(49,-34.5,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(49,-31,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(49,-27.5,23.5),
				ang = Angle(30,0,0)
			},
			{
				pos = Vector(-49,-38,23.5),
				ang = Angle(-30,0,0)
			},
			{
				pos = Vector(-49,-34.5,23.5),
				ang = Angle(-30,0,0)
			},
			{
				pos = Vector(-49,-31,23.5),
				ang = Angle(-30,0,0)
			},
			{
				pos = Vector(-49,-27.5,23.5),
				ang = Angle(-30,0,0)
			}
		},
		
		ModelInfo = {
			LinkDoorAnims = {
				["enter2"] = {
					enter = "enter1",
					exit = "exit1",
				},
				["enter1"] = {
					enter = "enter2",
					exit = "exit2",
				}
			}
		},
		
		FrontHeight = 10,
		FrontConstant = 28000,
		FrontDamping = 2800,
		FrontRelativeDamping = 2800,
		
		RearHeight = 8,
		RearConstant = 32000,
		RearDamping = 2900,
		RearRelativeDamping = 2900,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 44,
		Efficiency = 1.2,
		GripOffset = -3.8,
		BrakePower = 60,
		
		IdleRPM = 800,
		LimitRPM = 7000,
		PeakTorque = 200,
		PowerbandStart = 2000,
		PowerbandEnd = 6500,
		Turbocharged = false,
		Supercharged = true,
		
		FuelFillPos = Vector(-43.17,-72.93,49),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 100,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.85,
		snd_idle = "simulated_vehicles/shelby/shelby_idle.wav",
		
		snd_low = "simulated_vehicles/shelby/shelby_low.wav",
		snd_low_revdown = "simulated_vehicles/shelby/shelby_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/shelby/shelby_mid.wav",
		snd_mid_gearup = "simulated_vehicles/shelby/shelby_second.wav",
		snd_mid_geardown = "simulated_vehicles/shelby/shelby_shiftdown.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_7.wav",
		
		DifferentialGear = 0.58,
		Gears = {-0.12,0,0.12,0.21,0.32,0.40,0.48}
	}
}
if (file.Exists( "models/vehicles/madmax/interceptordrive.mdl", "GAME" )) then
	list.Set( "simfphys_vehicles", "sim_fphys_interceptor", V )
end


local V = {
	Name = "Alfa Romeo Brera",
	Model = "models/red_hd_brera/red_hd_brera.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1700,
		
		EnginePos = Vector(65.01,0,35),
		
		LightsTable = "alfons",
		
		CustomWheels = true,
		CustomSuspensionTravel = 15,
		
		CustomWheelModel = "models/red_hd_brera/red_hd_brera_wheel.mdl",
		CustomWheelPosFL = Vector(54,34.5,9),
		CustomWheelPosFR = Vector(54,-34.5,9),
		CustomWheelPosRL = Vector(-59,34.5,9),	
		CustomWheelPosRR = Vector(-59,-34.5,9),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-11,-19,42),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(-3,-18,10),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-30,-18,10),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-30,18,10),
				ang = Angle(0,-90,10)
			}
		},
		
		Backfire = true,
		ExhaustPositions = {
			{
				pos = Vector(-94.91,24.24,9.65),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-96.27,18.81,9.63),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-94.91,-24.24,9.65),
				ang = Angle(90,180,0)
			},
			{
				pos = Vector(-96.27,-18.81,9.63),
				ang = Angle(90,180,0)
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 29000,
		FrontDamping = 2500,
		FrontRelativeDamping = 2500,
		
		RearHeight = 8,
		RearConstant = 29000,
		RearDamping = 2500,
		RearRelativeDamping = 2500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 43,
		Efficiency = 1.6,
		GripOffset = 0,
		BrakePower = 50,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		Revlimiter = true,
		PeakTorque = 120,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = true,
		Supercharged = false,
		
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 65,
		
		PowerBias = 0,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/alfaromeo/alfons_idle.wav",
		
		snd_low ="simulated_vehicles/alfaromeo/alfons_low.wav",
		snd_low_revdown = "simulated_vehicles/alfaromeo/alfons_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/alfaromeo/alfons_mid.wav",
		snd_mid_gearup = "simulated_vehicles/alfaromeo/alfons_gear.wav",
		snd_mid_geardown = "simulated_vehicles/alfaromeo/alfons_shiftdown.wav",
		snd_mid_pitch = 1,
		
		DifferentialGear = 0.5,
		Gears = {-0.12,0,0.12,0.21,0.32,0.42,0.5}
	}
}
if file.Exists( "models/red_hd_brera/red_hd_brera.mdl", "GAME" ) then
	list.Set( "simfphys_vehicles", "sim_fphys_alfons", V )
end


local V = {
	Name = "GTA 5 Dukes",
	Model = "models/blu/gtav/dukes/dukes.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = "Base",
	SpawnOffset = Vector(0,0,20),
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1700,
		
		EnginePos = Vector(69.61,0,15),
		
		LightsTable = "dukes",
		
		CustomWheels = true,
		CustomSuspensionTravel = 15,
		
		CustomWheelModel = "models/winningrook/gtav/dukes/dukes_wheel.mdl",
		CustomWheelPosFL = Vector(63.5,36,-13),
		CustomWheelPosFR = Vector(63.5,-36,-13),
		CustomWheelPosRL = Vector(-64,36.5,-9),
		CustomWheelPosRR = Vector(-64,-36.5,-9),
		CustomWheelAngleOffset = Angle(0,-90,0),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-18,-18,19),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(-3,-19,-13),
				ang = Angle(0,-90,17)
			}
		},
		
		ExhaustPositions = {
			{
				pos = Vector(-122.25,20.93,-7.28),
				ang = Angle(90,165,0),
				OnBodyGroups = { 
					[6] = {0},
				}
			},
			{
				pos = Vector(-122.1,-20.95,-7.42),
				ang = Angle(90,195,0),
				OnBodyGroups = { 
					[6] = {0},
				}
			},
			{
				pos = Vector(-43.43,-38.07,-12.96),
				ang = Angle(90,-125,0),
				OnBodyGroups = { 
					[6] = {1},
				}
			},
			{
				pos = Vector(-35.28,-40.72,-13.18),
				ang = Angle(90,-125,0),
				OnBodyGroups = { 
					[6] = {1},
				}
			},
			{
				pos = Vector(-43.43,38.07,-12.96),
				ang = Angle(90,125,0),
				OnBodyGroups = { 
					[6] = {1},
				}
			},
			{
				pos = Vector(-35.28,40.72,-13.18),
				ang = Angle(90,125,0),
				OnBodyGroups = { 
					[6] = {1},
				}
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 29000,
		FrontDamping = 2500,
		FrontRelativeDamping = 2500,
		
		RearHeight = 9,
		RearConstant = 29000,
		RearDamping = 2500,
		RearRelativeDamping = 2500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 43,
		Efficiency = 1.2,
		GripOffset = -2,
		BrakePower = 40,
		
		IdleRPM = 600,
		LimitRPM = 7700,
		PeakTorque = 200,
		PowerbandStart = 1500,
		PowerbandEnd = 7400,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-92.72,39.75,8.31),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 80,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.8,
		snd_idle = "simulated_vehicles/gta5_dukes/dukes_idle.wav",
		
		snd_low = "simulated_vehicles/gta5_dukes/dukes_low.wav",
		snd_low_revdown = "simulated_vehicles/gta5_dukes/dukes_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/gta5_dukes/dukes_mid.wav",
		snd_mid_gearup = "simulated_vehicles/gta5_dukes/dukes_second.wav",
		snd_mid_pitch = 1,
		
		snd_horn = "simulated_vehicles/horn_3.wav",
		
		DifferentialGear = 0.6,
		Gears = {-0.12,0,0.12,0.21,0.32,0.42,0.5}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_dukes", V )
