local team_GetPlayers = team.GetPlayers
local GetAll = player.GetAll
local max,abs,min = math.max,math.abs,math.min

LimitAutoBalance = 1
function NeedAutoBalance(addT,addCT)
	addT = addT or 0
	addCT = addCT or 0

	local count = (#team_GetPlayers(1) + addT) - (#team_GetPlayers(2) + addCT)
	if count == 0 then return end

	local favorT
	if count > 0 then favorT = true end

	local limit = min(#GetAll() - LimitAutoBalance - 1,LimitAutoBalance)
	count = max(abs(count) - limit,0)

	if count == 0 then return end

	return favorT,count
end

local table_Random = table.Random
function AutoBalanceTwoTeam()
	for i = 1,#GetAll() do
		local favorT,count = NeedAutoBalance()
		if not count then break end

		if favorT then
			local ply = table_Random(team_GetPlayers(1))
			ply:SetTeam(2)
			ply:ChatPrint("Тебя перекинуло в CT команду, из-за неравенства команд.")
		else
			local ply = table_Random(team_GetPlayers(2))
			ply:SetTeam(1)
			ply:ChatPrint("Тебя перекинуло в T команду, из-за неравенства команд.")
		end
	end
end

local table_CopyFromTo = table.CopyFromTo
--local pairs = pairs--lol

function OpposingAllTeam()
	local oldT,oldCT = {},{}
	table_CopyFromTo(team_GetPlayers(1),oldT)
	table_CopyFromTo(team_GetPlayers(2),oldCT)

	for i,ply in pairs(oldT) do ply:SetTeam(2) end
	for i,ply in pairs(oldCT) do ply:SetTeam(1) end
end
