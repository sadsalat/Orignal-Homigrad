--
homigrad = homigrad or {}
homigrad.Modes = homigrad.Modes or {}

BaseMode = {}

BaseMode.Info = {
    Mode = "BaseMode",
    Name = "Homicide",
    ModeStateTable = {
        --[[ Here we can add anything i think... Edit This in hg_modes/"mode_name" ]]--
    }
}

BaseMode.RoundStart = function()

end

BaseMode.PlayerInitialSpawn = function(ply)
    
end

BaseMode.Think = function()
    
end

BaseMode.RoundEndCheck = function()
    local Timer = (homigrad.roundInfo.TimeStart+15)-CurTime()
    if Timer < 0 then return true, PrintMessage(HUD_PRINTTALK,"RoundEnded") end
end

BaseMode.RoundEnd = function()

end

homigrad.Modes.BaseMode = BaseMode