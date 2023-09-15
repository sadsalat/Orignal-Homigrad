include("shared.lua")

local healsound = Sound("Underwater.BulletImpact")

function SWEP:Heal(ply)
    if not ply or not ply:IsPlayer() then sound.Play(healsound,ply:GetPos(),75,100,0.5) return true end

    ply.pain = math.max(ply.pain - 400,0)
    ply.painlosing = ply.painlosing + 3
    ply:EmitSound(healsound)

    return true
end