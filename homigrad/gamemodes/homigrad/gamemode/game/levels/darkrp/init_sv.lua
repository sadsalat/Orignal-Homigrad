function darkrp.StartRoundSV()
    tdm.DirectOtherTeam(2,1)

    for i,ply in pairs(player.GetAll()) do
        jailbreak.ReadRank(ply)
    end

    local aviable = homicide.Spawns()
    tdm.SpawnCommand(team.GetPlayers(1),aviable,function(ply)
        darkrp.SetRole(ply,1)
        darkrp.SetMoney(ply,1000)
    end)

    for name in pairs(darkrp.doors) do
        for i,ent in pairs(ents.FindByClass(name)) do
            ent.buy = nil
        end
    end
end

local empty = {}

function darkrp.PlayerSpawn(ply)
    local role = darkrp.GetRole(ply)

    ply:SetPlayerColor(role[2]:ToVector())
    local id = ply.darkrpModelID
    ply:SetModel((id and role.models[id]) or role.models[math.random(1,#role.models)])

    if role.PlayerSpawn then role.PlayerSpawn(ply) end

    for i,weapon in pairs(role.weapons or empty) do ply:Give(weapon) end

    tdm.GiveSwep(ply,role.main_weapon,12)
	tdm.GiveSwep(ply,role.secondary_weapon,12)

    ply:Give("darkrp_key")
    ply:Give("weapon_physgun")

    darkrp.Inv_SetupDef(ply)
end

function darkrp.PlayerInitialSpawn(ply)
    jailbreak.ReadRank(ply)

    ply:SetTeam(1)

    darkrp.SetRole(ply,1)

    darkrp.RulesSync(ply)
end

function darkrp.PlayerCanJoinTeam(ply,teamID)
    if teamID == 2 or teamID == 3 then return false end
    if teamID == 1002 and not ply:IsAdmin() then return false end

    return true
end

function darkrp.PlayerDeathThink(ply)
    if ply:Team() ~= 1 then return end

    if (ply.darkrpDeathWait or 0) > CurTime() then return false end

    if
        ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_ATTACK2) or
        ply:KeyDown(IN_JUMP) or
        ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or
        ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)
    then
        ply:Spawn()
    end

    return true
end

function darkrp.PlayerDeath(ply)
    ply:SetNWFloat("DarkRPArestTime",0)

    if ply:IsAdmin() then return end

    ply.darkrpDeathWait = CurTime() + darkrp.DeathWait
    ply:SetNWFloat("DeathWait",ply.darkrpDeathWait)
end

function darkrp.ShouldSpawnLoot() return false end

util.AddNetworkString("darkrp shop buy")

net.Receive("darkrp shop buy",function(len,ply)
    local role = darkrp.GetRole(ply)
    local item = role.shop[net.ReadInt(16)]
    if not item then return end --ban

    local price = item[3]
    if darkrp.GetMoney(ply) < price then darkrp.Notify("Недотаточно средств.",NOTIFY_ERROR,5,ply) return end

    darkrp.AddMoney(ply,-price)

    local ent = ents.Create(item[2])
    ent:SetPos(ply:GetEyeTraceDis(75).HitPos)
    ent:SetAngles(ply:GetAngles())
    ent:Spawn()

    ent:CPPISetOwner(ply)--eee
end)

function darkrp.RoundEndCheck()
    for i,ply in pairs(team.GetPlayers(1)) do
        local diff = ply:GetNWFloat("Arest")

        if diff and diff - CurTime() < 0 then
            darkrp.Arest(ply,false)
        end
    end
end

function darkrp.GuiltLogic(ply,att,dmgInfo)
    --local rolePly,roleAtt = darkrp.GetRole(ply),darkrp.GetRole(att)

    --if rolePly.isGoverment and roleAtt.isGoverment then return true end
    --if rolePly ~= roleAtt then return true end

    return false
end