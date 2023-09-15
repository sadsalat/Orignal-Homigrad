function jailbreak.CanRoundNext()
    if #ReadDataMap("jailbreak_doors") == 0 and #ReadDataMap("jailbreak") == 0 then return false end

    for i,ply in pairs(team.GetPlayers(1)) do
        if jailbreak.GetRank(ply) then return true end
    end

    for i,ply in pairs(team.GetPlayers(2)) do
        if jailbreak.GetRank(ply) then return true end
    end

    for i,ply in pairs(team.GetPlayers(3)) do
        if jailbreak.GetRank(ply) then return true end
    end
end

local ranksPlayer = util.JSONToTable(file.Read("homigrad/jailbreak_ranks.txt") or "") or {}

function jailbreak.SetRank(ply,rank)
    ply:SetNWInt("JailBreakRank",rank or 0)
    ranksPlayer[ply:SteamID()] = rank

    file.Write("homigrad/jailbreak_ranks.txt",util.TableToJSON(ranksPlayer))
end

function jailbreak.ReadRank(ply)
    ply:SetNWInt("JailBreakRank",ranksPlayer[ply:SteamID()])
end

function jailbreak.StartRoundSV()
    for i,ply in pairs(team.GetPlayers(3)) do
        ply:SetTeam(1)
    end

    for i,ply in pairs(player.GetAll()) do
        ply.JB_Speak = nil

        jailbreak.ReadRank(ply)--lol...

        if ply:Team() == 2 and not jailbreak.GetRank(ply) then ply:SetTeam(1) ply:ChatPrint("читор!11") end
    end

    for i,ply in pairs(team.GetPlayers(1)) do
        if jailbreak.PlayerCanJoinTeam(ply,true) then ply:SetTeam(1) end
    end

    if GetGlobalBool("JailBreakRandom") then
        for i,ply in pairs(team.GetPlayers(2)) do
            if jailbreak.GetRank(ply) then continue end

            ply:SetTeam(1)
        end

        local list = team.GetPlayers(1)
        for i = 1,math.max(jailbreak.GetMaxBlue() - #team.GetPlayers(2),0) do
            local ply,key = table.Random(list)
            list[key] = nil
            ply:SetTeam(2)
            for i = 1,3 do ply:ChatPrint("!levelhelp") end
        end
    end

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)
end

function jailbreak.RoundEndCheck()
	local TAlive,TExit = 0,0

    local list = ReadDataMap("jailbreak")
    local team1,team2 = team.GetPlayers(1),team.GetPlayers(2)

    TAlive = tdm.GetCountLive(team1,function(ply)
        if ply.exit then TExit = TExit + 1 return false end

        if not ply:Alive() then return false end--lol

        for i,point in pairs(list) do
            if ply:GetPos():Distance(point[1]) < (point[3] or 250) then
                ply.exit = true
                ply:KillSilent()

                TExit = TExit + 1
            end
        end
    end)

    local CTAlive = tdm.GetCountLive(team2,function(ply)
        if not ply:HasWeapon("weapon_handcuffs") then ply:Give("weapon_handcuffs") end
        if not ply:HasWeapon("weapon_taser") then ply:Give("weapon_taser") end
    end)

    if #team1 == 0 then return end--fuck
    if #team2 == 0 then return end--fuck

	if TExit > 0 and TAlive == 0 then EndRound(2) return end
	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if CTAlive == 0 then EndRound(1) return end
	if TAlive == 0 then EndRound(2) return end
end

function jailbreak.EndRound(winner) tdm.EndRoundMessage(winner) end

function jailbreak.PlayerInitialSpawn(ply)
    jailbreak.ReadRank(ply)

    ply:SetTeam(1)
end

function jailbreak.PlayerSpawn(ply,teamID)
    local teamTbl = jailbreak[jailbreak.teamEncoder[teamID]]
    local models = teamTbl.models
    local teamColor = team.GetColor(ply:Team())

    local rank = teamID == 2 and jailbreak.GetRank(ply)

    teamColor = rank and rank[2] or teamColor

	ply:SetModel(models[math.random(#models)])
    ply:SetPlayerColor(teamColor:ToVector())

    ply:Give("weapon_hands")

    if ply:Team() == 1 then
        if math.random(1,4) == 4 then ply:Give("adrinaline") end
        if math.random(1,4) == 4 then ply:Give("painkiller") end
        if math.random(1,4) == 4 then ply:Give("medkit") end
        if math.random(1,4) == 4 then  ply:Give("bandage") end
        if math.random(1,4) == 4 then ply:Give("morphine") end

        local r = math.random(1,3)
        ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays")

        if math.random(1,3) == 3 then  ply:Give("food_monster") end

        if math.random(1,12) == 12 then ply:Give("weapon_per4ik") end
        if math.random(1,150) == 150 then ply:Give("weapon_knife") end
        if math.random(1,150) == 150 then ply:Give("weapon_t") end
        if math.random(1,1000) == 1000 then
            if math.random(1,2) == 2 then ply:Give("weapon_hidebomb") else ply:Give("weapon_jahidka") end

            ply:ChatPrint("time to kill ")
        end

        if math.random(1,48) == 48 then ply:Give("weapon_molotok") end
    end

    for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

    tdm.GiveSwep(ply,teamTbl.main_weapon,12)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon,12)

    if teamID == 2 then
        if rank and rank[3] then
            for i,name in pairs(rank[3]) do
                JMod.EZ_Equip_Armor(ply,name,teamColor,true)
            end
        else
            JMod.EZ_Equip_Armor(ply,"Light-Helmet",teamColor)
            JMod.EZ_Equip_Armor(ply,"Light-Vest",teamColor)
        end
    else
        timer.Simple(0.1,function()
            if not IsValid(ply) then return end

            for i,wep in pairs(ply:GetWeapons()) do
                if wep:GetClass() == "weapon_knife" then wep:Remove() end
            end
        end)
    end
end

COMMANDS.jailbreak_norank = {function(ply,args)
    jailbreak.norank = tonumber(args[1]) > 0
    PrintMessage(3,"cant join for ranked players: " .. tostring(jailbreak.norank))
end}

function jailbreak.PlayerCanJoinTeam(ply,teamID,noAdmin)
    if teamID == 2 then
        local rank = jailbreak.GetRank(ply)
        if not jailbreak.norank and not rank then ply:ChatPrint("У тебя нет ранга.") return false end

        if not noAdmin and ply:IsAdmin() then return true end

        --[[if jailbreak.GetMaxBlue() + 1 < #team.GetPlayers(2) then
            ply:ChatPrint("на 4 зеков 1 охраник, этот лимит исчерпан")

            return false
        end--на 4 зека 1 охраник]]--

        if jailbreak.norank and rank then ply:ChatPrint("no fuck off") return false end
    end

    if teamID == 1 then return true end
    if teamID == 3 then ply:ChatPrint("нахуй") return false end
end

local function CanLisen(self,output,input,isChat)
    if not output:Alive() or output.Otrub or input.Otrub then return false end
    if (isChat and output:GetActiveWeapon() == self) or output:KeyDown(IN_ATTACK) then return true end

    if output:InVehicle() and output:IsSpeaking() then self.voiceSpeak = CurTime() + 0.5 end

    if not input:HasWeapon("weapon_radio") then return end

    if output:GetActiveWeapon() ~= self or (not isChat and not self.Transmit) then return end

    if output:Team() == input:Team() or output:Team() == 1002 then return true end
end

local function CanTransmit(self)
    local owner = self:GetOwner()

    return self.voiceSpeak > CurTime() or owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)
end

hook.Add("WeaponEquip","JailBreakRadio",function(wep,ply)
    if roundActiveName ~= "jailbreak" then return end
    
    if wep:GetClass() == "weapon_radio" then
        wep.CanLisen = CanLisen
        wep.CanTransmit = CanTransmit
    end
end)

function jailbreak.ShouldSpawnLoot() return false end
function jailbreak.ShouldFakeGround(ply) return false end
function jailbreak.ShouldFakeVelocity(ply) return false end
function jailbreak.CanRandomNext() return false end