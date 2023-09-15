AddCSLuaFile()

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.PrintName = "Взломщик"
SWEP.Category = "DarkRP"
SWEP.Author = "0oa"

SWEP.AdminOnly = false
SWEP.Spawnable = true

SWEP.UseHands = false

SWEP.ViewModel = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end