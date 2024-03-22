DOG_NextCheck = CurTime() + 100
DOG_CheckCD = 40
DOG_ACrash = DOG_ACrash or {}
DOG_ACrash.CPS = 0
DOG_ACrash.NextWipe = nil
hook.Add("EntityTakeDamage", "DOG", function(ent, dmginfo) end) --[[if not IsValid(ent) then return nil end
	if ent:IsNPC() then return nil end
	if ent:IsVehicle() then return nil end

	if DOG_ACrash.NextWipe and DOG_ACrash.NextWipe + 1 < CurTime() then
		DOG_ACrash.CPS = 0
	end

	if dmginfo:GetDamageType() == DMG_CRUSH then
		DOG_ACrash.CPS = DOG_ACrash.CPS + 1
		DOG_ACrash.NextWipe = CurTime()
	end

	if DOG_ACrash.CPS > 46 then
		local phy = ent:GetPhysicsObject()

		if ent:GetClass() == "prop_ragdoll" then
			for i = 0, ent:GetPhysicsObjectCount() - 1 do
				local ragphy = ent:GetPhysicsObjectNum(i)

				if IsValid(ragphy) then
					ragphy:EnableMotion(false)
				else
					ent:Remove()
					break
				end
			end
		else
			if IsValid(phy) then
				phy:EnableMotion(false)
			else
				ent:Remove()
			end
		end

		PrintMessage(HUD_PRINTTALK, "Something trying to screw up the server, unscrewing")
	end

	if DOG_ACrash.CPS > 500 then
		RunConsoleCommand("phys_timescale", 0)
		PrintMessage(HUD_PRINTTALK, "Not enough. Disabling physics")
		DOG_ACrash.CPS = 0
	end]]