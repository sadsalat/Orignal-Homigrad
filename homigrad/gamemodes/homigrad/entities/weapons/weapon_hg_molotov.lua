SWEP.Base = "weapon_hg_granade_base"

SWEP.PrintName = "Коктейль Молотова"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Стеклянная бутылка, содержащая горючую жидкость и запал"
SWEP.Category = "Гранаты"

SWEP.Slot = 4
SWEP.SlotPos = 2
SWEP.Spawnable = true

SWEP.ViewModel = "models/w_models/weapons/w_eq_molotov.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_molotov.mdl"

SWEP.Granade = "ent_hgjack_molotov"
local angBack = Angle(0,0,180)
function SWEP:DrawWorldModel()
    local owner = self:GetOwner()

    if not IsValid(owner) then self:DrawModel() return end
    --if self:GetNWBool("hasbomb") then return end

    self.mdl = self.mdl or false
    if not IsValid(self.mdl) then
        self.mdl = ClientsideModel(self.WorldModel)
        self.mdl:SetNoDraw(true)
        self.mdl:SetModelScale(1)
    end
    self:CallOnRemove("huyhuy",function() self.mdl:Remove() end)
    local matrix = self:GetOwner():GetBoneMatrix(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))
    if not matrix then return end

    self.mdl:SetRenderOrigin(matrix:GetTranslation()+matrix:GetAngles():Forward()*3+matrix:GetAngles():Right()*3)
    self.mdl:SetRenderAngles(matrix:GetAngles()+angBack)
    self.mdl:DrawModel()
end