local color = Color(165,165,165)

function jailbreak.GetTeamName(ply)
    local teamID = ply:Team()

    if teamID == 1 then
        teamID = jailbreak[jailbreak.teamEncoder[teamID]]

        return teamID[1],teamID[2]
	elseif teamID == 2 then
        local rank = jailbreak.GetRank(ply)
        if not rank then return "Стажёр",color end

        return rank[1],rank[2]
    end
end

function jailbreak.Scoreboard_Status(ply)
	if not LocalPlayer():Alive() or LocalPlayer():Team() == 1002 then return true end

    if ply:Alive() then return "Живой",ScoreboardGreen else return "Мёртв",ScoreboardRed,ScoreboardRed end
end

--

local white = Color(255,255,255)
local whitePoint = Color(255,255,255)
local point
local pointStart = 0
local old

local circlePos,circleAngle

local circleMat = Material("vgui/loading-rotate")

function jailbreak.HUDPaint_RoundLeft(white2)
    if #team.GetPlayers(2) == 0 then
        draw.SimpleText("Игра не может начаться пока не будет хотябы один охраник.","HomigradFontSmall",ScrW() / 2,ScrH() / 2 - 250,white2,TEXT_ALIGN_CENTER)
    elseif #team.GetPlayers(1) == 0 then
        draw.SimpleText("Игра не может начаться пока не будет хотябы один зек.","HomigradFontSmall",ScrW() / 2,ScrH() / 2 - 250,white2,TEXT_ALIGN_CENTER)
    end

    local lply = LocalPlayer()
    --[[if circlePos then
        cam.Start3D2D(circlePos,circleAngle:Angle(),1)
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial(circleMat)
            surface.DrawTexturedRect(0,0,512,512)
        cam.End3D2D()
    end]]--

    if lply:Team() == 2 then
        local trace = lply:GetEyeTrace()
        local active = input.IsMouseDown(MOUSE_MIDDLE)

        if old ~= active then
            old = active

            if active then
                local ent = trace.Entity
                if IsValid(ent) and ent:GetClass() == "func_door" then
                    net.Start("jailbreak_door")
                    net.WriteEntity(ent)
                    net.SendToServer()
                else
                    net.Start("jailbreak_point")
                    net.WriteVector(trace.HitPos)
                    net.SendToServer()
                end
            end
        end
    else
        old = false
    end

    local k = math.max(pointStart + 5 - CurTime(),0) / 5
    if k > 0 then
        local pos = point:ToScreen()

        whitePoint.a = 255 * k
        draw.RoundedBox(4,pos.x - 2,pos.y - 2,4,4,whitePoint)
    end
end

net.Receive("jailbreak_point",function()
    point = net.ReadVector()
    pointStart = CurTime()

    surface.PlaySound("buttons/button15.wav")
end)

local white = Color(255,255,255)

function jailbreak.ScoreboardBuild(panel,list)
    if not (LocalPlayer():Team() == 2 or LocalPlayer():IsAdmin()) then return end

    local wide = 150
    local startX = ScrW() / 2 - wide * 3 / 2

    local button = vgui.Create("DButton")
    button:SetText("")
    button:SetSize(150,25)
    button:SetPos(startX,0)

    list[button] = true

    function button:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,ScoreboardBlack)

        draw.SimpleText("Открыть/Закрыть","HomigradFont",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function button:DoClick() RunConsoleCommand("say","!jailbreak_open 1") end
    function button:DoRightClick() RunConsoleCommand("say","!jailbreak_open 0") end

    local button = vgui.Create("DButton")
    button:SetText("")
    button:SetSize(150,25)
    button:SetPos(startX + wide,0)

    list[button] = true

    function button:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,ScoreboardBlack)

        draw.SimpleText("Гилт : " .. tostring(GetGlobalBool("JailBreakGuilt")),"HomigradFont",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function button:DoClick()
        RunConsoleCommand("say","!jailbreak_guilt " .. (GetGlobalBool("JailBreakGuilt") and 0 or 1))
    end

    local button = vgui.Create("DButton")
    button:SetText("")
    button:SetSize(150,25)
    button:SetPos(startX + wide * 2,0)

    list[button] = true

    function button:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,ScoreboardBlack)

        draw.SimpleText("Рандом join : " .. tostring(GetGlobalBool("JailBreakRandom")),"HomigradFont",w / 2,h / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function button:DoClick()
        RunConsoleCommand("say","!jailbreak_random " .. (GetGlobalBool("JailBreakRandom") and 0 or 1))
    end
end