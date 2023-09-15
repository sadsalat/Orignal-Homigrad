include("shared.lua")

local healsound = Sound("Underwater.BulletImpact")

function SWEP:Heal(ent)
    ent.adrenaline = ent.adrenaline + 2

    if not ent.adrenalineNeed and ent.adrenalineNeed > 4 then ent.adrenalineNeed = ent.adrenalineNeed + 1 end

    return true
end