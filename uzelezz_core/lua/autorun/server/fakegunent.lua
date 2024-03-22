local Guns = {"glock18", "glock", "p220", "mp5", "ar15", "ak74", "akm", "fiveseven", "hk_usp", "deagle", "magnum", "beretta", "ak74u", "l1a1", "fal", "galil", "galilsar", "m14", "m1a1", "mk18", "m249", "m4a1", "minu14", "mp40", "rpk", "ump", "hk_usps", "m3super",}
local Vectors = {
	["glock18"] = Vector(4, -1, 2.5),
	["glock"] = Vector(4, -1, 2.5),
	["glock"] = Vector(4, -1, 2.5),
	["p220"] = Vector(4, -1.2, 2),
	["mp5"] = Vector(3, -1, 2.5),
	["ar15"] = Vector(3, -1, 0),
	["ak74"] = Vector(5, -2, 0),
	["akm"] = Vector(3, -2, 0),
	["fiveseven"] = Vector(3.2, -1, 1.8),
	["hk_usp"] = Vector(4, -1.2, 2),
	["deagle"] = Vector(4, -1.2, 2),
	["magnum"] = Vector(4, -1.2, -2),
	["beretta"] = Vector(2, -1, 2),
	["ak74u"] = Vector(3, -2, 2),
	["l1a1"] = Vector(3, -2, 2),
	["fal"] = Vector(3, -2, 2),
	["galil"] = Vector(3, -2, 2),
	["galilsar"] = Vector(3, -2, 2),
	["m14"] = Vector(3, -2, 2),
	["m1a1"] = Vector(3, -2, 2),
	["mk18"] = Vector(3, -1, 0),
	["m249"] = Vector(3, -1, 0),
	["m4a1"] = Vector(3, -1, 0),
	["minu14"] = Vector(1, -1, 0),
	["mp40"] = Vector(2, -1, 0),
	["rpk"] = Vector(3, -1, 0),
	["ump"] = Vector(2, -1, 0),
	["m3super"] = Vector(14, -2, 0),
	["hk_usps"] = Vector(4, -1.2, 2),
}

local Vectors2 = {
	["mp5"] = Vector(7, -1, -2.5),
	["ar15"] = Vector(9, -2, -4),
	["act3_m249"] = Vector(10, -1, -6),
	["ak74"] = Vector(12, -3, -5),
	["akm"] = Vector(12, -3, -5),
	["ak74u"] = Vector(12, -3, -3),
	["l1a1"] = Vector(15, -2, -3),
	["fal"] = Vector(15, -2, -3),
	["galil"] = Vector(15, -3, -3),
	["galilsar"] = Vector(15, -3, -3),
	["m14"] = Vector(15, -3, -3.7),
	["m1a1"] = Vector(15, -3, -3.7),
	["mk18"] = Vector(9, -2, -4),
	["m249"] = Vector(11, -2, -4),
	["m4a1"] = Vector(9, -2, -4),
	["minu14"] = Vector(9, -2, -4),
	["mp40"] = Vector(12, -1, -4),
	["rpk"] = Vector(12, -2, -5),
	["ump"] = Vector(12, -1, -4),
	["m3super"] = Vector(16, -3.5, -6),
}

local vecZero = Vector(0, 0, 0)
function SpawnWeapon(ply)
	local guninfo = weapons.Get(ply.curweapon)
	if guninfo.Base ~= "salat_base" then return end
	if not IsValid(ply.wep) then
		local rag = ply:GetNWEntity("DeathRagdoll")
		if IsValid(rag) then
			ply.FakeShooting = true
			ply.wep = ents.Create("wep")
			ply.wep:SetModel(guninfo.WorldModel)
			ply.wep:SetOwner(ply)
			local vec1 = rag:GetPhysicsObjectNum(7):GetPos()
			local vec2 = vecZero
			vec2:Set(guninfo.fakeHandRight)
			vec2:Rotate(rag:GetPhysicsObjectNum(7):GetAngles())
			ply.wep:SetPos(vec1 + vec2)
			ply.wep:SetAngles(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand"))):GetAngles() - Angle(0, 0, 180))
			ply.wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ply.wep:Spawn()
			ply.wep:GetPhysicsObject():SetMass(0)
			--ply.wep.GunInfo = guninfo
			CheckAmmo(ply, ply.wep)
			if not IsValid(ply.WepCons) then
				local cons = constraint.Weld(ply.wep, rag, 0, 7, 0, true)
				if IsValid(cons) then
					ply.WepCons = cons
				end
			end

			ply.wep.curweapon = ply.curweapon
			ply:SetNWString("FakeWep", ply.curweapon)
			if guninfo.TwoHands then
				--[[local vec1 = rag:GetPhysicsObjectNum(7):GetPos()
				local vec22 = guninfo.fakeHandLeft
				vec22:Rotate(rag:GetPhysicsObjectNum(7):GetAngles())
				rag:GetPhysicsObjectNum(5):SetPos(vec1 + vec22)
				rag:GetPhysicsObjectNum(5):SetAngles(ply:GetNWEntity("DeathRagdoll"):GetPhysicsObjectNum(7):GetAngles() - Angle(0, 0, 180))
				if not IsValid(ply.WepCons2) then
					local cons2 = constraint.Weld(ply.wep, rag, 0, 5, 0, true) --2hand constraint
					if IsValid(cons2) then
						ply.WepCons2 = cons2
					end
				end]]
				--
				ply.wep:GetPhysicsObject():SetMass(1)
				local vec1 = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand"))):GetPos()
				local vec22 = vecZero
				vec22:Set(guninfo.fakeHandLeft)
				vec22:Rotate(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand"))):GetAngles())
				rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand"))):SetPos(vec1 + vec22)
				rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand"))):SetAngles(rag:GetPhysicsObjectNum(7):GetAngles() - Angle(0, 0, 180))
				if not IsValid(ply.WepCons2) then
					local cons2 = constraint.Weld(ply.wep, rag, 0, rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")), 0, true) --2hand constraint
					if IsValid(cons2) then
						ply.WepCons2 = cons2
					end
				end
			end
		end
	end
end

function DespawnWeapon(ply)
	ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
	ply.Info.ActiveWeapon2 = ply.curweapon
	--if ply:Alive() and !ply.wep.pickable then
	if IsValid(ply.wep) and ply:Alive() then
		ply.wep:Remove()
		ply.wep = nil
	elseif IsValid(ply.wep) and not ply:Alive() then
		ply.wep.canpickup = true
		ply.wep:SetOwner(nil)
		ply.wep.curweapon = ply.curweapon
		ply.wep = nil
	end

	if IsValid(ply.WepCons) and ply:Alive() then
		ply.WepCons:Remove()
		ply.WepCons = nil
	elseif IsValid(ply.WepCons) then
		ply.WepCons = nil
	end

	if IsValid(ply.WepCons2) and ply:Alive() then
		ply.WepCons2:Remove()
		ply.WepCons2 = nil
	elseif IsValid(ply.WepCons2) then
		ply.WepCons2 = nil
	end

	ply.FakeShooting = false
	--[[else
		ply.wep.pickable=true
		ply.wep=nil
		ply.FakeShooting=false
	end--]]
end

function CheckAmmo(ply, wep)
	local guninfo = weapons.Get(ply.curweapon)
	if ply:Alive() then
		wep.Clip = ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1
		wep.MaxClip = guninfo.Primary.ClipSize
		--print(ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType()))
		wep.Amt = ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType())
		wep.AmmoType = ply.Info.ActiveWeapon2:GetPrimaryAmmoType()
	else
		wep.Clip = ply:GetActiveWeapon():Clip1()
		wep.AmmoType = ply:GetActiveWeapon():GetPrimaryAmmoType()
		--print(wep.Clip, wep.AmmoType)
	end
end

function SpawnWeaponEnt(weapon, pos, ply)
	local wep = ents.Create("wep")
	local guninfo = weapons.Get(weapon)
	wep:SetModel(guninfo.WorldModel)
	wep:SetPos(pos)
	wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	wep:Spawn()
	wep:SetAngles(ply:EyeAngles())
	wep:GetPhysicsObject():ApplyForceOffset(VectorRand(-2, 2), wep:GetPos())
	wep.curweapon = ply.curweapon
	wep.Clip = ply.Clip
	wep.AmmoType = ply.AmmoType
	wep.canpickup = true

	return wep
end

function Reload(wep)
	if not IsValid(wep) then return nil end
	local ply = wep:GetOwner()
	local guninfo = weapons.Get(ply.curweapon)
	if not timer.Exists("reload" .. wep:EntIndex()) and wep.Clip ~= wep.MaxClip and wep.Amt > 0 then
		wep:EmitSound(guninfo.ReloadSound, 85, 100, 1)
		timer.Create(
			"reload" .. wep:EntIndex(),
			guninfo.ReloadTime,
			1,
			function()
				if IsValid(wep) then
					local oldclip = wep.Clip
					wep.Clip = math.Clamp(wep.Clip + wep.Amt, 0, wep.MaxClip)
					local needed = wep.Clip - oldclip
					wep.Amt = wep.Amt - needed
					ply.Info.Ammo[wep.AmmoType] = wep.Amt
					--print(ply.Info.Ammo[wep.AmmoType])
				end
			end
		)
	end
end

local NextShot = 0
local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
SIB_SurfaceHardness = SIB_SurfaceHardness or {
	[MAT_METAL] = .95,
	[MAT_COMPUTER] = .95,
	[MAT_VENT] = .95,
	[MAT_GRATE] = .95,
	[MAT_FLESH] = .5,
	[MAT_ALIENFLESH] = .3,
	[MAT_SAND] = .1,
	[MAT_DIRT] = .3,
	[74] = .1,
	[85] = .2,
	[MAT_WOOD] = .5,
	[MAT_FOLIAGE] = .5,
	[MAT_CONCRETE] = .9,
	[MAT_TILE] = .8,
	[MAT_SLOSH] = .05,
	[MAT_PLASTIC] = .3,
	[MAT_GLASS] = .6
}

function FireShot(wep)
	if not IsValid(wep) then return nil end
	if wep.Clip <= 0 then return nil end
	if timer.Exists("reload" .. wep:EntIndex()) then return nil end
	wep.NextShot = wep.NextShot or NextShot
	if wep.NextShot > CurTime() then return end
	function wep:BulletCallbackFunc(dmgAmt, ply, tr, dmg, tracer, hard, multi)
		if tr.MatType == MAT_FLESH then
			util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			local vPoint = tr.HitPos
			local effectdata = EffectData()
			effectdata:SetOrigin(vPoint)
			util.Effect("BloodImpact", effectdata)
		end

		if weapons.Get(wep.curweapon).NumBullet or 1 > 1 then return end
		if tr.HitSky then return end
		if hard then
			self:RicochetOrPenetrate(tr)
		end
	end

	function wep:RicochetOrPenetrate(initialTrace)
		local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, SIB_SurfaceHardness[initialTrace.MatType]
		if not SMul then
			SMul = .5
		end

		local ApproachAngle = -math.deg(math.asin(TNorm:DotProduct(AVec)))
		local MaxRicAngle = 60 * SMul
		-- all the way through
		if ApproachAngle > (MaxRicAngle * 1.25) then
			local MaxDist, SearchPos, SearchDist, Penetrated = ((weapons.Get(wep.curweapon).Primary.Damage / 10) / SMul) * .15, IPos, 5, false
			while (not Penetrated) and (SearchDist < MaxDist) do
				SearchPos = IPos + AVec * SearchDist
				local PeneTrace = util.QuickTrace(SearchPos, -AVec * SearchDist)
				if (not PeneTrace.StartSolid) and PeneTrace.Hit then
					Penetrated = true
				else
					SearchDist = SearchDist + 5
				end
			end

			if Penetrated then
				self:FireBullets(
					{
						Attacker = self:GetOwner(),
						Damage = 1,
						Force = 1,
						Num = 1,
						Tracer = 0,
						TracerName = "",
						Dir = -AVec,
						Spread = Vector(0, 0, 0),
						Src = SearchPos + AVec
					}
				)

				self:FireBullets(
					{
						Attacker = self:GetOwner(),
						Damage = weapons.Get(wep.curweapon).Primary.Damage * .65,
						Force = (weapons.Get(wep.curweapon).Primary.Force / 20) / 40 * .65,
						Num = 1,
						Tracer = 0,
						TracerName = "",
						Dir = AVec,
						Spread = Vector(0, 0, 0),
						Src = SearchPos + AVec
					}
				)
			end
		elseif ApproachAngle < (MaxRicAngle * .75) then
			-- ping whiiiizzzz
			if math.random(1, 5) <= 2 then return end
			sound.Play("salatbase/ricochet/ricochet" .. math.random(1, 12) .. ".wav", IPos, 70, math.random(90, 100))
			local NewVec = AVec:Angle()
			NewVec:RotateAroundAxis(TNorm, 180)
			NewVec = NewVec:Forward()
			self:FireBullets(
				{
					Attacker = self:GetOwner(),
					Damage = weapons.Get(wep.curweapon).Primary.Damage * .85,
					Force = (weapons.Get(wep.curweapon).Primary.Force / 20) / 60,
					Num = 1,
					Tracer = 0,
					TracerName = "",
					Dir = -NewVec,
					Spread = Vector(0, 0, 0),
					Src = IPos + TNorm
				}
			)
		end
	end

	local ply = wep:GetOwner()
	local guninfo = weapons.Get(ply.curweapon)
	wep.NextShot = CurTime() + guninfo.ShootWait
	local Attachment = wep:GetAttachment(1)
	local shootOrigin = Attachment.Pos
	local vec = vecZero
	vec:Rotate(Attachment.Ang)
	shootOrigin:Add(vec)
	local shootAngles = Attachment.Ang
	local ang = angZero
	shootAngles:Add(ang)
	local shootDir = shootAngles:Forward()
	local bullet = {}
	bullet.Num = guninfo.NumBullet or 1
	bullet.Src = shootOrigin
	bullet.Dir = shootDir
	bullet.Spread = Vector(guninfo.Primary.Cone, guninfo.Primary.Cone, 0)
	bullet.Tracer = 1
	bullet.TracerName = 4
	bullet.Force = guninfo.Primary.Force / 20
	bullet.Damage = guninfo.Primary.Damage
	bullet.Attacker = ply
	bullet.Callback = function(ply, tr)
		wep:BulletCallbackFunc(damage, ply, tr, damage, false, true, false)
	end

	--[[local bullet = {}
		bullet.Num 			= 1
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= 0.05
		bullet.Tracer		= guninfo.Trace
		bullet.TracerName 	= nil
		bullet.Force		= 10
		bullet.Damage		= guninfo.Damage
		bullet.Attacker 	= ply
	--]]
	wep:FireBullets(bullet)
	wep.GetSound = guninfo.Primary.Sound
	wep:EmitSound(wep.GetSound, 85, 100, 1, CHAN_WEAPON)
	wep:GetPhysicsObject():ApplyForceCenter(wep:GetAngles():Forward() * -250 + wep:GetAngles():Right() * VectorRand(-90, 90) + wep:GetAngles():Up() * 100) --сделать зависимым от force потом
	wep.Clip = wep.Clip - 1
	-- Make a muzzle flash
	if guninfo.DoFlash then
		local ef = EffectData()
		ef:SetEntity(wep)
		ef:SetAttachment(1) -- self:LookupAttachment( "muzzle" )
		ef:SetFlags(1) -- Sets the Combine AR2 Muzzle flash
		util.Effect("MuzzleFlash", ef)
	end
end