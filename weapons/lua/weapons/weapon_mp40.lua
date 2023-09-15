SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "FN P90"
SWEP.Instructions			= "Пистолет-пулемёт под калибр 5,7×28"
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "5.7×28 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 30
SWEP.Primary.Spread = 5
SWEP.Primary.Sound = "mp5k/mp5k_fp.wav"
SWEP.Primary.SoundFar = "mp5k/mp5k_dist.wav"
SWEP.Primary.Force = 120/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.05
SWEP.TwoHands = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "smg"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb/weapons/w_p90.mdl"
SWEP.WorldModel				= "models/pwb/weapons/w_p90.mdl"

SWEP.dwsPos = Vector(20,20,5)
SWEP.dwsItemPos = Vector(10,-1,-3)

SWEP.vbwPos = Vector(12,-5,-4)