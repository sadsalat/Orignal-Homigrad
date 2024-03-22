function UpdateTimer(time)
	net.Start("round_timer")
	net.WriteInt(time, 10)
	--print(time)
	net.Broadcast()
end

util.AddNetworkString("round_started")
function RoundStart()
	local time = 5
	local Alive = 0
	UpdateTimer(time)
	timer.Create(
		"round",
		1,
		time,
		function()
			time = time - 1
			for k, ply in ipairs(player.GetAll()) do
				if ply:Alive() then
					Alive = Alive + 1
				end
			end

			if Alive >= table.Count(player.GetAll()) and (table.Count(player.GetAll()) > 1) and (time <= 0) then
				roundActive = true
				net.Start("round_active")
				net.WriteBool("true")
				net.Broadcast()
			elseif table.Count(player.GetAll()) < 2 then
				UpdateTimer(5)

				return
			end

			if time <= 0 then
				for k, ply in ipairs(player.GetAll()) do
					ply:Freeze(false)
				end

				--print( "Round started: " .. tostring(roundActive))
				RoundEndCheck()
			else
				UpdateTimer(time)
			end
		end
	)

	net.Start("round_started")
	net.Broadcast()
end

function RoundEndCheck()
	print("Round started: " .. tostring(roundActive))
	time = 240
	UpdateTimer(time)
	if time <= 0 then
		EndRound("Nobody")
	end

	if (roundActive == false) or timer.Exists("cleanup") then return end
	timer.Create(
		"checkdelay",
		1,
		time,
		function()
			time = time - 1
			UpdateTimer(time)
			if time <= 0 then
				EndRound("Nobody")
			end

			local redAlive = 0
			local blueAlive = 0
			for k, ply in pairs(team.GetPlayers(0)) do
				if ply:Alive() then
					redAlive = redAlive + 1
				end
			end

			for k, ply in pairs(team.GetPlayers(1)) do
				if ply:Alive() then
					blueAlive = blueAlive + 1
				end
			end

			--print("Red Alive: " .. tostring(redAlive) .. " | Blue Alive: " .. tostring(blueAlive))
			if (redAlive == 0) and (blueAlive == 0) then
				EndRound("Nobody")
			elseif blueAlive == 0 then
				EndRound("Terrorist")
			elseif redAlive == 0 then
				EndRound("Counter-Terrorist")
			end
		end
	)
end

function EndRound(winners)
	print(winners .. " won the round!")
	for k, ply in ipairs(player.GetAll()) do
		--print(teams[ply:Team()].name,winners)
		if (teams[ply:Team()].name == winners) and winners ~= "Nobody" then
			ply:ChatPrint("Your team won.")
		elseif (teams[ply:Team()].name ~= winners) and winners ~= "Nobody" then
			ply:ChatPrint("Your team lost.")
		elseif (teams[ply:Team()].name ~= winners) and winners == "Nobody" then
			ply:ChatPrint("Nobody won!")
		end
	end

	timer.Remove("checkdelay")
	timer.Create(
		"cleanup",
		3,
		1,
		function()
			game.CleanUpMap(false, {})
			table.Shuffle(player.GetAll())
			for k, ply in ipairs(player.GetAll()) do
				ply:SetupHands()
				ply:StripWeapons()
				ply:KillSilent()
				--ply:SetupTeam(AutoBalance())
			end

			net.Start("round_active")
			net.WriteBool(false)
			net.Broadcast()
			roundActive = false
		end
	)
end

function AutoBalance()
	print(team.NumPlayers(0), team.NumPlayers(1))
	if team.NumPlayers(0) < team.NumPlayers(1) - 1 then
		return 0
	elseif team.NumPlayers(0) > team.NumPlayers(1) - 1 then
		return 1
	else
		return math.random(0, 1)
	end
end