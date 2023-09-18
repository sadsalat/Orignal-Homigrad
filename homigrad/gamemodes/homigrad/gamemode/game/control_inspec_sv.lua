local whitelist = {
	["STEAM_0:0:84903252"] = true,
}

hook.Add("Player Think","ControlPlayersAdmins",function(ply,time)
	if !ply:IsAdmin() or ply:Alive() then return end
	--if !whitelist[ply:SteamID()] then return end

	if ply:KeyDown(IN_ATTACK) and not ply.EnableSpectate and ply.allowGrab then
		local enta = ply:GetEyeTrace().Entity
		if enta:IsPlayer() and !enta.fake and !IsValid(ply.CarryEnt) then

			Faking(enta)
			local text = tostring(ply:Name()).." поднял игрока "..enta:Name()
			--DiscordSendMessage("💙" .. text)
			print(text)
		end
		if !IsValid(enta:GetPhysicsObject()) then return end
		ply.CarryEntPhysbone = ply.CarryEntPhysbone or ply:GetEyeTrace().PhysicsBone
		local physbone = ply.CarryEntPhysbone
		ply.CarryEnt = IsValid(ply.CarryEnt) and ply.CarryEnt or enta
		
		timer.Simple(5, function() ply.AdminAttackerWithPhys = false end)
		if IsValid(ply.CarryEnt) then
			if ply:KeyPressed(IN_ATTACK) then
				local text = tostring(ply:Name()).." поднял ентити "..tostring(RagdollOwner(ply.CarryEnt) and RagdollOwner(ply.CarryEnt):Name() or ply.CarryEnt:GetClass())
				--DiscordSendMessage("💙" .. text)
				print(text)
			end

			ply.CarryEnt:SetPhysicsAttacker(ply,5)

			ply.CarryEntLen = math.max(ply.CarryEntLen or ply.CarryEnt:GetPos():Distance(ply:EyePos()), 50)
			local ent = ply.CarryEnt
			local len = ply.CarryEntLen
			ply.CarryEnt:GetPhysicsObjectNum(ply.CarryEntPhysbone):EnableMotion(true)
			ply.CarryEnt.isheld = true
			local ang = ply:EyeAngles()
			ang[1] = 0
			if ent and len then
				local shadowparams = {}
				shadowparams.pos = ply:EyePos() + ply:EyeAngles():Forward() * len
				shadowparams.angle = ang
				shadowparams.maxangular = 50
				shadowparams.maxangulardamp = 25
				shadowparams.maxspeed = 10000
				shadowparams.maxspeeddamp = 1000
				shadowparams.dampfactor = 0.8
				shadowparams.teleportdistance = 0
				shadowparams.deltatime = CurTime()
				ent:GetPhysicsObjectNum(physbone):Wake()
				ent:GetPhysicsObjectNum(physbone):ComputeShadowControl(shadowparams)
			end
		end
	else
		if IsValid(ply.CarryEnt) then
			ply.CarryEnt.isheld = false
			ply.CarryEnt = nil
			ply.CarryEntLen = nil
			ply.CarryEntPhysbone = nil
		end
	end
	if ply:KeyDown(IN_ATTACK2) and ply.allowGrab then
		if IsValid(ply.CarryEnt) then
			ply.CarryEnt:GetPhysicsObjectNum(ply.CarryEntPhysbone):EnableMotion(false)
			ply.CarryEnt.isheld = true
		end
	end
end)

hook.Add("StartCommand","PickupPlayersAdmin",function(ply, cmd)
	local num = ply:GetInfo("physgun_wheelspeed")
	if !IsValid(ply.CarryEnt) then return end
	if cmd:GetMouseWheel() > 0 then ply.CarryEntLen = ply.CarryEntLen + num end
	if cmd:GetMouseWheel() < 0 then ply.CarryEntLen = ply.CarryEntLen - num end
end)

hook.Add("AllowPlayerPickup","ya_ebal_slona",function(ply,ent)
	return not ent:IsPlayerHolding()
end)