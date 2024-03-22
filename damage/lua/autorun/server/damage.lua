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
	["adrenaline"] = true,
	["medkit"] = true,
}

hook.Add(
	"ScalePlayerDamage",
	"ultra.megarealisicdamage",
	function(ply, hitgroup, dmginfo)
		dmginfo:ScaleDamage(0.3)
		local damage = dmginfo:GetDamage()
		local trace = util.QuickTrace(dmginfo:GetDamagePosition(), dmginfo:GetDamageForce():GetNormalized() * 100)
		local bone = trace.PhysicsBone
		ply.LastHit = ply:GetBoneName(bone)
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(2)
			ply:SetNWAngle("viewpunch", Angle(20, math.Rand(-5, 5), math.Rand(-5, 5)) / 2)
		end

		if hitgroup == HITGROUP_LEFTARM then
			dmginfo:ScaleDamage(0.3)
			ply:SetNWAngle("viewpunch", Angle(10, math.Rand(-15, 15), math.Rand(-15, 15)) / 2)
			if dmginfo:GetDamage() > 10 and ply.LeftArm > 0.6 then
				ply:ChatPrint("Твоя левая рука была сломана")
				ply:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
				ply.LeftArm = 0.6
				dmginfo:ScaleDamage(0.35)
			end
		end

		if hitgroup == HITGROUP_LEFTLEG then
			dmginfo:ScaleDamage(0.3)
			ply:SetNWAngle("viewpunch", Angle(10, math.Rand(-15, 15), math.Rand(-15, 15)) / 2)
			if dmginfo:GetDamage() > 15 and ply.LeftLeg > 0.6 then
				ply:ChatPrint("Твоя левая нога была сломана")
				ply:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
				ply.LeftLeg = 0.6
				dmginfo:ScaleDamage(0.3)
			end

			if not ply.fake then
				if dmginfo:GetDamageForce():Length() > 4000 or ply.pain > 60 then
					print(dmginfo:GetDamageForce():Length())
					Faking(ply)
				end
			end
		end

		if hitgroup == HITGROUP_RIGHTLEG then
			dmginfo:ScaleDamage(0.3)
			ply:SetNWAngle("viewpunch", Angle(10, math.Rand(-15, 15), math.Rand(-15, 15)) / 2)
			if dmginfo:GetDamage() > 15 and ply.RightLeg > 0.6 then
				ply:ChatPrint("Твоя правая нога была сломана")
				ply:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
				ply.RightLeg = 0.6
				dmginfo:ScaleDamage(0.35)
			end

			if not ply.fake then
				if dmginfo:GetDamageForce():Length() > 4000 or ply.pain > 60 then
					Faking(ply)
				end
			end
		end

		if hitgroup == HITGROUP_RIGHTARM then
			dmginfo:ScaleDamage(0.3)
			ply:SetNWAngle("viewpunch", Angle(10, math.Rand(-15, 15), math.Rand(-15, 15)) / 2)
			if dmginfo:GetDamage() > 10 and ply.RightArm > 0.6 then
				ply:ChatPrint("Твоя правая рука была сломана")
				ply:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
				ply.RightArm = 0.6
				dmginfo:ScaleDamage(0.3)
			end
		end

		if hitgroup == HITGROUP_CHEST then
			dmginfo:ScaleDamage(0.95)
			ply:SetNWAngle("viewpunch", Angle(10, math.Rand(-35, 15), math.Rand(-15, 15)) / 2)
			if not ply.fake then
				if dmginfo:GetDamageForce():Length() > 7255 or ply.pain > 140 then
					Faking(ply)
				end
			end
		end

		if hitgroup == HITGROUP_STOMACH then
			ply:SetNWAngle("viewpunch", Angle(10, math.Rand(-15, 15), math.Rand(-15, 15)) / 2)
			dmginfo:ScaleDamage(0.85)
			if not ply.fake then
				if dmginfo:GetDamageForce():Length() > 6000 or ply.pain > 120 then
					Faking(ply)
				end
			end
		end

		if hitgroup == HITGROUP_RIGHTARM then
			ply:SetNWAngle("viewpunch", Angle(20, math.Rand(-15, 15), math.Rand(-15, 15)) / 2)
			if not IsValid(ply:GetActiveWeapon()) then return end
			if whitelistWeapons[ply:GetActiveWeapon():GetClass()] then return end
			ply:DropWeapon(ply:GetActiveWeapon())
			ply:SelectWeapon("weapon_hands")
		end
	end
)