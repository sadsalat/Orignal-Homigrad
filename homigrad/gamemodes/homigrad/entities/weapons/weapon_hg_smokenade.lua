SWEP.Base = "weapon_hg_granade_base"

SWEP.PrintName = "Дымовая граната"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Пиротехническое средство для пуска дыма, предназначенное для подачи сигналов, указания места посадки, маскировки объектов при выполнении манёвров (в том числе в ходе уличных беспорядков)"
SWEP.Category = "Гранаты"

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/jmod/explosives/grenades/firenade/incendiary_grenade.mdl"
SWEP.WorldModel = "models/jmod/explosives/grenades/firenade/incendiary_grenade.mdl"

SWEP.Granade = "ent_hgjack_smoke"

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if not IsValid(owner) then self:DrawModel() return end

    local mdl = self.worldModel
    if not IsValid(mdl) then
        mdl = ClientsideModel(self.WorldModel)
        mdl:SetNoDraw(true)
        mdl:SetModelScale(0.8)

        self.worldModel = mdl
    end
    self:CallOnRemove("huyhuy",function() mdl:Remove() end)

    local matrix = self:GetOwner():GetBoneMatrix(11)
    if not matrix then return end

    mdl:SetRenderOrigin(matrix:GetTranslation()+matrix:GetAngles():Forward()*3+matrix:GetAngles():Right()*2)
    mdl:SetRenderAngles(matrix:GetAngles())
    mdl:DrawModel()
end