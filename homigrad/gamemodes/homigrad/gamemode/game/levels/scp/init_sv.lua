resource.AddWorkshop("779759026")--049
resource.AddWorkshop("367531149")--096
resource.AddWorkshop("830210642")--173

function scp.SpawnSCP(ply,id)
    ply:SetTeam(3)
    ply:Spawn()
    ply:SetPlayerClass("scp" .. id)
    local point = table.Random(ReadDataMap("scp" .. id))
    point = ReadPoint(point)
    ply:SetPos(point[1])
end

function scp.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

    local players = team.GetPlayers(1)
    for i,ply in pairs(players) do
        ply:SetPlayerClass()
    end

    local ply,key = table.Random(players)
    players[key] = nil
    scp.SpawnSCP(ply,"173")

    local ply,key = table.Random(players)
    players[key] = nil
    scp.SpawnSCP(ply,"096")
    
    local count = #players
    local countWhite = math.ceil(count * 0.25)
    local countBlue = math.ceil(count * 0.25)

    local aviable = ReadDataMap("scpWhite")
    for i,ply in RandomPairs(players) do
        if countWhite == 0 then break end
        countWhite = countWhite - 1

        ply:SetTeam(2)
        ply:SetNWInt("Role",1)
        ply:Spawn()

        local point,key = table.Random(aviable)
        if #aviable > 1 then aviable[key] = nil end
        point = ReadPoint(point)
        ply:SetPos(point[1])

        players[i] = nil
    end

    local aviable = ReadDataMap("spawnpointsct")
    for i,ply in RandomPairs(players) do
        if countBlue == 0 then break end
        countBlue = countBlue - 1

        ply:SetTeam(2)
        ply:Spawn()
        ply:SetNWInt("Role",2)

        local point,key = table.Random(aviable)
        if #aviable > 1 then aviable[key] = nil end
        point = ReadPoint(point)
        ply:SetPos(point[1])

        players[i] = nil
    end

    local aviable = ReadDataMap("spawnpointst")
    for i,ply in pairs(players) do
        ply:Spawn()

        local point,key = table.Random(aviable)
        if #aviable > 1 then aviable[key] = nil end
        point = ReadPoint(point)
        ply:SetPos(point[1])
    end

    for i,ent in pairs(ents.FindByClass("func_button")) do
        if ent:GetModel() ~= "*175" then continue end
    
        ent:Fire("Use")
    end

    scp.spawnMOG = CurTime() + 60 * 30

    return {spawnMOG = scp.spawnMOG}
end

function scp.RoundEndCheck()
    local TExit,TExit,SExit = 0,0,0
	local TAlive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.exit then TExit = TExit + 1 return false end end)
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2),function(ply)
        if ply.exit then CTExit = TExit + 1 return false end
        if ply:GetNWInt("Role") ~= 1 then return false end
    end)

	local SAlive = tdm.GetCountLive(team.GetPlayers(2),function(ply) if ply.exit then SExit = SExit + 1 return false end end)

    local list = ReadDataMap("spawnpoints_ss_exit")

    if scp.spawnMOG and scp.spawnMOG < CurTime() then
        scp.spawnMOG = nil

        local list = ReadDataMap("spawnpoints_ss_police")

        for i,ply in pairs(player.GetAll()) do
            if ply:Team() ~= 1 and ply:Team() ~= 2 then continue end

            local point,key = table.Random(list)
            if #list > 1 then list[key] = nil end
            point = ReadPoint(point)
            ply:SetTeam(2)
            ply:SetNWInt("Role",3)
            ply:Spawn()
            ply:SetPlayerClass("contr")
            ply:SetPos(point[1])
        end
    end

    for i,ply in pairs(player.GetAll()) do
        if ply:Team() == 1002 or not ply:Alive() or ply.exit then continue end

        for i,point in pairs(list) do
            if ply:GetPos():Distance(point[1]) < (point[3] or 250) then
                ply.exit = true
                ply:KillSilent()
            end
        end
    end

	if TAlive == 0 and CTAlive == 0 then EndRound() end
end

function scp.EndRound(winner)
    PrintMessage(3,"Выиграли : " .. ((winer == 1 and "Зеки") or (winner == 2 and "Мусора") or (winner == 3 and "SCP") or "Повстанцы хаоса"))
end

function scp.PlayerSpawn(ply,teamID)
    ply:Give("weapon_hands")

    if teamID == 1 then
        ply:SetModel(tdm.models[math.random(1,#tdm.models)])
        ply:SetPlayerColor(Vector(1,0.5,0))
    elseif teamID == 2 then
        local role = ply:GetNWInt("Role")

        if role == 1 then
            ply:SetModel("models/player/hostage/hostage_0" .. math.random(1,4) .. ".mdl")
            ply:SetPlayerColor(Vector(1,1,1))

        elseif role == 2 then
            ply:SetPlayerColor(Vector(0.25,0.25,1))

            JMod.EZ_Equip_Armor(ply,"Riot-Helmet")
            JMod.EZ_Equip_Armor(ply,"Light-Vest")
        elseif role == 3 then
            ply:SetPlayerColor(Vector(0,0,0.5))
        end

        for i,list in pairs(scp.roles[role][3]) do
            tdm.GiveSwep(ply,list)
        end
    end
end

function scp.PlayerCanJoinTeam(ply)
    if ply:Team() == 2 or ply:Team() == 3 then return false end
end

function scp.PlayerInitialSpawn(ply) ply:SetTeam(1) end

function scp.NoSelectRandom()
    return true
end

function scp.ShouldSpawnLoot() return false end