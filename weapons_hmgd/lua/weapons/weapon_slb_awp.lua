SWEP.Base = "salat_base" -- base 
SWEP.PrintName = "AWP"
SWEP.Instructions = "Пендоское оружие?"
SWEP.Category = "Оружие"
SWEP.Spawnable = true
SWEP.AdminOnly = false
------------------------------------------
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "SniperRound"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 400
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/awp/awp1.wav"
SWEP.Primary.Force = 100
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.8
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
SWEP.HoldType = "ar2"
------------------------------------------
SWEP.Slot = 2
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/salatbase/w_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/salatbase/w_snip_awp.mdl"
SWEP.addPos = Vector(20, -1.05, 10.5)
SWEP.addAng = Angle(-11, 0.8, 0)
SWEP.sightPos = Vector(6.5, 3, 0.83)
SWEP.sightAng = Angle(-5, 0, 0)
SWEP.fakeHandRight = Vector(12, -1, 2)
SWEP.fakeHandLeft = Vector(13, -3, -4)
-----------------------------------------
SWEP.Sight = true
SWEP.DrawScope = true
SWEP.ScopeAdjustAng = Angle(1, -0.03, 180)
SWEP.ScopeAdjustPos = Vector(0, 0, 0)
SWEP.ScopeFov = 13
SWEP.ScopeMat = Material("decals/perekrestie3.png")
SWEP.ScopeRot = -1
SWEP.UVAdjust = {0, -40}
SWEP.UVScale = {1.5, 1.2}
-----------------------------------------
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    slbweps[self] = true
    if SERVER then return end
    self.rtmat = GetRenderTarget("huy-glass", 512, 512, false)
    self.mat = Material("models/weapons/w_models/w_snip_awp/sight")
    self.mat:SetTexture("$basetexture", self.rtmat)
    local texture_matrix = self.mat:GetMatrix("$basetexturetransform")
    texture_matrix:SetAngles(Angle(0, 0, 32))
    self.mat:SetMatrix("$basetexturetransform", texture_matrix)
end

function SWEP:AdjustMouseSensitivity()
    if self:GetOwner():KeyDown(IN_ATTACK2) then return 0.5 end

    return 1
end

SWEP.Recoil = 4