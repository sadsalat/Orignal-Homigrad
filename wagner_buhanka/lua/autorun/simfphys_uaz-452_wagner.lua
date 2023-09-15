AddCSLuaFile()
local NameLang

if GetConVar("gmod_language"):GetString() == "ru" then
	NameLang = "УАЗ-452"
elseif GetConVar("gmod_language"):GetString() == "uk" then
	NameLang = "УАЗ-452"
else
	NameLang = "UAZ-452"
end

local light_table = {
	ModernLights = false, -- грубо говоря, ксенон или старые фары. True - ксенон, false - старые
	L_HeadLampPos = Vector(-26.05, 103.3, 47.14), -- рассположение обычных фар (левых - L)
	L_HeadLampAng = Angle(180,-90,0), -- угол поворота фар

	R_HeadLampPos = Vector(26.05, 103.3, 47.14), -- рассположение обычных фар (правых - R)
	R_HeadLampAng = Angle(180,-90,0), -- угол поворота фар

	L_RearLampPos = Vector(-37.57, -88.16, 45.54), -- расположение задних фар
	L_RearLampAng = Angle(0,-90,0), -- угол поворота фар

	R_RearLampPos = Vector(37.57, -88.16, 45.54), -- расположение задних фар
	R_RearLampAng = Angle(0,-90,0), -- угол поворота фар

	Headlight_sprites = { -- Обычные фары
		{pos =  Vector(26.05, 103.3, 47.14), material="sprites/light_ignorez_new", size = 150},
		{pos =  Vector(26.05, 103.3, 47.14), material="sprites/light_ignorez_new", size = 75, color = Color(255,255,255)},
		
		{pos =  Vector(31.55, 102.85, 37.23), material="sprites/light_ignorez_new", size = 40},
		---
		{pos =  Vector(-26.05, 103.3, 47.14), material="sprites/light_ignorez_new", size = 150},
		{pos =  Vector(-26.05, 103.3, 47.14), material="sprites/light_ignorez_new", size = 75, color = Color(255,255,255)},
		
		{pos =  Vector(-31.55, 102.85, 37.23), material="sprites/light_ignorez_new", size = 40},
	},
	Headlamp_sprites = { -- дальние
		{pos =  Vector(26.05, 103.3, 47.14), material="sprites/light_ignorez_new", size = 150},
		
		{pos =  Vector(-26.05, 103.3, 47.14), material="sprites/light_ignorez_new", size = 150},
	},
	FogLight_sprites = { -- противотуманки
		{pos =  Vector(0.8, 80.15, 97.67), size = 75, material="sprites/light_ignorez_new", color = Color(255,255,255), OnBodyGroups = {[5] = {1}}},
		{pos =  Vector(0.8, 80.15, 97.67), size = 100, material="sprites/light_ignorez_new", OnBodyGroups = {[5] = {1}}},
	},
	Rearlight_sprites = { -- задние фары
		{pos = Vector(37.57, -88.16, 45.54), size = 20, material="sprites/light_ignorez_new2", color = Color(255,150,0,150), OnBodyGroups = {[4] = {0}}},
		{pos = Vector(37.57, -88.16, 45.54), size = 40, material="sprites/light_ignorez_new", color = Color(255,60,0), OnBodyGroups = {[4] = {0}}},
		
		{pos = Vector(-37.57, -88.16, 45.54), size = 20, material="sprites/light_ignorez_new2", color = Color(255,150,0,150), OnBodyGroups = {[4] = {0}}},
		{pos = Vector(-37.57, -88.16, 45.54), size = 40, material="sprites/light_ignorez_new", color = Color(255,60,0), OnBodyGroups = {[4] = {0}}},
		---
		{pos = Vector(36.46, -88.27, 46.6), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(36.46, -88.27, 46.1), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(36.46, -88.27, 44.88), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(36.46, -88.27, 44.39), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		
		{pos = Vector(-36.46, -88.27, 46.6), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(-36.46, -88.27, 46.1), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(-36.46, -88.27, 44.88), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(-36.46, -88.27, 44.39), size = 10, material="sprites/light_ignorez_new", color = Color(255,60,0,150), OnBodyGroups = {[4] = {1}}},
	},
	Brakelight_sprites = { -- тормозные огни
		{pos = Vector(37.57, -88.16, 42.43), size = 15, material="sprites/light_ignorez_new2", color = Color(255,150,0,100), OnBodyGroups = {[4] = {0}}},
		{pos = Vector(37.57, -88.16, 42.43), size = 60, material="sprites/light_ignorez_new", color = Color(255,60,0), OnBodyGroups = {[4] = {0}}},
		
		{pos = Vector(-37.57, -88.16, 42.43), size = 15, material="sprites/light_ignorez_new2", color = Color(255,150,0,100), OnBodyGroups = {[4] = {0}}},
		{pos = Vector(-37.57, -88.16, 42.43), size = 60, material="sprites/light_ignorez_new", color = Color(255,60,0), OnBodyGroups = {[4] = {0}}},
		---
		{pos = Vector(37.56, -88.14, 42.5), size = 20, material="sprites/light_ignorez_new2", color = Color(255,65,0), OnBodyGroups = {[4] = {1}}},
		{pos = Vector(-37.56, -88.14, 42.5), size = 20, material="sprites/light_ignorez_new2", color = Color(255,65,0), OnBodyGroups = {[4] = {1}}},
	},
	Reverselight_sprites = { -- фары заднего хода
		{pos = Vector(-18.34, -88.6, 48.7), size = 20, material="sprites/light_ignorez_new", color = Color(255,255,255), OnBodyGroups = {[9] = {0}}},
		{pos = Vector(-18.34, -88.6, 48.7), size = 50, material="sprites/light_ignorez_new", color = Color(220, 205, 160), OnBodyGroups = {[9] = {0}}},
	},
	Turnsignal_sprites = { -- поворотники
		Right = { -- правый
			{pos =  Vector(31.55, 102.7, 39), material="sprites/light_ignorez_new2",size = 15, color = Color(255,255,0,100)},
			{pos =  Vector(31.55, 102.85, 39), material="sprites/light_ignorez_new",size = 60, color = Color(255,120,0)},
			
			{pos =  Vector(40.8, 43.9, 84), material="sprites/light_ignorez_new2",size = 15, color = Color(255,255,0,100)},
			{pos =  Vector(40.9, 43.9, 84), material="sprites/light_ignorez_new",size = 60, color = Color(255,120,0)},
			
			{pos = Vector(37.57, -88.16, 48.55), size = 15, material="sprites/light_ignorez_new2", color = Color(255,255,0,100), OnBodyGroups = {[4] = {0}}},
			{pos = Vector(37.57, -88.16, 48.55), size = 60, material="sprites/light_ignorez_new", color = Color(255,120,0), OnBodyGroups = {[4] = {0}}},
			---
			{pos = Vector(37.6, -88.12, 48.44), size = 20, material="sprites/light_ignorez_new2", color = Color(255,120,0), OnBodyGroups = {[4] = {1}}},
		},
		Left = { -- левый
			{pos =  Vector(-31.55, 102.7, 39), material="sprites/light_ignorez_new2",size = 15, color = Color(255,255,0,100)},
			{pos =  Vector(-31.55, 102.85, 39), material="sprites/light_ignorez_new",size = 60, color = Color(255,120,0)},
			
			{pos =  Vector(-40.8, 43.9, 84), material="sprites/light_ignorez_new2",size = 15, color = Color(255,255,0,100)},
			{pos =  Vector(-40.9, 43.9, 84), material="sprites/light_ignorez_new",size = 60, color = Color(255,120,0)},
			
			{pos = Vector(-37.57, -88.16, 48.55), size = 15, material="sprites/light_ignorez_new2", color = Color(255,255,0,100), OnBodyGroups = {[4] = {0}}},
			{pos = Vector(-37.57, -88.16, 48.55), size = 60, material="sprites/light_ignorez_new", color = Color(255,120,0), OnBodyGroups = {[4] = {0}}},
			---
			{pos = Vector(-37.6, -88.12, 48.44), size = 20, material="sprites/light_ignorez_new2", color = Color(255,120,0), OnBodyGroups = {[4] = {1}}},
		},
	},
}
list.Set( "simfphys_lights", "uaz_452", light_table) -- здесь тебе нужно изменить "test" на любое другое название, например "myfirstsimfcar"

local V = {
	Name = NameLang, -- название машины в меню
	Model = "models/negleb/uaz_452_wagner.mdl", -- модель машины (в вкладке дополнения и проп авто)
	Category = "Willi302's Cars", -- категория в которой будет машина

	Members = {
		Mass = 2000, -- масса авто
		
		OnTick = function(ent)
			if ent:GetLightsEnabled() then
				ent:SetSubMaterial(2, "sim_fphys_uaz_452/guages")
			else
				ent:SetSubMaterial(2, "sim_fphys_uaz_452/off")
			end
		end,
		
		LightsTable = "uaz_452", -- название light_table

		AirFriction = -300000,

		FrontWheelRadius = 16,--радиус переднего колеса
		RearWheelRadius = 16,--радиус заднего колеса

		CustomMassCenter = Vector(0,0,-1), 

		SeatOffset = Vector(-2,0,-4), -- положение водительского сидения
		SeatPitch = 0,

		SpeedoMax = -1, -- какая максималка на спидометре(может работать криво)

		ModelInfo = {
			Color = Color(154, 205, 230),
			Bodygroups = {2,2},
		},
		
		PassengerSeats = { -- пассажирские места
			{
				pos = Vector(25,63,38),
				ang = Angle(0,0,14) -- Vector(ширина, длина, высота),
			},
			{
				pos = Vector(30,-30,40),
				ang = Angle(0,0,14) -- Vector(ширина, длина, высота),
			},
			{
				pos = Vector(-30,-30,40),
				ang = Angle(0,0,14) -- Vector(ширина, длина, высота),
			},
			{
				pos = Vector(-13,-30,40),
				ang = Angle(0,0,14) -- Vector(ширина, длина, высота),
			},
			{
				pos = Vector(-30,28,40),
				ang = Angle(0,180,14) -- Vector(ширина, длина, высота),
			},
			{
				pos = Vector(-9,28,40),
				ang = Angle(0,180,14) -- Vector(ширина, длина, высота),
			},
			{
				pos = Vector(12,28,40),
				ang = Angle(0,180,14) -- Vector(ширина, длина, высота),
			},
		},

		ExhaustPositions = { -- позиция выхлопа
        	{
                pos = Vector(12, -88.3, 22.35),
                ang = Angle(90,-90,0),
        	},
        },

		StrengthenSuspension = false, -- жесткая подвеска.

		FrontHeight = 9, -- высота передней подвески
		FrontConstant = 43000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,

		RearHeight = 9, -- высота задней подвески
		RearConstant = 43000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,

		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,

		TurnSpeed = 4,

		MaxGrip = 45,
		Efficiency = 1,
		GripOffset = -3,
		BrakePower = 60, -- сила торможения

		IdleRPM = 650, -- мин. кол-во оборотов
		LimitRPM = 5000, -- макс. кол-во оборотов
		Revlimiter = false, -- Если true - Когда стрелка спидометра доходит до красного обозначения, она не проходит дальше, если false - это игнорируется
		PeakTorque = 100, -- крутящий момент
		PowerbandStart = 750, -- какие обороты на нейтральной передаче
		PowerbandEnd = 4000, -- ограничение по оборотам
		Turbocharged = false, -- турбо false = нет, true = да
		Supercharged = false, -- супер заряд
		Backfire = false, -- стреляющий выхлоп

		FuelFillPos = Vector(-43.65, 13.9, 38.7), -- положение заправки
		FuelType = FUELTYPE_PETROL, -- тип топлива
		FuelTankSize = 77, -- размер бака

		PowerBias = 0, -- привод. 1 - задний, 0 - полный, -1 - передний

		EngineSoundPreset = -1,

		snd_pitch = 0.85,
		snd_idle = "vehicles/sim_fphys_uaz-452/idle.wav",

		snd_low = "vehicles/sim_fphys_uaz-452/low.wav",
		snd_low_revdown = "vehicles/sim_fphys_uaz-452/low.wav", -- это всё звук
		snd_low_pitch = 0.8,

		snd_mid = "vehicles/sim_fphys_uaz-452/mid.wav",
		snd_mid_gearup = "vehicles/sim_fphys_uaz-452/second.wav",
		snd_mid_geardown = "vehicles/sim_fphys_uaz-452/second.wav",
		snd_mid_pitch = 0.8,

		snd_horn = "simulated_vehicles/horn_7.wav",

		DifferentialGear = 0.4,
		Gears = {-0.15,0,0.15,0.275,0.4,0.5} -- кол-во передач и "мощность"
	}
}
if (file.Exists( "models/negleb/uaz_452_wagner.mdl", "GAME" )) then -- путь модели (".mdl")
	list.Set( "simfphys_vehicles", "sim_fphys_uaz-452_wagner", V ) -- изменить на люброе название(например sim_fphys_lalala)
end