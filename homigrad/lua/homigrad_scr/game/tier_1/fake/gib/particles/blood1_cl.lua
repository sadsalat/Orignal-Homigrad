bloodparticels1 = bloodparticels1 or {}
local bloodparticels1 = bloodparticels1

local bloodparticels_hook = bloodparticels_hook

local tr = {filter = function(ent) return not ent:IsPlayer() and not ent:IsRagdoll() end}

local vecDown = Vector(0,0,-40)
local vecZero = Vector(0,0,0)
local LerpVector = LerpVector

local math_random = math.random
local table_remove = table.remove

local util_Decal = util.Decal
local util_TraceLine = util.TraceLine
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite

bloodparticels_hook[1] = function(anim_pos)
    for i = 1,#bloodparticels1 do
        local part = bloodparticels1[i]

        render_SetMaterial(part[4])
        render_DrawSprite(LerpVector(anim_pos,part[2],part[1]),part[5],part[6])
    end
end

bloodparticels_hook[2] = function(mul)
    for i = 1,#bloodparticels1 do
        local part = bloodparticels1[i]
        if not part then break end

        local pos = part[1]
        local posSet = part[2]
        
        tr.start = posSet
        tr.endpos = tr.start + part[3] * mul
        result = util_TraceLine(tr)
        
        local hitPos = result.HitPos

        if result.Hit then
            table_remove(bloodparticels1,i)
            
            local dir = result.HitNormal

            util_Decal("Blood",hitPos + dir,hitPos - dir)
            sound.Play("ambient/water/drip" .. math_random(1,4) .. ".wav",hitPos,60,math_random(230,240))
            continue
        else
            pos:Set(posSet)
            posSet:Set(hitPos)
        end

        part[3] = LerpVector(0.25 * mul,part[3],vecZero)
        part[3]:Add(vecDown)
    end
end