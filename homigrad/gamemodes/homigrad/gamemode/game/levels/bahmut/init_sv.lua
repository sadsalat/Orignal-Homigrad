function bahmut.SelectRandomPlayers(list,div,func)
	for i = 1,math.floor(#list / div) do
		local ply,key = table.Random(list)
		table.remove(list,key)

		func(ply)
	end
end

function bahmut.GiveMimomet(ply)
    ply:Give("weapon_gredmimomet")
    ply:Give("weapon_gredammo")
end

function bahmut.GiveAidPhone(ply)
    ply:Give("weapon_phone")
end

function bahmut.SpawnSimfphys(list,name,func)
	for i,point in pairs(list) do
		local ent = simfphys.SpawnVehicleSimple(name,point[1],point[2])

		if func then func(ent) end
	end
end

function bahmut.SpawnVehicle()
    bahmut.SpawnSimfphys(ReadDataMap("car_red"),"sim_fphys_van")
    bahmut.SpawnSimfphys(ReadDataMap("car_blue"),"sim_fphys_van")

	bahmut.SpawnSimfphys(ReadDataMap("sim_fphys_tank3"),"sim_fphys_tank3")
	bahmut.SpawnSimfphys(ReadDataMap("sim_fphys_tank4"),"sim_fphys_tank4")
	
    --bahmut.SpawnSimfphys(ReadDataMap("car_red_btr"),"gred_simfphys_brdm2",function(ent) timer.Simple(1,function() ent:SetSkin(11) end) end)
    --bahmut.SpawnSimfphys(ReadDataMap("car_blue_btr"),"gred_simfphys_brdm2",function(ent) timer.Simple(1,function() ent:SetSkin(10) end) end)
	bahmut.SpawnEnt(ReadDataMap("wac_hc_ah1z_viper"),"wac_hc_ah1z_viper")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_littlebird_ah6"),"wac_hc_littlebird_ah6")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_mi28_havoc"),"wac_hc_mi28_havoc")
	bahmut.SpawnEnt(ReadDataMap("wac_hc_blackhawk_uh60"),"wac_hc_blackhawk_uh60")
	bahmut.SpawnEnt(ReadDataMap("gred_emp_breda35"),"gred_emp_breda35")

    bahmut.SpawnSimfphys(ReadDataMap("car_red_tank"),"gred_simfphys_brdm2",function(ent) timer.Simple(1,function() ent:SetSkin(0) end) end)
    bahmut.SpawnSimfphys(ReadDataMap("car_blue_tank"),"gred_simfphys_brdm2",function(ent) timer.Simple(1,function() ent:SetSkin(10) end) end)
end

function bahmut.SpawnEnt(list,name,func)
    for i,point in pairs(list) do
		local ent = ents.Create(name)
		ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
	end
end

function bahmut.SpawnGred()
    bahmut.SpawnEnt(ReadDataMap("gred_emp_dshk"),"gred_emp_dshk")
    bahmut.SpawnEnt(ReadDataMap("gred_ammobox"),"gred_ammobox")
    bahmut.SpawnEnt(ReadDataMap("gred_emp_2a65"),"gred_emp_2a65")
	bahmut.SpawnEnt(ReadDataMap("gred_emp_pak40"),"gred_emp_pak40")
end

function bahmut.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	bahmut.SpawnVehicle()
	bahmut.SpawnGred()

	bahmut.oi = false

	tdm.CenterInit()

    bahmut.SelectRandomPlayers(team.GetPlayers(1),2,bahmut.GiveMimomet)
    bahmut.SelectRandomPlayers(team.GetPlayers(1),2,bahmut.GiveAidPhone)

    bahmut.SelectRandomPlayers(team.GetPlayers(2),2,bahmut.GiveMimomet)
    bahmut.SelectRandomPlayers(team.GetPlayers(2),2,bahmut.GiveAidPhone)
end

function bahmut.RoundEndCheck()
	if roundTimeStart + roundTime - CurTime() < 0 then
		if not bahmut.oi then
			bahmut.oi = true

			local list = ReadDataMap("points_nextbox")
			if #list > 0 then
				local bot = "npc_drg_huggy_elmo"
				bot = ents.Create(bot)
				local pos = table.Random(list)
				bot:SetPos(pos)
				bot:Spawn()

				PrintMessage(3,"оххх.. зря я туда полеззз....")
			end
		end
	end

	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end

function bahmut.EndRound(winner) tdm.EndRoundMessage(winner) end

function bahmut.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function bahmut.PlayerSpawn(ply,teamID)
	local teamTbl = bahmut[bahmut.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

	if teamID == 1 then
		ply:SetBodygroup(1,2)
		ply:SetBodygroup(2,1)
		ply:SetBodygroup(4,1)
		ply:SetBodygroup(5,1)
		ply:SetBodygroup(6,1)
		ply:SetBodygroup(7,1)
		ply:SetBodygroup(9,2)
	end

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon)

	if math.random(1,4) == 4 then ply:Give("adrinaline") end
	if math.random(1,4) == 4 then ply:Give("morphine") end
	if math.random(1,4) == 4 then ply:Give("weapon_hg_sleagehammer") end
	
	JMod.EZ_Equip_Armor(ply,"Medium-Helmet",color)
	local r = math.random(1,2)
	JMod.EZ_Equip_Armor(ply,(r == 1 and "Medium-Vest") or (r == 2 and "Light-Vest"),color)

	if roundStarter then
		ply:Give("weapon_gredmimomet")
		ply:Give("weapon_gredammo")
		ply:Give("weapon_phone")
		ply.allowFlashlights = true
	end
end

function bahmut.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end

function bahmut.ShouldSpawnLoot() return false end
function bahmut.PlayerDeath(ply,inf,att) return false end