SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "SPAS-12"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Полуавтоматический дробовик под калибр 12/70"
SWEP.Category 				= "Оружие"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.05
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "toz_shotgun/toz_fp.wav"
SWEP.Primary.SoundFar = "toz_shotgun/toz_dist.wav"
SWEP.Primary.Force = 15
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.15
SWEP.NumBullet = 12
SWEP.Sight = true
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
SWEP.shotgun = true

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb/weapons/w_spas_12.mdl"
SWEP.WorldModel				= "models/pwb/weapons/w_spas_12.mdl"

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(5,math.Rand(-2,2),0)
end

SWEP.vbwPos = Vector(-2,-4,-4)

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025

SWEP.addAng = Angle(-0.2,-0.15,0)