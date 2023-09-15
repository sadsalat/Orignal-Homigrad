function darkrp.Scoreboard_Status(ply)
    if ply:Alive() then return "Живой",ScoreboardGreen else return "Мёртв",ScoreboardRed,ScoreboardRed end
end

local staticWhite = Color(255,255,255)

function darkrp.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()

    if lply:Alive() then
        local time = lply:GetNWFloat("Arest",0) - CurTime()

        if time > 0 then
            draw.SimpleText("Осталось : " .. time .. " секунд.","HomigradFont",ScrW() / 2,ScrH() - 100,white,TEXT_ALIGN_CENTER)
        end
    else
        local time = lply:GetNWFloat("DeathWait",0) - CurTime()

        if time > 0 then
            draw.SimpleText("Осталось : " .. time .. " секунд.","HomigradFont",ScrW() / 2,ScrH() - 100,white,TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Нажми на что-нибудь что-бы возродится.","HomigradFont",ScrW() / 2,ScrH() - 100,staticWhite,TEXT_ALIGN_CENTER)
        end
    end

    draw.SimpleText(darkrp.GetMoney(lply) .. "$","HomigradFont",15,ScrH() - 15,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
end

function darkrp.EndRound()
    darkrp.OnContextMenuClose()
end