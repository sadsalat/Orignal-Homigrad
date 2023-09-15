table.insert(LevelList,"nextbot")
nextbot = {}
nextbot.Name = "NextBot"

local red,green,blue = Color(255,55,55),Color(55,255,55),Color(55,55,255)

function nextbot.GetTeamName(ply)
    local teamID = ply:Team()

    if not nextbot.twoteams then
        if teamID == 1 then return "Зелёные",green end
    else
        if teamID == 1 then
            return "Красные",red
        elseif teamID == 2 then
            return "Синие",blue
        end
    end
end

function nextbot.StartRound(data)
    team.SetColor(1,red)
    team.SetColor(2,blue)
    team.SetColor(1,green)

    game.CleanUpMap(false)

    if CLIENT then
        nextbot.twoteams = data.twoteams

        return
    end

    return nextbot.StartRoundSV()
end