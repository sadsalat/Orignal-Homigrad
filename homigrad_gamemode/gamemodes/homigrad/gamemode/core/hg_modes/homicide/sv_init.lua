--
homigrad = homigrad or {}
homigrad.Modes = homigrad.Modes or {}

homicide = {}

homicide.Info = {
    Mode = "homicide",
    Name = "Homicide",
    ModeStateTable = {
        --[[ Here we can add anything i think... Edit This in hg_modes/"mode_name" ]]--
    }
}

local PlayerModels = {}
for i = 1, 9 do
    table.insert(PlayerModels,"models/player/Group01/male_0"..i..".mdl")
end
for i = 1, 6 do
    table.insert(PlayerModels,"models/player/Group01/female_0"..i..".mdl")
end

local function DoPlyTraitor()

end

homicide.RoundStart = function()
    for i, ply in pairs(player.GetAll()) do
        ply:SetModel(PlayerModels[math.random(#PlayerModels)])
        print("setmodel")
    end
end

homicide.PlayerInitialSpawn = function(ply)
    
end

homicide.Think = function()
    
end

homicide.RoundEndCheck = function()
    local Timer = (homigrad.roundInfo.TimeStart+15)-CurTime()
    --if Timer < 0 then return true, PrintMessage(HUD_PRINTTALK,"RoundEnded") end
end

homicide.RoundEnd = function()

end

homigrad.Modes.homicide = homicide