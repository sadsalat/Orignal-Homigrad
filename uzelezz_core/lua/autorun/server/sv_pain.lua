function Pain()
	hook.Add(
		"EntityTakeDamage",
		"PlayerPainGrowth",
		function(ply, dmginfo)
			if ply:IsPlayer() or IsValid(RagdollOwner(ply)) then
				local ply = RagdollOwner(ply) or ply
				if not ply:Alive() then return end
				ply.pain = ply.pain or 0
				ply.painlosing = ply.painlosing or 1
				local dmg = dmginfo:GetDamage()
				if dmginfo:IsDamageType(DMG_BLAST + DMG_SLASH + DMG_GENERIC + DMG_BULLET) then
					dmg = dmg * 4
				elseif dmginfo:IsDamageType(DMG_VEHICLE + DMG_CRUSH) and dmg > 5 then
					dmg = dmg * 0.35
				elseif dmginfo:IsDamageType(DMG_CLUB + DMG_BURN + DMG_DROWN + DMG_SHOCK + DMG_BUCKSHOT) then
					dmg = dmg * 6
				elseif not dmginfo:IsDamageType(DMG_BLAST + DMG_NERVEGAS) then
					dmg = dmg * 2
				end

				if dmginfo:GetAttacker():IsRagdoll() then
					dmg = dmg * 0
				end

				dmginfo:SetDamage(dmginfo:GetDamage())
				ply.pain = ply.pain + dmg
				ply:SetNWInt("pain", ply.pain)
				math.Clamp(ply.pain, 0, 1000)
				if (ply.pain > (250 * (ply.Blood / 5000)) + (ply:GetNWInt("SharpenAMT") * 5) or ply.Blood < 3000) and not ply.Otrub then
					ply.gotuncon = true
				end
			end
		end
	)

	PainNextThink = 0
	hook.Add(
		"Think",
		"PainLosingValue",
		function()
			for i, ply in ipairs(player.GetAll()) do
				ply.pain = ply.pain or 0
				ply.painlosing = ply.painlosing or 1
				if ply:GetNWInt("painlosing") == nil then
					ply:SetNWInt("painlosing", 1)
				end

				ply.PainNextThink = ply.PainNextThink or PainNextThink
				if not (ply.PainNextThink > CurTime()) then
					ply.PainNextThink = CurTime() + 0.1
					ply.painlosing = math.Clamp(ply:GetNWInt("painlosing") - 0.01, 0.5, 15)
					ply:SetNWInt("painlosing", ply.painlosing)
					ply.pain = math.Clamp(ply.pain - ply.painlosing, 0, 1000)
					ply:SetNWInt("pain", ply.pain)
					if IsUnconscious(ply) then
						GetUnconscious(ply)
					else
						ply:SetDSP(1)
					end
				end
			end
		end
	)

	hook.Add(
		"PlayerDeath",
		"RefreshPain",
		function(ply)
			ply.pain = 0
			ply.painlosing = 0
			ply:SetNWInt("painlosing", 1)
			ply.Otrub = false
		end
	)
end

function IsUnconscious(ply)
	if ply.pain > (250 * (ply.Blood / 5000)) + (ply:GetNWInt("SharpenAMT") * 5) or ply.Blood < 3000 then
		ply.Otrub = true
	else
		ply.Otrub = false
	end

	ply:SetNWInt("Otrub", ply.Otrub)

	return ply.Otrub
end

function GetUnconscious(ply)
	if ply:Alive() then
		ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.01, 1)
		ply:SetDSP(15)
	else
		ply:SetDSP(1)
	end

	if not ply.fake then
		Faking(ply)
	end

	if ply.gotuncon then
		ply.pain = ply.pain + 100
	end

	ply.gotuncon = false
	local rag = ply:GetNWEntity("DeathRagdoll")
	if IsValid(rag) and RagdollOwner(rag).Otrub then
		rag:SetEyeTarget(vector_origin)
	end
end

Pain()