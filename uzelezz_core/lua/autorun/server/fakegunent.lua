

function SpawnWeapon(ply)
	bullets = {
		["m3super"] = 8,
	}
	cir = {
		["m3super"] = 0.02,
	}

	Vectors = {
	["glock18"]=Vector(4,-1,2.5),
	["p220"]=Vector(4,-1.2,2),
	["mp5"]=Vector(3,-1,2.5),
	["ar15"]=Vector(3,-1,0),
	["ak74"]=Vector(5,-2,0),
	["akm"]=Vector(3,-2,0),
	["fiveseven"]=Vector(3.2,-1,1.8),
	["hk_usp"]=Vector(4,-1.2,2),
	["deagle"]=Vector(4,-1.2,2),
	["beretta"]=Vector(2,-1,2),
	["ak74u"]=Vector(3,-2,2),
	["l1a1"]=Vector(3,-2,2),
	["fal"]=Vector(3,-2,2),
	["galil"]=Vector(3,-2,2),
	["galilsar"]=Vector(3,-2,2),
	["m14"]=Vector(3,-2,2),
	["m1a1"]=Vector(3,-2,2),
	["mk18"]=Vector(3,-1,0),
	["m249"]=Vector(3,-1,0),
	["m4a1"]=Vector(3,-1,0),
	["minu14"]=Vector(1,-1,0),
	["mp40"]=Vector(2,-1,0),
	["rpk"]=Vector(3,-1,0),
	["ump"]=Vector(2,-1,0),
	["m3super"]=Vector(14,-2,0),
	["hk_usps"]=Vector(4,-1.2,2),
	}

	Vectors2 = {
	["mp5"]=Vector(7,-1,-2.5),
	["ar15"]=Vector(9,-2,-4),
	["act3_m249"]=Vector(10,-1,-6),
	["ak74"]=Vector(12,-3,-5),
	["akm"]=Vector(12,-3,-5),
	["ak74u"]=Vector(12,-3,-3),
	["l1a1"]=Vector(15,-2,-3),
	["fal"]=Vector(15,-2,-3),
	["galil"]=Vector(15,-3,-3),
	["galilsar"]=Vector(15,-3,-3),
	["m14"]=Vector(15,-3,-3.7),
	["m1a1"]=Vector(15,-3,-3.7),
	["mk18"]=Vector(9,-2,-4),
	["m249"]=Vector(11,-2,-4),
	["m4a1"]=Vector(9,-2,-4),
	["minu14"]=Vector(9,-2,-4),
	["mp40"]=Vector(12,-1,-4),
	["rpk"]=Vector(12,-2,-5),
	["ump"]=Vector(12,-1,-4),
	["m3super"]=Vector(16,-3.5,-6),
	}

	--local guninfo = ply.GunInfo
--local guninfo = ply.GunInfo
	
	if !IsValid(ply.wep) then
	
	local rag = ply:GetNWEntity("DeathRagdoll")
		
		if IsValid(rag) then
			
			
			ply.FakeShooting=true
			
			ply.wep=ents.Create("wep")
			
			ply.wep:SetModel(GunsModel[ply.curweapon])
			
			ply.wep:SetOwner(ply)
			
			local vec1=rag:GetPhysicsObjectNum(7):GetPos()
			local vec2=Vectors[ply.curweapon]
			vec2:Rotate(rag:GetPhysicsObjectNum(7):GetAngles())
			ply.wep:SetPos(vec1+vec2)
			ply.wep:SetAngles(rag:GetPhysicsObjectNum(7):GetAngles()-Angle(0,0,180))
			ply.wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ply.wep:Spawn()
			ply.wep:GetPhysicsObject():SetMass(0)
			--ply.wep.GunInfo = guninfo
			CheckAmmo(ply, ply.wep)
			if !IsValid(ply.WepCons) then
				local cons = constraint.Weld(ply.wep,rag,0,7,0,true)
				if IsValid(cons) then 
					ply.WepCons=cons
				end
			end
			ply.wep.curweapon = ply.curweapon
			if TwoHandedOrNo[ply.curweapon] then
				local vec1=rag:GetPhysicsObjectNum(7):GetPos()
				local vec22=Vectors2[ply.curweapon]
				vec22:Rotate(rag:GetPhysicsObjectNum(7):GetAngles())
				rag:GetPhysicsObjectNum( 5 ):SetPos(vec1+vec22)
				rag:GetPhysicsObjectNum( 5 ):SetAngles(ply:GetNWEntity("DeathRagdoll"):GetPhysicsObjectNum( 7 ):GetAngles()-Angle(0,0,180))
				if !IsValid(ply.WepCons2) then
					local cons2 = constraint.Weld(ply.wep,rag,0,5,0,true)			--2hand constraint
					if IsValid(cons2) then 
						ply.WepCons2=cons2
					end
				end
			end
		end
	end
end

function DespawnWeapon(ply)
	ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
	ply.Info.ActiveWeapon2=ply.curweapon
	--if ply:Alive() and !ply.wep.pickable then
		
		if IsValid(ply.wep) and ply:Alive() then
			ply.wep:Remove()
			ply.wep=nil
		elseif IsValid(ply.wep) and !ply:Alive() then
            ply.wep.canpickup=true
            ply.wep:SetOwner(nil)
            ply.wep.curweapon=ply.curweapon
            ply.wep=nil
        end
		
		if IsValid(ply.WepCons) and ply:Alive() then 
			ply.WepCons:Remove()
			ply.WepCons=nil
		elseif IsValid(ply.WepCons) then
			ply.WepCons=nil
		end
		
		if IsValid(ply.WepCons2) and ply:Alive() then 
			ply.WepCons2:Remove()
			ply.WepCons2=nil
		elseif IsValid(ply.WepCons2) then
			ply.WepCons2=nil
		end
		ply.FakeShooting=false
	--[[else
		ply.wep.pickable=true
		ply.wep=nil
		ply.FakeShooting=false
	end--]]
end

function CheckAmmo(ply, wep)
	--print(ply.Info.ActiveWeapon)
	--print(ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1)
	--print(ply.Info.ActiveWeapon2:GetMaxClip1())
	if ply:Alive() then
		wep.Clip = ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1
		wep.MaxClip = ply.Info.ActiveWeapon2:GetMaxClip1()
		--print(ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType()))
		wep.Amt=ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType())
		wep.AmmoType=ply.Info.ActiveWeapon2:GetPrimaryAmmoType()
	else
		wep.Clip = ply:GetActiveWeapon():Clip1()
		wep.AmmoType=ply:GetActiveWeapon():GetPrimaryAmmoType()
		--print(wep.Clip, wep.AmmoType)
	end
end

function SpawnWeaponEnt(weapon, pos, ply)
    local wep = ents.Create("wep")
    local model
    wep:SetModel(GunsModel[weapon])
    wep:SetPos(pos)
    wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    wep:Spawn()
    wep:SetAngles(ply:EyeAngles())
    wep:GetPhysicsObject():ApplyForceOffset(VectorRand(-2,2),wep:GetPos())
    wep.curweapon=ply.curweapon
    wep.Clip = ply.Clip
    wep.AmmoType = ply.AmmoType
    wep.canpickup=true
    return wep
end

function Reload(wep)
	if !IsValid(wep) then return nil end
	local ply = wep:GetOwner()
	if !timer.Exists("reload"..wep:EntIndex()) and wep.Clip!=wep.MaxClip and wep.Amt>0 then
		wep:EmitSound( ReloadSound[wep.curweapon], 75, 100, 1 )
		timer.Create("reload"..wep:EntIndex(), ReloadTime[wep.curweapon], 1, function()
			if IsValid(wep) then
				local oldclip = wep.Clip
				wep.Clip = math.Clamp(wep.Clip+wep.Amt,0,wep.MaxClip)
				local needed = wep.Clip-oldclip
				wep.Amt=wep.Amt-needed
				ply.Info.Ammo[wep.AmmoType]=wep.Amt
				
				--print(ply.Info.Ammo[wep.AmmoType])
			end
		end)
	end
end

NextShot=0

function FireShot(wep)
	if !IsValid(wep) then return nil end
	if wep.Clip<=0 then return nil end
	if timer.Exists("reload"..wep:EntIndex()) then return nil end
	local guninfo = wep.GunInfo
	
	wep.NextShot=wep.NextShot or NextShot

	if ( wep.NextShot > CurTime() ) then return end
	
	wep.NextShot = CurTime() + ShootWait[wep.curweapon]

	local Attachment = wep:GetAttachment( 1 )

	local shootOrigin = Attachment.Pos
	local shootAngles = wep:GetAngles()
	local shootDir = shootAngles:Forward()

	local bullet = {}
		bullet.Num 			= bullets[wep.curweapon] or 1
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector(cir[wep.curweapon] or 0,cir[wep.curweapon]or 0,0)
		bullet.Tracer		= 1
		bullet.TracerName 	= 4
		bullet.Force		= 30
		bullet.Damage		= Damage[wep.curweapon]
		bullet.Attacker 	= ply	

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
	wep:FireBullets( bullet )
	wep.GetSound = SoundInfo[wep.curweapon]
	wep:EmitSound( wep.GetSound, 75, 100, 1, CHAN_WEAPON)
	wep:GetPhysicsObject():ApplyForceCenter(wep:GetAngles():Forward()*-250+wep:GetAngles():Right()*VectorRand(-90,90)+wep:GetAngles():Up()*100)			--сделать зависимым от force потом
	wep.Clip=wep.Clip-1
	// Make a muzzle flash
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( shootAngles )
		effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )
	
end
