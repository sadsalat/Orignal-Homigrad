BleedingEntities = {}
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
Organs = {
	["brain"] = 5,
	["lungs"] = 30,
	["liver"] = 30,
	["stomach"] = 40,
	["intestines"] = 40,
	["heart"] = 10,
	["artery"] = 1,
	["spine"] = 10
}

local bonenames = {
	["ValveBiped.Bip01_Head1"] = "Голову",
	["ValveBiped.Bip01_Spine"] = "Живот",
	["ValveBiped.Bip01_Spine1"] = "Кишки",
	["ValveBiped.Bip01_Spine2"] = "Грудь",
	["ValveBiped.Bip01_Spine4"] = "Грудь",
	["ValveBiped.Bip01_Pelvis"] = "Живот",
	["ValveBiped.Bip01_R_Hand"] = "Правую руку",
	["ValveBiped.Bip01_R_Forearm"] = "Голову",
	["ValveBiped.Bip01_R_Foot"] = "Правую ногу",
	["ValveBiped.Bip01_R_Thigh"] = "Правое бедро",
	["ValveBiped.Bip01_R_Calf"] = "Правую голень",
	["ValveBiped.Bip01_R_Shoulder"] = "Правое плечо",
	["ValveBiped.Bip01_R_Elbow"] = "Правый локоть",
	["ValveBiped.Bip01_L_Hand"] = "Левую руку",
	["ValveBiped.Bip01_L_Forearm"] = "Голову",
	["ValveBiped.Bip01_L_Foot"] = "Левую ногу",
	["ValveBiped.Bip01_L_Thigh"] = "Левое бедро",
	["ValveBiped.Bip01_L_Calf"] = "Левую голень",
	["ValveBiped.Bip01_L_Shoulder"] = "Левое плечо",
	["ValveBiped.Bip01_L_Elbow"] = "Левый локоть"
}

--Умножения урона при попадании по регдоллу
RagdollDamageBoneMul = {
	[HITGROUP_LEFTLEG] = 0.8,
	[HITGROUP_RIGHTLEG] = 0.8,
	[HITGROUP_GENERIC] = 0.8,
	[HITGROUP_LEFTARM] = 0.8,
	[HITGROUP_RIGHTARM] = 0.8,
	[HITGROUP_CHEST] = 1.0,
	[HITGROUP_STOMACH] = 0.9,
	[HITGROUP_HEAD] = 15,
}

--Хитгруппы костей
local bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = 1,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Forearm"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 5,
	["ValveBiped.Bip01_L_UpperArm"] = 4,
	["ValveBiped.Bip01_L_Forearm"] = 4,
	["ValveBiped.Bip01_L_Hand"] = 4,
	["ValveBiped.Bip01_Pelvis"] = 3,
	["ValveBiped.Bip01_Spine2"] = 2,
	["ValveBiped.Bip01_L_Thigh"] = 6,
	["ValveBiped.Bip01_L_Calf"] = 6,
	["ValveBiped.Bip01_L_Foot"] = 6,
	["ValveBiped.Bip01_R_Thigh"] = 7,
	["ValveBiped.Bip01_R_Calf"] = 7,
	["ValveBiped.Bip01_R_Foot"] = 7
}

-- Сохранение игрока перед его падением в фейк
function SavePlyInfo(ply)
	ply.Info = {}
	local info = ply.Info
	info.HasSuit = ply:IsSuitEquipped()
	info.SuitPower = ply:GetSuitPower()
	info.Ammo = ply:GetAmmo()
	info.ActiveWeapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil
	info.ActiveWeapon2 = ply:GetActiveWeapon()
	GetFakeWeapon(ply)
	info.Weapons = {}
	for i, wep in pairs(ply:GetWeapons()) do
		info.Weapons[wep:GetClass()] = {
			Clip1 = wep:Clip1(),
			Clip2 = wep:Clip2(),
		}
	end

	return info
end

function GetFakeWeapon(ply)
	ply.curweapon = ply.Info.ActiveWeapon
end

function ClearFakeWeapon(ply)
	if ply.FakeShooting then
		DespawnWeapon(ply)
	end
end

-- Сохранение игрока перед вставанием
function SavePlyInfoPreSpawn(ply)
	ply.Info = ply.Info or {}
	local info = ply.Info
	info.Hp = ply:Health()
	info.Armor = ply:Armor()

	return info
end

-- возвращение информации игроку по его вставанию
function ReturnPlyInfo(ply)
	ClearFakeWeapon(ply)
	local info = ply.Info
	if not info then return end
	ply:SetSuppressPickupNotices(true)
	ply:StripWeapons()
	ply:StripAmmo()
	for name, wepinfo in pairs(info.Weapons or {}) do
		local weapon = ply:Give(name, true)
		if IsValid(weapon) then
			weapon:SetClip1(wepinfo.Clip1)
			weapon:SetClip2(wepinfo.Clip2)
		end
	end

	for ammo, amt in pairs(info.Ammo or {}) do
		ply:GiveAmmo(amt, ammo)
	end

	if info.ActiveWeapon then
		ply:SelectWeapon(info.ActiveWeapon)
	end

	if info.HasSuit then
		ply:EquipSuit()
		ply:SetSuitPower(info.SuitPower or 0)
	else
		ply:RemoveSuit()
	end

	ply:SetHealth(info.Hp)
	ply:SetArmor(info.Armor)
	ply:SetSuppressPickupNotices(false)
end

-- функция падения
function Faking(ply)
	ply.fake = not ply.fake
	ply:SetNWBool("fake", ply.fake)
	if ply.fake == true then
		SavePlyInfo(ply)
		ply:DrawViewModel(false)
		if SERVER then
			ply:DrawWorldModel(false)
		end

		if ply:InVehicle() then
			ply:ExitVehicle()
		end

		ply:CreateRagdoll()
		if IsValid(ply:GetNWEntity("DeathRagdoll")) then
			ply.fakeragdoll = ply:GetNWEntity("DeathRagdoll")
			ply:HuySpectate()
			--ply:SetParent(ply:GetNWEntity("DeathRagdoll"))
			ply:SetSuppressPickupNotices(false)
			ply:SetActiveWeapon(nil)
			ply:DropObject()
			timer.Create("faketimer" .. ply:EntIndex(), 2, 1, function() end)
			local guninfo = weapons.Get(ply.curweapon)
			if guninfo and guninfo.Base == "salat_base" then
				ply.FakeShooting = true
				ply:SetNWInt("FakeShooting", true)
			else
				ply.FakeShooting = false
				ply:SetNWInt("FakeShooting", false)
			end
		end
	else
		if IsValid(ply:GetNWEntity("DeathRagdoll")) then
			ply.fakeragdoll = nil
			SavePlyInfoPreSpawn(ply)
			local pos = ply:GetNWEntity("DeathRagdoll"):GetPos()
			local vel = ply:GetNWEntity("DeathRagdoll"):GetVelocity()
			--ply:UnSpectate()
			ply.unfaked = true
			ply:SetNWBool("unfaked", ply.unfaked)
			local eyepos = ply:EyeAngles()
			ply:Spawn()
			ReturnPlyInfo(ply)
			ply.FakeShooting = false
			ply:SetNWInt("FakeShooting", false)
			ply:SetVelocity(vel)
			ply:SetEyeAngles(eyepos)
			ply.unfaked = false
			ply:SetNWBool("unfaked", ply.unfaked)
			ply:SetParent()
			ply:SetPos(pos)
			ply:DrawViewModel(true)
			ply:DrawWorldModel(true)
			ply:GetNWEntity("DeathRagdoll"):Remove()
			ply:SetNWEntity("DeathRagdoll", nil)
		end
	end
end

--функция стрельбы лежа
hook.Add(
	"Think",
	"FakedShoot",
	function()
		for i, ply in ipairs(player.GetAll()) do
			if IsValid(ply:GetNWEntity("DeathRagdoll")) and ply.FakeShooting and ply:Alive() then
				SpawnWeapon(ply)
			else
				if IsValid(ply.wep) then
					DespawnWeapon(ply)
				end
			end
		end
	end
)

--функция, определяет хозяина регдолла
function RagdollOwner(rag)
	for k, v in ipairs(player.GetAll()) do
		local ply = v
		if ply:GetNWEntity("DeathRagdoll") == rag then return ply end
	end

	return false
end

function PlayerMeta:DropWeapon()
	local ply = self
	if not IsValid(ply:GetActiveWeapon()) then return end
	local guninfo = weapons.Get(ply:GetActiveWeapon():GetClass())
	if guninfo.Base == "salat_base" then
		ply.curweapon = ply:GetActiveWeapon():GetClass()
		ply.Clip = ply:GetActiveWeapon():Clip1()
		ply.AmmoType = ply:GetActiveWeapon():GetPrimaryAmmoType()
		SpawnWeaponEnt(ply:GetActiveWeapon():GetClass(), ply:EyePos() + Vector(0, 0, -10), ply):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 200 + ply:GetVelocity())
		ply.curweapon = nil
		ply.Clip = nil
		ply.AmmoType = nil
		ply:GetActiveWeapon():Remove()
	end
end

function PlayerMeta:PickupEnt()
	local ply = self
	local rag = ply:GetNWEntity("DeathRagdoll")
	local phys = rag:GetPhysicsObjectNum(7)
	local offset = phys:GetAngles():Right() * 5
	local traceinfo = {
		start = phys:GetPos(),
		endpos = phys:GetPos() + offset,
		filter = rag,
		output = trace,
	}

	local trace = util.TraceLine(traceinfo)
	if trace.Entity == Entity(0) or trace.Entity == NULL or not trace.Entity.canpickup then return end
	if trace.Entity:GetClass() == "wep" then
		ply:Give(trace.Entity.curweapon, true):SetClip1(trace.Entity.Clip)
		--SavePlyInfo(ply)
		ply.wep.Clip = trace.Entity.Clip
		trace.Entity:Remove()
	end
end

--обнуление регдолла после вставания
hook.Add(
	"PlayerDeath",
	"resetfakes",
	function(ply, inflictor, attacker)
		if ply.fake then
			ply:SetNWEntity("DeathRagdoll", nil)
			Faking(ply)
			ply:SetParent()
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetNWEntity("DeathRagdoll", nil)
		end

		if ply.Attacker ~= nil and ply.Attacker ~= ply:Nick() then
			if bonenames[tostring(ply.LastHit)] ~= nil then
				ply:ChatPrint("Тебя убил " .. ply.Attacker .. " в " .. bonenames[tostring(ply.LastHit)] .. ".")
			else
				ply:ChatPrint("Тебя убил " .. ply.Attacker .. ".")
			end

			print(bonenames[tostring(ply.LastHit)])
		else
			ply:ChatPrint("Ты умер.")
		end
	end
)

hook.Add(
	"PhysgunDrop",
	"DropPlayer",
	function(ply, ent)
		ent.isheld = false
	end
)

hook.Add(
	"PhysgunPickup",
	"DropPlayer2",
	function(ply, ent)
		if ply:GetUserGroup() == "superadmin" then
			ent.isheld = true
			if ent:IsPlayer() and not ent.fake then
				Faking(ent)

				return false
			end
		end
	end
)

--обнуление регдолла после вставания
hook.Add(
	"DoPlayerDeath",
	"resetfakes3232",
	function(ply)
		if ply.fake then
			local rag = ply:GetNWEntity("DeathRagdoll")
			ply:GetNWEntity("DeathRagdoll").deadbody = true
			if ply.IsBleeding then
				rag.IsBleeding = true
			end

			table.insert(BleedingEntities, rag)
			rag:SetEyeTarget(vector_origin)
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetMoveType(MOVETYPE_OBSERVER)
		end
	end
)

--ply:GetNWEntity("DeathRagdoll").index=table.MemberValuesFromKey(BleedingEntities,ply:GetNWEntity("DeathRagdoll"))
hook.Add(
	"Think",
	"BodyDespawn",
	function()
		for i, ent in pairs(ents.FindByClass("prop_ragdoll")) do
			if ent.deadbody and engine.ActiveGamemode() == "sandbox" then
				if IsValid(ent.ZacConsLH) then
					ent.ZacConsLH:Remove()
					ent.ZacConsLH = nil
				end

				if IsValid(ent.ZacConsRH) then
					ent.ZacConsRH:Remove()
					ent.ZacConsRH = nil
				end

				if not timer.Exists("DecayTimer" .. ent:EntIndex()) then
					timer.Create(
						"DecayTimer" .. ent:EntIndex(),
						60,
						1,
						function()
							if IsValid(ent) then
								ent:Remove()
								table.RemoveByValue(BleedingEntities, ent)
							end
						end
					)
				end
			end
		end
	end
)

util.AddNetworkString("ragplayercolor")
function EntityMeta:BetterSetPlayerColor(col)
	if not (col or self) then return end
	timer.Simple(
		.1,
		function()
			if not IsValid(self) then return end
			net.Start("ragplayercolor")
			net.WriteEntity(self)
			net.WriteVector(col)
			net.Broadcast()
		end
	)
end

--обнуление регдолла после вставания
hook.Add(
	"PlayerSpawn",
	"resetfakebody",
	function(ply)
		ply.fake = false
		if not ply.unfaked then
			ply.suiciding = false
			ply:SetNWEntity("DeathRagdoll", nil)
			--ply:GetNWEntity("DeathRagdoll").health=ply:Health()
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
			--table.Merge(Organs,ply.Organs)
		end
	end
)

--урон по разным костям регдолла
hook.Add(
	"EntityTakeDamage",
	"ragdamage",
	function(ent, dmginfo)
		if ent.deadbody and not ent.IsBleeding and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then
			ent.IsBleeding = true
		end

		local trace = util.QuickTrace(dmginfo:GetDamagePosition(), dmginfo:GetDamageForce():GetNormalized() * 100)
		local bone = trace.PhysicsBone
		local hitgroup
		local isfall
		local bonename = ent:GetBoneName(bone)
		if bonetohitgroup[bonename] ~= nil then
			hitgroup = bonetohitgroup[bonename]
		end

		if RagdollDamageBoneMul[hitgroup] then
			if RagdollOwner(ent) then
				dmginfo:ScaleDamage(0.3)
				timer.Create("faketimer" .. RagdollOwner(ent):EntIndex(), dmginfo:GetDamage() / 30, 1, function() end)
				if hitgroup == HITGROUP_HEAD then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(2)
					if dmginfo:GetDamageType() == 2 then
						dmginfo:ScaleDamage(2)
					end

					if dmginfo:GetDamageType() == 1 and dmginfo:GetDamage() > 6 and ent:GetVelocity():Length() > 500 then
						RagdollOwner(ent):ChatPrint("Твоя шея была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
						dmginfo:ScaleDamage(1000000)
					end

					if dmginfo:GetDamageType() == 1 and dmginfo:GetDamage() > 5 and ent:GetVelocity():Length() > 220 and RagdollOwner(ent).Otrub == 0 then
						RagdollOwner(ent).pain = 270
					end
				end

				if hitgroup == HITGROUP_LEFTARM then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
					if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 10 and RagdollOwner(ent).LeftArm > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя левая рука была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).LeftArm = 0.6
						dmginfo:ScaleDamage(0.3)
					end

					if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).LeftArm > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя левая рука была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).LeftArm = 0.6
						dmginfo:ScaleDamage(0.3)
					end
				end

				if hitgroup == HITGROUP_LEFTLEG then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
					if dmginfo:GetDamageType() == 2 then end
					if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 15 and RagdollOwner(ent).LeftLeg > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя левая нога была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).LeftLeg = 0.6
						dmginfo:ScaleDamage(0.3)
					end

					if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).LeftLeg > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя левая нога была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).LeftLeg = 0.6
						dmginfo:ScaleDamage(0.3)
					end
				end

				if hitgroup == HITGROUP_RIGHTLEG then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
					if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 15 and RagdollOwner(ent).RightLeg > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя правая нога была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightLeg = 0.6
						dmginfo:ScaleDamage(0.3)
					end

					if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).RightLeg > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя правая нога была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightLeg = 0.6
						dmginfo:ScaleDamage(0.3)
					end
				end

				if hitgroup == HITGROUP_RIGHTARM then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.3)
					if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 10 and RagdollOwner(ent).RightArm > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя правая рука была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightArm = 0.6
						dmginfo:ScaleDamage(0.3)
					end

					if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).RightArm > 0.6 then
						RagdollOwner(ent):ChatPrint("Твоя правая рука была сломана")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightArm = 0.6
						dmginfo:ScaleDamage(0.3)
					end
				end

				if hitgroup == HITGROUP_CHEST then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 800 and RagdollOwner(ent).Organs["spine"] > 0 then
						RagdollOwner(ent).brokenspine = true
						RagdollOwner(ent).Organs["spine"] = 0
						RagdollOwner(ent):ChatPrint("Твоя спина была сломана.")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
						dmginfo:ScaleDamage(0.3)
					end

					dmginfo:ScaleDamage(0.8)
				end

				if hitgroup == HITGROUP_STOMACH then
					if dmginfo:GetAttacker():IsRagdoll() then return end
					dmginfo:ScaleDamage(0.5)
				end
			end

			local ply
			local penetration
			if IsValid(RagdollOwner(ent)) then
				ply = RagdollOwner(ent)
			elseif ent:IsPlayer() then
				ply = ent
			end

			if dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH) then
				penetration = dmginfo:GetDamageForce() * 0.008
			else
				penetration = dmginfo:GetDamageForce() * 0.004
			end

			if not dmginfo:IsDamageType(DMG_CRUSH + DMG_GENERIC) then
				if hitgroup == 1 and ent:IsPlayer() and ent.fake == false and ent:Alive() then
					Faking(ent)
				end

				--and ent:LookupBone(bonename)==3 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-1, 0, -6), Vector(10, 6, 6))
					--ply:ChatPrint("You were hit in the lungs.")
					if huy ~= nil then
						if ply.Organs["lungs"] ~= 0 then
							ply.Organs["lungs"] = math.Clamp(ply.Organs["lungs"] - dmginfo:GetDamage(), 0, 30)
							--if ply.Organs["lungs"]==0 then ply:ChatPrint("Твои легкие были уничтожены.") end
						end
					end
				end

				--lungs
				--and ent:LookupBone(bonename)==6 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(2, -4, -3), Vector(7, 4, 3))
					--[[if huy then
					if IsValid(RagdollOwner(ent)) then
						RagdollOwner(ent):Kill()
					elseif ent:IsPlayer() then
						ent:Kill()
					end
				end--]]
					--fuck simplicity
					--ply:ChatPrint("You were hit in the brain.")
					if huy then
						if ply.Organs["brain"] ~= 0 then
							ply.Organs["brain"] = math.Clamp(ply.Organs["brain"] - dmginfo:GetDamage(), 0, 20)
							if ply.Organs["brain"] == 0 then
								ply:ChatPrint("Твои мозги на вылет.")
							end
						end
					end
				end

				--brain
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-4, -1, -6), Vector(2, 5, -1))
					--ply:ChatPrint("You were hit in the liver.")
					if huy then
						if ply.Organs["liver"] ~= 0 then
							ply.Organs["liver"] = math.Clamp(ply.Organs["liver"] - dmginfo:GetDamage(), 0, 30)
							--if ply.Organs["liver"]==0 then ply:ChatPrint("Твоя печень была уничтожена.") end
						end
					end
				end

				--liver
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-4, -1, -1), Vector(2, 5, 6))
					--ply:ChatPrint("You were hit in the stomach.")
					if huy then
						if ply.Organs["stomach"] ~= 0 then
							ply.Organs["stomach"] = math.Clamp(ply.Organs["stomach"] - dmginfo:GetDamage(), 0, 40)
							--if ply.Organs["stomach"]==0 then ply:ChatPrint("Твой желудок был уничтожен.") end
						end
					end
				end

				--stomach
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-4, -1, -6), Vector(1, 5, 6))
					--ply:ChatPrint("You were hit in the intestines.")
					if huy then
						if ply.Organs["intestines"] ~= 0 then
							ply.Organs["intestines"] = math.Clamp(ply.Organs["intestines"] - dmginfo:GetDamage(), 0, 40)
							--if ply.Organs["intestines"]==0 then ply:ChatPrint("Твои кишечник был уничтожен.")end
						end
					end
				end

				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine2"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(1, 0, -1), Vector(5, 4, 3))
					--ply:ChatPrint("You were hit in the heart.")
					if huy then
						if ply.Organs["heart"] ~= 0 then
							ply.Organs["heart"] = math.Clamp(ply.Organs["heart"] - dmginfo:GetDamage(), 0, 10)
							--if ply.Organs["heart"]==0 then ply:ChatPrint("Твое сердце уничтожено.") end
						end
					end
				end

				--heart
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-3, -2, -2), Vector(0, -1, -1))
					local huy2 = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-3, -2, 1), Vector(0, -1, 2))
					--ply:ChatPrint("You were hit in the artery.")
					if huy or huy2 then
						if ply.Organs["artery"] ~= 0 then
							ply.Organs["artery"] = math.Clamp(ply.Organs["artery"] - dmginfo:GetDamage(), 0, 1)
							if ply.Organs["artery"] == 0 then
								if not ply.fake then
									Faking(ply)
								end
							end
						end
					end
				end

				--coronary artery
				--and ent:LookupBone(bonename)==2 then
				if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine4"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine4"))
					local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-8, -1, -1), Vector(2, 0, 1))
					local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local ang = matrix:GetAngles()
					local pos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Spine1"))
					local huy2 = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(), penetration, pos, ang, Vector(-8, -3, -1), Vector(2, -2, 1))
					--ply:ChatPrint("You were hit in the spine.")
					if huy or huy2 then
						if ply.Organs["spine"] ~= 0 then
							ply.Organs["spine"] = math.Clamp(ply.Organs["spine"] - dmginfo:GetDamage(), 0, 1)
							if ply.Organs["spine"] == 0 then
								if not ply.fake then
									Faking(ply)
									ply.brokenspine = true
									ply:ChatPrint("Твоя спина была сломана.")
								end
							end
						end
					end
				end
				--spine
			end

			--print(dmginfo:GetDamage())
			--print(hitgroup)
			if IsValid(RagdollOwner(ent)) then
				RagdollOwner(ent).LastHit = bonename
			elseif ent:IsPlayer() then
				ent.LastHit = bonename
			end
		end

		if IsValid(RagdollOwner(ent)) then
			if dmginfo:GetDamageType() == 1 then
				if dmginfo:GetAttacker():IsRagdoll() then
					RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health())
				else
					RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health() - dmginfo:GetDamage() / 100)
				end
			end

			RagdollOwner(ent):TakeDamageInfo(dmginfo)
			if RagdollOwner(ent):Health() <= 0 and RagdollOwner(ent):Alive() then
				RagdollOwner(ent):Kill()
			end
		end
	end
)

concommand.Add(
	"fake",
	function(ply)
		if timer.Exists("faketimer" .. ply:EntIndex()) then return nil end
		if ply:GetNWEntity("DeathRagdoll").isheld == true then return nil end
		if ply.brokenspine then return nil end
		if IsValid(ply:GetNWEntity("DeathRagdoll")) and ply:GetNWEntity("DeathRagdoll"):GetVelocity():Length() > 300 then return nil end
		if IsValid(ply:GetNWEntity("DeathRagdoll")) and table.Count(constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope")) > 0 then return nil end
		if ply.pain > (250 * (ply.Blood / 5000)) + (ply:GetNWInt("SharpenAMT") * 5) or ply.Blood < 3000 then return end
		timer.Create("faketimer" .. ply:EntIndex(), 2, 1, function() end)
		if ply:Alive() then
			Faking(ply)
			ply.fakeragdoll = ply:GetNWEntity("DeathRagdoll")
		end
	end
)

--все игроки встают после очистки карты
hook.Add(
	"PreCleanupMap",
	"cleannoobs",
	function()
		for i, v in ipairs(player.GetAll()) do
			if v.fake then
				Faking(v)
			end
		end

		BleedingEntities = {}
	end
)

--изменение функции регдолла
function PlayerMeta:CreateRagdoll(attacker, dmginfo)
	if not self:Alive() and self.fake then return nil end
	local rag = self:GetNWEntity("DeathRagdoll")
	if IsValid(rag.ZacConsLH) then
		rag.ZacConsLH:Remove()
		rag.ZacConsLH = nil
	end

	if IsValid(rag.ZacConsRH) then
		rag.ZacConsRH:Remove()
		rag.ZacConsRH = nil
	end

	local Data = duplicator.CopyEntTable(self)
	local rag = ents.Create("prop_ragdoll")
	duplicator.DoGeneric(rag, Data)
	rag:SetModel(self:GetModel())
	rag:SetColor(self:GetColor())
	rag:SetSkin(self:GetSkin())
	rag:BetterSetPlayerColor(self:GetPlayerColor())
	rag:Spawn()
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag:SetNWEntity("RagdollOwner", self)
	local vel = self:GetVelocity() / 1
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local physobj = rag:GetPhysicsObjectNum(i)
		local ragbonename = rag:GetBoneName(rag:TranslatePhysBoneToBone(i))
		local bone = self:LookupBone(ragbonename)
		if bone then
			local bonemat = self:GetBoneMatrix(bone)
			if bonemat then
				local bonepos = bonemat:GetTranslation()
				local boneang = bonemat:GetAngles()
				physobj:SetPos(bonepos, true)
				physobj:SetAngles(boneang)
				--УБРАТЬ ГОВНЕЦО ПОТОМ
				if not self:Alive() then
					vel = vel / 2
				end

				physobj:AddVelocity(vel)
			end
		end
	end

	if self:Alive() then
		self:SetNWEntity("DeathRagdoll", rag)
	else
		self:SetNWEntity("DeathRagdoll", rag)
		self.curweapon = self:GetActiveWeapon():GetClass()
		local guninfo = weapons.Get(self.curweapon)
		if guninfo.Base == "salat_base" then
			SpawnWeapon(self)
		end

		self:Spectate(OBS_MODE_ROAMING)
		self:SetMoveType(MOVETYPE_OBSERVER)
		rag:SetEyeTarget(vector_origin)
		if self.IsBleeding then
			rag.IsBleeding = true
		end

		rag.deadbody = true
	end
end

--проверка на скорость в фейке (для сбивания с ног других игроков)
hook.Add(
	"Think",
	"VelocityFakeHitPlyCheck",
	function()
		for i, rag in pairs(ents.FindByClass("prop_ragdoll")) do
			local ply = RagdollOwner(rag)
			if IsValid(ply) or rag.deadbody then
				if rag:GetVelocity():Length() > 250 then
					rag:SetCollisionGroup(COLLISION_GROUP_NONE)
					local trace = {
						start = rag:GetPos(),
						endpos = rag:GetPos() + rag:GetVelocity() / 4,
						filter = rag
					}

					local tr = util.TraceLine(trace)
					if tr.Entity == NULL or tr.Entity == rag or tr.Entity == Entity(0) then return nil end
					if tr.Entity:IsPlayer() and tr.Entity ~= RagdollOwner(rag) and tr.Entity.fake == false then
						Faking(tr.Entity)
					end
				else
					rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				end
			end
		end
	end
)

--проверка на скорость в фейке (для сбивания с ног других игроков)
hook.Add(
	"Think",
	"VelocityFakeHitPlyCheck",
	function()
		for i, rag in pairs(ents.FindByClass("prop_ragdoll")) do
			if IsValid(rag) then
				if rag:GetVelocity():Length() > 200 then
					rag:SetCollisionGroup(COLLISION_GROUP_NONE)
				else
					rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				end
			end
		end
	end
)

hook.Add(
	"PlayerInitialSpawn",
	"homigrad-addcallback",
	function(ply)
		ply:AddCallback(
			"PhysicsCollide",
			function(phys, data)
				hook.Run("Player Collide", ply, data.HitEntity, data)
			end
		)
	end
)

local gg = CreateConVar("hg_oldcollidefake", "0")
hook.Add(
	"Player Collide",
	"homigrad-fake",
	function(ply, hitEnt, data)
		--if not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not ply.fake and not hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 80 then
		if (not ply:HasGodMode() and data.Speed > 250) or (not gg:GetBool() and not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not ply.fake and not hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 250) then
			timer.Simple(
				0,
				function()
					if not IsValid(ply) or ply.fake then return end
					if hook.Run("Should Fake Collide", ply, hitEnt, data) == false then return end
					Faking(ply)
				end
			)
		end
	end
)

--управление в фейке
local dvec = Vector(0, 0, -64)
hook.Add(
	"Think",
	"FakeControl",
	function()
		for i, ply in ipairs(player.GetAll()) do
			ply.holdingartery = false
			local rag = ply:GetNWEntity("DeathRagdoll")
			if IsValid(rag) then
				ply:SetNWBool("fake", ply.fake)
				local deltatime = CurTime() - (rag.ZacLastCallTime or CurTime())
				rag.ZacLastCallTime = CurTime()
				local eyeangs = ply:EyeAngles()
				local head = rag:GetPhysicsObjectNum(10)
				rag:SetFlexWeight(9, 0)
				local dist = (rag:GetAttachment(rag:LookupAttachment("eyes")).Ang:Forward() * 10000):Distance(ply:GetAimVector() * 10000)
				local distmod = math.Clamp(1 - (dist / 20000), 0.1, 1)
				local lookat = LerpVector(distmod, rag:GetAttachment(rag:LookupAttachment("eyes")).Ang:Forward() * 100000, ply:GetAimVector() * 100000)
				local attachment = rag:GetAttachment(rag:LookupAttachment("eyes"))
				local LocalPos, LocalAng = WorldToLocal(lookat, angle_zero, attachment.Pos, attachment.Ang)
				local bone = rag:LookupBone("ValveBiped.Bip01_Head1")
				local head1 = rag:GetBonePosition(bone) + dvec
				ply:SetPos(head1)
				if not RagdollOwner(rag).Otrub then
					rag:SetEyeTarget(LocalPos)
				else
					rag:SetEyeTarget(vector_origin)
				end

				if RagdollOwner(rag):Alive() then
					if not RagdollOwner(rag).Otrub then
						if ply:KeyPressed(IN_JUMP) and table.Count(constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope")) > 0 and ply.stamina > 45 then
							local RopeCount = table.Count(constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope"))
							Ropes = constraint.FindConstraints(ply:GetNWEntity("DeathRagdoll"), "Rope")
							Try = math.random(1, 10 * RopeCount)
							ply.stamina = ply.stamina - 4 * (RopeCount / 6)
							local phys = rag:GetPhysicsObjectNum(1)
							local speed = 200
							local shadowparams = {
								secondstoarrive = 0.05,
								pos = phys:GetPos() + phys:GetAngles():Forward() * 20,
								angle = phys:GetAngles(),
								maxangulardamp = 30,
								maxspeeddamp = 30,
								maxangular = 90,
								maxspeed = speed,
								teleportdistance = 0,
								deltatime = 0.01,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
							if Try > (7 * RopeCount) then
								if RopeCount > 1 then
									ply:ChatPrint("Осталось веревок: " .. RopeCount - 1)
								else
									ply:ChatPrint("Ты развязался")
								end

								Ropes[1].Constraint:Remove()
								rag:EmitSound("snd_jack_hmcd_ducttape.wav", 90, 50, 0.5, CHAN_AUTO)
							end
						end

						if ply:KeyPressed(IN_RELOAD) then
							Reload(ply.wep)
						end

						if ply:KeyDown(IN_ATTACK) then
							if not ply.FakeShooting and not ply.arterybleeding then
								local phys = rag:GetPhysicsObjectNum(5)
								local ang = ply:EyeAngles()
								local shadowparams = {
									secondstoarrive = 0.5,
									pos = head:GetPos() + eyeangs:Forward() * (180 / math.Clamp(rag:GetVelocity():Length() / 300, 1, 6)),
									angle = ang,
									maxangulardamp = 100,
									maxspeeddamp = 10,
									maxspeed = 110,
									teleportdistance = 0,
									deltatime = deltatime,
								}

								phys:Wake()
								phys:ComputeShadowControl(shadowparams)
							end
						end

						local guninfo = weapons.Get(ply.curweapon)
						if guninfo and guninfo.Primary.Automatic then
							--KeyDown if an automatic gun
							if ply:KeyDown(IN_ATTACK) then
								if ply.FakeShooting then
									FireShot(ply.wep)
								end
							end
						else
							if ply:KeyPressed(IN_ATTACK) then
								if ply.FakeShooting then
									FireShot(ply.wep)
								end
							end
						end

						if ply:KeyDown(IN_ATTACK2) then
							local physa = rag:GetPhysicsObjectNum(7)
							local phys = rag:GetPhysicsObjectNum(5) --rhand
							local ang = ply:EyeAngles() --LerpAngle(0.5,ply:EyeAngles(),ply:GetNWEntity("DeathRagdoll"):GetAttachment(1).Ang)
							if ply.FakeShooting then
								ang:RotateAroundAxis(eyeangs:Forward(), 180)
							end

							local shadowparams = {
								secondstoarrive = 0.5,
								pos = head:GetPos() + eyeangs:Forward() * (180 / math.Clamp(rag:GetVelocity():Length() / 300, 1, 6)),
								angle = ang,
								maxangular = 370,
								maxangulardamp = 100,
								maxspeeddamp = 10,
								maxspeed = 110,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							physa:Wake()
							if not ply.suiciding or (guninfo and guninfo.TwoHands) then
								if guninfo and guninfo.TwoHands and IsValid(ply.wep) then
									shadowparams.angle:RotateAroundAxis(eyeangs:Up(), 45)
									shadowparams.pos = shadowparams.pos + eyeangs:Right() * 40
									shadowparams.pos = shadowparams.pos + eyeangs:Up() * 40
									shadowparams.angle:RotateAroundAxis(eyeangs:Forward(), -90)
									ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
									--shadowparams.maxspeed=20
									phys:ComputeShadowControl(shadowparams) --if 2handed
									shadowparams.pos = rag:GetPhysicsObjectNum(0):GetPos()
									shadowparams.angle = ang
									ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
								else
									physa:ComputeShadowControl(shadowparams)
								end
							else
								if ply.FakeShooting and IsValid(ply.wep) then
									shadowparams.maxspeed = 500
									shadowparams.maxangular = 500
									shadowparams.pos = head:GetPos() - ply.wep:GetAngles():Forward() * 12
									ply.wep:GetAngles():Right()
								elseif 5 then
									shadowparams.angle = ply.wep:GetPhysicsObject():GetAngles()
									ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
									physa:ComputeShadowControl(shadowparams)
								end
							end
							--[[physa:ComputeShadowControl(shadowparams)
			if TwoHandedOrNo[ply.curweapon] then
				shadowparams.maxspeed=90
				ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
				shadowparams.maxspeed=20
				shadowparams.angle:RotateAroundAxis(eyeangs:Forward(),90)
				phys:ComputeShadowControl(shadowparams) --if 2handed
			end--]]
						end

						if ply:KeyDown(IN_USE) then
							local phys = head
							local angs = ply:EyeAngles()
							angs:RotateAroundAxis(angs:Forward(), 90)
							angs:RotateAroundAxis(angs:Up(), 90)
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = head:GetPos() + vector_up * 20,
								angle = angs,
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 370,
								maxspeed = 40,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							head:Wake()
							head:ComputeShadowControl(shadowparams)
						end
					end

					if ply:KeyDown(IN_SPEED) and ply.stamina > 45 and not RagdollOwner(rag).Otrub then
						local bone = 5
						local phys = rag:GetPhysicsObjectNum(bone)
						if ply.arterybleeding and not TwoHandedOrNo[ply.curweapon] then
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = head:GetPos(),
								angle = angs,
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 370,
								maxspeed = 1120,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
							ply.holdingartery = true
							if IsValid(rag.ZacConsLH) then
								rag.ZacConsLH:Remove()
								rag.ZacConsLH = nil
							end
						end

						if not IsValid(rag.ZacConsLH) and (not rag.ZacNextGrLH or rag.ZacNextGrLH <= CurTime()) then
							rag.ZacNextGrLH = CurTime() + 0.1
							for i = 1, 2 do
								local offset = phys:GetAngles():Up() * -5
								if i == 2 then
									offset = phys:GetAngles():Right() * 5
								end

								local traceinfo = {
									start = phys:GetPos(),
									endpos = phys:GetPos() + offset,
									filter = rag,
									output = trace,
								}

								local trace = util.TraceLine(traceinfo)
								if trace.Hit and not trace.HitSky then
									local cons = constraint.Weld(rag, trace.Entity, bone, trace.PhysicsBone, 0, false, false)
									if IsValid(cons) then
										rag.ZacConsLH = cons
									end

									break
								end
							end
						end
					else
						if ply.arterybleeding then
							ply.holdingartery = false
						end

						if IsValid(rag.ZacConsLH) then
							rag.ZacConsLH:Remove()
							rag.ZacConsLH = nil
						end
					end

					if ply:KeyDown(IN_WALK) and ply.stamina > 45 and not RagdollOwner(rag).Otrub then
						local bone = 7
						local phys = rag:GetPhysicsObjectNum(bone)
						if not IsValid(rag.ZacConsRH) and (not rag.ZacNextGrRH or rag.ZacNextGrRH <= CurTime()) then
							rag.ZacNextGrRH = CurTime() + 0.1
							for i = 1, 2 do
								local offset = phys:GetAngles():Up() * 5
								if i == 2 then
									offset = phys:GetAngles():Right() * 5
								end

								local traceinfo = {
									start = phys:GetPos(),
									endpos = phys:GetPos() + offset,
									filter = rag,
									output = trace,
								}

								local trace = util.TraceLine(traceinfo)
								if trace.Hit and not trace.HitSky then
									local cons = constraint.Weld(rag, trace.Entity, bone, trace.PhysicsBone, 0, false, false)
									if IsValid(cons) then
										rag.ZacConsRH = cons
									end

									break
								end
							end
						end
					else
						if IsValid(rag.ZacConsRH) then
							rag.ZacConsRH:Remove()
							rag.ZacConsRH = nil
						end
					end

					if ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH) then
						local phys = rag:GetPhysicsObjectNum(1)
						local lh = rag:GetPhysicsObjectNum(5)
						local angs = ply:EyeAngles()
						angs:RotateAroundAxis(angs:Forward(), 90)
						angs:RotateAroundAxis(angs:Up(), 90)
						local speed = 45
						ply.stamina = ply.stamina - 0.02
						if rag.ZacConsLH.Ent2:GetVelocity():LengthSqr() < 1000 then
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = lh:GetPos(),
								angle = phys:GetAngles(),
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 50,
								maxspeed = speed,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
							--[[
				shadowparams.pos=phys:GetPos()+ply:EyeAngles():Right()*-300
				rag:GetPhysicsObjectNum( 11 ):Wake()
				rag:GetPhysicsObjectNum( 11 ):ComputeShadowControl(shadowparams)				-переделывай говно
				shadowparams.pos=phys:GetPos()-ply:EyeAngles():Forward()*300
				rag:GetPhysicsObjectNum( 9 ):Wake()
				rag:GetPhysicsObjectNum( 9 ):ComputeShadowControl(shadowparams)
				shadowparams.pos=lh:GetPos()
				--]]
							local angre = ply:EyeAngles()
							angre:RotateAroundAxis(ply:EyeAngles():Forward(), -90)
							shadowparams.angle = angre
							shadowparams.maxangular = 100
							shadowparams.pos = rag:GetPhysicsObjectNum(1):GetPos()
							shadowparams.secondstoarrive = 1
							rag:GetPhysicsObjectNum(0):Wake()
							rag:GetPhysicsObjectNum(0):ComputeShadowControl(shadowparams)
						end
					end

					if ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH) then
						local phys = rag:GetPhysicsObjectNum(1)
						local rh = rag:GetPhysicsObjectNum(7)
						local angs = ply:EyeAngles()
						angs:RotateAroundAxis(angs:Forward(), 90)
						angs:RotateAroundAxis(angs:Up(), 90)
						local speed = 45
						ply.stamina = ply.stamina - 0.02
						if rag.ZacConsRH.Ent2:GetVelocity():LengthSqr() < 1000 then
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = rh:GetPos(),
								angle = phys:GetAngles(),
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 50,
								maxspeed = speed,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
							--[[
				shadowparams.pos=phys:GetPos()+ply:EyeAngles():Right()*300
				rag:GetPhysicsObjectNum( 9 ):Wake()
				rag:GetPhysicsObjectNum( 9 ):ComputeShadowControl(shadowparams)				-переделывай говно
				shadowparams.pos=phys:GetPos()-ply:EyeAngles():Forward()*300
				rag:GetPhysicsObjectNum( 11 ):Wake()
				rag:GetPhysicsObjectNum( 11 ):ComputeShadowControl(shadowparams)
				shadowparams.pos=rh:GetPos()
				--]]
							local angre2 = ply:EyeAngles()
							angre2:RotateAroundAxis(ply:EyeAngles():Forward(), 90)
							shadowparams.angle = angre2
							shadowparams.maxangular = 100
							shadowparams.pos = rag:GetPhysicsObjectNum(1):GetPos()
							shadowparams.secondstoarrive = 1
							rag:GetPhysicsObjectNum(0):Wake()
							rag:GetPhysicsObjectNum(0):ComputeShadowControl(shadowparams)
						end
					end

					if ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsLH) then
						local phys = rag:GetPhysicsObjectNum(1)
						local chst = rag:GetPhysicsObjectNum(0)
						local angs = ply:EyeAngles()
						angs:RotateAroundAxis(angs:Forward(), 90)
						angs:RotateAroundAxis(angs:Up(), 90)
						local speed = 45
						ply.stamina = ply.stamina - 0.02
						if rag.ZacConsLH.Ent2:GetVelocity():LengthSqr() < 1000 then
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = chst:GetPos(),
								angle = phys:GetAngles(),
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 50,
								maxspeed = speed,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
						end
					end

					if ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsRH) then
						local phys = rag:GetPhysicsObjectNum(1)
						local chst = rag:GetPhysicsObjectNum(0)
						local angs = ply:EyeAngles()
						angs:RotateAroundAxis(angs:Forward(), 90)
						angs:RotateAroundAxis(angs:Up(), 90)
						local speed = 45
						ply.stamina = ply.stamina - 0.02
						if rag.ZacConsRH.Ent2:GetVelocity():LengthSqr() < 1000 then
							local shadowparams = {
								secondstoarrive = 0.5,
								pos = chst:GetPos(),
								angle = phys:GetAngles(),
								maxangulardamp = 10,
								maxspeeddamp = 10,
								maxangular = 50,
								maxspeed = speed,
								teleportdistance = 0,
								deltatime = deltatime,
							}

							phys:Wake()
							phys:ComputeShadowControl(shadowparams)
						end
					end
				end
			end
		end
	end
)

hook.Add(
	"Think",
	"VelocityPlayerFallOnPlayerCheck",
	function()
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetVelocity():Length() > 600 and ply:Alive() and not ply.fake and not ply:HasGodMode() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
				Faking(ply)
			end
		end
	end
)

physenv.SetPerformanceSettings(
	{
		MaxVelocity = 99999
	}
)

physenv.SetAirDensity(2)
hook.Add(
	"EntityTakeDamage",
	"LastAttacker",
	function(ent, dmginfo)
		local attacker = dmginfo:GetAttacker()
		local ply = RagdollOwner(ent)
		if ent:IsPlayer() and attacker:IsPlayer() then
			ent.Attacker = attacker:Nick()
			ent.AttackerEnt = attacker
		elseif IsValid(ply) and attacker:IsPlayer() then
			ply.Attacker = attacker:Nick()
			ply.AttackerEnt = attacker
		elseif IsValid(ply) and attacker == ply.wep then
			-- сделать по-другому (тут только если ты себя убиваешь)
			ply.Attacker = ply:Nick()
			ply.AttackerEnt = attacker
		end
	end
)

concommand.Add(
	"suicide",
	function(ply)
		if not ply:Alive() then return nil end
		ply.suiciding = not ply.suiciding
	end
)

hook.Add(
	"PlayerSwitchWeapon",
	"fakewep",
	function(ply, oldwep, newwep)
		if ply.Otrub then return true end
		if ply.fake then
			if IsValid(ply.Info.ActiveWeapon2) and IsValid(ply.wep) then
				ply.Info.ActiveWeapon2:SetClip1(ply.wep.Clip)
				ply:SetAmmo(ply.wep.Amt, ply.wep.AmmoType)
			end

			local guninfo = weapons.Get(newwep:GetClass())
			if guninfo.Base == "salat_base" then
				if IsValid(ply.wep) then
					DespawnWeapon(ply)
				end

				ply:SetActiveWeapon(newwep)
				ply.Info.ActiveWeapon = newwep
				ply.curweapon = newwep
				SavePlyInfo(ply)
				ply:SetActiveWeapon(nil)
				SpawnWeapon(ply)
				ply.FakeShooting = true
			else
				if IsValid(ply.wep) then
					DespawnWeapon(ply)
				end

				ply:SetActiveWeapon(nil)
				ply.curweapon = newwep
				ply.FakeShooting = false
			end

			return true
		end
	end
)

function PlayerMeta:HuySpectate()
	local ply = self
	ply:Spectate(OBS_MODE_ROAMING)
	ply:UnSpectate()
	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end

OrgansNextThink = 0
InternalBleeding = 10
hook.Add(
	"Think",
	"InternalBleeding",
	function()
		for i, ply in ipairs(player.GetAll()) do
			ply.OrgansNextThink = ply.OrgansNextThink or OrgansNextThink
			if not (ply.OrgansNextThink > CurTime()) then
				ply.OrgansNextThink = CurTime() + 0.2
				--print(ply) PrintTable(ply.Organs)
				if ply.Organs and ply:Alive() then
					if ply.Organs["brain"] == 0 then
						ply:Kill()
					end

					if ply.Organs["liver"] == 0 then
						ply.InternalBleeding = ply.InternalBleeding or InternalBleeding
						ply.InternalBleeding = math.Clamp(ply.InternalBleeding - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding
					end

					if ply.Organs["stomach"] == 0 then
						ply.InternalBleeding2 = ply.InternalBleeding2 or InternalBleeding
						ply.InternalBleeding2 = math.Clamp(ply.InternalBleeding2 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding2
					end

					if ply.Organs["intestines"] == 0 then
						ply.InternalBleeding3 = ply.InternalBleeding3 or InternalBleeding
						ply.InternalBleeding3 = math.Clamp(ply.InternalBleeding3 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding3
					end

					if ply.Organs["heart"] == 0 then
						ply.InternalBleeding4 = ply.InternalBleeding4 or InternalBleeding
						--print(ply.InternalBleeding4)
						ply.InternalBleeding4 = math.Clamp(ply.InternalBleeding4 * 10 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding4 * 3
					end

					if ply.Organs["lungs"] == 0 then
						ply.InternalBleeding5 = ply.InternalBleeding5 or InternalBleeding
						ply.InternalBleeding5 = math.Clamp(ply.InternalBleeding5 - 0.1, 0, 10)
						--print(ply.InternalBleeding, ply.Blood)
						ply.Blood = ply.Blood - ply.InternalBleeding5
					end

					if ply.Organs["spine"] == 0 then
						ply.brokenspine = true
						if not ply.fake then
							Faking(ply)
						end
					end

					if ply.Organs["artery"] == 0 then
						ply.arterybleeding = true
					else
						ply.arterybleeding = false
					end

					--print(ply.Blood)
					if ply.Blood and ply.Blood <= 2000 and ply:Alive() or ply.pain and ply.pain > 950 and ply:Alive() then
						ply:ExitVehicle()
						ply:Kill()
						ply.Bloodlosing = 0
						ply:SetNWInt("BloodLosing", 0)
					end
				end
			end
		end
	end
)

hook.Add(
	"PlayerUse",
	"nouseinfake",
	function(ply)
		if ply.fake then return false end
	end
)

hook.Add(
	"PlayerSay",
	"dropweaponhuy",
	function(ply, text)
		if string.lower(text) == "*drop" then
			if not ply.fake then
				ply:DropWeapon()

				return ""
			else
				if IsValid(ply.wep) then
					if IsValid(ply.WepCons) then
						ply.WepCons:Remove()
						ply.WepCons = nil
					end

					if IsValid(ply.WepCons2) then
						ply.WepCons2:Remove()
						ply.WepCons2 = nil
					end

					ply.wep.canpickup = true
					ply.wep:SetOwner()
					ply.wep.curweapon = ply.curweapon
					ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
					ply:StripWeapon(ply.Info.ActiveWeapon)
					ply.Info.Weapons[ply.Info.ActiveWeapon] = nil
					ply.wep = nil
					ply.Info.ActiveWeapon = nil
					ply.Info.ActiveWeapon2 = nil
					ply:SetActiveWeapon(nil)
					ply.FakeShooting = false
				else
					ply:PickupEnt()
				end

				return ""
			end
		end
	end
)