AddCSLuaFile()

SWEP.Base = "medkit"

SWEP.PrintName = "Большой бинт"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Лечит большую кровопотерю"

SWEP.Spawnable = true
SWEP.Category = "Медицина"

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/bandages.mdl"
SWEP.WorldModel = "models/bandages.mdl"

SWEP.dwsPos = Vector(25,25,10)

SWEP.vbwPos = Vector(2,6,-8)
SWEP.vbwAng = Angle(0,0,0)
SWEP.vbwModelScale = 0.25

SWEP.vbwPos2 = Vector(0,3,-8)
SWEP.vbwAng2 = Angle(0,0,0)

function SWEP:vbwFunc(ply)
    local ent = ply:GetWeapon("medkit")
    if ent and ent.vbwActive then return self.vbwPos,self.vbwAng end
    return self.vbwPos2,self.vbwAng2
end

SWEP.dwmModeScale = 1.2
SWEP.dwmForward = 3.5
SWEP.dwmRight = 1
SWEP.dwmUp = -1

SWEP.dwmAUp = 90
SWEP.dwmARight = 90
SWEP.dwmAForward = 0