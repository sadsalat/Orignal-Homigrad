function stamina()
	hook.Add(
		"Move",
		"move.speed",
		function(ply, movedata)
			if ply:Alive() then
				ply.speeed = movedata:GetVelocity():Length()
			end
		end
	)

	stamina_NextThink = 0
	hook.Add(
		"Think",
		"saystamina",
		function()
			for _, ply in ipairs(player.GetAll()) do
				ply.stamina_NextThink = ply.stamina_NextThink or stamina_NextThink
				ply.stamina = ply.stamina or 100
				ply.fake = ply.fake or false
				if not (ply.stamina_NextThink > CurTime()) then
					ply.stamina_NextThink = CurTime() + 1
					if ply.HasLeft == nil then
						if ply.stamina < 0 then
							ply.stamina = 0
						end

						if ply.stamina > 100 then
							ply.stamina = 100
							ply:SetNWInt("stamina", ply.stamina)
						end

						if not ply.fake then
							if ply.stamina < 60 and ply:WaterLevel() <= 2 or ply.Organs["lungs"] == 0 and ply:WaterLevel() <= 2 then
								ply:EmitSound("snds_jack_hmcd_breathing/m" .. math.random(1, 6) .. ".wav", 60, 100, 0.6, CHAN_AUTO)
							end

							if ply.stamina < 20 and ply:WaterLevel() == 3 then
								if not ply.Otrub then
									ply:EmitSound("Player.DrownContinue", 40, 100, 0.6, CHAN_AUTO)
								end

								d = DamageInfo()
								d:SetDamage(8)
								d:SetDamageType(DMG_DROWN)
								ply:TakeDamageInfo(d)
							end

							if ply.stamina < 100 and not ply:IsSprinting() and ply:WaterLevel() <= 2 then
								--print(ply.stamina.." - "..ply:GetName())
								ply.stamina = ply.stamina + 1 + (ply:GetNWInt("hungryregen") / 2)
								ply:SetNWInt("stamina", ply.stamina)
							end

							if ply:IsSprinting() then
								ply.stamina = ply.stamina - 0.5
							end

							if ply:WaterLevel() == 3 then
								if ply:Alive() then
									ply.stamina = ply.stamina - 2.5
								end
							end
						elseif ply:Alive() then
							if ply.fakeragdoll:WaterLevel() == 3 then
								if ply:Alive() then
									ply.stamina = ply.stamina - 2.5
								end
							end

							if ply.stamina < 60 and ply.fakeragdoll:WaterLevel() <= 2 or ply.Organs["lungs"] == 0 and ply.fakeragdoll:WaterLevel() <= 2 and ply:Alive() then
								ply:EmitSound("snds_jack_hmcd_breathing/m" .. math.random(1, 6) .. ".wav", 60, 100, 0.6, CHAN_AUTO)
							end

							if ply.stamina < 100 and ply.fakeragdoll:WaterLevel() <= 2 then
								--print(ply.stamina.." - "..ply:GetName())
								ply.stamina = ply.stamina + 1 + (ply:GetNWInt("hungryregen") / 2)
								ply:SetNWInt("stamina", ply.stamina)
							end

							if ply.stamina < 20 and ply.fakeragdoll:WaterLevel() == 3 then
								d = DamageInfo()
								d:SetDamage(5)
								d:SetDamageType(DMG_DROWN)
								ply:SetHealth(ply:Health() - 1)
								ply:TakeDamageInfo(d)
								if not ply.Otrub then
									ply:EmitSound("Player.DrownContinue", 40, 100, 0.6, CHAN_AUTO)
								end
							end

							if ply:Alive() and ply:Health() <= 0 then
								ply:Kill()
							end
						end
					end
				end
			end
		end
	)
end

stamina()
hook.Add(
	"UpdateAnimation",
	"fwep-attachmetfixer",
	function(ply, event, data)
		ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER)
	end
)