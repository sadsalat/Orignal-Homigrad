SWEP.Base = "salat_base" -- base 
SWEP.PrintName = "Scout"
SWEP.Instructions = "Пендоское оружие?"
SWEP.Category = "Оружие"
SWEP.Spawnable = true
SWEP.AdminOnly = false
------------------------------------------
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "AirboatGun"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 300
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/scout/scout_fire-1.wav"
SWEP.Primary.Force = 80
SWEP.ReloadTime = 2
SWEP.ShootWait = 1
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
SWEP.ViewModel = "models/weapons/salatbase/w_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/salatbase/w_snip_scout.mdl"
SWEP.addPos = Vector(20, -1.05, 8)
SWEP.addAng = Angle(-11, 0.55, 0)
SWEP.sightPos = Vector(5.8, 1, 1.03)
SWEP.sightAng = Angle(-5, -2.5, 0)
SWEP.fakeHandRight = Vector(12, -2, 3)
SWEP.fakeHandLeft = Vector(13, -5, -2)
------------------------------------------
SWEP.Sight = true
SWEP.DrawScope = true
SWEP.ScopeAdjustAng = Angle(0.9, 0, 180)
SWEP.ScopeAdjustPos = Vector(0, 0, 0)
SWEP.ScopeFov = 12
SWEP.ScopeMat = Material("decals/perekrestie3.png")
SWEP.ScopeRot = 0.5
SWEP.UVAdjust = {0, -40}
SWEP.UVScale = {1.5, 1.2}
-----------------------------------------
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    slbweps[self] = true
    if SERVER then return end
    self.rtmat = GetRenderTarget("huy-glass", 512, 512, false)
    self.mat = Material("models/weapons/w_models/w_snip_scout/sight")
    self.mat:SetTexture("$basetexture", self.rtmat)
    local texture_matrix = self.mat:GetMatrix("$basetexturetransform")
    texture_matrix:SetAngles(Angle(0, 0, 32))
    self.mat:SetMatrix("$basetexturetransform", texture_matrix)
end

function SWEP:AdjustMouseSensitivity()
    if self:GetOwner():KeyDown(IN_ATTACK2) then return 0.5 end

    return 1
end

SWEP.Recoil = 2