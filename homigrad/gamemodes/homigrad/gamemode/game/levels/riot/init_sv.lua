
function riot.StartRoundSV()
	tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 8,2))

	tdm.DirectOtherTeam(3,1,2)

	OpposingAllTeam()
	AutoBalanceTwoTeam()

	local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	tdm.CenterInit()

end

function riot.RoundEndCheck()

	local TAlive = tdm.GetCountLive(team.GetPlayers(1))
	local CTAlive = tdm.GetCountLive(team.GetPlayers(2))

	if TAlive == 0 and CTAlive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if CTAlive == 0 then EndRound(1) end

	tdm.Center()
end

function riot.EndRound(winner) tdm.EndRoundMessage(winner) end

function riot.PlayerInitialSpawn(ply) ply:SetTeam(math.random(1,2)) end

function riot.PlayerSpawn(ply,teamID)
	local teamTbl = riot[riot.teamEncoder[teamID]]
	local color = teamTbl[2]
	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon,0)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon)

	if teamID == 1 then
		JMod.EZ_Equip_Armor(ply,"Riot-Helmet",Color(65,65,65))
		local r = math.random(1,2)
		JMod.EZ_Equip_Armor(ply,(r == 1 and "Medium-Light-Vest") or (r == 2 and "Light-Vest"),Color(65,65,65))
	else
		local r = math.random(1,10)
		if r == 10 then
			JMod.EZ_Equip_Armor(ply,"Metal Pot",Color(255,255,255))
		end
	end

	if roundStarter then
		ply.allowFlashlights = false
	end
end

function riot.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end

local common = {"food_lays","weapon_pipe","weapon_bat","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"weapon_molotok","painkiller"}

function riot.ShouldSpawnLoot()
	local chance = math.random(100)

	if chance < 30 then
		return true,uncommon[math.random(#uncommon)]
	elseif chance < 70 then
		return true,common[math.random(#common)]
	else
		return false
	end
end

function riot.PlayerDeath(ply,inf,att) return false end
