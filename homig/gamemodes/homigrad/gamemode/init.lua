
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("roundsystem.lua")
include("teamsetup.lua")

if (SERVER) then
util.AddNetworkString( "round_timer" )
util.AddNetworkString( "round_active" )
end


spawnPointsRed = {}
spawnPointsBlue = {}

roundActive=false

function GM:PlayerSpawn(ply)
	if ply:GetNWBool("unfaked") then return nil end
	ply:SetupHands()
	ply:SetupTeam(AutoBalance())
	if(ply:Team()==0)then
		ply:SetPos(Vector(spawnPointsRed[math.random(1,#spawnPointsRed)]))
	elseif(ply:Team()==1)then
		ply:SetPos(Vector(spawnPointsBlue[math.random(1,#spawnPointsBlue)]))
	end
	ply:ChatPrint("Your team is " .. teams[ply:Team()].name)
	SavePlyInfo(ply)
	ply:Freeze(true)
	ply.Blood=5000
	ply.pain=0
	if(roundActive==true)then
		ply:KillSilent()
		ply.SpectateGuy=1
		return
	else
		RoundStart()
		ply:Freeze(true)
	end
end

function GM:PlayerDeath(ply,attacker)
	if attacker:IsPlayer() then
		if ply:Team()==attacker:Team() and !(ply==attacker) then
			attacker:ChatPrint("You killed your teammate!")
		end
		if ply.Attacker2!=nil and ply:Team()==ply.Attacker2:Team() and !(ply==ply.Attacker2) then
			ply.Attacker2:ChatPrint("You killed your teammate!")
		end
	end
	ply:Spectate(OBS_MODE_CHASE)
	ply.SpectateGuy=1
end

function GM:PlayerDeathThink(ply)
	if(roundActive==false)then
		ply:Spawn()
		ply:UnSpectate()
		ply:SetNWEntity("DeathRagdoll",NULL)
		return true
	else
		if ply:KeyPressed(IN_ATTACK) then ply.SpectateGuy=math.Clamp(ply.SpectateGuy+1,1,player.GetCount()) end
		if ply:KeyPressed(IN_ATTACK2) then ply.SpectateGuy=math.Clamp(ply.SpectateGuy-1,1,player.GetCount()) end
		local ent
		if IsValid(player.GetByID(ply.SpectateGuy):GetNWEntity("DeathRagdoll")) then ent = player.GetByID(ply.SpectateGuy):GetNWEntity("DeathRagdoll") else ent = player.GetByID(ply.SpectateGuy) end
		ply:SpectateEntity(ent)
		ply.Blood=5000
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

--[[function GM:ShowTeam()
end--]]

hook.Add("PlayerSay","huy",function(ply,text)
	text = string.lower(text)
	textTable = string.Explode(" ",text)
	if (textTable[1] == "!setspawn" ) then
		if (textTable[2] == nil) then return end
		if (!file.Exists("homigrad","DATA"))then
			file.CreateDir("homigrad","DATA")
		end
		if (!file.Exists("homigrad/spawnpointsred","DATA"))then
			file.CreateDir("homigrad/spawnpointsred","DATA")
		end
		if (!file.Exists("homigrad/spawnpointsblue","DATA"))then
			file.CreateDir("homigrad/spawnpointsblue","DATA")
		end
		if(!file.Exists("homigrad/spawnpointsred/"..game.GetMap()..".txt","DATA"))then
			file.Write("homigrad/spawnpointsred/"..game.GetMap()..".txt",util.TableToKeyValues(spawnPointsRed))
		else
			spawnPointsRed = util.KeyValuesToTable(file.Read("homigrad/spawnpointsred/"..game.GetMap()..".txt","DATA"))
		end
		if(!file.Exists("homigrad/spawnpointsblue/"..game.GetMap()..".txt","DATA"))then
			file.Write("homigrad/spawnpointsblue/"..game.GetMap()..".txt",util.TableToKeyValues(spawnPointsBlue))
		else
			spawnPointsBlue = util.KeyValuesToTable(file.Read("homigrad/spawnpointsblue/"..game.GetMap()..".txt","DATA"))
		end
		if (textTable[2]=="red")then
			table.insert(spawnPointsRed,tostring(ply:GetPos()+Vector(0,0,5)))
			file.Write("homigrad/spawnpointsred/"..game.GetMap()..".txt",util.TableToKeyValues(spawnPointsRed))
		elseif (textTable[2]=="blue")then
			table.insert(spawnPointsBlue,tostring(ply:GetPos()+Vector(0,0,5)))
			file.Write("homigrad/spawnpointsblue/"..game.GetMap()..".txt",util.TableToKeyValues(spawnPointsBlue))
		end
	end
end)

--[[hook.Add("PlayerSelectTeamSpawn","teamspawn",function(team1,ply)
local redspawns = ents.FindByClass("info_player_terrorist")
local bluespawns = ents.FindByClass("info_player_counterterrorist")
local random_red =  math.random(#redspawns)
local random_blue =  math.random(#bluespawns)
if team1 == 0 then return redspawns[random_red] end
if team1 == 1 then return bluespawns[random_blue] end
end)--]]