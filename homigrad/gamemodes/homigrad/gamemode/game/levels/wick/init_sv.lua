
local function makeT(ply)
    ply.roleT = true
    table.insert(wick.t,ply)

    ply:Give("weapon_kabar")
    local wep = ply:Give("weapon_hk_usp")
    wep:SetClip1(wep:GetMaxClip1())
    ply:GiveAmmo(6 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())

    ply:Give("weapon_hg_rgd5")

    local wep = ply:Give("weapon_ar15")
    wep:SetClip1(wep:GetMaxClip1())
    ply:GiveAmmo(2 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
    ply.nopain = true
    ply:SetMaxHealth(#player.GetAll() * 200)
    ply:SetHealth(#player.GetAll() * 200)

    ply:ChatPrint("Вы Джон Уик.")
end

COMMANDS.nopain = {function(ply,args)
    ply.nopain = args[1]
end}

function wick.SpawnsCT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointsnaem")) do
        table.insert(aviable,point)
    end

    return aviable
end

function wick.SpawnsT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("spawnpointswick")) do
        table.insert(aviable,point)
    end

    return aviable
end

function wick.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 2.5),1) * 60

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in pairs(player.GetAll()) do ply.roleT = false end

    wick.t = {}

    local countT = 0

    local aviable = wick.SpawnsCT()
    local aviable2 = wick.SpawnsT()

    local players = PlayersInGame()

    local count = 1
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    wick.SyncRole()

    tdm.SpawnCommand(players,aviable,function(ply)
        ply.roleT = false

        ply:Give("weapon_gurkha")
        local wep = ply:Give("weapon_hk_usp")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(2 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
    end)

    tdm.SpawnCommand(wick.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function wick.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(wick.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
        EndRound(1)
	end

	if TAlive == 0 and Alive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function wick.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Победа Джона Уика." or winner == 2 and "Победа наемников." or "Ничья"))
end

local empty = {}

function wick.PlayerSpawn(ply,teamID)
    local teamTbl = wick[wick.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function wick.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function wick.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget2")

function wick.SyncRole()
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
    end

    net.Start("homicide_roleget2")
    net.WriteTable(role)
    net.Broadcast()
end

function wick.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_glock18","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function wick.ShouldSpawnLoot()
    return false
end

function wick.GuiltLogic(ply,att,dmgInfo)
    return (not ply.roleT) == (not att.roleT) and 20 or 0
end

function wick.NoSelectRandom()
    return #ReadDataMap("spawnpointswick") < 1
end
