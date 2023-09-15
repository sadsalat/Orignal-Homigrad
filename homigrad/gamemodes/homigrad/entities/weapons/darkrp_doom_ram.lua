AddCSLuaFile()

SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.PrintName = "Ломатель дверей"
SWEP.Author = "0oa"

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/c_rpg.mdl")
SWEP.WorldModel = Model("models/weapons/w_rocket_launcher.mdl")
SWEP.AnimPrefix = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP"

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = 0     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false     -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy() end
function SWEP:Holster()
    self:SetNWBool("Ready",false)

    return true
end

function SWEP:PrimaryAttack()
    local Owner = self:GetOwner()
    if not IsValid(Owner) then return end

    if not self:GetNWBool("Ready") then return end

    self:SetNextPrimaryFire(CurTime() + 0.1)

    local trace = Owner:GetEyeTrace()

    local ent = trace.Entity
    if not IsValid(ent) or not darkrp.doors[ent:GetClass()] then return end

    if SERVER then
        ent:Fire("UnLock")
        ent:Fire("Open")
    end

    self:SetNextPrimaryFire(CurTime() + 2.5)

    Owner:SetAnimation(PLAYER_ATTACK1)
    Owner:EmitSound(self.Sound)
    Owner:ViewPunch(Angle(-10,0,0))
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.30)

    self:SetNWBool("Ready",not self:GetNWBool("Ready"))

    if self:GetNWBool("Ready") then
        self:SetHoldType("rpg")
    else
        self:SetHoldType("normal")
    end
end


function SWEP:GetViewModelPosition(pos, ang)
    local Mul = 1

    if self.LastIron > CurTime() - 0.25 then
        Mul = math.Clamp((CurTime() - self.LastIron) / 0.25, 0, 1)
    end

    if self:GetNWBool("Ready") then
        Mul = 1 - Mul
    end

    ang:RotateAroundAxis(ang:Right(), - 15 * Mul)
    return pos,ang
end