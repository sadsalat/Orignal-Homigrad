local ENT = FindMetaTable("Entity")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_DamageRagdoll_Gibbing( dmginfo )
    if dmginfo:GetDamage() <= 0 then return end

    -- Return if dmgtype is DMG_NEVERGIB or DMG_BURN for example:
    if dmginfo:ZippyGoreMod3_GibType() == ZGM3_GIB_NEVER then return end

    -- Don't gib dissolving ragdolls if that is turned off:
    if bit.band( self:GetFlags(), FL_DISSOLVING ) == FL_DISSOLVING && !GetConVar("zippygore3_gib_dissolving_ragdoll"):GetBool() then return end

    if dmginfo:IsExplosionDamage() then dmginfo:ScaleDamage( GetConVar("zippygore3_explosion_damage_mult"):GetFloat() ) end
    if dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_VEHICLE) then dmginfo:ScaleDamage( GetConVar("zippygore3_phys_damage_mult"):GetFloat() ) end

    local gib_type_aoe = dmginfo:ZippyGoreMod3_IsGibType(ZGM3_GIB_AOE)
    local gib_type_direct = dmginfo:ZippyGoreMod3_IsGibType(ZGM3_GIB_DIRECT)
    local gib_type_always = dmginfo:ZippyGoreMod3_IsGibType(ZGM3_GIB_ALWAYS)
    local gib_type_dismember = dmginfo:ZippyGoreMod3_IsGibType(ZGM3_GIB_DISMEMBER)
    local gib_type_bullet = dmginfo:ZippyGoreMod3_IsGibType(ZGM3_GIB_BULLET)
    local gib_type_explosion = dmginfo:ZippyGoreMod3_IsGibType(ZGM3_GIB_EXPLOSION)

    local _, phys_idx = dmginfo:ZippyGoreMod3_RagdollHitPhysBone( self )
    if phys_idx then
        local hit_bone_name = self:GetBoneName( self:TranslatePhysBoneToBone(phys_idx) )
        local dismemberEnabled = GetConVar("zippygore3_dismemberment"):GetBool()
        local shouldDismember = dismemberEnabled && gib_type_dismember &&
        !(gib_type_bullet && hit_bone_name == "ValveBiped.Bip01_Head1") -- Don't dismember head on bullet damage
        -- AOE gibtype:
        if gib_type_aoe then
            -- "AOE damage" such as DMG_BLAST or DMG_CRUSH:
            local data = {
                damage = dmginfo:GetDamage(),
                forceVec = dmginfo:GetDamageForce(),
                dismember = shouldDismember,
                explosion = gib_type_explosion,
            }
            local hurt_pos = dmginfo:ZippyGoreMod3_RagdollHurtPosition( self )
            if hurt_pos then self:ZippyGoreMod3_PhysBonesAOEDamage( hurt_pos, data ) end
        end
        -- Direct and always gibtype:
        if (!gib_type_aoe && gib_type_direct) or gib_type_always then
            -- Direct damage, such as bullets:
            local data = {
                damage = gib_type_always && self.ZippyGoreMod3_PhysBoneHPs[phys_idx] or dmginfo:GetDamage(),
                forceVec = dmginfo:GetDamageForce(),
                dismember = shouldDismember,
            }
            self:ZippyGoreMod3_DamagePhysBone( phys_idx, data )
        end
    end

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_GuessBloodColorFromDamage( dmginfo )
    local trStartPos = dmginfo:GetDamagePosition()
    local trEndPos = dmginfo:ZippyGoreMod3_RagdollHurtPosition( self )

    if trEndPos then
        local filterEnts = {} for _, v in ipairs(ents.FindInSphere( trStartPos, trStartPos:Distance(trEndPos) )) do if v != self then table.insert(filterEnts, v) end end
        local tr = util.TraceLine({
            start = trStartPos,
            endpos = trEndPos,
            ignoreworld = true,
            filter = filterEnts,
            mask = MASK_ALL,
        })

        local surfaceProp = util.GetSurfacePropName(tr.SurfaceProps)
        if surfaceProp == "flesh" or surfaceProp == "bloodyflesh" then
            return BLOOD_COLOR_RED
        elseif surfaceProp == "alienflesh" or surfaceProp == "antlion" or surfaceProp == "zombieflesh" then
            return BLOOD_COLOR_YELLOW
        elseif surfaceProp == "strider" or surfaceProp == "gunship" or surfaceProp == "hunter" then
            return BLOOD_COLOR_ZGM3SYNTH
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_NewBloodColorOnDamage( dmginfo )
    -- Give blood color on damage if ragdoll doesn't have a engine blood color assigned to it
    local newBloodCol = self:ZippyGoreMod3_GuessBloodColorFromDamage(dmginfo)
    if newBloodCol then
        self.ZippyGoreMod3_BloodColor = newBloodCol
        return true -- Has blood, should be gibbed
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_DamageRagdoll( dmginfo )
    if self.ZippyGoreMod3_BloodColor or
    ( self:ZippyGoreMod3_NewBloodColorOnDamage(dmginfo) ) then -- Don't gib if blood color was not found
        self:ZippyGoreMod3_DamageRagdoll_Gibbing(dmginfo)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_PhysBonesAOEDamage( pos, data )
    local phys_bones = {}

    for i = 0, self:GetPhysicsObjectCount()-1 do
        local phys = self:GetPhysicsObjectNum( i )
        local dist = phys:GetPos():DistToSqr( pos )
        table.insert(phys_bones, { phys_bone_idx = i, dist = dist })
    end

    local phys_bones_sorted_dist = {}

    for i = 1, #phys_bones do
        local mindist
        local closest_phys_bone
        for k, v in ipairs(phys_bones) do
            if !mindist or v.dist < mindist then
                mindist = v.dist
                closest_phys_bone = v
            end
        end
        table.RemoveByValue(phys_bones, closest_phys_bone)
        table.insert(phys_bones_sorted_dist, closest_phys_bone.phys_bone_idx)
    end

    for i ,v in ipairs(phys_bones_sorted_dist) do
        local newData = {
            damage = data.damage / i,
            forceVec = data.forceVec,
            dismember = data.dismember && (!data.explosion or (data.explosion && math.random(1, 2) == 1)),
        }
        self:ZippyGoreMod3_DamagePhysBone( v, newData )
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ZippyGoreMod3_DamagePhysBone( phys_bone_idx, data )
    local health = self.ZippyGoreMod3_PhysBoneHPs[phys_bone_idx]
    if health == -1 then return end

    self.ZippyGoreMod3_PhysBoneHPs[phys_bone_idx] = health - data.damage
    if self.ZippyGoreMod3_PhysBoneHPs[phys_bone_idx] <= 0 then
        self.ZippyGoreMod3_PhysBoneHPs[phys_bone_idx] = -1
        self:ZippyGoreMod3_BreakPhysBone( phys_bone_idx, data )
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("EntityTakeDamage", "EntityTakeDamage_ZippyGoreMod3", function( ent, dmginfo )
    if ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer() then
        -- If it doesn't have an engine blood color, guess a blood color based on its surface properties:
        if ent:GetBloodColor() == -1 then
            local bloodColor = ent:ZippyGoreMod3_GuessBloodColorFromDamage( dmginfo )
            if bloodColor then
                ent.ZippyGoreMod3_BackupBloodColor = bloodColor
            end
        end

        ent.ZippyGoreMod3_LastDMGINFO = dmginfo
    end

    if ent.ZippyGoreMod3_Ragdoll then
        ent:ZippyGoreMod3_DamageRagdoll( dmginfo )
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------