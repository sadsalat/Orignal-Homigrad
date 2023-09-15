include("shared.lua")

local healsound = Sound("snds_jack_gmod/ez_medical/15.wav")

function SWEP:Heal(ent)
    if not ent or not ent:IsPlayer() then sound.Play(healsound,ent:GetPos(),75,100,0.5) return true end

    ent.painlosing = ent.painlosing + 1

    ent:EmitSound(healsound)

    return true
end