function GuiltLogic(ply,att,dmgInfo,dontApply)
	--if ply.RoundGuilt > 3 then return end
	--if #ply.attackees > 0 then return end
	if att == ply then return end
	if not roundActive then return end
	--if #player.GetAll() <= 6 then return end

	local resultHook = hook.Run("Guilt Logic",ply,att,dmgInfo)
	if resultHook == false then return end

	local resultGame = TableRound().GuiltLogic
	resultGame = resultGame and resultGame(ply,att,dmgInfo)
	if resultGame == false then return end

	local resultClass = ply:PlayerClassEvent("GuiltLogic",att,dmgInfo)
	if resultClass == false then return end
	
	local plyTeam = ply:Team()
	local attTeam = att:Team()

	if resultGame or resultHook or resultClass or plyTeam == attTeam then
		if ply.DontGuiltProtect then
			if not dontApply then
				att.Guilt = math.max(att.Guilt - dmgInfo:GetDamage(),0)
			end

			return false,true
		end

		if not dontApply then
			local customGuiltAdd = (type(resultHook) == "number" and resultHook) or (type(resultGame) == "number" and resultGame) or (type(resultClass) == "number" and resultClass)

			att.Guilt = (att.Guilt or 0) + (customGuiltAdd or math.min(dmgInfo:GetDamage() / (3),50))
			att.DontGuiltProtect = true

			GuiltCheck(att,ply)
		end
		
		return true
	end

	return false
end

local validUserGroup = {
	superadmin = true,
	admin = true,
	megapenis = true
}

COMMANDS.noguilt = {function(ply,args)
	if not ply:IsAdmin() then return end
	local value = tonumber(args[2]) > 0

	for i,ply in pairs(player.GetListByName(args[1]) or {ply}) do
		ply.noguilt = value
		ply:ChatPrint("Guilt Protect: " .. tostring(value))
	end
end,1}

--[[COMMANDS.fake = {function(ply,args)
	if not ply:IsAdmin() then return end

	for i,ply in pairs(player.GetListByName(args[1]) or {ply}) do
		Faking(ply)
	end
end,1}]]--

function GuiltCheck(att,ply)
	if att.Guilt >= 100 then
		att.Guilt = 0
		
		if not att.noguilt and not att:HasGodMode() then
			att:Kill()

			if not validUserGroup[att:GetUserGroup()] then
				RunConsoleCommand("ulx","fakeban",att:Name(),"10","Kicked and Banned for RDM")
			else
				RunConsoleCommand("ulx","fakeban",att:Name(),"10","Kicked and Banned for RDM")
			end
		end
	end
end

hook.Add("HomigradDamage","guilt-logic",function(ply,hitGroup,dmgInfo,rag)
	local att = ply.LastAttacker

	if ply and att then
		GuiltLogic(ply,att,dmgInfo)
	end
end)

hook.Add("Should Fake Collide","guilt",function(ply,hitEnt,data)
	if hitEnt == game.GetWorld() then return end
	hitEnt = RagdollOwner(hitEnt)
	if not hitEnt:IsPlayer() then return end

	local dmgInfo = DamageInfo()
	dmgInfo:SetAttacker(hitEnt)
	dmgInfo:SetDamage(10)
	dmgInfo:SetDamageType(DMG_CRUSH)

	GuiltLogic(ply,hitEnt,dmgInfo)
end)

hook.Add("PlayerInitialSpawn","guiltasdd",function(ply)
	ply.Guilt = ply:GetPData("Guilt") or 0
	ply:ChatPrint("Ваш гилт составляет " .. tostring(ply.Guilt) .. "%")
	ply.RoundGuilt = 0
end)

--[[local function Seizure(ply)
	ply.Seizure = true
	ply:ChatPrint("У тебя приступ.")
	if not ply.fake then
		Faking(ply)
	end
	timer.Create("seizure"..ply:EntIndex(),math.random(7,15),1,function()
		if ply:IsValid() and ply:Alive() then
			ply:Kill()
		end
	end)
end]]--

hook.Add("PlayerSpawn","guilt",function(ply)
	if PLYSPAWN_OVERRIDE then return end
	ply.DontGuiltProtect = nil
	ply.Seizure = false
	ply.Guilt = ply.Guilt or 0
	ply:ChatPrint("Ваш гилт составляет " .. tostring(math.floor(ply.Guilt)) .. "%")
	--[[if ply.Guilt > 30 then
		timer.Create("seizure"..ply:EntIndex(),math.random(30,50),1, function()
			Seizure(ply)
		end)
	end]]--
end)

hook.Add("PlayerDisconnected","guiltasd",function(ply)
	ply:SetPData("Guilt",ply.Guilt)
end)

hook.Add("Player Think","guilt reduction",function(ply,time)
	ply.GuiltReductionCooldown = ply.GuiltReductionCooldown or time

	if ply.GuiltReductionCooldown < time then
		ply.GuiltReductionCooldown = time + 5
		ply.Guilt = math.max((ply.Guilt or 0) - 1,0)
	end
end)

concommand.Add("hg_getguilt",function(ply)
	local text = "Guilt information\n"

	for i,ply in pairs(player.GetAll()) do
		text = text .. ply:Name() .. "\t\t\t\t" .. ply.Guilt .. "\n"
	end

	ply:ConsolePrint(text)
end)