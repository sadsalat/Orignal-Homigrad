function SBTM:IsTeamed(ply)
    return ply:Team() >= SBTM_RED and ply:Team() <= SBTM_YEL
end

function SBTM:SetPlayerColor(ply, id)
    if GetConVar("sbtm_setplayercolor"):GetBool() and id >= SBTM_RED and id <= SBTM_YEL then
        local clr = team.GetColor(id)
        local v = Vector(clr.r / 255, clr.g / 255, clr.b / 255)
        ply:SetPlayerColor(v)
        if SERVER then
            net.Start("SBTM_Color")
                net.WriteEntity(ply)
                net.WriteVector(v)
            net.Broadcast()
        end
    end
end

function SBTM:Hint(ply, str, i, args)
    net.Start("SBTM_Hint")
        net.WriteString(str)
        net.WriteUInt(i or 0, 3)
        net.WriteUInt(args and #args or 0, 2)
        if args then
            for _, v in pairs(args) do
                net.WriteString(v)
            end
        end
    net.Send(ply)
end

function SBTM:SetTeam(ent, id, h)
    local oldTeam = ent:Team()
    ent:SetTeam(id)
    SBTM:SetPlayerColor(ent, id)
    SBTM:Hint(ent, h, 0, {team.GetName(id)})
    if SBMG and SBMG:GetActiveGame() then
        if not SBMG.ActivePlayers[ent] then
            SBMG:AddScore(ent, 0)
        end
        if SBMG:GetCurrentGameTable().PlayerLeave and SBMG.TeamScore[oldTeam] then
            SBMG:GetCurrentGameTable():PlayerLeave(ent, oldTeam)
        end
        if SBMG:GetCurrentGameTable().PlayerJoin and SBMG.TeamScore[id] then
            SBMG:GetCurrentGameTable():PlayerJoin(ent, oldTeam)
        end
    end
end

function SBTM:SetNPCTeam(class, id)
    if id == TEAM_UNASSIGNED then
        SBTM.NPCTeams[class] = nil
    else
        SBTM.NPCTeams[class] = id
        for _, ent in pairs(ents.FindByClass(class)) do
            if ent.SBTM_Team then continue end
            ent.SBTM_Team = id
            if GetConVar("sbtm_teamnpcs_color"):GetBool() then
                ent:SetColor(team.GetColor(id))
            end
            ent:SetKeyValue("squadname", "SBTM_" .. tostring(id))
            for c, t in pairs(SBTM.NPCTeams) do
                if c ~= class then
                    ent:AddRelationship(c .. " " .. (t == id and "D_LI" or "D_HT") .. " 9999")
                    for _, e in pairs(ents.FindByClass(c)) do
                        e:AddRelationship(class .. " " .. (t == id and "D_LI" or "D_HT") .. " 9999")
                    end
                end
            end
            for _, ply in pairs(player.GetAll()) do
                if SBTM:IsTeamed(ply) then
                    ent:AddEntityRelationship(ply, ply:Team() == id and D_LI or D_HT, 9999)
                end
            end
        end
    end
    net.Start("SBTM_NPC")
        net.WriteString(class)
        net.WriteUInt(id, 12)
    net.Broadcast()
end

function SBTM:Shuffle(plys)
    plys = plys or player.GetAll()
    local t = 1
    while #plys > 0 do
        local i = math.random(1, #plys)
        if SBTM_RED + t ~= plys[i]:Team() then
            SBTM:SetTeam(plys[i], SBTM_RED + t, "#sbtm.hint.team_set_force")
        end
        table.remove(plys, i)
        t = (t + 1) % GetConVar("sbtm_shuffle_max"):GetInt()
    end
end

function SBTM:AutoAssign(plys)
    plys = plys or team.GetPlayers(TEAM_UNASSIGNED)
    while #plys > 0 do
        local index = math.random(1, #plys)
        -- Find the team with the minimum amount of players
        local target_team, balanced = SBTM_RED, true
        for i = SBTM_BLU, SBTM_BLU + GetConVar("sbtm_shuffle_max"):GetInt() - 2 do
            if team.NumPlayers(i) < team.NumPlayers(target_team) then
                balanced = false
                target_team = i
            elseif team.NumPlayers(i) > team.NumPlayers(target_team) then
                balanced = false
            end
        end
        -- If teams are balanced just pick a random one
        if balanced then target_team = SBTM_RED + math.random(1, GetConVar("sbtm_shuffle_max"):GetInt()) - 1 end
        SBTM:SetTeam(plys[index], target_team, "#sbtm.hint.team_set_force")
        table.remove(plys, index)
    end
end

function SBTM:UnassignAll()
    for _, p in pairs(player.GetAll()) do
        SBTM:SetTeam(p, TEAM_UNASSIGNED, "#sbtm.hint.team_set_force")
    end
end

function SBTM:ConVarTeamColor(t)
    local cvar = "sbtm_clr_"
    if t == SBTM_RED then
        cvar = cvar .. "red"
    elseif t == SBTM_BLU then
        cvar = cvar .. "blue"
    elseif t == SBTM_GRN then
        cvar = cvar .. "green"
    elseif t == SBTM_YEL then
        cvar = cvar .. "yellow"
    end
    local clr = Color(255, 255, 255)
    clr.r = GetConVar(cvar .. "_r"):GetInt()
    clr.g = GetConVar(cvar .. "_g"):GetInt()
    clr.b = GetConVar(cvar .. "_b"):GetInt()
    return clr
end

local tcc = {}
function SBTM:TeamColor(t, modifier)
    if t:IsPlayer() then t = t:Team() end
    if not team.Valid(t) then return Color(255, 255, 255) end

    if not tcc[t] then tcc[t] = {} end
    if not tcc[t][modifier] then
        tcc[t][modifier] = team.GetColor(t)
        if modifier == SBTM_TCLR_SOFT then
            tcc[t][modifier].r = (tcc[t][modifier].r * 0.5) + (255 * 0.5)
            tcc[t][modifier].g = (tcc[t][modifier].g * 0.5) + (255 * 0.5)
            tcc[t][modifier].b = (tcc[t][modifier].b * 0.5) + (255 * 0.5)
        end
    end

    return tcc[t][modifier]
end

function SBTM:GetTeamProperty(t, prop)
    if not prop or not self.TeamProperties[prop] then
        error("SBTM: Tried to get invalid team property '" .. tostring(prop) .. "'!")
        return
    end
    if self.TeamConfig[t] and self.TeamConfig[t][prop] ~= nil then
        return self.TeamConfig[t][prop]
    end
    if self.TeamConfig[0] and self.TeamConfig[0][prop] ~= nil then
        return self.TeamConfig[0][prop]
    end
    return self.TeamProperties[prop].default
end

function SBTM:WriteProperty(p, v)
    local prop = SBTM.TeamProperties[p]
    if not prop then return end
    if prop.type == "b" then
        net.WriteBool(v)
    elseif prop.type == "i" then
        net.WriteInt(v, 32)
    elseif prop.type == "f" then
        net.WriteFloat(v)
    elseif prop.type == "s" then
        net.WriteString(v)
    end
end

function SBTM:ReadProperty(p)
    local prop = SBTM.TeamProperties[p]
    if not prop then return end
    if prop.type == "b" then
        return net.ReadBool()
    elseif prop.type == "i" then
        return math.Clamp(net.ReadInt(32), prop.min or -math.huge, prop.max or math.huge)
    elseif prop.type == "f" then
        return math.Clamp(net.ReadFloat(), prop.min or -math.huge, prop.max or math.huge)
    elseif prop.type == "s" then
        return net.ReadString()
    end
end