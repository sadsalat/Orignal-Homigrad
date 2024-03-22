roundActive = true
local function logic(output, input, isChat, teamonly)
	local result, is3D = hook.Run("Player Can Lisen", output, input, isChat, teamonly)
	if result ~= nil then return result, is3D end
	if not roundActive then return true end
	if output:Alive() and input:Alive() and not output.Otrub and not input.Otrub then
		if input:GetPos():DistToSqr(output:GetPos()) < 800000 and not teamonly then
			return true, true
		else
			return false
		end
	elseif not output:Alive() and not input:Alive() then
		return true
	else
		if not input:Alive() and output:Alive() then return true, true end
		if not output:Alive() and input:Team() == 1002 and input:Alive() then return true end

		return false
	end
end

hook.Add(
	"PlayerCanSeePlayersChat",
	"RealiticChar",
	function(text, teamonly, input, output)
		if not IsValid(output) then return end

		return logic(output, input, true, false)
	end
)

hook.Add(
	"PlayerCanHearPlayersVoice",
	"RealisticVoice",
	function(input, output)
		local result, is3D = logic(output, input, false, false)
		local speak = output:IsSpeaking()
		output.IsSpeak = speak
		if output.IsOldSpeak ~= speak then
			output.IsOldSpeak = speak
			if speak then
				hook.Run("Player Start Voice", output)
			else
				hook.Run("Player End Voice", output)
			end
		end

		return result, is3D
	end
)

hook.Add("PlayerDeathSound", "CustomPlayerDeath", function(ply) return true end)