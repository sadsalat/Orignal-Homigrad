DeriveGamemode("sandbox")

GM.Name = "Homigrad"
GM.Author = "sadsalat, uzelezz"
GM.Email = "N/A"
GM.Website = "N/A"
GM.TeamBased = true

include("loader.lua")

homigrad = homigrad or {}

local start = SysTime()
print("gamemode is loading.")

GM.Run()
homigrad.StartedTime = math.Round(SysTime() - start,4)
print("gamemode loaded for " .. math.Round(SysTime() - start,4) .. "s")

function GM:CreateTeams()
	team.SetUp(1,"Team01",Color(255,0,0))
	team.SetUp(2,"Team02",Color(0,0,255))
end
