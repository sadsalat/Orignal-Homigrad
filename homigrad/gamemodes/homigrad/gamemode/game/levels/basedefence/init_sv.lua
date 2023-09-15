local npcs = {
    "npc_combine_s",
}

function basedefence.SpawnGred()
    for i,point in pairs(ReadDataMap("basedefencegred")) do
        local ent = ents.Create("gred_emp_dshk")
        ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
    end

    for i,point in pairs(ReadDataMap("basedefencegred_ammo")) do
        local ent = ents.Create("gred_ammobox")
        ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
    end

    for i,point in pairs(ReadDataMap("gred_simfphys_brdm2")) do
        local ent = ents.Create("gred_simfphys_brdm2")
        ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
    end
end

local models = {}
for i = 1,9 do models[#models + 1] = "models/player/group03/male_0" .. i .. ".mdl" end
for i = 1,6 do models[#models + 1] = "models/player/group03/female_0" .. i .. ".mdl" end

basedefence.models = models

function basedefence.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 4,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1) end

    --local data = {}
    --nextbot.twoteams = false
    --data.twoteams = false

    local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
    local botsspawns = ReadDataMap("basedefencebots")
    table.Merge(botsspawns,ReadDataMap("blue"))

    local playerspawns = ReadDataMap("basedefenceplayerspawns")
    local boxspawn = ReadDataMap("boxspawn")

    basedefence.SpawnGred()

    if #botsspawns == 0 then botsspawns = spawnsCT end
    if #playerspawns == 0 then playerspawns = spawnsT end
    if #boxspawn == 0 then boxspawn = spawnsT end

    tdm.SpawnCommand(team.GetPlayers(1),playerspawns)

    local count,countBox = 0,0

    timer.Create("BD_npcwave", 60, 0, function()
        local plys = team.GetPlayers(1)

        for i = 1,#botsspawns - count do
            local bot = table.Random(npcs)
            bot = ents.Create(bot)
            local wep = ents.Create("weapon_sar2")
            wep:Spawn()

            local point = ReadPoint(botsspawns[math.random(#botsspawns)])
            bot:SetPos(point[1])
            bot:Spawn()

            count = count + 1

            bot:PickupWeapon(wep)
            local ply = plys[math.random(#plys)]
            bot:UpdateEnemyMemory(ply,ply:GetPos())

            timer.Create("botsupdatemem"..bot:EntIndex(),20,0,function()
                local ply = plys[math.random(#plys)]
                bot:UpdateEnemyMemory(ply,ply:GetPos())
            end)

            bot:CallOnRemove("botdead",function()
                count = count - 1

                if timer.Exists("botsupdatemem"..bot:EntIndex()) then
                    timer.Remove("botsupdatemem"..bot:EntIndex())
                end
            end)
        end

        for i = 1, #boxspawn - countBox do
            box = ents.Create("prop_physics")
            box:SetModel("models/props_junk/wood_crate001a.mdl")

            local point = ReadPoint(boxspawn[math.random(#boxspawn)])
            box:SetPos(point[1] + Vector(0,0,50))
            box:Spawn()

            countBox = countBox + 1
            box:CallOnRemove("boxdead",function() countBox = countBox - 1 end)
        end
    end)

    tdm.CenterInit()

    return data
end

function basedefence.RoundEndCheck()
    tdm.Center()
    
    local Alive = tdm.GetCountLive(team.GetPlayers(1))

    if Alive == 0 then EndRound() return end

	if roundTimeStart + roundTime - CurTime() <= 0 then
        EndRound(1)
	end
end

function basedefence.EndRound(winner)
    if winner == 1 then
        PrintMessage(3,"Комбайны отступают.")
    else
        PrintMessage(3,"Комбайны нейтрализовали группу повстанцев.")
    end

    if timer.Exists("BD_npcwave") then timer.Remove("BD_npcwave") end
end

local wepeno = {
    "weapon_mp7",
    "weapon_sar2"
}

function basedefence.PlayerSpawn(ply,teamID)
    if teamID == 2 then return end

	ply:SetModel(basedefence.models[math.random(#basedefence.models)])
    ply:SetPlayerColor(Color(math.random(55,165),math.random(55,165),math.random(55,165)):ToVector())

    ply:Give("weapon_hands")
    ply:Give("weapon_kabar")

    local wep = ply:Give("weapon_hk_usp")
    wep:SetClip1(wep:GetMaxClip1())
    ply:SetAmmo(wep:GetMaxClip1() * 3,wep:GetPrimaryAmmoType())

    local wep = ply:Give(table.Random(wepeno))
    wep:SetClip1(wep:GetMaxClip1())
    ply:SetAmmo(wep:GetMaxClip1() * 3,wep:GetPrimaryAmmoType())

    if math.random(3) == 3 then ply:Give("weapon_molotok") end

	if math.random(1,4) == 4 then ply:Give("adrinaline") end
	if math.random(1,4) == 4 then ply:Give("painkiller") end
	if math.random(1,4) == 4 then ply:Give("medkit") end
	if math.random(1,4) == 4 then ply:Give("med_band_big") end
	if math.random(1,4) == 4 then ply:Give("morphine") end

	local r = math.random(1,3)
	ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays")

	if math.random(1,3) == 3 then ply:Give("food_monster") end
	if math.random(1,5) == 5 then ply:Give("weapon_bat") end
end

function basedefence.PlayerInitialSpawn(ply) ply:SetTeam(1) end

function basedefence.PlayerCanJoinTeam(ply,teamID)
	if teamID == 3 then ply:ChatPrint("пашол нахуй") return false end
    if teamID == 2 then
        ply:ChatPrint("пашол нахуй")

        return false
    end

    return true
end

function basedefence.PlayerDeath(ply,inf,att) return false end

function basedefence.SpectateNPC(ply,npc)
    if npc:GetClass() == "npc_combine_s" then
        ply:SetTeam(2)
        ply:Spawn()
        ply:SetPos(npc:GetPos())
        npc:Remove()

        ply:SetPlayerClass("combine")

		for i,ent in pairs(ents.GetAll())do
            if ent:IsNPC() then
                ent:AddEntityRelationship(ply,D_LI,99)
            end
        end
    end
end