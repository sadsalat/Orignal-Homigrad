hook.Add("PreDrawOutlines", "SBTM", function()
    local cvar = GetConVar("cl_sbtm_teamoutline"):GetInt()
    local m = GetConVar("cl_sbtm_teamoutline_mode"):GetInt()
    if cvar > 0 and m > 0 and m ~= 2 and
            (not SBMG or not SBMG:GameHasTag(SBMG_TAG_FORCE_FRIENDLY_FIRE)) and
            (cvar == 1 or (SBMG and SBMG:GetActiveGame())) then
        if SBTM:IsTeamed(LocalPlayer()) then
            -- outline.Add(team.GetPlayers(LocalPlayer():Team()), team.GetColor(LocalPlayer():Team()), OUTLINE_MODE_NOTVISIBLE)
            local c = team.GetColor(LocalPlayer():Team())
            for _, p in pairs(team.GetPlayers(LocalPlayer():Team())) do
                if p:Alive() and p ~= LocalPlayer() then outline.Add(p, c, OUTLINE_MODE_NOTVISIBLE) end
            end
        elseif LocalPlayer():Team() == TEAM_SPECTATOR then
            for _, p in pairs(player.GetAll()) do
                if p:Alive() then outline.Add(p, p:Team() == TEAM_UNASSIGNED and color_white or team.GetColor(p:Team()), OUTLINE_MODE_NOTVISIBLE) end
            end
        end
    end
end)

hook.Add("PreDrawHalos", "SBTM", function()
    local cvar = GetConVar("cl_sbtm_teamoutline"):GetInt()
    local m = GetConVar("cl_sbtm_teamoutline_mode"):GetInt()
    if cvar > 0 and m > 0 and m ~= 1 and
            (not SBMG or not SBMG:GameHasTag(SBMG_TAG_FORCE_FRIENDLY_FIRE)) and
            (cvar == 1 or (SBMG and SBMG:GetActiveGame())) then
        if SBTM:IsTeamed(LocalPlayer()) then
            local c = team.GetColor(LocalPlayer():Team())
            for _, p in pairs(team.GetPlayers(LocalPlayer():Team())) do
                if p:Alive() and p ~= LocalPlayer() then halo.Add({p}, c, 4, 4, 1, true, true) end
            end
        elseif LocalPlayer():Team() == TEAM_SPECTATOR then
            for _, p in pairs(player.GetAll()) do
                if p:Alive() then halo.Add({p}, p:Team() == TEAM_UNASSIGNED and color_white or team.GetColor(p:Team()), 4, 4, 1, true, true) end
            end
        end
    end
end)