AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("roundsystem.lua")
include("sv_gulit.lua")
include("teamsetup.lua")
if SERVER then
	util.AddNetworkString("round_timer")
	util.AddNetworkString("round_active")
end

spawnPointsRed = file.Exists("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", "DATA") and util.KeyValuesToTable(file.Read("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", "DATA")) or {}
spawnPointsBlue = file.Exists("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", "DATA") and util.KeyValuesToTable(file.Read("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", "DATA")) or {}
if not file.Exists("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", "DATA") then
	for k, v in ipairs(ents.FindByClass("info_player_terrorist")) do
		spawnPointsRed[#spawnPointsRed + 1] = v:GetPos()
	end
end

if not file.Exists("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", "DATA") then
	for k, v in ipairs(ents.FindByClass("info_player_counterterrorist")) do
		spawnPointsBlue[#spawnPointsBlue + 1] = v:GetPos()
	end
end

roundActive = false
function GM:PlayerSpawn(ply)
	if ply:GetNWBool("unfaked") then return nil end
	ply:SetupHands()
	ply:SetupTeam(AutoBalance())
	if ply:Team() == 0 then
		ply:SetPos(Vector(spawnPointsRed[math.random(1, #spawnPointsRed)]))
	elseif ply:Team() == 1 then
		ply:SetPos(Vector(spawnPointsBlue[math.random(1, #spawnPointsBlue)]))
	end

	ply:ChatPrint("Your team is " .. teams[ply:Team()].name)
	SavePlyInfo(ply)
	ply:Freeze(true)
	ply.Blood = 5000
	ply.pain = 0
	if roundActive == true then
		ply:KillSilent()
		ply:SetMoveType(MOVETYPE_WALK)

		return
	else
		RoundStart()
		ply:Freeze(true)
		ply:SetMoveType(MOVETYPE_WALK)
	end
end

function GM:PlayerDeath(ply, attacker)
	if attacker:IsPlayer() then
		if ply:Team() == attacker:Team() and ply ~= attacker then
			attacker:ChatPrint("You killed your teammate!")
		end

		if ply.Attacker2 ~= nil and ply:Team() == ply.Attacker2:Team() and ply ~= attacker then
			ply.Attacker2:ChatPrint("You killed your teammate!")
		end
	end

	ply:Spectate(OBS_MODE_CHASE)
	ply.SpectateGuy = 1
end

function GM:PlayerDeathThink(ply)
	if roundActive == false then
		ply:Spawn()
		ply:UnSpectate()
		ply:SetNWEntity("DeathRagdoll", NULL)
		ply:SetNWEntity("SpecPly", nil)

		return true
	else
		local tbl = {}
		for _, ply in ipairs(player.GetAll()) do
			if not ply:Alive() then continue end
			tbl[#tbl + 1] = ply
		end

		if ply:KeyPressed(IN_ATTACK) then
			ply.SpectateGuy = math.Clamp(ply.SpectateGuy + 1, 1, #tbl)
		end

		if ply:KeyPressed(IN_ATTACK2) then
			ply.SpectateGuy = math.Clamp(ply.SpectateGuy - 1, 1, #tbl)
		end

		if not ply.SpectateGuy or not IsValid(tbl[ply.SpectateGuy]) then
			ply.SpectateGuy = 1

			return false
		end

		local ent
		if ply.SpectateGuy and IsValid(tbl[ply.SpectateGuy]) and IsValid(tbl[ply.SpectateGuy]:GetNWEntity("DeathRagdoll")) then
			ent = tbl[ply.SpectateGuy]:GetNWEntity("DeathRagdoll")
		elseif ply.SpectateGuy and IsValid(tbl[ply.SpectateGuy]) then
			ent = tbl[ply.SpectateGuy]
		else
			ply.SpectateGuy = 1
		end

		ply:SetPos(ent:GetPos())
		ply:SetNWEntity("SpecPly", tbl[ply.SpectateGuy])
		ply:SpectateEntity(ent)
		ply.Blood = 5000

		return false
	end
end

function GM:PlayerDisconnected(ply)
	RoundEndCheck()
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerCanHearPlayersVoice()
	return true
end

function GM:PlayerInitialSpawn(ply)
end

--[[function GM:ShowTeam()
end--]]
hook.Add(
	"PlayerSay",
	"huy",
	function(ply, text)
		text = string.lower(text)
		textTable = string.Explode(" ", text)
		if textTable[1] == "!setspawn" then
			if textTable[2] == nil then return end
			if not file.Exists("homigrad", "DATA") then
				file.CreateDir("homigrad", "DATA")
			end

			if not file.Exists("homigrad/spawnpointsred", "DATA") then
				file.CreateDir("homigrad/spawnpointsred", "DATA")
			end

			if not file.Exists("homigrad/spawnpointsblue", "DATA") then
				file.CreateDir("homigrad/spawnpointsblue", "DATA")
			end

			if not file.Exists("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", "DATA") then
				file.Write("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", util.TableToKeyValues(spawnPointsRed))
			else
				spawnPointsRed = util.KeyValuesToTable(file.Read("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", "DATA"))
			end

			if not file.Exists("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", "DATA") then
				file.Write("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", util.TableToKeyValues(spawnPointsBlue))
			else
				spawnPointsBlue = util.KeyValuesToTable(file.Read("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", "DATA"))
			end

			if textTable[2] == "red" then
				table.insert(spawnPointsRed, tostring(ply:GetPos() + Vector(0, 0, 5)))
				file.Write("homigrad/spawnpointsred/" .. game.GetMap() .. ".txt", util.TableToKeyValues(spawnPointsRed))
			elseif textTable[2] == "blue" then
				table.insert(spawnPointsBlue, tostring(ply:GetPos() + Vector(0, 0, 5)))
				file.Write("homigrad/spawnpointsblue/" .. game.GetMap() .. ".txt", util.TableToKeyValues(spawnPointsBlue))
			end
		end
	end
)
--[[hook.Add("PlayerSelectTeamSpawn","teamspawn",function(team1,ply)
local redspawns = ents.FindByClass("info_player_terrorist")
local bluespawns = ents.FindByClass("info_player_counterterrorist")
local random_red =  math.random(#redspawns)
local random_blue =  math.random(#bluespawns)
if team1 == 0 then return redspawns[random_red] end
if team1 == 1 then return bluespawns[random_blue] end
end)--]]