hook.Add("HomigradDamage","Organs",function(ply,hitgroup,dmginfo,rag,armorMul,armorDur,haveHelmet)
    local ent = rag or ply
    local inf = dmginfo:GetInflictor()

    if hitgroup == HITGROUP_HEAD then
        if not haveHelmet and dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then

            dmginfo:ScaleDamage(inf.RubberBullets and 0.1 or 1)
            ply.pain = ply.pain + (ply.nopain and 1 or (inf.RubberBullets and 100 or 350))
            
            ply:SetDSP(37)

        end

        if
            dmginfo:GetDamageType() == DMG_CRUSH and
            dmginfo:GetDamage() >= 6 and
            ent:GetVelocity():Length() > 500
        then
            ply:ChatPrint("Твоя шея была сломана")
            ent:EmitSound("NPC_Barnacle.BreakNeck",511,200,1,CHAN_ITEM)
            dmginfo:ScaleDamage(5000 * 5)

            return
        end
    end

    if dmginfo:GetDamage() >= 40 or (dmginfo:GetDamageType() == DMG_CRUSH and dmginfo:GetDamage() >= 6 and ent:GetVelocity():Length() > 700) then
        local brokenLeftLeg = hitgroup == HITGROUP_LEFTLEG
        local brokenRightLeg = hitgroup == HITGROUP_RIGHTLEG
        local brokenLeftArm = hitgroup == HITGROUP_LEFTARM
        local brokenRightArm = hitgroup == HITGROUP_RIGHTARM

        local sub = dmginfo:GetDamage() / 120 * armorMul

        if brokenLeftArm then
            ply.LeftArm = math.min(0.6,ply.LeftArm - sub)
            if ply.msgLeftArm < CurTime() then
                ply.msgLeftArm = CurTime() + 1
                ply:ChatPrint("Правая рука повреждена.")
                ent:EmitSound("NPC_Barnacle.BreakNeck",70,65,0.4,CHAN_ITEM)
            end
        end

        if brokenRightArm then
            ply.RightArm = math.max(0.6,ply.RightArm - sub)
            if ply.msgRightArm < CurTime() then
                ply.msgRightArm = CurTime() + 1
                ply:ChatPrint("Левая рука повреждена.")
                ent:EmitSound("NPC_Barnacle.BreakNeck",70,65,0.4,CHAN_ITEM)
            end
        end

        if brokenLeftLeg then
            ply.LeftLeg = math.max(0.6,ply.LeftLeg - sub)
            if ply.msgLeftLeg < CurTime() then
                ply.msgLeftLeg = CurTime() + 1
                ply:ChatPrint("Левая нога повреждена.")
                ent:EmitSound("NPC_Barnacle.BreakNeck",70,65,0.4,CHAN_ITEM)
            end
        end

        if brokenRightLeg then
            ply.RightLeg = math.max(0.6,ply.RightLeg - sub)
            if ply.msgRightLeg < CurTime() then
                ply.msgRightLeg = CurTime() + 1
                ply:ChatPrint("Правая нога повреждена.")
                ent:EmitSound("NPC_Barnacle.BreakNeck",70,65,0.4,CHAN_ITEM)
            end
        end
    end

    local penetration = dmginfo:GetDamageForce()
    if dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH) then
        penetration:Mul(0.015)
    else
        penetration:Mul(0.004)
    end

    penetration:Mul(armorMul)

    if not rag or (rag and not dmginfo:IsDamageType(DMG_CRUSH)) then
        local dmg = dmginfo:GetDamage() * armorMul

        if
            hitgroup == HITGROUP_HEAD and
            math.random(1,math.max(math.floor(armorDur),1)) == 1 and dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_CLUB+DMG_GENERIC+DMG_BUCKSHOT)
        then
            timer.Simple(0.01,function()
                local wep = ply:GetActiveWeapon()
                if ply:Alive() and not ply.fake and not ply.nopain and (IsValid(wep) and not wep.GetBlocking and true or not wep:GetBlocking()) then Faking(ply) end
            end)
        end

        local dmgpos = dmginfo:GetDamagePosition()

        local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine2'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration,pos,ang,Vector(-1,0,-6),Vector(10,6,6))
        
        if huy then
            if ply.Organs['lungs'] ~= 0 then
                ply.Organs['lungs'] = math.max(ply.Organs['lungs'] - dmg,0)
                if ply.Organs['lungs'] == 0 then
                    timer.Simple(3,function()
                        if ply:Alive() then ply:ChatPrint("Ты чувствуешь, как воздух заполняет твою грудную клетку. ") end
                    end)
                end
            end
        end

        local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration,pos,ang,Vector(3,-6,-4), Vector(9,4,4))

        if huy then
            if ply.Organs['brain']!=0 and dmginfo:IsDamageType(DMG_BULLET) and not inf.RubberBullets then
                ply.Organs['brain']=math.max(ply.Organs['brain']-dmg,0)
                if ply.Organs["brain"] == 0 then
                    ply:Kill()
                    
                    return
                end
            end
        end
		
        --brain
        local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-4,-1,-6),Vector(2,5,-1))

        if huy then --ply:ChatPrint("You were hit in the liver.")
            if ply.Organs['liver']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['liver']=math.max(ply.Organs['liver']-dmg,0)
                --if ply.Organs['liver']==0 then ply:ChatPrint("Твоя печень была уничтожена.") end
            end
        end
        --liver

        local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-4,-1,-1),Vector(2,5,6))
        
        if huy then --ply:ChatPrint("You were hit in the stomach.")
            if ply.Organs['stomach']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['stomach']=math.max(ply.Organs['stomach']-dmg,0)
                if ply.Organs['stomach']==0 then ply:ChatPrint("Ты чувствуешь острую боль в животе.") end
            end
        end
        --stomach

        local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-4,-1,-6),Vector(1,5,6))
        
        if huy then --ply:ChatPrint("You were hit in the intestines.")
            if ply.Organs['intestines']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['intestines']=math.max(ply.Organs['intestines']-dmg,0)
                --if ply.Organs['intestines']==0 then ply:ChatPrint("Твои кишечник был уничтожен.")end
            end
        end

        local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine2'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(1,0,-1),Vector(5,4,3))
        
        if huy then --ply:ChatPrint("You were hit in the heart.")
            if ply.Organs['heart']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['heart']=math.max(ply.Organs['heart']-dmg,0)
                --if ply.Organs['heart']==0 then ply:ChatPrint("Ты чувствоешь очень сильную боль в сердце.") end
            end
        end

        --heart
        if dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BLAST+DMG_ENERGYBEAM+DMG_NEVERGIB+DMG_ALWAYSGIB+DMG_PLASMA+DMG_AIRBOAT+DMG_SNIPER+DMG_BUCKSHOT) then --and ent:LookupBone(bonename)==2 then
            local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
            local huy = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-3,-2,-2),Vector(0,-1,-1))
            local huy2 = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-3,-2,1),Vector(0,-1,2))

            if huy or huy2 then --ply:ChatPrint("You were hit in the artery.")
                if ply.Organs['artery']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
                    ply.Organs['artery']=math.max(ply.Organs['artery']-dmg,0)
                end
            end
        end
        --coronary artery
        local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine4'))
        local ang = matrix:GetAngles()
        local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine4'))
        local huy = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-8,-1,-1),Vector(2,0,1))
        local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine1'))
        local ang = matrix:GetAngles()
        local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
        local huy2 = util.IntersectRayWithOBB(dmgpos,penetration, pos, ang, Vector(-8,-3,-1),Vector(2,-2,1))
        if (huy or huy2) then --ply:ChatPrint("You were hit in the spine.")
            if ply.Organs['spine']!=0 then
                ply.Organs['spine']=math.Clamp(ply.Organs['spine']-dmg,0,1)
                if ply.Organs['spine']==0 then
                    timer.Simple(0.01,function()
                        if !ply.fake then
                            Faking(ply)
                        end
                    end)
                    ply.brokenspine=true 
                    ply:ChatPrint("Твоя спина была сломана.")
                    ent:EmitSound("NPC_Barnacle.BreakNeck",70,125,0.7,CHAN_ITEM)
                end
            end
        end
        --spine
    end
end)

hook.Add("HomigradDamage","BurnDamage",function(ply,hitgroup,dmginfo) 
    if dmginfo:IsDamageType( DMG_BURN ) then
        dmginfo:ScaleDamage( 5 )
    end
end)
