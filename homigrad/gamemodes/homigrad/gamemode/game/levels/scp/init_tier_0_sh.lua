table.insert(LevelList,"scp")
scp = scp or {}
scp.Name = "SCP"

function scp.CanRoundNext()
    if #ReadDataMap("scp096") == 0 or #ReadDataMap("scp173") == 0 or #ReadDataMap("spawnpoints_ss_exit") == 0 then return end

    return true
end

function scp.StartRound(data)
    game.CleanUpMap(false)

    if CLIENT then
        scp.spawnMOG = data.spawnMOG

        return
    end

    return scp.StartRoundSV()
end

scp.roles = {
    [1] = {
        "Учённый",Color(200,200,200),
        {
            "morphine",
            "medkit",
            "bandage"
        }
    },
    [2] = {
        "Охрана",Color(75,75,255),
        {
            "weapon_hk_usp",
            "weapon_mp5",

            "weapon_radio"
        }
    },
    [3] = {
        "МОГ",Color(0,0,125),
        {
            {"weapon_mk18","weapon_m249"},
            "weapon_glock",

            "weapon_radio",

            "medkit",
            "adrenaline",
            "morphine"
        }
    
    }
}

local orange = Color(255,125,0)

function scp.GetTeamName(ply)
    local teamID = ply:Team()

    local color = ply:GetPlayerColor():ToColor()

    if teamID == 1 then
        return "D-Класс",orange
    elseif teamID == 2 then
        local role = ply:GetNWInt("Role")
        role = scp.roles[role]
        if not role then return end

        return role[1],role[2]
    end
end
function scp.Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return true end

    return "Неизвестно",ScoreboardSpec
end

function scp.HUDPaint_RoundLeft(white2,time)
	local time = math.Round((scp.spawnMOG or 0) - CurTime())
	local acurcetime = string.FormattedTime(time,"%02i:%02i")

	if time > 0 then
		draw.SimpleText("До прибытия МОГ : ","HomigradFont",ScrW() / 2 - 200,ScrH()-25,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		draw.SimpleText(acurcetime,"HomigradFont",ScrW() / 2 + 200,ScrH()-25,white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
	end
end
