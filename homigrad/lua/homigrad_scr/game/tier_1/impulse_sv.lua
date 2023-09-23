
--[[hook.Add("EntityTakeDamage","GainImpulse",function(ply,dmginfo)
	local ply = RagdollOwner(ply) or ply
	local dmg=dmginfo:GetDamage()
	ply.dmgimpulse=ply.dmgimpulse or 0
	ply.dmgimpulse=ply.dmgimpulse+dmg
end)--]]

hook.Add("HomigradDamage","ImpulseShock",function(ply,hitGroup,dmginfo)
	local dmg = dmginfo:GetDamage()

	if dmginfo:IsDamageType(DMG_BLAST) then
		dmg = dmg * 4
	elseif dmginfo:IsDamageType(DMG_VEHICLE+DMG_CRUSH) and dmg > 5 then
		dmg = dmg * 0.05
	elseif dmginfo:IsDamageType(DMG_BURN+DMG_SHOCK+DMG_BUCKSHOT) then
		dmg = dmg * 6
	elseif dmginfo:IsDamageType(DMG_BLAST+DMG_CLUB+DMG_GENERIC+DMG_SLASH) then
		dmg = dmg * 1
	elseif dmginfo:IsDamageType(DMG_NERVEGAS+DMG_DROWN) then
		dmg = 0
	else
		dmg = dmg
	end

	dmg = ply.nopain and 0.01 or dmg

	ply.dmgimpulse = ply.dmgimpulse or 0
	ply.dmgimpulse = ply.dmgimpulse + dmg * 1.5

	net.Start("info_impulse")
	net.WriteFloat(ply.dmgimpulse)
	net.Send(ply)

	local force = dmginfo:GetDamageForce() / 5

	if hitGroup == HITGROUP_RIGHTLEG or hitGroup == HITGROUP_LEFTLEG then
		if ply.dmgimpulse > 12 then timer.Simple(0,function() if not ply.fake then Faking(ply,force) end end) end
	end

	if hitGroup == HITGROUP_CHEST then
		if ply.dmgimpulse > 24 then timer.Simple(0,function() if not ply.fake then Faking(ply,force) end end) end
	end

	if hitGroup == HITGROUP_STOMACH then
		if ply.dmgimpulse > 48 then timer.Simple(0,function() if not ply.fake then Faking(ply,force) end end) end
	end
end)

util.AddNetworkString("info_impulse")

hook.Add("Player Think","StoppingImpulse",function(ply,time)
	if ply:HasGodMode() or (ply.impulseNext or time) > time then return end
	ply.impulseNext = time + 0.05

	net.Start("info_impulse")
	net.WriteFloat(ply.dmgimpulse)
	net.Send(ply)

	ply.dmgimpulse  = math.max(ply.dmgimpulse - 3,0)
end)

hook.Add("PlayerSpawn","homgirad-impulse",function(ply)
	if PLYSPAWN_OVERRIDE then return end
	ply.dmgimpulse = 0
	ply.impulseNext = 0

	net.Start("info_impulse")
	net.WriteFloat(0)
	net.Send(ply)
end)
