SWEP.Base = 'salat_base' -- base 

SWEP.PrintName 				= "M249"
SWEP.Instructions			= "Пулемёт под калибр 5,56х45"
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "m249/m249_fp.wav"
SWEP.Primary.SoundFar = "m249/m249_dist.wav"
SWEP.Primary.Force = 160/3
SWEP.ReloadTime = 4
SWEP.ShootWait = 0.075
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
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

SWEP.ViewModel				= "models/pwb2/weapons/w_m249paratrooper.mdl"
SWEP.WorldModel				= "models/pwb2/weapons/w_m249paratrooper.mdl"

SWEP.addPos = Vector(0,0,0)
SWEP.addAng = Angle(0.25,0.025,0)