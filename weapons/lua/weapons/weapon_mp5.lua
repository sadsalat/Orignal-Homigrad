SWEP.Base = 'salat_base' -- base 

SWEP.PrintName 				= "HK MP5a3"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Пистолет-пулемёт под калибр 9х19"
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9х19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Spread = 5
SWEP.Primary.Sound = "mp5k/mp5k_fp.wav"
SWEP.Primary.SoundFar = "mp5k/mp5k_dist.wav"
SWEP.Primary.Force = 85/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.06
SWEP.TwoHands = true
							
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb2/weapons/w_mp5a3.mdl"
SWEP.WorldModel				= "models/pwb2/weapons/w_mp5a3.mdl"

SWEP.dwsPos = Vector(20,20,5)
SWEP.dwsItemPos = Vector(-7,0,1.5)

SWEP.addAng = Angle(0,0,0)