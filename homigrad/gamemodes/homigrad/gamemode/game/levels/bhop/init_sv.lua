function bhop.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (1 + math.min(#player.GetAll() / 16,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1) end

    local aviable = ReadDataMap("bhop")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()
    tdm.SpawnCommand(team.GetPlayers(1),aviable,function(ply)
        ply:Freeze(true)
    end)

    freezing = true

    RTV_CountRound = RTV_CountRound - 1

    roundTimeRespawn = CurTime() + 15

    return {roundTimeStart,roundTime}
end

function bhop.RoundEndCheck()
    local Alive = 0

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then Alive = Alive + 1 end
    end

    if freezing and roundTimeStart + bhop.LoadScreenTime < CurTime() then
        freezing = nil

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:Freeze(false)
        end
    end

    /*if roundTimeRespawn < CurTime() then
        roundTimeRespawn = CurTime() + 15

        local aviable = ReadDataMap("bhop")
        aviable = #aviable ~= 0 and aviable or homicide.Spawns()
        tdm.SpawnCommand(team.GetPlayers(1),aviable,nil,function(ply) if ply:Alive() then return false end end)
    end*/

    if Alive <= 1 then EndRound() return end

	if roundTimeStart + roundTime - CurTime() <= 0 then
        EndRound(1)
	end
end

function bhop.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

    PrintMessage(3,"Победили " .. (winner == 1 and "CS'еры" or "Жертвы кибербулинга"))
end

local red = Color(255,0,0)

function bhop.PlayerSpawn(ply,teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(red:ToVector())

    ply:Give("weapon_hands")
    ply:Give("weapon_bhop_machine")

    ply:SetLadderClimbSpeed(300)

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

function bhop.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function bhop.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("пашол нахуй") return false end

    return true
end

function bhop.GuiltLogic() return false end

util.AddNetworkString("bhop die")
function bhop.PlayerDeath()
    net.Start("bhop die")
    net.Broadcast()
end