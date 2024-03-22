--
util.AddNetworkString("homigrad.Sync")
util.AddNetworkString("homigrad.SyncNextRound")

homigrad = homigrad or {}

homigrad.roundInfo = homigrad.roundInfo or {
    Mode = "nan",
    Name = "Nah",
    ModeStateTable = {
        --[[ Here we can add anything i think... Edit This on hg_modes/"mode_name" ]]--
    }
}
homigrad.roundState = homigrad.roundState or "ended"
homigrad.NextRound = homigrad.NextRound or "homicide"

homigrad.Sync = function(ply) -- this function syncs players or player. Next steps in cl_round.lua Search [ net.Recive("homigrad.Sync" ]
    net.Start("homigrad.Sync")
        net.WriteTable(homigrad.roundInfo)
        net.WriteString(homigrad.roundState)
    if ply then net.Send(ply) else net.Broadcast() end
end

homigrad.SyncNextRound = function(ply) -- this function syncs players or player next round. Next steps in cl_round.lua Search [ net.Recive("homigrad.SyncNextRound" ]
    net.Start("homigrad.SyncNextRound")
        net.WriteString(homigrad.NextRound)
    if ply then net.Send(ply) else net.Broadcast() end
end

homigrad.SetActiveMode = function(name)
    if not homigrad.Modes[name] then return false, print("[HG] ERROR! that mode dosen't exists | Server Do nothing.") end
    homigrad.roundInfo = homigrad.Modes[name].Info
    homigrad.roundInfo.TimeStart = CurTime()
    homigrad.roundState = "started"

    homigrad.StartRound()

    homigrad.Sync()
    return true, print("[HG] Mode changed on "..homigrad.NextRound)
end

homigrad.SetNextMode = function(name)
    if not homigrad.Modes[name] then return false, print("[HG] ERROR! that mode dosen't exists | Server Do nothing.") end
    homigrad.NextRound = name

    homigrad.SyncNextRound()
    return true, print("[HG] Next mode is "..homigrad.NextRound), PrintMessage(HUD_PRINTTALK,"Next mode on "..homigrad.NextRound)
end

homigrad.SetActiveMode("homicide")

AddConsoleCommand("hg_changemode","changing Homigrad gamemode")

concommand.Add( "hg_changemode", function( ply, cmd, args )
    homigrad.SetNextMode(args[1])
end )