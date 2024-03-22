--
homigrad = homigrad or {}

hook.Add("homigrad_ply.init","hg.SyncPlyRound",homigrad.Sync) -- function in sv_util.lua

hook.Add("PlayerInitialSpawn","hg.InitalSpawn",homigrad.PlayerInitialSpawn)

hook.Add("Think","hg.Thinker",function()
    if homigrad.roundInfo.Mode and homigrad.Modes[homigrad.roundInfo.Mode] then
        homigrad.RoundThink()
        if homigrad.RoundEndCheck() then
            homigrad.SetActiveMode(homigrad.NextRound)
        end
    end
end)