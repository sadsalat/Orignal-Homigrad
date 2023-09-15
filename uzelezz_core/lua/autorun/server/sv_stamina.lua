
function stamina()
hook.Add("Move" , "move.speed", function(ply, movedata)
    if ply:Alive() then
    	ply.speeed = movedata:GetVelocity():Length()
    end
end)
stamina_NextThink=0
hook.Add("Think","saystamina",function()
	for i, v in ipairs( player.GetAll() ) do
		v.stamina_NextThink=v.stamina_NextThink or stamina_NextThink
		v.stamina=v.stamina or 100
		v.fake=v.fake or false
		if not(v.stamina_NextThink>CurTime())then
		v.stamina_NextThink=CurTime()+1
		if v.HasLeft==nil then
			if v.stamina < 0 then
				v.stamina = 0
			end
			if v.stamina > 100 then
				v.stamina = 100
				v:SetNWInt("stamina",v.stamina)
			end
		if not v.fake then
			if v.stamina < 60 and v:WaterLevel()<=2 or v.Organs['lungs']==0 and v:WaterLevel()<=2 then 
				v:EmitSound( "snds_jack_hmcd_breathing/m"..math.random(1,6)..".wav", 60,100, 0.6, CHAN_AUTO )	
			end
			if v.stamina < 20 and v:WaterLevel()==3 then 
				if not v.Otrub then
				v:EmitSound( "Player.DrownContinue", 40,100, 0.6, CHAN_AUTO )
				end
				d = DamageInfo()
				d:SetDamage( 8 )
				d:SetDamageType( DMG_DROWN ) 

				v:TakeDamageInfo( d )
			end
			if v.stamina<100 and not v:IsSprinting() and v:WaterLevel()<=2  then
				--print(v.stamina.." - "..v:GetName())
				v.stamina=v.stamina+1+(v:GetNWInt("hungryregen")/2)
				v:SetNWInt("stamina",v.stamina)
			end
			if v:IsSprinting() then
				v.stamina=v.stamina - 0.5
			end
			if v:WaterLevel()==3 then
				if v:Alive() then
				v.stamina=v.stamina - 2.5
				end
			end
		elseif v:Alive() then

				if v.fakeragdoll:WaterLevel()==3 then
					if v:Alive() then
					v.stamina=v.stamina - 2.5
					end
				end

				if v.stamina < 60 and v.fakeragdoll:WaterLevel()<=2 or v.Organs['lungs']==0 and v.fakeragdoll:WaterLevel()<=2 then 
					v:EmitSound( "snds_jack_hmcd_breathing/m"..math.random(1,6)..".wav", 60,100, 0.6, CHAN_AUTO )	
				end

				if v.stamina<100 and v.fakeragdoll:WaterLevel()<=2  then
					--print(v.stamina.." - "..v:GetName())
					v.stamina=v.stamina+1+(v:GetNWInt("hungryregen")/2)
					v:SetNWInt("stamina",v.stamina)
				end

				if v.stamina < 20 and v.fakeragdoll:WaterLevel()==3 then 
					d = DamageInfo()
					d:SetDamage( 5 )
					d:SetDamageType( DMG_DROWN ) 

					v:SetHealth(v:Health()-1)
					v:TakeDamageInfo( d )


					if not v.Otrub then
						v:EmitSound( "Player.DrownContinue", 40,100, 0.6, CHAN_AUTO )
					end
				end
				if v:Alive() and v:Health()<=0 then
					v:Kill()
				end
		end
		end
		end
	end
	end)
end
stamina()