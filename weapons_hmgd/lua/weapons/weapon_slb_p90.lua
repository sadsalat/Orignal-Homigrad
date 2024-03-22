SWEP.Base = "salat_base" -- base 
SWEP.PrintName = "P90"
SWEP.Instructions = "Что может еще делать ПП? СТРЕЛЯТЬ В ЛИЦО!"
SWEP.Category = "Оружие"
SWEP.Spawnable = true
SWEP.AdminOnly = false
------------------------------------------
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 2
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 85
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/p90/p90-1.wav"
SWEP.Primary.Force = 30
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.06
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
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/salatbase/w_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/salatbase/w_smg_p90.mdl"
SWEP.addPos = Vector(14, -0.2, 7)
SWEP.addAng = Angle(-8, 2.4, 0)
SWEP.sightPos = Vector(9.2, -1, 0.73)
SWEP.sightAng = Angle(0, 4, 0)
SWEP.fakeHandRight = Vector(2, -2, 2)
SWEP.fakeHandLeft = Vector(4, -5, -4)
-------------------------------------------
SWEP.Sight = false
SWEP.DrawScope = true
SWEP.ScopeAdjustAng = Angle(0.5, 0, 180)
SWEP.ScopeAdjustPos = Vector(0, 0, 0)
SWEP.ScopeFov = 6
SWEP.ScopeMat = Material("holo/huy-holo.png")
SWEP.ScopeRot = -1
SWEP.UVAdjust = {0, -40}
SWEP.UVScale = {4, 4}
-----------------------------------------
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    slbweps[self] = true
    if SERVER then return end
    self.rtmat = GetRenderTarget("huy-glass", 512, 512, false)
    self.mat = Material("models/weapons/w_models/w_smg_p90/sight")
    self.mat:SetTexture("$basetexture", self.rtmat)
    local texture_matrix = self.mat:GetMatrix("$basetexturetransform")
    texture_matrix:SetAngles(Angle(0, 0, 32))
    self.mat:SetMatrix("$basetexturetransform", texture_matrix)
end

SWEP.Recoil = 0.5