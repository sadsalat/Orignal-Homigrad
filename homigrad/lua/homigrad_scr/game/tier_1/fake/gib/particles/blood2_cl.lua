bloodparticels2 = bloodparticels2 or {}
local bloodparticels = bloodparticels2

local bloodparticels_hook = bloodparticels_hook

local tr = {filter = function(ent) return not ent:IsPlayer() and not ent:IsRagdoll() end}

local vecZero = Vector(0,0,0)
local LerpVector = LerpVector

local math_random = math.random
local table_remove = table.remove

local util_Decal = util.Decal
local util_TraceLine = util.TraceLine
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local surface_SetDrawColor = surface.SetDrawColor

local color = Color(255,255,255,255)

bloodparticels_hook[3] = function(anim_pos)
    local time = CurTime()

    for i = 1,#bloodparticels2 do
        local part = bloodparticels2[i]

        color.a = 255 * (part[7] - time) / part[8]
        render_SetMaterial(part[4])
        render_DrawSprite(LerpVector(anim_pos,part[2],part[1]),part[5],part[6],color)
    end
end

bloodparticels_hook[4] = function(mul)
    local time = CurTime()

    for i = 1,#bloodparticels2 do
        local part = bloodparticels2[i]
        if not part then break end

        local pos = part[1]
        local posSet = part[2]
        
        tr.start = posSet
        tr.endpos = tr.start + part[3] * mul
        result = util_TraceLine(tr)
        
        local hitPos = result.HitPos

        if result.Hit or part[7] - time <= 0 then
            table_remove(bloodparticels2,i)
  
            continue
        else
            pos:Set(posSet)
            posSet:Set(hitPos)
        end

        part[3] = LerpVector(0.5 * mul,part[3],vecZero)
    end
end