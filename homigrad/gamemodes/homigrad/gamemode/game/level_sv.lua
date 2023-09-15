util.AddNetworkString("round")
util.AddNetworkString("round_next")

function RoundActiveSync(ply)
    net.Start("round")
    net.WriteString(roundActiveName)
    if ply then net.Send(ply) else net.Broadcast() end
end

function RoundActiveNextSync(ply)
    net.Start("round_next")
    net.WriteString(roundActiveNameNext)
    if ply then net.Send(ply) else net.Broadcast() end
end

function SetActiveRound(name)
    if not _G[name] then return false end
    roundActiveName = name

    RoundActiveSync()

    return true
end

function SetActiveNextRound(name)
    if not _G[name] then return false end
    roundActiveNameNext = name

    RoundActiveNextSync()

    return true
end