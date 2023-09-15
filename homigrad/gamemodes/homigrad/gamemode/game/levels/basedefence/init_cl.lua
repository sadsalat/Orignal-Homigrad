function basedefence.GetTeamName(ply)
    local teamID = ply:Team()
    local team = basedefence.teamEncoder[teamID]

    if team then
        team = basedefence[team]

        if teamID == 2 and not ply:Alive() then
            return ""
        else
            return team[1],team[2]
        end
    end
end

function basedefence.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = basedefence.GetTeamName(lply)

	local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_disaster.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,255),0.5,0.5)


        draw.DrawText( "Вы повстанец" , "HomigradFontBig", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "[Халф-Лайф 2] Оборона", "HomigradFontBig", ScrW() / 2, ScrH() / 8, Color( 155,155,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "Постройте оборону против комбайнов и продержитесь до отступления комбайнов", "HomigradFontBig", ScrW() / 2, ScrH() / 1.2, Color( 155,155,155,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end