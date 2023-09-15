local function create_materials( mat_names )
    local mats = {}
    for _, v in ipairs(mat_names) do
        local imat = Material(v)
        table.insert(mats, imat)
    end
    return mats
end

local blood_materials = create_materials({
    "decals/blood1",
    "decals/blood2",
    "decals/blood3",
    "decals/blood4",
    "decals/blood5",
    "decals/blood6",
})

local yblood_materials = create_materials({
    "decals/yblood1",
    "decals/yblood2",
    "decals/yblood3",
    "decals/yblood4",
    "decals/yblood5",
    "decals/yblood6",
})

local particleMat1 = Material("particle/particle_smokegrenade")
local particleMat2 = Material("effects/blood")

local blood_colors = {
    [BLOOD_COLOR_RED] = Color(85,0,0),
    [BLOOD_COLOR_ANTLION] = Color(100,50,0),
    [BLOOD_COLOR_ANTLION_WORKER] = Color(200,200,0),
    [BLOOD_COLOR_GREEN] = Color(100,100,0),
    [BLOOD_COLOR_ZOMBIE] = Color(100,100,0),
    [BLOOD_COLOR_YELLOW] = Color(100,100,0),
    [BLOOD_COLOR_ZGM3SYNTH] = Color(165,175,150),
}

local splatter_distance = 50
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init( data )
    local blood_color = data:GetFlags()
    local blood_color_tbl = blood_colors[ blood_color ]
    if !blood_color_tbl then return end

    local pos_min, pos_max = data:GetOrigin(), data:GetStart()
    local phys_bone_size = ( pos_max - pos_min ):Length()
    local base_particle_size = phys_bone_size*2.5

    -- Particles:
    local emitter = ParticleEmitter( pos_min, false )

    for i = 1, 14 do
        local particle_pos = VectorRand( pos_min, pos_max )
        local particle = emitter:Add( table.Random({particleMat1, particleMat2}), particle_pos )
        particle:SetDieTime(math.Rand(0.25, 1.25))
        particle:SetStartSize(0)
        particle:SetEndSize( math.Rand(base_particle_size*0.5, base_particle_size) )
        particle:SetStartAlpha(math.Rand(155, 255))
        particle:SetEndAlpha(0)
        particle:SetColor( blood_color_tbl.r, blood_color_tbl.g, blood_color_tbl.b )
        particle:SetGravity( Vector( 0, 0, -math.Rand(25, 50) ) )
        particle:SetVelocity( VectorRand()*35 )
        particle:SetRollDelta( math.Rand( -math.pi*0.2, math.pi*0.2) )
    end

    emitter:Finish()

    -- Splatter decals:
    local bc = blood_color
    local splatter_materials = ( bc==BLOOD_COLOR_RED && table.Copy(blood_materials) ) or
    ( ( bc==BLOOD_COLOR_ANTLION or bc==BLOOD_COLOR_ANTLION_WORKER or bc==BLOOD_COLOR_GREEN or bc==BLOOD_COLOR_ZOMBIE or bc==BLOOD_COLOR_YELLOW ) && table.Copy(yblood_materials) )

    if splatter_materials then
        local splatter_directions = {
            Vector(splatter_distance,0,0),
            Vector(0,splatter_distance,0),
            Vector(0,0,splatter_distance),
            Vector(-splatter_distance,0,0),
            Vector(0,-splatter_distance,0),
            Vector(0,0,-splatter_distance),
        }

        local filter_ents = {}

        for _, v in ipairs( splatter_directions ) do
            local splatter_start_pos = VectorRand( pos_min, pos_max )

            if ZGM3_INSANE_BLOOD_EFFECTS && bc == BLOOD_COLOR_RED then
                local effectdata = EffectData()
                effectdata:SetEntity(NULL)
                effectdata:SetStart(splatter_start_pos)
                effectdata:SetNormal( (v+VectorRand()*splatter_distance*0.5):GetNormalized() )
                effectdata:SetMagnitude(GetConVar("realistic_blood_max_damage"):GetInt()*0.75)
                effectdata:SetFlags( math.random(1, 2) )
                util.Effect("realisticblood_splatter", effectdata)
            elseif ZGM3_ANIMATED_BLOOD && bc == BLOOD_COLOR_RED then
                local vec = (v+VectorRand()*splatter_distance*0.5)
                local normal = vec:GetNormalized()
                net.Start("ZGM3AnimBloodSplatter")
                net.WriteVector(splatter_start_pos)
                net.WriteNormal(normal)
                net.WriteVector(vec)
                net.SendToServer()
            else
                local tr = util.TraceLine({
                    start = splatter_start_pos,
                    endpos = splatter_start_pos + v,
                    filter = filter_ents,
                })
                if IsValid(tr.Entity) then filter_ents[ tr.Entity:EntIndex() ] = tr.Entity end

                local decal_size = math.Clamp( phys_bone_size*0.1 , 0.5, 8 )
                util.DecalEx( table.Random(splatter_materials), IsValid(tr.Entity) && tr.Entity or Entity(0), tr.HitPos, tr.HitNormal, Color(255,255,255), decal_size, decal_size)
            end
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() return false end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------