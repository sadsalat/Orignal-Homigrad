table.insert(LevelList,"construct")
construct = {}
construct.Name = "Construct"

function construct.StartRound(data)
	game.CleanUpMap(false)

	if CLIENT then
        wait = data[1]

        return
    end

    construct.StartRoundSV()
end

if SERVER then return end

function construct.CanUseSpawnMenu() return GetGlobalVar("Can",false) end

local gray = Color(122,122,122,255)

function construct.GetTeamName(ply)
    local teamID = ply:Team()

    if ply:Team() == 1 then
        return "Constructer",gray
    end
end

function construct.HUDPaint_RoundLeft()
    local time = math.Round((wait or 0) - CurTime())

    if time > 0 then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = "До окончания строительства : " .. acurcetime

        draw.SimpleText(acurcetime,"HomigradFont",ScrW() / 2,ScrH() - 25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end