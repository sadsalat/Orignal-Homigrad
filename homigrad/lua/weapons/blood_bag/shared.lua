AddCSLuaFile()

SWEP.Base = "medkit"

SWEP.PrintName = "Пустой пакет крови"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Пакет ёмкостью 500мл для забора крови, наборы для определения группы крови в комплекте\nКАК ИСПОЛЬЗОВАТЬ: зажать на 2 секунды ЛКМ/ПКМ, чтобы влить в пакет кровь/вылить из пакета кровь (ЛКМ - действие с собой, ПКМ - действие с игроком)"

SWEP.Spawnable = true
SWEP.Category = "Медицина"

SWEP.Slot = 3
SWEP.SlotPos = 3

SWEP.ViewModel = "models/blood_bag/models/blood_bag.mdl"
SWEP.WorldModel = "models/blood_bag/models/blood_bag.mdl"

SWEP.dwsPos = Vector(55,55,20)

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

if CLIENT then
    net.Receive("blood_gotten",function(len)
        local wep = net.ReadEntity()
        wep.bloodinside = not net.ReadBool()

        wep.PrintName = wep.bloodinside and "Пакет крови" or "Пустой пакет крови"
    end)

    local model = GDrawWorldModel or ClientsideModel(SWEP.WorldModel,RENDER_GROUP_OPAQUE_ENTITY)
    GDrawWorldModel = model
    model:SetNoDraw(true)

    SWEP.dwmModeScale = 0.5
    SWEP.dwmForward = 5
    SWEP.dwmRight = 5
    SWEP.dwmUp = -1

    SWEP.dwmAUp = 30
    SWEP.dwmARight = 90
    SWEP.dwmAForward = 0
    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()
        if not IsValid(owner) then
            self:DrawModel()

            return
        end

        local Pos,Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
        if not Pos then return end

        model:SetModel(self.WorldModel)
        model:SetSkin(not self.bloodinside and 1 or 0)

        Pos:Add(Ang:Forward() * self.dwmForward)
        Pos:Add(Ang:Right() * self.dwmRight)
        Pos:Add(Ang:Up() * self.dwmUp)

        model:SetPos(Pos)

        Ang:RotateAroundAxis(Ang:Up(),self.dwmAUp)
        Ang:RotateAroundAxis(Ang:Right(),self.dwmARight)
        Ang:RotateAroundAxis(Ang:Forward(),self.dwmAForward)
        model:SetAngles(Ang)

        model:SetModelScale(1)

        model:DrawModel()
    end
end