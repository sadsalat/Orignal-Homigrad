numpad.Register( "k_forward", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["W"] = keydown
	end
	
	if keydown and ent:GetIsCruiseModeOn() then
		ent:SetIsCruiseModeOn( false )
	end
end )

numpad.Register( "k_reverse", function( pl, ent, keydown ) 
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["S"] = keydown
	end
	
	if keydown and ent:GetIsCruiseModeOn() then
		ent:SetIsCruiseModeOn( false )
	end
end )

numpad.Register( "k_left", function( pl, ent, keydown ) 
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["A"] = keydown
	end
end )

numpad.Register( "k_right", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["D"] = keydown
	end
end )

numpad.Register( "k_a_forward", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["aW"] = keydown
	end
end )

numpad.Register( "k_a_reverse", function( pl, ent, keydown ) 
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["aS"] = keydown
	end
end )

numpad.Register( "k_a_left", function( pl, ent, keydown ) 
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if (ent.PressedKeys) then
		ent.PressedKeys["aA"] = keydown
	end
end )

numpad.Register( "k_a_right", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["aD"] = keydown
	end
end )

numpad.Register( "k_gup", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	if pl.blockcontrols then keydown = false end
	
	if ent.PressedKeys then
		ent.PressedKeys["M1"] = keydown
	end
	
	if keydown and ent:GetIsCruiseModeOn() then
		ent:SetIsCruiseModeOn( false )
	end
end )

numpad.Register( "k_gdn", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	if pl.blockcontrols then keydown = false end
	
	if ent.PressedKeys then
		ent.PressedKeys["M2"] = keydown
	end
	
	if keydown and ent:GetIsCruiseModeOn() then
		ent:SetIsCruiseModeOn( false )
	end
end )

numpad.Register( "k_wot", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["Shift"] = keydown
	end
end )

numpad.Register( "k_clutch", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["Alt"] = keydown
	end
end )
numpad.Register( "k_hbrk", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if ent.PressedKeys then
		ent.PressedKeys["Space"] = keydown
	end
	
	if keydown and ent:GetIsCruiseModeOn() then
		ent:SetIsCruiseModeOn( false )
	end
end )

numpad.Register( "k_ccon", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if keydown then
		if ent:GetIsCruiseModeOn() then
			ent:SetIsCruiseModeOn( false )
		else
			ent:SetIsCruiseModeOn( true )
			ent.cc_speed = math.Round(ent:GetVelocity():Length(),0)
		end
	end
end )

numpad.Register( "k_hrn", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	ent.KeyPressedTime = isnumber( ent.KeyPressedTime ) and ent.KeyPressedTime or 0

	local v_list = list.Get( "simfphys_lights" )[ent.LightsTable] or false
	
	if keydown then
		ent.HornKeyIsDown = true
		
		if v_list and v_list.ems_sounds then
			if not ent.emson then
				timer.Simple( 0.1, function()
					if not IsValid(ent) or not ent.HornKeyIsDown then return end
					
					if not ent.horn then
						ent.horn = CreateSound(ent, ent.snd_horn or "simulated_vehicles/horn_1.wav")
						ent.horn:PlayEx(0,100)
					end
				end)
			end
		else
			if not ent.horn then
				ent.horn = CreateSound(ent, ent.snd_horn or "simulated_vehicles/horn_1.wav")
				ent.horn:PlayEx(0,100)
			end
		end
	else
		ent.HornKeyIsDown = false
	end
	
	if not v_list then return end
	
	if v_list.ems_sounds then
		
		local Time = CurTime()

		if keydown then
			ent.KeyPressedTime = Time
		else
			if (Time - ent.KeyPressedTime) < 0.15 then
				if not ent.emson then
					ent.emson = true
					ent.cursound = 0
				end
			end
			
			if (Time - ent.KeyPressedTime) >= 0.22 then
				if ent.emson then
					ent.emson = false
					if ent.ems then
						ent.ems:Stop()
					end
				end
			else
				if ent.emson then
					if ent.ems then ent.ems:Stop() end
					local sounds = v_list.ems_sounds
					local numsounds = table.Count( sounds )
					
					if numsounds <= 1 and ent.ems then
						ent.emson = false
						ent.ems = nil
						ent:SetEMSEnabled( false )
						return
					end
					
					ent.cursound = ent.cursound + 1
					if ent.cursound > table.Count( sounds ) then
						ent.cursound = 1
					end
					
					ent.ems = CreateSound(ent, sounds[ent.cursound])
					ent.ems:Play()
				end
			end
			ent:SetEMSEnabled( ent.emson )
		end
	end
end)

numpad.Register( "k_eng", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if keydown then
		if ent:EngineActive() then
			ent:StopEngine()
		else
			ent:StartEngine( true )
		end
	end
end)

numpad.Register( "k_lock", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) then return false end
	
	if keydown then
		if ent:GetIsVehicleLocked() then
			ent:UnLock()
		else
			ent:Lock()
		end
	end
end )

numpad.Register( "k_flgts", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) or not ent.LightsTable then return false end
	
	if keydown then
		ent:EmitSound( "buttons/lightswitch2.wav" )
		
		if ent:GetFogLightsEnabled() then
			ent:SetFogLightsEnabled( false )
		else
			ent:SetFogLightsEnabled( true )
		end
	end
end)

numpad.Register( "k_lgts", function( pl, ent, keydown )
	if not IsValid(pl) or not IsValid(ent) or not ent.LightsTable then return false end
	
	local Time = CurTime()
	
	if keydown then
		ent.KeyPressedTime = Time
	else
		if ent.KeyPressedTime and (Time - ent.KeyPressedTime) >= (ent.LightsActivated and 0.22 or 0) then
			if (ent.NextLightCheck or 0) > Time then return end
			
			local vehiclelist = list.Get( "simfphys_lights" )[ent.LightsTable] or false
			if not vehiclelist then return end
			
			if ent.LightsActivated then
				ent.NextLightCheck = Time + (vehiclelist.DelayOff or 0)
				ent.LightsActivated = false
				ent:SetLightsEnabled(false)
				ent:EmitSound( "buttons/lightswitch2.wav" )
				ent.LampsActivated = false
				ent:SetLampsEnabled( ent.LampsActivated )
			else
				ent.NextLightCheck = Time + (vehiclelist.DelayOn or 0)
				ent.LightsActivated = true
				ent:EmitSound( "buttons/lightswitch2.wav" )
			end
			
			if ent.LightsActivated then
				if vehiclelist.BodyGroups then
					ent:SetBodygroup(vehiclelist.BodyGroups.On[1], vehiclelist.BodyGroups.On[2] )
				end
				if vehiclelist.Animation then
					ent:PlayAnimation( vehiclelist.Animation.On )
				end
				if ent.LightsPP then
					ent:PlayPP(ent.LightsActivated)
				end
			else
				if vehiclelist.BodyGroups then
					ent:SetBodygroup(vehiclelist.BodyGroups.Off[1], vehiclelist.BodyGroups.Off[2] )
				end
				if vehiclelist.Animation then
					ent:PlayAnimation( vehiclelist.Animation.Off )
				end
				if ent.LightsPP then
					ent:PlayPP(ent.LightsActivated)
				end
			end
		else
			if (ent.NextLightCheck or 0) > Time then return end
			
			if ent.LampsActivated then
				ent.LampsActivated = false
			else
				ent.LampsActivated = true
			end
			
			ent:SetLampsEnabled( ent.LampsActivated )
			
			ent:EmitSound( "items/flashlight1.wav" )
		end
	end
end )
