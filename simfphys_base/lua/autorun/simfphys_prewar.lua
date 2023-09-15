local Category = "Half Life 2 - Prewar"

local light_table = {
	L_HeadLampPos = Vector(118.8,30.5,41.8),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(118.8,-35,41.8),
	R_HeadLampAng = Angle(15,0,0),
	
	Headlight_sprites = { 
		Vector(118.8,30.5,41.8),
		Vector(118.8,-35,41.8)
	},
	Headlamp_sprites = {
		Vector(118.8,30.5,41.8),
		Vector(118.8,-35,41.8)
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(116.88,36.33,53.57),
			Vector(115.4,37.9,53.59),
			Vector(113.67,39.87,53.72),
			Vector(-100.76,20.37,18.99),
			Vector(-100.71,18.55,18.97),
			Vector(-100.71,16.69,19.1),
		},
		Right = {
			Vector(114.88,-40.33,53.57),
			Vector(113.4,-41.9,53.59),
			Vector(111.67,-43.87,53.72),
			Vector(-100.76,-22.37,18.99),
			Vector(-100.71,-20.55,18.97),
			Vector(-100.71,-18.69,19.1),
		},
	}
}
list.Set( "simfphys_lights", "avia", light_table)


local light_table = {
	L_HeadLampPos = Vector(-36.87,87.86,47.32),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(36.33,87.27,46.67),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(43.03,-194,25),
	L_RearLampAng = Angle(60,-90,0),
	R_RearLampPos = Vector(-43.03,-194,25),
	R_RearLampAng = Angle(60,-90,0),
	
	Headlight_sprites = { 
		{pos = Vector(-36.87,87.86,47.32),material = "sprites/light_ignorez",size = 64},
		{pos = Vector(-36.87,87.86,47.32),size = 75},
		
		{pos = Vector(36.33,87.27,46.67),material = "sprites/light_ignorez",size = 64},
		{pos = Vector(36.33,87.27,46.67),size = 75}
	},
	Headlamp_sprites = { 
		{pos = Vector(-36.87,87.86,47.32),size = 110},
		{pos = Vector(36.33,87.27,46.67),size = 110}
	},
	Rearlight_sprites = {
		Vector(43.04,-194,21.05),
		Vector(43.03,-194,22.49),
		Vector(43.23,-194,23.34),
		Vector(43.14,-194,24.32),
		
		Vector(-43.04,-194,21.05),
		Vector(-43.03,-194,22.49),
		Vector(-43.23,-194,23.34),
		Vector(-43.14,-194,24.32)
	},
	Brakelight_sprites = {
		Vector(43.04,-194,21.05),
		Vector(43.03,-194,22.49),
		Vector(43.23,-194,23.34),
		Vector(43.14,-194,24.32),
		
		Vector(-43.04,-194,21.05),
		Vector(-43.03,-194,22.49),
		Vector(-43.23,-194,23.34),
		Vector(-43.14,-194,24.32)
	},
	FrontMarker_sprites = {
		Vector(55.4,-156.48,56.9),
		Vector(56.74,-70.56,55.19),
		Vector(50,73.98,57.71),
		Vector(-53.4,-156.48,56.9),
		Vector(-54,-70.56,55.19),
		Vector(-50,73.98,57.71)
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(-38.2,87.81,58.93),
			Vector(-42.96,-193.67,28.29),
		},
		Right = {
			Vector(37.8,87.41,58.52),
			Vector(43.38,-194.54,28.99),
		},
	}
}
list.Set( "simfphys_lights", "gaz", light_table)


local light_table = {
	L_HeadLampPos = Vector(71.15,23.26,27.92),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(71.07,-23.15,27.95),
	R_HeadLampAng = Angle(15,0,0),

	L_RearLampPos = Vector(-72,26.5,29),
	L_RearLampAng = Angle(30,185,0),
	R_RearLampPos = Vector(-72,-26.5,29),
	R_RearLampAng = Angle(30,175,0),
	
	Headlight_sprites = { 
		Vector(71.15,23.26,27.92),
		Vector(71.07,-23.15,27.95)
	},
	Headlamp_sprites = { 
		{pos = Vector(71.15,23.26,27.92),size = 80, color = Color( 220,205,160,50)},
		{pos = Vector(71.07,-23.15,27.95),size = 80, color = Color( 220,205,160,50)},
	},
	Rearlight_sprites = {
		Vector(-72,22,29),Vector(-72,23.5,29),Vector(-72,25,29),Vector(-72,26.5,29),Vector(-72,28,29),Vector(-72,29.5,29),Vector(-72,31,29),
		Vector(-72,-22,29),Vector(-72,-23.5,29),Vector(-72,-25,29),Vector(-72,-26.5,29),Vector(-72,-28,29),Vector(-72,-29.5,29),Vector(-72,-31,29),
	},
	Brakelight_sprites = {
		Vector(-72,22,29),Vector(-72,23.5,29),Vector(-72,25,29),Vector(-72,26.5,29),Vector(-72,28,29),Vector(-72,29.5,29),Vector(-72,31,29),
		Vector(-72,-22,29),Vector(-72,-23.5,29),Vector(-72,-25,29),Vector(-72,-26.5,29),Vector(-72,-28,29),Vector(-72,-29.5,29),Vector(-72,-31,29),
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(-72.14,29.97,31.85),
			Vector(-72.14,27.97,31.85),
			Vector(-72.14,25.97,31.85),
			Vector(72.19,24.97,20.34),
		},
		Right = {
			Vector(-72.54,-30.32,31.81),
			Vector(-72.54,-28.32,31.81),
			Vector(-72.54,-26.32,31.81),
			Vector(72.19,-24.6,20.34),
		},
	},
}
list.Set( "simfphys_lights", "golf", light_table)

local light_table = {
	L_HeadLampPos = Vector(-36.74,121.35,45.43),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(32.15,118.88,45.13),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(-47,-133.97,28.14),
	L_RearLampAng = Angle(30,-90,0),
	R_RearLampPos = Vector(44.13,-134.42,27.34),
	R_RearLampAng = Angle(30,-90,0),
	
	Headlight_sprites = { 
		{pos = Vector(-36.74,121.35,45.43),material = "sprites/light_ignorez",size = 40},
		{pos = Vector(-36.74,121.35,45.43),size = 55},
		
		{pos = Vector(32.15,118.88,45.13),material = "sprites/light_ignorez",size = 40},
		{pos = Vector(32.15,118.88,45.13),size = 55},
	},
	Headlamp_sprites = { 
		{pos = Vector(-36.74,121.35,45.43),size = 80},
		{pos = Vector(32.15,118.88,45.13),size = 80},
	},
	Rearlight_sprites = {
		Vector(-47,-133.97,28.14),
		Vector(44.13,-134.42,27.34),
	},
	Reverselight_sprites = {
		Vector(32.33,-134.11,27.34),
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(-39.88,119.03,66.5),
		},
		Right = {
			Vector(36.11,119.71,66.5),
		},
		
		TurnBrakeLeft = {
			Vector(-47,-133.97,28.14),
		},
		
		TurnBrakeRight = {
			Vector(44.13,-134.42,27.34),
		},
	},
}
list.Set( "simfphys_lights", "liaz", light_table)

local light_table = {
	L_HeadLampPos = Vector(75.7,28.09,31.28),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(75.7,-28.09,31.28),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-99.86,23.01,29.9),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector(-99.86,-23.01,29.9),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		{pos = Vector(75.7,28.09,31.28),material = "sprites/light_ignorez",size = 32, color = Color( 220,205,160,255)},
		{pos = Vector(75.7,28.09,31.28),size = 64, color = Color( 220,205,160,50)},
		
		{pos = Vector(75.7,-28.09,31.28),material = "sprites/light_ignorez",size = 32, color = Color( 220,205,160,255)},
		{pos = Vector(75.7,-28.09,31.28),size = 64, color = Color( 220,205,160,50)},
	},
	Headlamp_sprites = { 
		{pos = Vector(75.7,28.09,31.28),size = 80, color = Color( 220,205,160,80)},
		{pos = Vector(75.7,-28.09,31.28),size = 80, color = Color( 220,205,160,80)},
	},
	Rearlight_sprites = {
		Vector(-99.8,21.57,29.93),Vector(-99.86,23.01,29.9),Vector(-99.75,24.52,29.92),
		Vector(-99.8,-21.57,29.93),Vector(-99.86,-23.01,29.9),Vector(-99.75,-24.52,29.92),
	},
	Brakelight_sprites = {
		Vector(-99.8,21.57,29.93),Vector(-99.86,23.01,29.9),Vector(-99.75,24.52,29.92),
		Vector(-99.8,-21.57,29.93),Vector(-99.86,-23.01,29.9),Vector(-99.75,-24.52,29.92),
	},
	Reverselight_sprites = {
		Vector(-99.98,27.41,30.76),
		Vector(-99.98,-27.41,30.76)
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(80.52,25.03,20.21),
			Vector(80.47,23.03,20.25),
			Vector(-100.5,18.95,29.97),
		},
		Right = {
			Vector(80.52,-25.03,20.21),
			Vector(80.47,-23.03,20.25),
			Vector(-100.5,-18.95,29.97),
		},
	},
}
list.Set( "simfphys_lights", "moskvich", light_table)

local light_table = {
	L_HeadLampPos = Vector(-28.77,70.69,30.73),
	L_HeadLampAng = Angle(15,90,0),
	R_HeadLampPos = Vector(29.13,70.77,30.58),
	R_HeadLampAng = Angle(15,90,0),
	
	L_RearLampPos = Vector(30.83,-78.44,25),
	L_RearLampAng = Angle(45,-95,0),
	R_RearLampPos = Vector(-30.83,-78.50,25),
	R_RearLampAng = Angle(45,-85,0),
	
	Headlight_sprites = { 
		Vector(-28.77,70.69,30.73),
		Vector(29.13,70.77,30.58)
	},
	Headlamp_sprites = { 
		{pos = Vector(-28.77,70.69,30.73),size = 80, color = Color( 220,205,160,50)},
		{pos = Vector(29.13,70.77,30.58),size = 80, color = Color( 220,205,160,50)},
	},
	Rearlight_sprites = {
		Vector(30.83,-78.44,24.),Vector(30.83,-78.44,25),Vector(30.83,-78.44,26),
		Vector(-30.83,-78.50,24),Vector(-30.83,-78.50,25),Vector(-30.83,-78.50,26)
	},
	Brakelight_sprites = {
		Vector(30.83,-78.44,24.),Vector(30.83,-78.44,25),Vector(30.83,-78.44,26),
		Vector(-30.83,-78.50,24),Vector(-30.83,-78.50,25),Vector(-30.83,-78.50,26)
	},
	Reverselight_sprites = {
		Vector(30.77,-76.39,20.09),
		Vector(-31.01,-76.14,20.29),
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(-28.5,70.97,20.41),
			Vector(-30,70.97,20.41),
			Vector(-31.5,70.97,20.41),
			
			Vector(-30.63,-79,34),
			Vector(-30.63,-79.,32),
			Vector(-30.63,-79,30),
			Vector(-30.63,-79,28),
		},
		Right = {
			Vector(28.5,70.97,20.41),
			Vector(30,70.97,20.41),
			Vector(31.5,70.97,20.41),
			
			Vector(30.63,-79,34),
			Vector(30.63,-79.,32),
			Vector(30.63,-79,30),
			Vector(30.63,-79,28),
		},
	}
}
list.Set( "simfphys_lights", "trabbi", light_table)

local light_table = {
	L_HeadLampPos = Vector(97.45,36.17,37.08),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(97.23,-36.19,37.03),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-117,-32.5,41),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector(-117,32.5,41),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		Vector(97.41,33.55,37.05),Vector(97.45,36.17,37.08),Vector(97.61,38.86,37.14),
		Vector(97.25,-33.56,37.04),Vector(97.23,-36.19,37.03),Vector(97.13,-38.64,37.08)
	},
	Headlamp_sprites = { 
		Vector(97.45,36.17,37.08),
		Vector(97.23,-36.19,37.03)
	},
	Rearlight_sprites = {
		{pos = Vector(-117,-32.5,41),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-117,-32.5,41),size = 45,color = Color( 255, 0, 0,  250)},
		
		{pos = Vector(-117,32.5,41),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-117,32.5,41),size = 45,color = Color( 255, 0, 0,  250)},
	},
	Reverselight_sprites = {
		Vector(-117,-32.5,45),Vector(-117,-34.5,45),Vector(-117,-30.5,45),
		Vector(-117,32.5,45),Vector(-117,34.5,45),Vector(-117,30.5,45)
	},
	
	Turnsignal_sprites = {
		Left = {
			Vector(96.64,36.27,27.21),
			Vector(96.64,35,27.21),
		},
		Right = {
			Vector(96.64,-36.27,27.21),
			Vector(96.64,-35,27.21),
		},
		TurnBrakeLeft = {
			{pos = Vector(-117,32.5,41),material = "sprites/light_ignorez",size = 50},
			{pos = Vector(-117,32.5,41),size = 55},
		},
		TurnBrakeRight = {
			{pos = Vector(-117,-32.5,41),material = "sprites/light_ignorez",size = 50},
			{pos = Vector(-117,-32.5,41),size = 55},
		},
	},
}
list.Set( "simfphys_lights", "van", light_table)

local light_table = {
	L_HeadLampPos = Vector(91.33,30.44,30.63),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(91.33,-30.44,30.63),
	R_HeadLampAng = Angle(15,0,0),

	L_RearLampPos = Vector( -102.69,29.97,34.21),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector( -102.69,-29.97,34.21),
	R_RearLampAng = Angle(45,180,0),

	Headlight_sprites = { 
		Vector(91.33,30.44,30.63),
		Vector(91.33,-30.44,30.63)
	},
	Headlamp_sprites = { 
		Vector(91.33,30.44,30.63),
		Vector(91.33,-30.44,30.63)
	},
	Rearlight_sprites = {
		{pos = Vector(-102.23,30,35.85),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.23,30,35.85),size = 45,color = Color( 255, 0, 0,  90)},
		
		{pos = Vector(-102.23,-30,35.85),material = "sprites/light_ignorez",size = 35,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.23,-30,35.85),size = 45,color = Color( 255, 0, 0,  90)},
	},
	Brakelight_sprites = {
		{pos = Vector(-102.23,-30,35.85),material = "sprites/light_ignorez",size = 45,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.23,-30,35.85),size = 50,color = Color( 255, 0, 0,  150)},
		
		{pos = Vector(-102.23,30,35.85),material = "sprites/light_ignorez",size = 45,color = Color( 255, 60, 0,  125)},
		{pos = Vector(-102.23,30,35.85),size = 50,color = Color( 255, 0, 0,  150)},
	},
	Reverselight_sprites = {
		Vector(-101.8,-29.4,30.7),Vector(-101.8,-31.09,30.7),
		Vector(-101.8,29.4,30.7),Vector(-101.8,31.09,30.7),
	},
	Turnsignal_sprites = {
		Left = {
			Vector(-102.62,31,33.24),
			Vector(-102.62,29,33.24),
			Vector(92.09,31,22.4),
			Vector(91.71,33,22.4),
		},
		Right = {
			Vector(-102.62,-31,33.24),
			Vector(-102.62,-29,33.24),
			Vector(92.09,-31,22.4),
			Vector(91.71,-33,22.4),
		},
	},
}
list.Set( "simfphys_lights", "volga", light_table)

local light_table = {
	L_HeadLampPos = Vector(87.3,29.59,35.42),
	L_HeadLampAng = Angle(15,0,0),
	R_HeadLampPos = Vector(87.34,-31.76,35.52),
	R_HeadLampAng = Angle(15,0,0),
	
	L_RearLampPos = Vector(-95.5,22.25,32),
	L_RearLampAng = Angle(45,180,0),
	R_RearLampPos = Vector(-95.5,-24.75,32),
	R_RearLampAng = Angle(45,180,0),
	
	Headlight_sprites = { 
		Vector(87.3,29.59,35.42),
		Vector(87.34,-31.76,35.52)
	},
	Headlamp_sprites = { 
		Vector(87.3,29.59,35.42),
		Vector(87.34,-31.76,35.52)
	},
	
	Rearlight_sprites = {
		Vector(-95.5,21,34),Vector(-95.5,21,33),Vector(-95.5,21,32),Vector(-95.5,22.25,34),Vector(-95.5,22.25,32),Vector(-95.5,23.5,34),Vector(-95.5,23.5,33),Vector(-95.5,23.5,32),
		Vector(-95.5,-23.5,34),Vector(-95.5,-23.5,33),Vector(-95.5,-23.5,32),Vector(-95.5,-24.75,34),Vector(-95.5,-24.75,32),Vector(-95.5,-26,34),Vector(-95.5,-26,33),Vector(-95.5,-26,32)
	},
	Brakelight_sprites = {
		Vector(-95.5,15.5,34.8),Vector(-95.5,15.5,33.4),Vector(-95.5,15.5,32.6),Vector(-95.5,15.5,31.2),
		Vector(-95.5,-18,34.8),Vector(-95.5,-18,33.4),Vector(-95.5,-18,32.6),Vector(-95.5,-18,31.2)
	},
	Reverselight_sprites = {
		Vector(-95.5,18.25,34.8),Vector(-95.5,18.25,33.4),Vector(-95.5,18.25,32.6),Vector(-95.5,18.25,31.2),
		Vector(-95.5,-20.75,34.8),Vector(-95.5,-20.75,33.4),Vector(-95.5,-20.75,32.6),Vector(-95.5,-20.75,31.2)
	},
	Turnsignal_sprites = {
		Left = {
			Vector(86.78,22.39,31.92),
			Vector(-95.41,26.7,33.76),
			Vector(-95.42,26.72,32.22),
		},

		Right = {
			Vector(86.78,-24.39,31.92),
			Vector(-95.41,-28.7,33.76),
			Vector(-95.42,-28.72,32.22),
		},
	},
}
list.Set( "simfphys_lights", "zaz", light_table)

local V = {
	Name = "HL2 Golf",
	Model = "models/blu/hatchback/pw_hatchback.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 800,
		
		EnginePos = Vector(54.27,0,37.26),
		
		LightsTable = "golf",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/hatchback/hatchback_wheel.mdl",
		CustomWheelPosFL = Vector(44.5,28,12),
		CustomWheelPosFR = Vector(44.5,-28,12),
		CustomWheelPosRL = Vector(-46,29.5,12),
		CustomWheelPosRR = Vector(-46,-29.5,12),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,2),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-8.5,-16,44),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(5,-16,14),
				ang = Angle(0,-90,20)
			},
			{
				pos = Vector(-24,-16,14),
				ang = Angle(0,-90,20)
			},
			{
				pos = Vector(-24,16,14),
				ang = Angle(0,-90,20)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 20000,
		FrontDamping = 1000,
		FrontRelativeDamping = 500,
		
		RearHeight = 6.5,
		RearConstant = 20000,
		RearDamping = 1000,
		RearRelativeDamping = 500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 23,
		Efficiency = 1,
		GripOffset = -0.7,
		BrakePower = 25,
		
		IdleRPM = 750,
		LimitRPM = 6200,
		PeakTorque = 75,
		PowerbandStart = 1750,
		PowerbandEnd = 5700,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-61.59,32.11,31.83),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = -1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/4banger/4banger_idle.wav",
		
		snd_low = "simulated_vehicles/4banger/4banger_low.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/4banger/4banger_mid.wav",
		snd_mid_gearup = "simulated_vehicles/4banger/4banger_second.wav",
		snd_mid_pitch = 0.8,
		
		snd_horn = "simulated_vehicles/horn_3.wav",
		
		DifferentialGear = 0.78,
		Gears = {-0.08,0,0.08,0.18,0.26,0.33}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwhatchback", V )


local V = {
	Name = "HL2 Van",
	Model = "models/blu/van/pw_van.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,
	
	Members = {
		Mass = 2500,
		
		EnginePos = Vector(89.98,0,51.3),
		
		LightsTable = "van",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/van/van_wheel.mdl",
		CustomWheelPosFL = Vector(45,44,20),
		CustomWheelPosFR = Vector(45,-44,20),
		CustomWheelPosRL = Vector(-72,44,20),
		CustomWheelPosRR = Vector(-72,-44,20),
		CustomWheelAngleOffset = Angle(0,-90,0),
		
		CustomMassCenter = Vector(0,0,15),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(36,-23,72),
		SeatPitch = 8,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(45,-27,33),
				ang = Angle(0,-90,9)
			},
			{
				pos = Vector(45,0,33),
				ang = Angle(0,-90,9)
			},
			{
				pos = Vector(-38,-29,28),
				ang = Angle(0,0,0)
			}
		},
		
		FrontHeight = 12,
		FrontConstant = 45000,
		FrontDamping = 3500,
		FrontRelativeDamping = 3500,
		
		RearHeight = 12,
		RearConstant = 45000,
		RearDamping = 3500,
		RearRelativeDamping = 3500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 350,
		
		TurnSpeed = 8,
		
		MaxGrip = 45,
		Efficiency = 1.8,
		GripOffset = -2,
		BrakePower = 55,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 95,
		PowerbandStart = 1000,
		PowerbandEnd = 5500,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-93.45,46.02,42.24),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic3/generic3_idle.wav",
		
		snd_low = "simulated_vehicles/generic3/generic3_low.wav",
		snd_low_revdown = "simulated_vehicles/generic3/generic3_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/generic3/generic3_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic3/generic3_second.wav",
		snd_mid_pitch = 1,
		
		DifferentialGear = 0.52,
		Gears = {-0.1,0,0.1,0.2,0.3,0.4}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwvan", V )


local V = {
	Name = "HL2 Moskvich",
	Model = "models/blu/moskvich/moskvich.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1350,
		
		EnginePos = Vector(55.76,0,44.4),
		
		LightsTable = "moskvich",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/moskvich/moskvich_wheel.mdl",
		CustomWheelPosFL = Vector(52,32,12),
		CustomWheelPosFR = Vector(52,-32,12),
		CustomWheelPosRL = Vector(-55,29.5,12),
		CustomWheelPosRR = Vector(-55,-29.5,12),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,2.5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-12,-16,49),
		SeatPitch = 0,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(-4,-16,17.5),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-40,16,19),
				ang = Angle(0,-90,10)
			},
			{
				pos = Vector(-40,-16,19),
				ang = Angle(0,-90,10)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 25000,
		FrontDamping = 1500,
		FrontRelativeDamping = 1500,
		
		RearHeight = 6.5,
		RearConstant = 25000,
		RearDamping = 1500,
		RearRelativeDamping = 1500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 35,
		Efficiency = 1,
		GripOffset = -1.5,
		BrakePower = 38,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-78.34,33.36,33.18),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic1/generic1_idle.wav",
		
		snd_low = "simulated_vehicles/generic1/generic1_low.wav",
		snd_low_revdown = "simulated_vehicles/generic1/generic1_revdown.wav",
		snd_low_pitch = 0.8,
		
		snd_mid = "simulated_vehicles/generic1/generic1_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic1/generic1_second.wav",
		snd_mid_pitch = 1.1,
		
		snd_horn = "simulated_vehicles/horn_5.wav",
		
		DifferentialGear = 0.6,
		Gears = {-0.1,0,0.1,0.18,0.26,0.34,0.42}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwmoskvich", V )



local V = {
	Name = "HL2 Trabant",
	Model = "models/blu/trabant/trabant.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 850,
		
		EnginePos = Vector(0.6,56.38,38.7),
		
		LightsTable = "trabbi",
		
		FirstPersonViewPos =  Vector(0,-15,6),
		
		AirFriction = -8000,
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/trabant/trabant_wheel.mdl",
		CustomWheelPosFL = Vector(-32,50,12),
		CustomWheelPosFR = Vector(32,50,12),
		CustomWheelPosRL = Vector(-32,-41.5,12),
		CustomWheelPosRR = Vector(32,-41.5,12),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,3),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-8.5,-16,44),
		SeatPitch = 0,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(16,-2,12.5),
				ang = Angle(0,0,8)
			},
			{
				pos = Vector(0,-2,12.5),
				ang = Angle(0,0,8)
			}
		},
		
		FrontHeight = 7,
		FrontConstant = 20000,
		FrontDamping = 1800,
		FrontRelativeDamping = 1800,
		
		RearHeight = 7,
		RearConstant = 20000,
		RearDamping = 1800,
		RearRelativeDamping = 1800,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 30,
		Efficiency = 1.1,
		GripOffset = -1,
		BrakePower = 30,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 85,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(5.41,46.61,39.91),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = -1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.9,
		snd_idle = "simulated_vehicles/generic5/generic5_idle.wav",
		
		snd_low = "simulated_vehicles/generic5/generic5_low.wav",
		snd_low_revdown = "simulated_vehicles/generic5/generic5_revdown.wav",
		snd_low_pitch = 0.7,
		
		snd_mid = "simulated_vehicles/generic5/generic5_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic5/generic5_gear.wav",
		snd_mid_pitch = 0.7,
		
		DifferentialGear = 0.6,
		Gears = {-0.1,0,0.1,0.2,0.28}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwtrabant", V )



local V = {
	Name = "HL2 Trabant 2",
	Model = "models/blu/trabant/trabant02.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 850,
		
		AirFriction = -8000,
		
		EnginePos = Vector(0,56.38,38.7),
		
		FirstPersonViewPos =  Vector(0,-15,6),
		
		LightsTable = "trabbi",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/trabant/trabant02_wheel.mdl",
		CustomWheelPosFL = Vector(-32,50,12),
		CustomWheelPosFR = Vector(32,50,12),
		CustomWheelPosRL = Vector(-32,-41.5,12),
		CustomWheelPosRR = Vector(32,-41.5,12),
		CustomWheelAngleOffset = Angle(0,0,0),
		
		CustomMassCenter = Vector(0,0,3),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-8.5,-16,44),
		SeatPitch = 0,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(16,-2,12.5),
				ang = Angle(0,0,8)
			},
			{
				pos = Vector(0,-2,12.5),
				ang = Angle(0,0,8)
			}
		},
		
		FrontHeight = 7,
		FrontConstant = 20000,
		FrontDamping = 1800,
		FrontRelativeDamping = 1800,
		
		RearHeight = 7,
		RearConstant = 20000,
		RearDamping = 1800,
		RearRelativeDamping = 1800,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 30,
		Efficiency = 1.1,
		GripOffset = -1,
		BrakePower = 30,
		
		IdleRPM = 750,
		LimitRPM = 7500,
		PeakTorque = 85,
		PowerbandStart = 2000,
		PowerbandEnd = 7000,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(5.41,46.61,39.91),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = -1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 0.9,
		snd_idle = "simulated_vehicles/generic5/generic5_idle.wav",
		
		snd_low = "simulated_vehicles/generic5/generic5_low.wav",
		snd_low_revdown = "simulated_vehicles/generic5/generic5_revdown.wav",
		snd_low_pitch = 0.7,
		
		snd_mid = "simulated_vehicles/generic5/generic5_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic5/generic5_gear.wav",
		snd_mid_pitch = 0.7,
		
		DifferentialGear = 0.6,
		Gears = {-0.1,0,0.1,0.2,0.28}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwtrabant02", V )


local V = {
	Name = "HL2 Volga",
	Model = "models/blu/volga/volga.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1350,
		
		EnginePos = Vector(65.39,0,44.84),
		
		LightsTable = "volga",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/volga/volga_wheel.mdl",
		CustomWheelPosFL = Vector(64,34,13),
		CustomWheelPosFR = Vector(64,-34,13),
		CustomWheelPosRL = Vector(-55,34,13),
		CustomWheelPosRR = Vector(-55,-34,13),
		CustomWheelAngleOffset = Angle(0,-90,0),
		
		CustomMassCenter = Vector(0,0,3.5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-4,-17.5,52),
		SeatPitch = 5,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(6,-17.5,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(6,0,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,-17.5,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,17.5,18.5),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,-0,18.5),
				ang = Angle(0,-90,12)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 25000,
		FrontDamping = 1300,
		FrontRelativeDamping = 1300,
		
		RearHeight = 6.5,
		RearConstant = 25000,
		RearDamping = 1300,
		RearRelativeDamping = 1300,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 35,
		Efficiency = 1,
		GripOffset = -1.5,
		BrakePower = 38,
		
		IdleRPM = 750,
		LimitRPM = 6000,
		PeakTorque = 100,
		PowerbandStart = 1500,
		PowerbandEnd = 5800,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-80.3,37.79,35.54),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic2/generic2_idle.wav",
		
		snd_low = "simulated_vehicles/generic2/generic2_low.wav",
		snd_low_revdown = "simulated_vehicles/generic2/generic2_revdown.wav",
		snd_low_pitch = 1,
		
		snd_mid = "simulated_vehicles/generic2/generic2_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic2/generic2_second.wav",
		snd_mid_pitch = 1.1,
		
		snd_horn = "simulated_vehicles/horn_5.wav",
		
		DifferentialGear = 0.62,
		Gears = {-0.1,0,0.1,0.18,0.26,0.31,0.38}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwvolga", V )


local V = {
	Name = "HL2 ZAZ",
	Model = "models/blu/zaz/zaz.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 1150,
		
		EnginePos = Vector(63.64,0,47.96),
		
		LightsTable = "zaz",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/zaz/zaz_wheel.mdl",
		CustomWheelPosFL = Vector(61,32,17),
		CustomWheelPosFR = Vector(61,-34,17),
		CustomWheelPosRL = Vector(-53,32,17),
		CustomWheelPosRR = Vector(-53,-34,17),
		CustomWheelAngleOffset = Angle(0,90,0),
		
		CustomMassCenter = Vector(0,0,3.5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-3,-17.5,54),
		SeatPitch = 5,
		SeatYaw = 90,
		
		--[[
		ModelInfo = {
			Skin = 1
		},
		]]--
		
		PassengerSeats = {
			{
				pos = Vector(6,-17.5,20),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,-17.5,24),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,17.5,24),
				ang = Angle(0,-90,12)
			},
			{
				pos = Vector(-30,0,24),
				ang = Angle(0,-90,12)
			}
		},
		
		FrontHeight = 6.5,
		FrontConstant = 25000,
		FrontDamping = 1300,
		FrontRelativeDamping = 1300,
		
		RearHeight = 6.5,
		RearConstant = 25000,
		RearDamping = 1300,
		RearRelativeDamping = 1300,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 400,
		
		TurnSpeed = 8,
		
		MaxGrip = 35,
		Efficiency = 1,
		GripOffset = -1.5,
		BrakePower = 38,
		
		IdleRPM = 750,
		LimitRPM = 7250,
		PeakTorque = 60,
		PowerbandStart = 2000,
		PowerbandEnd = 6950,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-67.9,-37.75,38.59),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 65,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/generic3/generic3_idle.wav",
		
		snd_low = "simulated_vehicles/generic3/generic3_low.wav",
		snd_low_revdown = "simulated_vehicles/generic3/generic3_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/generic3/generic3_mid.wav",
		snd_mid_gearup = "simulated_vehicles/generic3/generic3_second.wav",
		snd_mid_pitch = 0.9,
		
		DifferentialGear = 0.42,
		Gears = {-0.1,0,0.1,0.17,0.24,0.3,0.37,0.41}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwzaz", V )


local V = {
	Name = "HL2 GAZ52",
	Model = "models/blu/gaz52/gaz52.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 3000,
		
		EnginePos = Vector(0,61.23,76.81),
		
		LightsTable = "gaz",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/gaz52/gaz52_wheel.mdl",
		CustomWheelPosFL = Vector(-40,55,25),
		CustomWheelPosFR = Vector(40,55,25),
		CustomWheelPosRL = Vector(-45,-120,25),
		CustomWheelPosRR = Vector(45,-120,25),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,18),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(-20,-23,85),
		SeatPitch = 10,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(23,-2,50),
				ang = Angle(0,0,5)
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 38000,
		FrontDamping = 6000,
		FrontRelativeDamping = 6000,
		
		RearHeight = 12.5,
		RearConstant = 38000,
		RearDamping = 6000,
		RearRelativeDamping = 6000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 600,
		
		TurnSpeed = 8,
		
		MaxGrip = 85,
		Efficiency = 1.2,
		GripOffset = -12,
		BrakePower = 80,
		
		IdleRPM = 500,
		LimitRPM = 5000,
		PeakTorque = 150,
		PowerbandStart = 650,
		PowerbandEnd = 4700,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-25.29,-34.76,50),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 140,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "vehicles/crane/crane_startengine1.wav",
		
		snd_low ="simulated_vehicles/alfaromeo/alfaromeo_low.wav",
		snd_low_pitch = 0.35,
		
		snd_mid = "simulated_vehicles/alfaromeo/alfaromeo_mid.wav",
		snd_mid_gearup = "simulated_vehicles/alfaromeo/alfaromeo_second.wav",
		snd_mid_pitch = 0.5,
		
		DifferentialGear = 0.25,
		Gears = {-0.1,0,0.1,0.19,0.29,0.37,0.44,0.5,0.57}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwgaz52", V )




local V = {
	Name = "HL2 Liaz",
	Model = "models/blu/skoda_liaz/skoda_liaz.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,

	Members = {
		Mass = 3000,
		
		EnginePos = Vector(-1.75,-0.56,51.17),
		
		LightsTable = "liaz",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		FirstPersonViewPos =  Vector(0,-10,12),
		
		CustomWheelModel = "models/salza/skoda_liaz/skoda_liaz_fwheel.mdl",
		CustomWheelModel_R = "models/salza/skoda_liaz/skoda_liaz_rwheel.mdl",
		CustomWheelPosFL = Vector(-44,57,25),
		CustomWheelPosFR = Vector(40,57,25),
		CustomWheelPosRL = Vector(-50,-98,25),
		CustomWheelPosRR = Vector(47,-98,25),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,30,10),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(40,-27,100),
		SeatPitch = 10,
		SeatYaw = 0,
		
		PassengerSeats = {
			{
				pos = Vector(27,58,60),
				ang = Angle(0,0,5)
			}
		},
		
		StrengthenSuspension = false,
		
		FrontHeight = 16,
		FrontConstant = 32000,
		FrontDamping = 4000,
		FrontRelativeDamping = 4000,
		
		RearHeight = 13.5,
		RearConstant = 20000,
		RearDamping = 3000,
		RearRelativeDamping = 2000,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 600,
		
		TurnSpeed = 8,
		
		MaxGrip = 75,
		Efficiency = 2,
		GripOffset = -5,
		BrakePower = 80,
		
		IdleRPM = 500,
		LimitRPM = 5500,
		PeakTorque = 55,
		PowerbandStart = 650,
		PowerbandEnd = 5300,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(-17.8,2.09,51.93),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 140,
		
		PowerBias = 1,
		
		EngineSoundPreset = 0,
		
		Sound_Idle = "vehicles/crane/crane_startengine1.wav",
		Sound_IdlePitch = 1,
		
		Sound_Mid = "simulated_vehicles/alfaromeo/alfaromeo_low.wav",
		Sound_MidPitch = 0.5,
		Sound_MidVolume = 1,
		Sound_MidFadeOutRPMpercent = 100,
		Sound_MidFadeOutRate = 1,
		
		Sound_High = "",
		
		Sound_Throttle = "",
		
		DifferentialGear = 0.22,
		Gears = {-0.1,0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.5}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwliaz", V )



local V = {
	Name = "HL2 avia",
	Model = "models/blu/avia/avia.mdl",
	Class = "gmod_sent_vehicle_fphysics_base",
	Category = Category,
	SpawnAngleOffset = 90,

	Members = {
		Mass = 2500,
		
		EnginePos = Vector(49.37,-2.41,44.13),
		
		LightsTable = "avia",
		
		CustomWheels = true,
		CustomSuspensionTravel = 10,
		
		CustomWheelModel = "models/salza/avia/avia_wheel.mdl",
		CustomWheelPosFL = Vector(78,37,17),
		CustomWheelPosFR = Vector(78,-40,17),
		CustomWheelPosRL = Vector(-55,38.5,17),
		CustomWheelPosRR = Vector(-55,-37,17),
		CustomWheelAngleOffset = Angle(0,180,0),
		
		CustomMassCenter = Vector(0,0,5),
		
		CustomSteerAngle = 35,
		
		SeatOffset = Vector(55,-20,95),
		SeatPitch = 15,
		SeatYaw = 90,
		
		PassengerSeats = {
			{
				pos = Vector(79,-21,45),
				ang = Angle(0,-90,0)
			}
		},
		
		FrontHeight = 8,
		FrontConstant = 40000,
		FrontDamping = 3500,
		FrontRelativeDamping = 3500,
		
		RearHeight = 8,
		RearConstant = 40000,
		RearDamping = 3500,
		RearRelativeDamping = 3500,
		
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		
		TurnSpeed = 8,
		
		MaxGrip = 49,
		Efficiency = 1.1,
		GripOffset = -2,
		BrakePower = 45,	
		
		IdleRPM = 750,
		LimitRPM = 4200,
		PeakTorque = 160,
		PowerbandStart = 1500,
		PowerbandEnd = 3800,
		Turbocharged = false,
		Supercharged = false,
		
		FuelFillPos = Vector(9.79,35.14,30.77),
		FuelType = FUELTYPE_DIESEL,
		FuelTankSize = 100,
		
		PowerBias = 1,
		
		EngineSoundPreset = -1,
		
		snd_pitch = 1,
		snd_idle = "simulated_vehicles/jeep/jeep_idle.wav",
		
		snd_low = "simulated_vehicles/jeep/jeep_low.wav",
		snd_low_revdown = "simulated_vehicles/jeep/jeep_revdown.wav",
		snd_low_pitch = 0.9,
		
		snd_mid = "simulated_vehicles/jeep/jeep_mid.wav",
		snd_mid_gearup = "simulated_vehicles/jeep/jeep_second.wav", 
		snd_mid_pitch = 1,
		
		DifferentialGear = 0.45,
		Gears = {-0.15,0,0.15,0.25,0.35,0.45,0.52}
	}
}
list.Set( "simfphys_vehicles", "sim_fphys_pwavia", V )