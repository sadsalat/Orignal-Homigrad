SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "АС «Вал»"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Автоматическая винтовка со встроенным глушителем под калибр 9х39"
SWEP.Category 				= "Оружие"
SWEP.WepSelectIcon			= "pwb2/vgui/weapons/asval"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 45
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "mp5k/mp5k_suppressed_fp.wav"
SWEP.Primary.SoundFar = "mp5k/mp5k_suppressed_tp.wav"
SWEP.Primary.Force = 200/3
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.065
SWEP.ReloadSound = "pwb2/weapons/deserteagle/reload.wav"
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

SWEP.ViewModel				= "models/pwb2/weapons/w_asval.mdl"
SWEP.WorldModel				= "models/pwb2/weapons/w_asval.mdl"

SWEP.addAng = Angle(0,0,0)
SWEP.addPos = Vector(0,0,0)

SWEP.Supressed = true