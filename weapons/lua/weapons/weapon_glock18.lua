SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "MP-80-13T"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Пистолет под калибр .45 Rubber"
SWEP.Category 				= "Оружие"
SWEP.WepSelectIcon			= "entities/weapon_insurgencymakarov.png"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ".45 Rubber"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 10
SWEP.RubberBullets = true
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "hndg_colt1911/colt_1911_fire1.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_smp_far.wav"
SWEP.Primary.Force = 0.1
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "revolver"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/weapons/insurgency/w_makarov.mdl"
SWEP.WorldModel				= "models/weapons/insurgency/w_makarov.mdl"

SWEP.vbwPos = Vector(8,0,-6)
SWEP.addPos = Vector(0,0,0.2)
SWEP.addAng = Angle(0.4,0,0)