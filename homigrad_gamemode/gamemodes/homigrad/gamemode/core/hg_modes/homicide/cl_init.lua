--
homigrad = homigrad or {}
homigrad.Modes = homigrad.Modes or {}

homicide = {}

homicide.RoundCLHud = function()
    local HideTime = HideTime or 1
    if HideTime < 0 then return end
    HideTime = math.Clamp((homigrad.CLroundInfo.TimeStart+5)-CurTime(),0,1)
    draw.RoundedBox(0,0,0,ScrW(),ScrH(),Color(0,0,0,255*HideTime))
    draw.SimpleText("Homicide","GModToolSubtitle",ScrW()/2,ScrH()/5,Color(55,55,255,255*HideTime),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    draw.SimpleText("You are innocent, your task is to catch or kill the traitor","GModToolSubtitle",ScrW()/2,ScrH()/1.2,Color(255,255,255,255*HideTime),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

homigrad.Modes.homicide = homicide