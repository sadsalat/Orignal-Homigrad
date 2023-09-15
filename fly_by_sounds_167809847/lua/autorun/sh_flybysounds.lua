
local sv_flybysound_minspeed = CreateConVar("sv_flybysound_minspeed", 100, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Minimum speed required for sound to be heard.")
local sv_flybysound_maxspeed = CreateConVar("sv_flybysound_maxspeed", 1000, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Volume does not increase after this speed is exceeded.")

local sv_flybysound_minshapevolume = CreateConVar("sv_flybysound_minshapevolume", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Pitch does not increase when volume (area) falls below this amount.")
local sv_flybysound_maxshapevolume = CreateConVar("sv_flybysound_maxshapevolume", 300, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Pitch does not decrease when volume (area) exceeds this amount.")

local sv_flybysound_minvol = CreateConVar("sv_flybysound_minvol", 30, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Object must have at least this much volume (area) to produce fly by sounds.")

local sv_flybysound_playersounds = CreateConVar("sv_flybysound_playersounds", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Script applies to players.")

local windsound = "pink/flybysounds/fast_windloop1-louder.wav"

if SERVER then
	AddCSLuaFile()
	resource.AddSingleFile("sound/" .. windsound)
else
	local Round,abs = math.Round,math.abs

	local cl_flybysound_enable = CreateClientConVar("cl_flybysound_enable","1",true,false)

	local function averageSpeed(ent)
		local vel = ent:GetVelocity()

		return Round((abs(vel.y) + abs(vel.x) + abs(vel.z)) / 3)
	end

	/*local function guessScale(ent)
		if (!IsValid(ent)) then return 0 end
		return math.Round(ent:BoundingRadius()*ent:GetModelScale())
	end*/

	local function guessScale(ent)
		if ent:IsPlayer() then return 125 end

		local min,max = ent:GetCollisionBounds()
		local vecdiff = min - max
		local scaled = vecdiff * ent:GetModelScale()

		return Round((abs(scaled.x) + abs(scaled.y) + abs(scaled.z)) / 3)
	end

	--[[local validClasses = {}
	validClasses.prop_physics = true
	validClasses.prop_physics_multiplayer = true
	validClasses.prop_ragdoll = true
	validClasses.sent_ball = true]]--fuck off

	flybysound_entities = flybysound_entities or {}
	local flybysound_entities = flybysound_entities--погодите, это реально? да это реально

	local CreateSound,EyePos,LocalPlayer,Clamp = CreateSound,EyePos,LocalPlayer,math.Clamp

	hook.Add("Think","FlyBySound_Think",function()
		if not cl_flybysound_enable:GetBool() then return end

		local minspeed = sv_flybysound_minspeed:GetInt()
		local maxspeed = sv_flybysound_maxspeed:GetInt()
		local minshapevolume = sv_flybysound_minshapevolume:GetInt()
		local maxshapevolume = sv_flybysound_maxshapevolume:GetInt()
		local minvol = sv_flybysound_minvol:GetInt()
		local applytoplayer = sv_flybysound_playersounds:GetBool()

		local eyePos = EyePos()
		local lply = LocalPlayer()

		for ent in pairs(flybysound_entities) do
			if ent:GetMoveType() == MOVETYPE_NOCLIP then
				if ent.FlyBySound:IsPlaying() then ent.FlyBySound:Stop() end

				continue
			end

			if ent:WaterLevel() > 1 then
				if ent.FlyBySound:IsPlayng() then ent.FlyBySound:FadeOut(0.5) end--wtf???7777

				continue
			end

			local speed = averageSpeed(v)
			local shapevolume = guessScale(v)

			if shapevolume < minvol then continue end

			if not ent.FlyBySound then ent.FlyBySound = CreateSound(v,windsound) end

			if speed > minspeed then
				local dist = Round(EyePos():Distance(ent:GetPos()))

				if ent == lply then dist = maxspeed - speed end
				if dist < 0 then dist = 0 end

				local volume = (Clamp(speed,minspeed,maxspeed) - minspeed) / (maxspeed - minspeed)
				if ent == lply then volume = volume / 3 end

				local pitch = ((1-((Clamp(shapevolume,minshapevolume,maxshapevolume) - minshapevolume) / (maxshapevolume - minshapevolume))) * 200) - (dist / 500) * 50
				if pitch < 10 then pitch = 10 end

				if ent.FlyBySoundPlaying then
					ent.FlyBySound:ChangeVolume(volume,0)
					ent.FlyBySound:ChangePitch(pitch,0)

					continue
				end

				ent.FlyBySoundPlaying = true

				ent.FlyBySound:PlayEx(volume,pitch)
			else
				if not v.FlyBySoundPlaying then continue end

				ent.FlyBySoundPlaying = false
				ent.FlyBySound:FadeOut(0.5)
			end
		end
	end)

	hook.Add("OnEntityCreated","FlyBySound_EntityRemoved",function(ent)
		if not IsValid(ent) or not IsValid(ent:GetPhysicsObject()) then return end

		flybysound_entities[ent] = true
	end)

	hook.Add("EntityRemoved","FlyBySound_EntityRemoved",function(ent)
		if flybysound_entities[ent] then
			flybysound_entities[ent] = nil

			ent.FlyBySound:Stop()
		end
	end)

	/*hook.Add("HUDPaint", "DebugSpeeds", function()
		for k, v in pairs (ents.GetAll()) do

			if (!table.HasValue(validClasses, v:GetClass())) then continue end

			local speed = averageSpeed(v)
			local dist = math.Round(EyePos():Distance(v:GetPos()))

			local ts = v:GetPos():ToScreen()
			draw.SimpleTextOutlined(speed .. " - " .. dist .. " - " .. guessScale(v), "TargetID", ts.x, ts.y, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
		end
	end)*/

end
