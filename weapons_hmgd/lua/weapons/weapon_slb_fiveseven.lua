SWEP.Base = "salat_base" -- base 
SWEP.PrintName = "FiveSeven"
SWEP.Author = "FN"
SWEP.Instructions = "Что может еще делать пистолет? СТРЕЛЯТЬ В ЛИЦО!"
SWEP.Category = "Оружие"
SWEP.Spawnable = true
SWEP.AdminOnly = false
------------------------------------------
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 80
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/fiveseven/fiveseven-1.wav"
SWEP.Primary.Force = 25
SWEP.ReloadTime = 2
SWEP.ReloadSound = "weapons/pistol/pistol_reload1.wav"
SWEP.ShootWait = 0.1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
------------------------------------------
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "revolver"
------------------------------------------
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/salatbase/w_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/salatbase/w_pist_fiveseven.mdl"
SWEP.addPos = Vector(5, 0.1, 4)
SWEP.addAng = Angle(-2.2, 4.95, 0)
SWEP.sightPos = Vector(3.9, 10, 1.20)
SWEP.sightAng = Angle(4, 8, 0)
SWEP.fakeHandRight = Vector(3.5, -1.5, 2)
SWEP.Recoil = 1.5