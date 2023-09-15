include("shared.lua")

function SWEP:PrimaryAttack()
    local ent = self:GetOwner():GetEyeTraceDis(75)
    if not darkrp.doors[ent:GetClass()] then return end

    ent:Fire("UnLock")
    self:Remove()
end
