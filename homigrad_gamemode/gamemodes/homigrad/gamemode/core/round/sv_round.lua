--
homigrad.StartRound = function()
    for i, ply in pairs(player.GetAll()) do
        ply:KillSilent()
    end
    if player.GetCount() < 2 then return PrintMessage(HUD_PRINTTALK,"Can't start round, not enough players") end
    game.CleanUpMap()
    for i, ply in pairs(player.GetAll()) do
        if ply:Team() == TEAM_SPECTATOR then return end
        ply:Spawn()
    end

    if homigrad.roundInfo.Mode and homigrad.Modes[homigrad.roundInfo.Mode] then
        homigrad.Modes[homigrad.roundInfo.Mode].RoundStart()
        print("huy")
    end

end
local WaitPlayer = false
homigrad.RoundEndCheck = function()
    if player.GetCount() < 2 then WaitPlayer = true return false end
    WaitPlayer = false
    if homigrad.roundInfo.Mode and homigrad.Modes[homigrad.roundInfo.Mode] then
        return homigrad.Modes[homigrad.roundInfo.Mode].RoundEndCheck()
    end
end

homigrad.RoundThink = function()
    if homigrad.roundInfo.Mode and homigrad.Modes[homigrad.roundInfo.Mode] then
        homigrad.Modes[homigrad.roundInfo.Mode].Think()
    end
end

homigrad.PlayerInitialSpawn = function(ply)
    if homigrad.roundInfo.Mode and homigrad.Modes[homigrad.roundInfo.Mode] then
        homigrad.Modes[homigrad.roundInfo.Mode].PlayerInitialSpawn(ply)
    end
end