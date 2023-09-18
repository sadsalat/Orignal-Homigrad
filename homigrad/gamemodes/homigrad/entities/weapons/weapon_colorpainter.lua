SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Балончик с краской"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= ""
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
SWEP.SlotPos				= 3
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/props/cs_office/phone_p2.mdl"
SWEP.WorldModel				= "models/props/cs_office/phone_p2.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

function SWEP:Initialize()
    self:SetHoldType("normal")
end

if SERVER then
    function SWEP:SecondaryAttack()
        net.Start("JMod_EZradio")
        net.WriteBool(false)
        net.WriteEntity(self)
        net.WriteTable(JMod.Config.RadioSpecs.AvailablePackages)
        net.Send(activator)
    end

    return
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if not IsValid(owner) then self:DrawModel() return end

    local mdl = self.worldModel
    if not IsValid(mdl) then
        mdl = ClientsideModel(self.WorldModel)
        mdl:SetNoDraw(true)
        mdl:SetModelScale(0.5)

        self.worldModel = mdl
    end
    self:CallOnRemove("huyhuy",function() mdl:Remove() end)

    local matrix = self:GetOwner():GetBoneMatrix(11)
    if not matrix then return end

    mdl:SetRenderOrigin(matrix:GetTranslation())
    mdl:SetRenderAngles(matrix:GetAngles())
    mdl:DrawModel()
end