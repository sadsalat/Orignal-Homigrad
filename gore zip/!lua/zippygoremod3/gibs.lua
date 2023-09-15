local ENT = FindMetaTable("Entity")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_CreateGib( pos, flesh_material, model, angles, scale, is_ragdoll, tangle_ragdoll )
    if GetConVar("zippygore3_gib_limit"):GetInt() <= 0 then return end

    local gib = ents.Create("zippygoremod3_gib")
    gib:SetPos( pos )
    gib:SetAngles( angles or AngleRand() )
    gib:SetModel( model or table.Random(ZippyGoreMod3_BasicGib_Models) )
    if flesh_material then gib:SetMaterial("models/flesh") end
    if scale && scale != 1 then gib:SetModelScale(scale) end
    gib.BloodColor = self.ZippyGoreMod3_BloodColor
    gib.DoGibRagdoll = is_ragdoll
    gib:Spawn()

    return is_ragdoll && gib.Ragdoll or gib
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_CreateGibs( phys_idx, damageData )
    if GetConVar("zippygore3_gib_limit"):GetInt() <= 0 then return end

    local phys_bone = self:GetPhysicsObjectNum(phys_idx)

    local function get_bone_randompos()
        local mins, maxs = phys_bone:GetAABB()

        local tr = util.TraceLine({
            start = phys_bone:GetPos(),
            endpos = phys_bone:GetPos() + VectorRand(mins, maxs),
            mask = MASK_NPCWORLDSTATIC,
        })

        return tr.HitPos+tr.HitNormal*10
    end

    if self.ZippyGoreMod3_BloodColor == BLOOD_COLOR_ZGM3SYNTH then
        -- Don't spawn gibs for synths, do some effects instead
        local amt = math.Clamp( phys_bone:GetSurfaceArea()*0.015, 0, 8 )
        for i = 1, amt do
            if math.random(1, 2) == 1 then
                ParticleEffect( "blood_impact_synth_01", get_bone_randompos(), AngleRand() )
            end
        end
        return
    end 

    local function get_custom_gibs( bone_name )
        if !ZippyGoreMod3_CustomGibs[bone_name] then return {}, 1 end
        return ZippyGoreMod3_CustomGibs[bone_name].gibs, ZippyGoreMod3_CustomGibs[bone_name].basic_gib_mult or 1
    end

    local function get_gib_force()
        local forceMult = math.Clamp( damageData.Damage, 0, 1000 )
        return damageData.ForceVec:GetNormalized()*forceMult + VectorRand()*forceMult
    end

    -- Spawn the gibs:
    local custom_gibs, basic_gib_mult = get_custom_gibs( self:GetBoneName( self:TranslatePhysBoneToBone( phys_idx ) ) )
    for _,v in ipairs(custom_gibs) do
        for i = 1, ( v.count && ( istable(v.count) && math.random(v.count[1], v.count[2]) ) or v.count ) or 1 do
            local pos = ( v.random_pos && get_bone_randompos() ) or phys_bone:GetPos()
            local scale = v.scale && (istable(v.scale) && math.Rand(v.scale[1], v.scale[2])) or v.scale or 1
            local gib = self:ZippyGoreMod3_CreateGib( pos, v.use_flesh_material, v.model, !v.random_angle && phys_bone:GetAngles(), scale, v.is_ragdoll, true )

            -- Gib ragdoll stuff:
            if gib:GetClass() == "prop_ragdoll" then
                -- Position it so that it doesn't get stuck in the ground:
                for i = 0, gib:GetPhysicsObjectCount()-1 do
                    local phys_obj_to_reposition = gib:GetPhysicsObjectNum(i)

                    local tr = util.TraceLine({
                        start = gib:GetPhysicsObjectNum(0):GetPos(),
                        endpos = phys_obj_to_reposition:GetPos(),
                        mask = MASK_NPCWORLDSTATIC,
                    })

                    if tr.Hit then
                        phys_obj_to_reposition:SetPos(tr.HitPos+tr.HitNormal*4)
                    end
                end
            end

            gib:GetPhysicsObject():SetVelocity( get_gib_force() )
        end
    end
    if basic_gib_mult > 0 then
        for i = 1, math.Clamp( phys_bone:GetSurfaceArea()*0.015*basic_gib_mult, 0, 6 ) do
            local gib = self:ZippyGoreMod3_CreateGib( get_bone_randompos(), ZippyGoreMod3_BasicGib_UseFleshMaterial, nil, nil, math.Rand(ZippyGoreMod3_BasicGib_Scale[1], ZippyGoreMod3_BasicGib_Scale[2]) )
            gib:GetPhysicsObject():SetVelocity( get_gib_force() )
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------