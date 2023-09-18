SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Бинокль"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Оптический прибор, состоящий из двух параллельно расположенных и соединённых вместе зрительных труб, для наблюдения удалённых предметов двумя глазами"
SWEP.Category 				= "Разное"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 5
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/maxofs2d/camera.mdl"
SWEP.WorldModel				= "models/maxofs2d/camera.mdl"

SWEP.ViewBack = true
SWEP.ForceSlot1 = true

SWEP.dwsPos = Vector(10,10,10)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(-6,0,6)
SWEP.vbwAng = Angle(0,150,0)
--SWEP.vbwPos = Vector(47,-6,10)
--SWEP.vbwAng = Angle(-180,90,0)
SWEP.vbwModelScale = 0.8

homigrad_weapons = homigrad_weapons or {}

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

function SWEP:Initialize()
    homigrad_weapons[self] = true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Think() end

function SWEP:Step()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then self:SetNWBool("Focus",owner:KeyDown(IN_ATTACK2)) end

    local isFocus = self:GetNWBool("Focus")

    local clientMoment = CLIENT and (owner ~= LocalPlayer() or GetViewEntity() ~= LocalPlayer())

    self:SetWeaponHoldType("camera")
    if CLIENT or SERVER then
        self:SetWeaponHoldType(isFocus and "camera" or "slam")
    end
end

if SERVER then return end

local value = 0
hook.Add("CalcAddFOV","Binokle",function(ply)
    local wep = ply:GetActiveWeapon()
    wep = IsValid(wep) and wep:GetClass() == "weapon_binokle" and ply:KeyDown(IN_ATTACK2)
    value = LerpFT(0.1,value,wep and -75 or 0) 
    ADDFOV = ADDFOV + value
end)

local white = Color(255,255,255)

hook.Add("HUDPaint","binokle",function()
    local have

    for i,wep in pairs(LocalPlayer():GetWeapons()) do
        if wep:GetClass() == "weapon_binokle" then have = true break end
    end

    if not have then return end

    local count = 36
    local step = 360 / count

    for i = 0,count - 1 do
        local dir = Vector(8000,0,0)
        dir:Rotate(Angle(0,i * step,0))

        local pos = LocalPlayer():GetPos() + dir
        pos = pos:ToScreen()

        local max = ScrW() / 4
        local a = math.max(max - math.abs(ScrW() / 2 - pos.x),0) / max

        a = math.max(a - 0.4,0) / 0.6
        white.a = a * 255

        draw.SimpleText(i * step,"DefaultFixedDropShadow",pos.x,25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end)