SWEP.Base = "weapon_hg_granade_base"

SWEP.PrintName = "Светошумовая Граната"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Специальное средство несмертельного действия, оказывающие на человека светозвуковое и осколочное воздействие."
SWEP.Category = "Гранаты"

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/jmod/explosives/grenades/flashbang/flashbang.mdl"
SWEP.WorldModel = "models/jmod/explosives/grenades/flashbang/flashbang.mdl"

SWEP.Granade = "ent_hgjack_flashbang"

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