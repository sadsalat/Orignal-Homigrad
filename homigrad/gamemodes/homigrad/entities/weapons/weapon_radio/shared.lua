AddCSLuaFile()

SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Рация"
SWEP.Author 				= "0oa"
SWEP.Instructions			= "Общение со своей командой"
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

SWEP.Slot					= 0
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"
SWEP.WorldModel				= "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(15,15,5)
SWEP.dwsItemPos = Vector(0,7,-40)

SWEP.vbw = true
SWEP.vbwPistol = true
SWEP.vbwPos = Vector(0.5,-44,-0.5)
SWEP.vbwAng = Angle(-90,0,-90)
SWEP.vbwModelScale = 1

if SERVER then return end

local white = Color(255,255,255)
local hg_hint = CreateClientConVar("hg_hint","1",true,false)

function SWEP:DrawHUD()
    if LocalPlayer():InVehicle() or not hg_hint:GetBool() then return end

    draw.SimpleText("В голосовой","DebugFixedSmall",ScrW() / 2 - 200,ScrH() - 175,white)
    draw.SimpleText("Зажми ПКМ и говори","DebugFixedSmall",ScrW() / 2 + 200,ScrH() - 175,white,TEXT_ALIGN_RIGHT)
    draw.SimpleText("В чат","DebugFixedSmall",ScrW() / 2 - 200,ScrH() - 150,white)
    draw.SimpleText("Просто пиши и держи в руках","DebugFixedSmall",ScrW() / 2 + 200,ScrH() - 150,white,TEXT_ALIGN_RIGHT)
    draw.SimpleText("Сидя в машине нужно просто говорить","DebugFixedSmall",ScrW() / 2 ,ScrH() - 125,white,TEXT_ALIGN_CENTER)

    draw.SimpleText("Убрать подсказки hg_hint 0","DebugFixedSmall",ScrW() / 2,ScrH() - 100,white,TEXT_ALIGN_CENTER)
end
