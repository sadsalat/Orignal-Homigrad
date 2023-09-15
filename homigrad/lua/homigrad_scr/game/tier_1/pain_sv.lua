hook.Add("PlayerSpawn","homigrad-pain",function(ply)
	if PLYSPAWN_OVERRIDE then return end
	ply.painlosing = 0
	ply.pain = 0
	ply.painNext = 0
	ply.painNextNet = 0
	ply.otravlen = false
	ply.otravlen2 = false
end)

for i,ply in pairs(player.GetAll()) do
	--hook.Run("PlayerInitialSpawn",ply)
end

hook.Add("HomigradDamage","PlayerPainGrowth",function(ply,hitGroup,dmginfo,rag,armorMul)
	if dmginfo:GetAttacker():IsRagdoll() then return end
	local dmg = dmginfo:GetDamage()

	dmg = dmg * 1.3

	if dmginfo:IsDamageType(DMG_BLAST+DMG_SLASH+DMG_BULLET) then
		if dmginfo:IsDamageType(DMG_SLASH) then
			dmg = dmg * 4.5
		end

		if dmginfo:IsDamageType(DMG_BULLET) then
			dmg = dmg
		end

		dmg = dmg * 2
	elseif dmginfo:IsDamageType(DMG_VEHICLE+DMG_CRUSH+DMG_BUCKSHOT+DMG_GENERIC) then
		dmg = dmg * 1.5
	elseif dmginfo:IsDamageType(DMG_CLUB+DMG_BURN+DMG_DROWN+DMG_SHOCK) then
		dmg = dmg * 6.5
	elseif not dmginfo:IsDamageType(DMG_BLAST+DMG_NERVEGAS) then
		dmg = dmg * 2
	else
		if dmginfo:GetAttacker():IsRagdoll() then dmg = dmg * 0 end

		dmginfo:SetDamage(dmginfo:GetDamage())

		if ply.painlosing > 10 or ply.pain > 250 + ply:GetNWInt("SharpenAMT") * 5 or ply.Blood < 3000 and not ply.Otrub then
			ply.gotuncon = true
		end
	end

	if dmginfo:IsDamageType(DMG_CLUB+DMG_GENERIC) then
		dmginfo:ScaleDamage((IsValid(wep) and wep.GetBlocking and not wep:GetBlocking()) and 1 or 0.25)
	end
	
	dmg = dmg / ply.painlosing
	dmg = ply.nopain and 1 or dmg
	ply.pain = ply.pain + dmg
end)

local empty = {}

util.AddNetworkString("info_pain")

hook.Add("Player Think","homigrad-pain",function(ply,time)
	if not ply:Alive() or (ply.painNext or time) > time or ply:HasGodMode() then return end
	ply.painNext = time + 0.1
	
	if ply.painlosing > 5 then
		ply.stamina = 30
		ply.pain = ply.pain + 8
		--ply.KillReason = "painlosing"
		--ply:Kill()
		
	end

	if ply.pain >= 1800 then
		ply.KillReason = "pain"
		ply:Kill()
		return
	end

	local k = 0

	if ply.adrenaline <= 2 then
		k = 1 - ply.adrenaline / 2
	end

	if ply.adrenaline > 2 then
		ply.stamina = 30
		ply.pain = ply.pain + 5
		--ply.KillReason = "adrenaline"
		--ply:Kill()
	end
	--PrintMessage(3,tostring(ply.Otrub)..ply:Name())
	ply.pain = math.max(ply.pain - ply.painlosing * 1 + ply.adrenalineNeed * k,0)
	ply.painlosing = math.max(ply.painlosing - 0.01,1)
	
	if ply.painNextNet <= time then
		ply.painNextNet = time + 0.25
		net.Start("info_pain")
		net.WriteFloat(ply.pain)
		net.WriteFloat(ply.painlosing)
		net.Send(ply)
	end

	if IsUnconscious(ply) then
		GetUnconscious(ply)

		--net.Start("inventory")
		--net.WriteTable(empty)
		--net.Send(ply)
	else
		ply:ConCommand("soundfade 0 1")
	end
end)

hook.Add("PostPlayerDeath","RefreshPain",function(ply)
	ply.pain = 0
	ply.painlosing = 1
	
	ply.otravlen = false
	ply.otravlen2 = false

	ply:ConCommand("soundfade 0 1")

	ply.Otrub = false

	net.Start("info_pain")
	net.WriteFloat(ply.pain)
	net.WriteFloat(ply.painlosing)
	net.Send(ply)
end)

function IsUnconscious(ply)
	if ply.painlosing > 20 or ply.pain > 250 + ply:GetNWInt("SharpenAMT") * 5 or ply.Blood < 3000 or ply.heartstop then
		ply.Otrub = true

		ply:SetDSP(16)
	else
		ply.Otrub = false

		if ply.EZarmor.effects.earPro then
			ply:SetDSP(58)
		else
			ply:SetDSP(1)
		end
	end

	ply:SetNWInt("Otrub",ply.Otrub)

	return ply.Otrub
end

function GetUnconscious(ply)
	if ply:Alive() then
		ply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),0.5,0.5)
		--ply:ConCommand( "soundfade 5 1" )
		--ply:SetDSP(16)
	else
		--ply:ConCommand( "soundfade 0 1" )
		--ply:SetDSP(0)
	end

	if not ply.fake then Faking(ply) end
	if ply.gotuncon then ply.pain = ply.pain + 100 end
	ply.gotuncon = false

	local rag = ply:GetNWEntity("Ragdoll")
	if IsValid(rag) and ply.Otrub then rag:SetEyeTarget(Vector(0,0,0)) end
end