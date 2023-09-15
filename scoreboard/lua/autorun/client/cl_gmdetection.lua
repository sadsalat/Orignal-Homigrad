print("[Shaped Scoreboard] Tracksters Shaped Scoreboard has been loaded.")
print("[Shaped Scoreboard] Searching for Gamemode Name...")

hook.Add("PostGamemodeLoaded", "MultigamemodeShapedScoreboard", function()
if CLIENT then
local GMName = gmod.GetGamemode()
    if GMName.Name == "Sandbox" then
		print("[Shaped Scoreboard] Gamemode Sandbox found")
		include ("client/scoreboard_sandbox.lua")
	elseif GMName.Name == "DarkRP" then
	    print("[Shaped Scoreboard] Gamemode DarkRP found")
	    include ("client/scoreboard_darkrp.lua")
	elseif GMName.Name == "Trouble in Terrorist Town" then
        print("[Shaped Scoreboard] Gamemode TTT found")
        include ("client/scoreboard_ttt.lua")
	end
end
end)