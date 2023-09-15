--[[
       _            _                              _
      | |          | |                            | |
      | | __ _  ___| | ____ _ _ __ _   _ _ __   __| | __ _
  _   | |/ _` |/ __| |/ / _` | '__| | | | '_ \ / _` |/ _` |
 | |__| | (_| | (__|   < (_| | |  | |_| | | | | (_| | (_| |
  \____/ \__,_|\___|_|\_\__,_|_|   \__,_|_| |_|\__,_|\__,_| 2023

--]]

AddCSLuaFile()

if (SERVER) then
	local ItsHere = false

	THE_ANCIENT_WENDIGO = THE_ANCIENT_WENDIGO or nil

	hook.Add("PlayerSay", "Jendigo_PlayerSay", function(ply, txt)
		if (txt and txt == "it's here" and not ItsHere) then
			ply:EmitSound("jendigo/scream" .. math.random(1, 2) .. ".wav", 90, math.random(90, 110))
			ItsHere = true

			for i,ply in pairs(player.GetAll()) do
				ply:Give("gmod_camera")
			end
		end
	end)

	hook.Add("PlayerSpawn","giveCamera",function(ply)
		if not ItsHere then return end

		ply:Give("gmod_camera")
	end)

	local NextThink = 100
	hook.Add("Think", "Jendigo_Think", function()
		if not(ItsHere) then return end
		local Time = CurTime()
		if (NextThink > Time) then return end
		NextThink = Time + 100

		if not(IsValid(THE_ANCIENT_WENDIGO)) then
			THE_ANCIENT_WENDIGO = ents.Create("jendigo")
			THE_ANCIENT_WENDIGO:SetPos(Vector(0, 0, 0))
			THE_ANCIENT_WENDIGO:SetAngles(Angle(0, 0, 0))
			THE_ANCIENT_WENDIGO:Spawn()
			THE_ANCIENT_WENDIGO:Activate()
		end
	end)
elseif (CLIENT) then
	ANCIENT_WENDIGO_DRAW_FRAMES = ANCIENT_WENDIGO_DRAW_FRAMES or 0

	hook.Add("CreateMove", "Jendigo_CreateMove", function()
		if (input.WasMousePressed(MOUSE_LEFT)) then
			local ply = LocalPlayer()

			if (IsValid(ply)) then
				local wep = ply:GetActiveWeapon()

				if (IsValid(wep)) then
					if (wep:GetClass() == "gmod_camera") then
						ANCIENT_WENDIGO_DRAW_FRAMES = 5
					end
				end
			end
		end
	end)
end
