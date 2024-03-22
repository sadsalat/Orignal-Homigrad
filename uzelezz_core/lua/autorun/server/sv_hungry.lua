function hungry()
	hungry_NextThink = 0
	hook.Add(
		"Think",
		"sayhungry",
		function()
			for i, v in pairs(player.GetAll()) do
				v.hungry_NextThink = v.hungry_NextThink or hungry_NextThink
				v.hungry = v.hungry or 89
				if not (v.hungry_NextThink > CurTime()) then
					v.hungry_NextThink = CurTime() + 1.5
					if v.HasLeft == nil then
						if not v:Alive() then return end
						v:SetNWInt("hungryregen", math.Clamp(v:GetNWInt("hungryregen") - 0.25, -0.05, 10))
						if v:GetNWInt("hungryregen") == nil then
							v:SetNWInt("hungryregen", math.Clamp(v:GetNWInt("hungryregen") - 0.25, -0.01, 10))
						end

						if v.hungry > 100 then
							v.hungry = 100
							v:SetNWInt("hungry", v.hungry)
						end

						if v.hungry > 0 then
							--v:ChatPrint("Hungry "..v.hungry.." - "..v:GetName())
							v.hungry = v.hungry + v:GetNWInt("hungryregen")
							v:SetNWInt("hungry", v.hungry)
						end

						if v.hungry < 5 then
							local d = DamageInfo()
							d:SetDamage(1)
							d:SetDamageType(DMG_GENERIC)
							v:TakeDamageInfo(d)
						end

						if v.hungry < 80 then
							v.r = math.random(1, 100)
							if v.hungry < 40 and v.r == 30 then
								v:ChatPrint("Ты голоден")
							end

							if v.hungry > 40 and v.hungry < 65 and v.r == 30 then
								v:ChatPrint("Ты проголодался")
							end
						end
					end
				end
			end
		end
	)
end

hungry()
hook.Add(
	"PlayerDeath",
	"deathhungry",
	function(v)
		v.hungry = 89
		v:SetNWInt("hungryregen", 0)
	end
)

local dei = Vector(252 / 255, 61 / 255, 230 / 255)
hook.Add(
	"PlayerSpawn",
	"spawnhungry",
	function(v)
		v.hungry = 89
		v:SetNWInt("hungryregen", -0.05)
	end
)