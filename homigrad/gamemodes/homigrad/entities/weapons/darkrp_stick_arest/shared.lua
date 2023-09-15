AddCSLuaFile()

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.PrintName = "Палочка справедливости"
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

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

local stunstickMaterials
function SWEP:Initialize()
    self:SetHoldType("normal")
    self:SetMaterial("models/debug/debugwhite")

    if SERVER then
        self.reloadNext = 0
    end
end

function SWEP:Deploy() end
function SWEP:Holster() return true end
function SWEP:Reload() end

Sound("weapons/stunstick/stunstick_swing1.wav")

if SERVER then return end

function SWEP:PrimaryAttack()
    self:SetHoldType("melee")
    self:SetNextPrimaryFire(CurTime() + 0.51)

    local owner = self:GetOwner()
    owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
    self:SetHoldType("melee")
    self:SetNextSecondaryFire(CurTime() + 0.51)

    local owner = self:GetOwner()
    owner:SetAnimation(PLAYER_ATTACK1)
end

function darkrp.PlayerSwitchWeapon(ply,old,new)
    if ply:GetNWFloat("Arest",0) - CurTime() > 0 then return false end
end