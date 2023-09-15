local ScoreboardDerma = nil
local PlayerList = nil

surface.CreateFont( "Board", {
    font = "Arial",
    extended = false,
    size = 20,
    weight = 530,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

local function PingBars()
    local ping = LocalPlayer():Ping()
    draw.SimpleText(ping.."ms","Board",PlayerList:GetWide()-53,5,Color(255,255,255))
    draw.RoundedBox(0,PlayerList:GetWide()-42,26,5,12,Color(40,40,40)) --Bar 2
    draw.RoundedBox(0,PlayerList:GetWide()-34,21,5,17,Color(40,40,40)) --Bar 3
    if ping <= 50 then
        draw.RoundedBox(0,PlayerList:GetWide()-50,31,5,7,Color(0,255,0)) --Bar 1
        draw.RoundedBox(0,PlayerList:GetWide()-42,26,5,12,Color(0,255,0)) --Bar 2
        draw.RoundedBox(0,PlayerList:GetWide()-34,21,5,17,Color(0,255,0)) --Bar 3
    elseif ping >= 999 then
        draw.RoundedBox(0,PlayerList:GetWide()-50,31,5,7,Color(40,40,40)) --Bar 1
    elseif ping >= 150 then
        draw.RoundedBox(0,PlayerList:GetWide()-50,31,5,7,Color(0,255,0)) --Bar 1
    else 
        draw.RoundedBox(0,PlayerList:GetWide()-50,31,5,7,Color(0,255,0)) --Bar 1
        draw.RoundedBox(0,PlayerList:GetWide()-42,26,5,12,Color(0,255,0)) --Bar 2
    end
end

hook.Add("ScoreboardShow", "ShapedScoreboardShow", function()

    local Scrw = ScrW()
    local Scrh = ScrH()

    if !IsValid(ScoreboardDerma) then
    	ScoreboardDerma = vgui.Create("DFrame")
    	ScoreboardDerma:SetSize(750,500)
    	ScoreboardDerma:Center()
    	ScoreboardDerma:SetDraggable(false)
    	ScoreboardDerma:ShowCloseButton(false)
        ScoreboardDerma:SetTitle("")
    	ScoreboardDerma.Paint = function()
    	draw.RoundedBox(0,0,0,ScoreboardDerma:GetWide(),ScoreboardDerma:GetTall(),Color(40,40,40,255))
        draw.SimpleText("Shaped Scoreboard",Board,325,4,Color(255,255,255))
        end

        local PlayerScrollPanel = vgui.Create("DScrollPanel",ScoreboardDerma)
        PlayerScrollPanel:SetSize(ScoreboardDerma:GetWide(),ScoreboardDerma:GetTall() -20)
        PlayerScrollPanel:SetPos(0,20)

        PlayerList = vgui.Create("DListLayout",PlayerScrollPanel)
        PlayerList:SetSize(PlayerScrollPanel:GetWide(),PlayerScrollPanel:GetTall())
        PlayerList:SetPos(0,0)
    end

    if IsValid(ScoreboardDerma) then
        PlayerList:Clear()

        for k, v in pairs(player.GetAll()) do
            local PlayerPanel = vgui.Create("DPanel",PlayerList)
            local Avatar      = vgui.Create("AvatarImage",PlayerPanel)
            local PlayerRang  = v:GetUserGroup()
            local JobName     = v:getDarkRPVar("job")
            local wanted      = v:getDarkRPVar("wanted")
            local arrested    = v:getDarkRPVar("Arrested")
            local AFK         = v:getDarkRPVar("AFK")
            PlayerPanel:SetSize(PlayerList:GetWide(),50)
            PlayerPanel:SetPos(0,0)
            PlayerPanel.Paint = function()
                draw.RoundedBox(0,0,0,PlayerPanel:GetWide(),PlayerPanel:GetTall(),Color(50,50,50,255))
                draw.RoundedBox(0,0,49,PlayerPanel:GetWide(),1,Color(20,20,20,255))
                PingBars()
                
                if v:IsAdmin() or v:IsSuperAdmin() then
                    draw.RoundedBox(0,0,0,50,50,Color(200,200,200,255))
                else
                    draw.RoundedBox(0,0,0,50,50,Color(100,100,100,255))
                end
                if AFK then
                    draw.SimpleText(v:GetName().." [ AFK ]", "Board",60,5,Color(255,255,255))
                else
                    draw.SimpleText(v:GetName(), "Board",60,5,Color(255,255,255))
                end
                draw.SimpleText("[ "..PlayerRang.." ]", "Board",60,23,Color(255,255,255))
                draw.SimpleText("Job: "..JobName,"Board",PlayerList:GetWide()/2 - 50,5,Color(255,255,255))
                if wanted then
                    draw.SimpleText("Wanted!","Board",PlayerList:GetWide()/2 - 50,23,Color(255,100,100))
                end
                if arrested then
                    draw.SimpleText("Arrested","Board",PlayerList:GetWide()/2 - 50,23,Color(100,100,255))
                end
                if v:Frags() <= 0 then
                    draw.SimpleText("Kills: "..0,"Board",PlayerList:GetWide()-60,5,Color(255,255,255),TEXT_ALIGN_RIGHT)
                else
                	draw.SimpleText("Kills: "..v:Frags(),"Board",PlayerList:GetWide()-60,5,Color(255,255,255),TEXT_ALIGN_RIGHT)
                end
                draw.SimpleText("Deaths: "..v:Deaths(),"Board",PlayerList:GetWide()-60,23,Color(255,255,255),TEXT_ALIGN_RIGHT)
            end
            Avatar:SetSize(46,46)
            Avatar:SetPos(2,2)
            Avatar:SetPlayer(v,64)
        end

    	ScoreboardDerma:Show()
    	ScoreboardDerma:MakePopup()
    	ScoreboardDerma:SetKeyBoardInputEnabled(false)
    end
    return false
end)

hook.Add("ScoreboardHide", "ShapedScoreboardHide", function()
	if IsValid(ScoreboardDerma) then 
		ScoreboardDerma:Hide()
	end
end) 