local DMGINFO = FindMetaTable("CTakeDamageInfo")

ZGM3_GIB_NEVER = 0
ZGM3_GIB_DIRECT = 1
ZGM3_GIB_AOE = 2
ZGM3_GIB_ALWAYS = 4
ZGM3_GIB_DISMEMBER = 8
ZGM3_GIB_BULLET = 16
ZGM3_GIB_EXPLOSION = 32

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DMGINFO:ZippyGoreMod3_IsGibType( gib_type )
    return bit.band(self:ZippyGoreMod3_GibType(), gib_type) == gib_type
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DMGINFO:ZippyGoreMod3_GibType()
    local gib_type = 0
    
    if !( !GetConVar("zippygore3_disable_never_gib_damage"):GetBool() && self:IsDamageType(DMG_NEVERGIB ) ) then
        for dmg_type, type in pairs({
            [DMG_BLAST] = {ZGM3_GIB_AOE, ZGM3_GIB_DISMEMBER, ZGM3_GIB_EXPLOSION},
            [DMG_BLAST_SURFACE] = {ZGM3_GIB_AOE, ZGM3_GIB_DISMEMBER, ZGM3_GIB_EXPLOSION},
            [DMG_SONIC] = {ZGM3_GIB_AOE, ZGM3_GIB_DISMEMBER, ZGM3_GIB_EXPLOSION},
            [DMG_CRUSH] = ZGM3_GIB_AOE,
            [DMG_VEHICLE] = ZGM3_GIB_AOE,
            [DMG_FALL] = ZGM3_GIB_AOE,
            [DMG_ACID] = ZGM3_GIB_AOE,
            [DMG_DISSOLVE] = ZGM3_GIB_AOE,
            [DMG_BULLET] = {ZGM3_GIB_DIRECT, ZGM3_GIB_DISMEMBER, ZGM3_GIB_BULLET},
            [DMG_SLASH] = {ZGM3_GIB_DIRECT, ZGM3_GIB_DISMEMBER},
            [DMG_GENERIC] = ZGM3_GIB_DIRECT,
            [DMG_CLUB] = ZGM3_GIB_DIRECT,
            [DMG_SHOCK] = ZGM3_GIB_DIRECT,
            [DMG_ENERGYBEAM] = ZGM3_GIB_DIRECT,
            [DMG_PREVENT_PHYSICS_FORCE] = ZGM3_GIB_DIRECT,
            [DMG_REMOVENORAGDOLL] = ZGM3_GIB_DIRECT,
            [DMG_PHYSGUN] = ZGM3_GIB_DIRECT,
            [DMG_PLASMA] = ZGM3_GIB_DIRECT,
            [DMG_AIRBOAT] = ZGM3_GIB_DIRECT,
            [DMG_BUCKSHOT] = ZGM3_GIB_DIRECT,
            [DMG_SNIPER] = ZGM3_GIB_DIRECT,
            [DMG_MISSILEDEFENSE] = ZGM3_GIB_DIRECT,
            [DMG_NEVERGIB] = ZGM3_GIB_DIRECT, -- If the effects from DMG_NEVERGIB are disabled, use direct gibbing type. 
            [DMG_ALWAYSGIB] = GetConVar("zippygore3_disable_always_gib_damage"):GetBool() && ZGM3_GIB_DIRECT or {ZGM3_GIB_ALWAYS, ZGM3_GIB_AOE},
        }) do
            if istable(type) then
                for _,v in ipairs(type) do if self:IsDamageType(dmg_type) && bit.band( gib_type, v ) != v then gib_type = bit.bor(gib_type, v) end end
            elseif self:IsDamageType(dmg_type) && bit.band( gib_type, type ) != type then gib_type = bit.bor(gib_type, type) end
        end
    end

    return gib_type
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DMGINFO:ZippyGoreMod3_RagdollHitPhysBone( ent )
    local closest_phys_bone
    local closest_phys_bone_idx
    local mindist

    for i = 0, ent:GetPhysicsObjectCount()-1 do
        -- If physbone is already gibbed, skip it:
        if ent.ZippyGoreMod3_PhysBoneHPs && ent.ZippyGoreMod3_PhysBoneHPs[i] == -1 then continue end

        local phys = ent:GetPhysicsObjectNum( i )
        local dist = phys:GetPos():DistToSqr( self:GetDamagePosition() )

        if !mindist or dist < mindist then
            mindist = dist
            closest_phys_bone = phys
            closest_phys_bone_idx = i
        end
    end

    if closest_phys_bone then return closest_phys_bone, closest_phys_bone_idx end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DMGINFO:ZippyGoreMod3_RagdollHurtPosition( ent )
    local phys_bone = self:ZippyGoreMod3_RagdollHitPhysBone( ent )
    if phys_bone then return phys_bone:GetPos() end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------