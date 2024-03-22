SWEP.Base = "salat_base" -- base 
SWEP.PrintName = "AUG"
SWEP.Instructions = "Пендоское оружие?"
SWEP.Category = "Оружие"
SWEP.Spawnable = true
SWEP.AdminOnly = false
------------------------------------------
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 2
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Cone = 0.006
SWEP.Primary.Damage = 200
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/aug/aug-1.wav"
SWEP.Primary.Force = 80
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.1
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
------------------------------------------
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = "smg"
------------------------------------------
SWEP.Slot = 2
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/salatbase/w_rif_aug.mdl"
SWEP.WorldModel = "models/weapons/salatbase/w_rif_aug.mdl"
SWEP.addPos = Vector(10, -0.58, 7)
SWEP.addAng = Angle(-9.5, -0.1, 0)
SWEP.sightPos = Vector(5.5, 5.8, 0.68)
SWEP.sightAng = Angle(-5, -5, 0)
SWEP.fakeHandRight = Vector(12, -2, 0)
SWEP.fakeHandLeft = Vector(10, -4, -4)
-----------------------------------------
SWEP.DrawScope = true
SWEP.ScopeAdjustAng = Angle(1.1, 0, 180)
SWEP.ScopeAdjustPos = Vector(0, 0, 0)
SWEP.ScopeFov = 15
SWEP.ScopeMat = Material("holo/huy-holo2.png")
SWEP.ScopeRot = 1
SWEP.UVAdjust = {0, -40}
SWEP.UVScale = {0.2, 0.17}
-----------------------------------------
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    slbweps[self] = true
    if SERVER then return end
    self.rtmat = GetRenderTarget("huy-glass", 512, 512, false)
    self.mat = Material("models/weapons/w_models/w_rif_aug/sight")
    self.mat:SetTexture("$basetexture", self.rtmat)
    local texture_matrix = self.mat:GetMatrix("$basetexturetransform")
    texture_matrix:SetAngles(Angle(0, 0, 32))
    self.mat:SetMatrix("$basetexturetransform", texture_matrix)
end

function SWEP:AdjustMouseSensitivity()
    if self:GetOwner():KeyDown(IN_ATTACK2) then return 0.7 end

    return 1
end

SWEP.Recoil = 0.6