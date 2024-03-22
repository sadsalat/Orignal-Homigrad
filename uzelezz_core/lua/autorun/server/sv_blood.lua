local models = {
	["models/player/combine_soldier_prisonguard.mdl"] = true,
	["models/player/police.mdl"] = true,
	["models/player/police_fem.mdl"] = true,
	["models/player/combine_super_soldier.mdl"] = true,
	["models/player/zombie_fast.mdl"] = true,
	["models/player/skeleton.mdl"] = true,
	["models/player/soldier_stripped.mdl"] = true,
	["models/player/zombie_fast.mdl"] = true,
	["models/player/zombie_soldier.mdl"] = true,
	["models/player/combine_soldier.mdl"] = true,
	["models/bloocobalt/splinter cell/chemsuit_cod.mdl"] = true,
}

function Bleeding()
	hook.Add(
		"EntityTakeDamage",
		"phildcorn",
		function(victim, dmginfo)
			victim.Blood = victim.Blood or 5000
			victim.Bloodlosing = victim.Bloodlosing or 0
			--[[if dmginfo:IsDamageType(DMG_BLAST) then
        	Faking(victim)
    	end]]
			if dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then
				if victim:IsPlayer() or IsValid(RagdollOwner(victim)) then
					damage = dmginfo:GetDamage()
					victim.Bloodlosing = victim.Bloodlosing + (damage / 3)
					victim:SetNWInt("BloodLosing", victim.Bloodlosing)
					victim.IsBleeding = true
				end
			end
		end
	)

	local 👽, 🤑 = Vector(252 / 255, 61 / 255, 230 / 255), Model("models/player/group01/male_06.mdl") -- Дей
	BLEEDING_NextThink = 0
	hook.Add(
		"Think",
		"saygex",
		function()
			for i, ply in ipairs(player.GetAll()) do
				ply.Blood = ply.Blood or 5000
				ply.RightLeg = ply.RightLeg or 1
				ply.LeftLeg = ply.LeftLeg or 1
				ply.RightArm = ply.RightArm or 1
				ply.LeftArm = ply.LeftArm or 1
				ply.Speed = ply:GetNWInt("Adrenaline") or 0
				ply.BLEEDING_NextThink = ply.BLEEDING_NextThink or BLEEDING_NextThink
				ply.arterybloodlosing = ply.arterybloodlosing or 0
				if models[ply:GetModel()] then
					ply:SetModel("models/player/group01/male_01.mdl")
				end

				local pulse = math.Clamp((2 - ply.Blood / 5000) - ((ply.Bloodlosing + ply.arterybloodlosing) / 250), 0.1, 1)
				if not (ply.BLEEDING_NextThink > CurTime()) then
					ply.BLEEDING_NextThink = CurTime() + pulse
					if ply.HasLeft == nil then
						ply.Bloodlosing = ply.Bloodlosing or 0
						if ply.Bloodlosing < 0 then
							ply.Bloodlosing = 0
							ply:SetNWInt("BloodLosing", ply.Bloodlosing)
						end

						if ply.Bloodlosing > 0 or ply.arterybleeding then
							--print("pain: "..ply.Bloodlosing.." - "..ply:GetName())
							ply.Bloodlosing = ply:GetNWInt("BloodLosing")
							ply.Bloodlosing = ply.Bloodlosing - 0.5
							ply.Blood = ply.Blood - ply.Bloodlosing / 5 - ply.arterybloodlosing / 5
							ply:SetNWInt("BloodLosing", ply.Bloodlosing)
							ply:SetNWInt("Blood", ply.Blood)
							ply:SetNWInt("Speed", ply.Speed)
							if ply.Organs["artery"] == 0 and not ply.holdingartery then
								ply.arterybloodlosing = 250
							else
								ply.arterybloodlosing = 50
							end

							if IsValid(ply:GetNWEntity("DeathRagdoll")) then
								ply.pos = ply:GetNWEntity("DeathRagdoll"):GetPos()
								ply:GetNWEntity("DeathRagdoll"):EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.1, CHAN_AUTO)
							else
								ply.pos = ply:GetPos()
								ply:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.1, CHAN_AUTO)
							end

							local rn = math.Rand(-0.35, 0.35)
							local rnn = math.Rand(-0.35, 0.35)
							local tr = {}
							tr.start = Vector(ply.pos) + Vector(0, 0, 50)
							tr.endpos = tr.start + Vector(rn, rnn, -1) * 8000
							tr.filter = {ply, ply.fakeragdoll}
							local trw = util.TraceHull(tr)
							local Pos1 = trw.HitPos + trw.HitNormal
							local Pos2 = trw.HitPos - trw.HitNormal
							util.Decal("Blood", Pos1, Pos2, ply)
						elseif ply.Blood < 5000 then
							--print(ply.Blood.." - "..ply:GetName())
							ply.Blood = ply:GetNWInt("Blood") + 5
							ply:SetNWInt("Blood", ply.Blood)
							ply:SetNWInt("Speed", ply.Speed)
							ply.IsBleeding = false
						end

						ply:SetWalkSpeed((120 * (ply.Blood / 5000)) * (ply.stamina / 100) * ply.RightLeg * ply.LeftLeg)
						ply:SetRunSpeed((210 * (ply.Blood / 5000) + (ply.Speed * 50)) * (ply.stamina / 100) * ply.RightLeg * ply.LeftLeg)
						ply:SetJumpPower(((190 * (ply.Blood / 5000) + (ply.Speed * 25)) * (ply.stamina / 100)) * ply.RightLeg * ply.LeftLeg)
					end
				end
			end
		end
	)

	BLEEDING_NextThink1 = 0
	hook.Add(
		"Think",
		"BleedingBodies",
		function()
			for i, ent in pairs(BleedingEntities) do
				if not ent.IsBleeding then return end
				ent.BLEEDING_NextThink1 = ent.BLEEDING_NextThink1 or BLEEDING_NextThink1
				if ent.BLEEDING_NextThink1 < CurTime() then
					ent.BLEEDING_NextThink1 = CurTime() + math.random(0.6, 0.8)
					local rn = math.Rand(-0.35, 0.35)
					local rnn = math.Rand(-0.35, 0.35)
					local tr = {}
					tr.start = Vector(ent:GetPos(0, 0, 50)) + Vector(0, 0, 50)
					tr.endpos = tr.start + Vector(rn, rnn, -1) * 8000
					tr.filter = ent
					local trw = util.TraceHull(tr)
					local Pos1 = trw.HitPos + trw.HitNormal
					local Pos2 = trw.HitPos - trw.HitNormal
					ent:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.2, CHAN_AUTO)
					util.Decal("Blood", Pos1, Pos2, ent)
				end
			end
		end
	)
end

Bleeding()
local syncenabled = CreateConVar("hg_sync", 0, FCVAR_NOTIFY, "Enable death sync (death = kick)", 0, 1)
function Bleeding1()
	hook.Add(
		"PlayerSpawn",
		"RefreshBlood",
		function(ply)
			ply.unfaked = ply.unfaked or false
			if ply.unfaked == false then
				ply.IsBleeding = false
				ply.Blood = 5000
				ply:SetNWInt("Blood", ply.Blood)
				ply.Bloodlosing = 0
				ply:SetNWInt("BloodLosing", 0)
				ply:ConCommand("soundfade 0 1")
				ply.stamina = 100
				ply:SetNWInt("stamina", ply.stamina)
				ply.LeftLeg = 1
				ply.RightLeg = 1
				ply.RightArm = 1
				ply.LeftArm = 1
				ply.Attacker = nil
			end
		end
	)

	hook.Add(
		"PlayerDeath",
		"deathblood",
		function(ply)
			ply.Bloodlosing = 0
			ply:SetNWInt("BloodLosing", 0)
			ply.Blood = 5000
			ply:SetNWInt("Blood", ply.Blood)
			ply:ConCommand("soundfade 0 1")
			ply:SetNWInt("painlosing", 1)
			ply.stamina = 100
			ply.LeftLeg = 1
			ply.RightLeg = 1
			ply.RightArm = 1
			ply.LeftArm = 1
			ply.arterybleeding = nil
			ply.Organs = {
				["brain"] = 20,
				["lungs"] = 30,
				["liver"] = 30,
				["stomach"] = 40,
				["intestines"] = 40,
				["heart"] = 10,
				["artery"] = 1,
				["spine"] = 10
			}

			ply.InternalBleeding = nil
			ply.InternalBleeding2 = nil
			ply.InternalBleeding3 = nil
			ply.InternalBleeding4 = nil
			ply.InternalBleeding5 = nil
			ply.arterybleeding = false
			ply.brokenspine = false
			-- sync
			if syncenabled:GetInt() == 1 then
				ply:Kick("you dead fool")
				print(ply, "умер")
			end
		end
	)

	hook.Add(
		"PlayerDisconnected",
		"playerLeave",
		function(ply)
			ply.HasLeft = true
		end
	)

	timer.Simple(
		1,
		function()
			function GAMEMODE:PlayerLoadout(ply)
				ply:Give("weapon_hands")
				--ply:Give( "act3_ak" )
				--ply:Give( "act3_knife" )
				--ply:Give( "act3_g17" )
				--ply:Give( "medkit" )
				--ply:Give( "bandage" )
				--ply:Give( "weapon_jmodnade" )

				return false
			end
		end
	)
end

Bleeding1()