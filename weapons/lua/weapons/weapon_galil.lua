SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "GALIL-SAR"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Автоматическая винтовка под калибр 5,56х45"
SWEP.Category 				= "Оружие"
SWEP.WepSelectIcon			= "pwb2/vgui/weapons/ace23"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= 35
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 40
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "m16a4/m16a4_fp.wav"
SWEP.Primary.SoundFar = "m16a4/m16a4_dist.wav"
SWEP.Primary.Force = 240/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.07
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

SWEP.ViewModel				= "models/pwb2/weapons/w_ace23.mdl"
SWEP.WorldModel				= "models/pwb2/weapons/w_ace23.mdl"

SWEP.dwsPos = Vector(20,20,5)
SWEP.dwsItemPos = Vector(-7,0,3)

SWEP.addAng = Angle(1.7,0.1,0)