local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local function removeBone(rag,bone,phys_bone)
	rag:ManipulateBoneScale(bone,vecZero)
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.1)
	--rag:RemoveInternalConstraint(phys_bone)

	constraint.RemoveAll(phys_obj)
	rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag,bone,list)
	for i,bone in pairs(rag:GetChildBones(bone)) do
		if bone == 0 then continue end--wtf

		list[#list + 1] = bone

		recursive_bone(rag,bone,list)
	end

end

function Gib_RemoveBone(rag,bone,phys_bone)
	rag.gibRemove = rag.gibRemove or {}

	removeBone(rag,bone,phys_bone)

	local list = {}
	recursive_bone(rag,bone,list)
	for i,bone in pairs(list) do
		removeBone(rag,bone,rag:TranslateBoneToPhysBone(bone))
	end
end

concommand.Add("removebone",function(ply)
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity
	if not IsValid(ent) then return end

	local phys_bone = trace.PhysicsBone
	if not phys_bone or phys_bone == 0 then return end

	Gib_RemoveBone(ent,ent:TranslatePhysBoneToBone(phys_bone),phys_bone)
end)

gib_ragdols = gib_ragdols or {}
local gib_ragdols = gib_ragdols

local validHitGroup = {
	[HITGROUP_LEFTARM] = true,
	[HITGROUP_RIGHTARM] = true,
	[HITGROUP_LEFTLEG] = true,
	[HITGROUP_RIGHTLEG] = true,
}

local Rand = math.Rand

local validBone = {
	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true ,
	["ValveBiped.Bip01_R_Hand"] = true,
	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,

	["ValveBiped.Bip01_L_Thigh"] = true,
	["ValveBiped.Bip01_L_Calf"] = true,
	["ValveBiped.Bip01_L_Foot"] = true,
	["ValveBiped.Bip01_R_Thigh"] = true,
	["ValveBiped.Bip01_R_Calf"] = true,
	["ValveBiped.Bip01_R_Foot"] = true
}

function Gib_Input(rag,bone,dmgInfo)
	if not IsValid(rag) then return end

	local hitgroup = bonetohitgroup[rag:GetBoneName(bone)]

	local gibRemove = rag.gibRemove
	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove

		gib_ragdols[rag] = true

		if not dmgInfo:IsDamageType(DMG_CRUSH) then
			rag.Blood = rag.Blood or 5000
			rag.BloodNext = 0
			rag.BloodGibs = {}
		end
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)

	local dmgPos = dmgInfo:GetDamagePosition()

	if dmgInfo:GetDamage() >= 50 and dmgInfo:IsDamageType(DMG_BLAST) then
	local bone = rag:LookupBone("ValveBiped.Bip01_Spine3")
	if bone and rag:GetPhysicsObjectNum(bone):Distance(dmgPos) <= 75 then
		sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2,4) .. ".wav")
		sound.Emit(rag,"physics/body/body_medium_break3.wav")
		sound.Emit(rag,"physics/flesh/flesh_bloody_break.wav",nil,75)

		BloodParticleExplode(rag:GetPhysicsObject(phys_bone):GetPos())

		--rag:Remove()

		return
	end
	end

	if hitgroup == HITGROUP_HEAD and not dmgInfo:IsDamageType(DMG_CRUSH) and not gibRemove[phys_bone] then
		sound.Emit(rag,"player/headshot" .. math.random(1,2) .. ".wav")
		sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2,4) .. ".wav")
		sound.Emit(rag,"physics/body/body_medium_break3.wav")
		sound.Emit(rag,"physics/glass/glass_sheet_step" .. math.random(1,4) .. ".wav",90,50,2)

		timer.Simple(0.05,function()
			if not IsValid(rag) then return end

			rag:EmitSound("physics/flesh/flesh_bloody_break.wav",90,75,2)
		end)

		Gib_RemoveBone(rag,bone,phys_bone)

		BloodParticleHeadshoot(rag:GetPhysicsObject(phys_bone):GetPos(),dmgInfo:GetDamageForce() * 2)
	end

	if dmgInfo:GetDamage() >= 50 and dmgInfo:IsDamageType(DMG_BLAST) and not gibRemove[phys_bone] then
		local access
		for bonename in pairs(validBone) do
			local bone = rag:LookupBone(bonename)
			if not bone then continue end--lol???????????????

			if rag:GetBonePosition(bone):Distance(dmgPos) <= 75 then access = true break end
		end

		if access then
			sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2,4) .. ".wav")
			sound.Emit(rag,"physics/body/body_medium_break3.wav")
			sound.Emit(rag,"physics/flesh/flesh_bloody_break.wav",nil,75)

			Gib_RemoveBone(rag,bone,phys_bone)

			BloodParticleMore(rag:GetPhysicsObject(phys_bone):GetPos(),dmgInfo:GetDamageForce() * 10)
		end
	end
	rag:GetPhysicsObject():SetMass(20)
end

hook.Add("PlayerDeath","Gib",function(ply)
	dmgInfo = ply.LastDMGInfo
	if not dmgInfo then return end

	--разве это не смешно когда ножом башка взрывается?
	--нет
	
	if dmgInfo:GetDamage() >= 350 then
		timer.Simple(0,function()
			local rag = ply:GetNWEntity("Ragdoll")
			local bone = rag:LookupBone(ply.LastHitBoneName)

			if not IsValid(rag) or not bone then return end--неебу как пашол нахуй

			Gib_Input(rag,bone,dmgInfo)
		end)
	end
end)

hook.Add("EntityTakeDamage","Gib",function(ent,dmgInfo)
	if not ent:IsRagdoll() then return end
	
	local ply = RagdollOwner(ent)
	ply = ply and ply:Alive() and ply
	if ply then return end
	
	local phys_bone = GetPhysicsBoneDamageInfo(ent,dmgInfo)
	if phys_bone == 0 then return end--lol

	local hitgroup

	local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(phys_bone))

	if bonetohitgroup[bonename] then hitgroup = bonetohitgroup[bonename] end

	local mul = RagdollDamageBoneMul[hitgroup]
	
	if dmgInfo:GetDamage() * mul < 350 then return end
	
	Gib_Input(ent,ent:TranslatePhysBoneToBone(phys_bone),dmgInfo)
end)

local max = math.max
local util_TraceLine = util.TraceLine
local util_Decal = util.Decal

local tr = {}

hook.Add("Think","Gib",function()
	local time = CurTime()

	for ent in pairs(gib_ragdols) do
		if not IsValid(ent) then gib_ragdols[ent] = nil continue end

		if ent.BloodGibs and ent.Blood > 0 then
			local k = ent.Blood / 5000

			if (ent.BloodNext or 0) < time then
				ent.BloodNext = time + Rand(0.25,0.5) / max(k,0.25)
				ent.Blood = max(ent.Blood - 25,0)

				tr.start = ent:GetPos()
				tr.endpos = tr.start + Vector(Rand(-1,1),Rand(-1,1),-Rand(0.25,0.4)) * 125 * Rand(0.8,1.2)
				tr.filter = ent

				local traceResult = util_TraceLine(tr)
				if traceResult.Hit then
					ent:EmitSound("ambient/water/drip" .. math.random(1,4) .. ".wav", 60,math.random(230,240),0.1,CHAN_AUTO)

					util_Decal("Blood",traceResult.HitPos + traceResult.HitNormal,traceResult.HitPos - traceResult.HitNormal,ply)
				else
					BloodParticle(ent:GetPos() + ent:OBBCenter(),ent:GetVelocity() + Vector(math.Rand(-5,5),math.Rand(-5,5),0))
				end
			end

			local BloodGibs = ent.BloodGibs

			for phys_bone,phys_obj in pairs(ent.gibRemove) do
				if (BloodGibs[phys_bone] or 0) < time then
					ent.Blood = max(ent.Blood - 25,0)

					BloodGibs[phys_bone] = time + Rand(0.07,0.1) / max(k,0.25)

					BloodParticle(phys_obj:GetPos(),phys_obj:GetVelocity() + phys_obj:GetAngles():Forward() * Rand(200,250) * k)
				end
			end
		end
	end
end)