DeriveGamemode("sandbox")

GM.Name = "Homigrad"
GM.Author = "loh"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true

--hg.includeDir("gamemodes/homigrad/game/")ебланы

include("loader.lua")

local start = SysTime()
print("	start homigrad gamemode.")

GM.includeDir("homigrad/gamemode/game/")--все файлы запускает, когда обновляем один.. можно из этого даже чо-то сделать.нахуй

print("	end homigrad gamemode for " .. math.Round(SysTime() - start,4) .. "s")

function GM:CreateTeams()
	team.SetUp(1,"Terrorists",Color(255,0,0))
	team.SetUp(2,"Counter Terrorists",Color(0,0,255))
	team.SetUp(3,"Other",Color(0,255,0))

	team.MaxTeams = 3
end

function OpposingTeam(team)
	if team == 1 then return 2 elseif team == 2 then return 1 end
end

function ReadPoint(point)
	if TypeID(point) == TYPE_VECTOR then
		return {point,Angle(0,0,0)}
	elseif type(point) == "table" then
		if type(point[2]) == "number" then
			point[3] = point[2]
			point[2] = Angle(0,0,0)
		end

		return point
	end
end

local team_GetPlayers = team.GetPlayers

function PlayersInGame()
    local newTbl = {}

    for i,ply in pairs(team_GetPlayers(1)) do newTbl[i] = ply end
    for i,ply in pairs(team_GetPlayers(2)) do newTbl[#newTbl + 1] = ply end
    for i,ply in pairs(team_GetPlayers(3)) do newTbl[#newTbl + 1] = ply end

    return newTbl
end