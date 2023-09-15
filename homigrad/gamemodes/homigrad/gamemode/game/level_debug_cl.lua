concommand.Add("hg_dataround",function()
	PrintTable(dataRound)
end)

concommand.Add("hg_enddataround",function()
	PrintTable(dataRound)
end)

concommand.Add("hg_roundinfo",function()
	print("roundActive	" .. tostring(roundActive))
	print("roundActiveName	" .. tostring(roundActiveName))

	print("roundTimeStart	" .. tostring(roundTimeStart))
	print("roundTime	" .. tostring(roundTime))

	if roundTimeStart and roundTime then
		print("time left	" .. tostring(math.Round(roundTimeStart + roundTime - CurTime())))
	end
end)