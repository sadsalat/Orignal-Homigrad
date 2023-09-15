LimitAutoBalance = 1
function NeedAutoBalance(addT,addCT)
	addT = addT or 0
	addCT = addCT or 0

	local count = (#team.GetPlayers(1) + addT) - (#team.GetPlayers(2) + addCT)
	if count == 0 then return end

	local favorT
	if count > 0 then favorT = true end

	local limit = math.min(#player.GetAll() - LimitAutoBalance - 1,LimitAutoBalance)
	count = math.max(math.abs(count) - limit,0)

	if count == 0 then return end

	return favorT,count
end

function PlayerIsCuffs(ply)
	if not ply:Alive() then return end
	local ent = ply:GetNWEntity("DeathRagdoll")
	if not IsValid(ent) then return end

	return constraint.FindConstraint(ent,"Rope")
end

function AutoBalanceTwoTeam()
	for i = 1,#player.GetAll() do
		local favorT,count = NeedAutoBalance()
		if not count then break end

		if favorT then
			local ply = table.Random(team.GetPlayers(1))
			ply:SetTeam(2)
			ply:ChatPrint("Тебя перекинуло в CT команду, из-за неравенства команд.")
		else
			local ply = table.Random(team.GetPlayers(2))
			ply:SetTeam(1)
			ply:ChatPrint("Тебя перекинуло T команду, из-за неравенства команд.")
		end
	end
end

function OpposingAllTeam()
	local oldT,oldCT = {},{}
	table.CopyFromTo(team.GetPlayers(1),oldT)
	table.CopyFromTo(team.GetPlayers(2),oldCT)

	for i,ply in pairs(oldT) do ply:SetTeam(2) end
	for i,ply in pairs(oldCT) do ply:SetTeam(1) end
end

function PlayersInGame()
    local newTbl = {}

    for i,ply in pairs(team.GetPlayers(1)) do newTbl[i] = ply end
    for i,ply in pairs(team.GetPlayers(2)) do table.insert(newTbl,ply) end
    for i,ply in pairs(team.GetPlayers(3)) do table.insert(newTbl,ply) end

    return newTbl
end


