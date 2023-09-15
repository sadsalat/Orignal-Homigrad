net.Receive("SBTM_Hint", function()
    local str = net.ReadString()
    local i = net.ReadUInt(3)
    local argCount = net.ReadUInt(2)
    str = language.GetPhrase(str)
    if argCount > 0 then
        local args = {}
        for j = 1, argCount do args[j] = net.ReadString() end
        str = string.format(str, unpack(args))
    end
    notification.AddLegacy(str, i, 5)
    MsgC(Color(255, 255, 255), "[SBTM] ", str, "\n")
    surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
end)

net.Receive("SBTM_Color", function()
    local ply = net.ReadEntity()
    local v = net.ReadVector()
    ply:SetPlayerColor(v)
end)

net.Receive("SBTM_NPC", function()
    local class = net.ReadString()
    local id = net.ReadUInt(12)
    if id == TEAM_UNASSIGNED then
        SBTM.NPCTeams[class] = nil
    else
        SBTM.NPCTeams[class] = id
    end
end)

net.Receive("SBTM_TeamPropertySet", function()
    local t = net.ReadUInt(16)
    local p = net.ReadString()
    if not SBTM.TeamProperties[p] then return end
    SBTM.TeamConfig[t] = SBTM.TeamConfig[t] or {}
    SBTM.TeamConfig[t][p] = SBTM:ReadProperty(p)
    --hook.Run("SBTM_UpdateConfigMenu")
end)

net.Receive("SBTM_TeamPropertyReset", function()
    local t = net.ReadUInt(16)
    local p = net.ReadString()
    local prop = SBTM.TeamProperties[p]
    if not prop then return end
    SBTM.TeamConfig[t] = SBTM.TeamConfig[t] or {}
    SBTM.TeamConfig[t][p] = nil
    --hook.Run("SBTM_UpdateConfigMenu")
end)

net.Receive("SBTM_TeamPropertyUpdate", function()
    SBTM.TeamConfig = net.ReadTable()
end)

hook.Add("InitPostEntity", "SBTM_TeamPropertyUpdate", function()
    timer.Simple(1, function()
        net.Start("SBTM_TeamPropertyUpdate") net.SendToServer()
    end)
end)