local nextbots = {
    "custom_ceno0",
    "custom_ceno0_alt",
    "npc_drg_huggy_wuggy",
    "npc_drg_huggy_elmo"
}

function nextbot.CanRoundNext()
    if #ReadDataMap("points_nextbox") == 0 then return false end--пау пау пау бам мы стреляем по хохлам!11
end

function nextbot.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1)  end

    local data = {}
    nextbot.twoteams = false
    data.twoteams = nextbot.twoteams

    if nextbot.twoteams then
        AutoBalanceTwoTeam()

        local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
        tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
        tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)
    else
        local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
        tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
    end

    for i = 1,math.min(math.random(3),#ReadDataMap("points_nextbox")) do
        local bot = table.Random(nextbots)
        bot = ents.Create(bot)
        local point = ReadPoint(table.Random(ReadDataMap("points_nextbox")))
        bot:SetPos(point[1])
        bot:Spawn()
    end

    for i,ply in pairs(players) do
        ply:SetPlayerColor(Color(math.random(160),math.random(160),math.random(160)):ToVector())
    end

    return data
end

function nextbot.RoundEndCheck()
    if nextbot.twoteams then
        local TAlive = 0
        local CTAlive = 0

        for i,ply in pairs(team.GetPlayers(1)) do
            if not PlayerIsCuffs(ply) and ply:Alive() then TAlive = TAlive + 1 end
        end

        for i,ply in pairs(team.GetPlayers(2)) do
            if not PlayerIsCuffs(ply) and ply:Alive() then CTAlive = CTAlive + 1 end
        end

        if TAlive == 0 and CTAlive == 0 then EndRound() return end

        if TAlive == 0 then EndRound(2) return end
        if CTAlive == 0 then EndRound(1) return end
    else
        local Alive = 0

        for i,ply in pairs(team.GetPlayers(1)) do
            if ply:Alive() then Alive = Alive + 1 end
        end

        if Alive == 0 then EndRound() return end
    end

	if roundTimeStart + roundTime - CurTime() <= 0 then
        if nextbot.twoteams then
            local TAlive = 0
            local CTAlive = 0

            for i,ply in pairs(team.GetPlayers(1)) do
                if not PlayerIsCuffs(ply) and ply:Alive() then TAlive = TAlive + 1 end
            end

            for i,ply in pairs(team.GetPlayers(2)) do
                if not PlayerIsCuffs(ply) and ply:Alive() then CTAlive = CTAlive + 1 end
            end

            if TAlive > CTAlive then EndRound(1) return else EntRound(2) return end
        else
            EndRound(1)
        end
	end
end

function nextbot.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

	nextbot.police = false
    if homicide.twoteams then
        PrintMessage(3,"Победили " .. (winner == 1 and "Красные" or winner == 2 and "Синие" or "Жертвы кибербулинга"))
    else
        if winner == 1 then
            PrintMessage(3,"Победа")
        else
            PrintMessage(3,"ну бывает...")
        end
    end
end

local teams = {}
local models = {}

for i = 1,9 do table.insert(models,"models/player/group01/male_0" .. i .. ".mdl") end
for i = 1,6 do table.insert(models,"models/player/group01/female_0" .. i .. ".mdl") end

table.insert(models,"models/player/group02/male_02.mdl")
table.insert(models,"models/player/group02/male_06.mdl")
table.insert(models,"models/player/group02/male_08.mdl")

function nextbot.PlayerSpawn(ply,teamID)
	ply:SetModel(models[math.random(#models)])
    ply:SetPlayerColor(team.GetColor(ply:Team()):ToVector())

    ply:Give("weapon_hands")

	if math.random(1,4) == 4 then
		ply:Give("adrinaline")
	end

	if math.random(1,4) == 4 then
		ply:Give("painkiller")
	end

	if math.random(1,4) == 4 then
		ply:Give("medkit")
	end

	if math.random(1,4) == 4 then
		ply:Give("med_band_big")
	end

	if math.random(1,4) == 4 then
		ply:Give("morphine")
	end

	local r = math.random(1,3)
	ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays")

	if math.random(1,3) == 3 then
		ply:Give("food_monster")
	end

	if math.random(1,5) == 5 then
		ply:Give("weapon_bat")
	end
end

function nextbot.PlayerInitialSpawn(ply)
    if nextbot.twoteams then ply:SetTeam(math.random(1,2)) else ply:SetTeam(1) end
end

function nextbot.PlayerCanJoinTeam(ply,teamID)
	if teamID == 3 then ply:ChatPrint("пашол нахуй") return false end

    if not nextbot.twoteams then
        if teamID == 2 then
            ply:ChatPrint("пашол нахуй")

            return false
        end

        return true
    else
        return true
    end
end

function nextbot.NoSelectRandom()
    return #ReadDataMap("points_nextbox") < 1
end
