
local whitelistWeapons = {
    ["weapon_physgun"] = true,
    ["weapon_fists"] = true,
    ["gmod_tool"] = true,
    ["weapon_rpg"] = true,
    ["weapon_slam"] = true,
    ["weapon_shotgun"] = true,
    ["weapon_357"] = true,
    ["weapon_physcannon"] = true,
    ["weapon_crossbow"] = true,
    ["weapon_crowbar"] = true,
    ["weapon_hands"] = true,
    ["gmod_camera"] = true,
    ["itemstore_checker"] = true,
    ["itemstore_pickup"] = true,
    ["stungun"] = true,
    ["weapon_medkit"] = true,
    ["door_ram"] = true,
    ["weapon_simrepair"] = true,
    ["weapon_simremote"] = true,
    ["glorifiedhandcuffs_handcuffs"] = true,
    ["glorifiedhandcuffs_nightstick"] = true,
    ["glorifiedhandcuffs_restrained"] = true,
    ["adrinaline"] = true,
    ["medkit"] = true,
}

hook.Add("ScalePlayerDamage", "ultra.megarealisicdamage", function(ply, hitgroup, dmginfo)
    dmginfo:ScaleDamage(0.3)
    damage=dmginfo:GetDamage()
    if hitgroup == HITGROUP_HEAD then
        dmginfo:ScaleDamage(2)
    end
    if hitgroup == HITGROUP_LEFTARM then
        dmginfo:ScaleDamage(0.3)
        if dmginfo:GetDamage()>10 and ply.LeftArm > 0.6 then
            ply:ChatPrint("Твоя левая рука была сломана")
            ply.LeftArm = 0.6
            dmginfo:ScaleDamage(0.35)
        end   
    end
    if hitgroup == HITGROUP_LEFTLEG then
        dmginfo:ScaleDamage(0.3)
        if dmginfo:GetDamage()>15 and ply.LeftLeg > 0.6 then
            ply:ChatPrint("Твоя левая нога была сломана")
            ply.LeftLeg = 0.6
            dmginfo:ScaleDamage(0.3)
        end   
        if !ply.fake then 
        if dmginfo:GetDamageForce():Length()>4000 or ply.pain>60 then
        print( dmginfo:GetDamageForce():Length() )
        Faking(ply)
        end  
        end
    end
    if hitgroup == HITGROUP_RIGHTLEG then
        dmginfo:ScaleDamage(0.3)
        if dmginfo:GetDamage()>15 and ply.RightLeg > 0.6 then
            ply:ChatPrint("Твоя правая нога была сломана")
            ply.RightLeg = 0.6
            dmginfo:ScaleDamage(0.35)
        end 
        if !ply.fake then 
        if dmginfo:GetDamageForce():Length()>4000 or ply.pain>60 then
        Faking(ply)
        end  
        end 
    end
    if hitgroup == HITGROUP_RIGHTARM then
        dmginfo:ScaleDamage(0.3)
        if dmginfo:GetDamage()>10 and ply.RightArm > 0.6 then
            ply:ChatPrint("Твоя правая рука была сломана")
            ply.RightArm = 0.6
            dmginfo:ScaleDamage(0.3)
        end    
    end
    if hitgroup == HITGROUP_CHEST then
        dmginfo:ScaleDamage(0.8)
        if !ply.fake then 
        if dmginfo:GetDamageForce():Length()>7255 or ply.pain>140 then
        Faking(ply)
        end  
        end
    end
    if hitgroup == HITGROUP_STOMACH then
        dmginfo:ScaleDamage(0.65)
        if !ply.fake then 
        if dmginfo:GetDamageForce():Length()>6000 or ply.pain>120  then
        Faking(ply)
        end  
        end
    end
    if hitgroup == HITGROUP_RIGHTARM then
        if not IsValid(ply:GetActiveWeapon()) then return end
        if whitelistWeapons[ply:GetActiveWeapon():GetClass()] then return end
            ply:DropWeapon(ply:GetActiveWeapon())
            ply:SelectWeapon("weapon_hands")
    end
end)