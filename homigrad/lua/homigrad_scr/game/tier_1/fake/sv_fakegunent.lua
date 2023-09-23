bullets = {
	["weapon_m3super"] = 8,
	["weapon_remington870"] = 12,
	["weapon_xm1014"] = 8,
}
cir = {
	["weapon_m3super"] = 0.02,
	["weapon_ak74"] = 0.1,
	["weapon_remington870"] = 0.1,
	["weapon_xm1014"] = 0.02,
}

Vectors = {
["weapon_glock18"]=Vector(4,-1,2.5),
["weapon_p220"]=Vector(13.5,-0.5,4),
["weapon_mp5"]=Vector(0.5,-1,0),
["weapon_ar15"]=Vector(-3,-1,0),
["weapon_ak74"]=Vector(14,-1,2),
["weapon_akm"]=Vector(13,-2,2),
["weapon_fiveseven"]=Vector(14,0,4),
["weapon_hk_usp"]=Vector(0,-0.5,0),
["weapon_deagle"]=Vector(0,-0.5,0),
["weapon_beretta"]=Vector(13,0,4),
["weapon_ak74u"]=Vector(13,-1,2),
["weapon_l1a1"]=Vector(3,-2,2),
["weapon_fal"]=Vector(13,-2,2),
["weapon_galil"]=Vector(-1,-2,0),
["weapon_galilsar"]=Vector(4,-2,-1),
["weapon_m14"]=Vector(3,-2,2),
["weapon_m1a1"]=Vector(3,-2,2),
["weapon_mk18"]=Vector(12,-1,4),
["weapon_m249"]=Vector(4,-1.5,0),
["weapon_m4a1"]=Vector(-2,-2,0),
["weapon_minu14"]=Vector(1,-1,0),
["weapon_mp40"]=Vector(13,-1,3),
["weapon_rpk"]=Vector(3,-1,0),
["weapon_ump"]=Vector(2,-1,0),
["weapon_m3super"]=Vector(5,-2,0),
["weapon_hk_usps"]=Vector(-1,-0.6,1),
["weapon_glock"]=Vector(14,0,4),
["weapon_mp7"]=Vector(0,0,0),
["weapon_remington870"]=Vector(-2,-1,0),
["weapon_xm1014"]=Vector(12,-1,4),
["bandage"]=Vector(0,0,0),
["weapon_taser"]=Vector(2,1.5,0),
["weapon_sar2"]=Vector(16,-2,2),
["weapon_civil_famas"]=Vector(-1,-1,-1),
["weapon_spas12"]=Vector(13,-1,2),
}

Vectors2 = {
["weapon_mp5"]=Vector(11,-2	,-2.5),
["weapon_ar15"]=Vector(9,-2,-3),
["weapon_act3_m249"]=Vector(10,-1,-6),
["weapon_ak74"]=Vector(12,-3,-2),
["weapon_akm"]=Vector(12,-4,-5),
["weapon_ak74u"]=Vector(10,-3,-5),
["weapon_l1a1"]=Vector(15,-2,-3),
["weapon_fal"]=Vector(9,-4,-3),
["weapon_galil"]=Vector(15,-3,-3),
["weapon_galilsar"]=Vector(15,-3,-3),
["weapon_m14"]=Vector(15,-3,-3.7),
["weapon_m1a1"]=Vector(15,-3,-3.7),
["weapon_mk18"]=Vector(12,-2,-4),
["weapon_m249"]=Vector(15,-4,-4),
["weapon_m4a1"]=Vector(9,-2,-3),
["weapon_minu14"]=Vector(9,-2,-4),
["weapon_mp40"]=Vector(5,-3,1),
["weapon_rpk"]=Vector(12,-2,-2),
["weapon_ump"]=Vector(12,-1,-4),
["weapon_m3super"]=Vector(15,-3.5,-2),
["weapon_mp7"]=Vector(6,-2,0),
["weapon_remington870"]=Vector(10,-2,-2),
["weapon_xm1014"]=Vector(14,-2,-2),
["weapon_sar2"]=Vector(12,-2,2),
["weapon_civil_famas"]=Vector(9,-2,-3),
["weapon_spas12"]=Vector(15,-4,-3),
}

vecZero = Vector(0,0,0)
function SpawnWeapon(ply,clip1)
	--local guninfo = ply.GunInfo
	--local guninfo = ply.GunInfo луа очень легкий

	if !IsValid(ply.wep) and table.HasValue(Guns,ply.curweapon) then
		local rag = ply:GetNWEntity("Ragdoll")

		if IsValid(rag) then
			ply.FakeShooting=true

			ply.wep=ents.Create("wep")

			ply.wep:SetModel(weapons.Get(ply.curweapon).WorldModel)

			ply.wep:SetOwner(ply)

			local vec1=rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetPos()
			local vec2 = vecZero
			vec2:Set((Vectors[ply.curweapon] or Vector(0,0,0)))

			vec2:Rotate(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetAngles())
			ply.wep:SetPos(vec1+vec2)

			ply.wep:SetAngles(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetAngles()-Angle(0,0,180))

			if ply.curweapon == "weapon_sar2" then
				local ang = ply.wep:GetAngles()
				ang:RotateAroundAxis(ang:Up(),180)
				ang:RotateAroundAxis(ang:Right(),10)
				ply.wep:SetAngles(ang)
			elseif ply.curweapon == "weapon_hk_usps" then
				local ang = ply.wep:GetAngles()
				ang:RotateAroundAxis(ang:Forward(),90)
				ply.wep:SetAngles(ang)
			end

			--[[local hand = rag:GetBoneMatrix(rag:LookupBone("ValveBiped.Bip01_R_Hand"))
			local handPos,handAng = hand:GetTranslation(),hand:GetAngles()

			ply.wep:SetPos(handPos)
			ply.wep:SetAngles(handAng)

			local handWep = ply.wep:GetBoneMatrix(0)
			local wepPos,wepAng = handWep:GetTranslation(),handWep:GetAngles()
			
			local lpos = ply.wep:GetPos() - wepPos

			ply.wep:SetPos(wepPos + lpos)
			ply.wep:SetAngles(handAng - Angle(20,0,180))
--]]
			ply.wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ply.wep:Spawn()
			ply:SetNWEntity("wep",ply.wep)
			--ply.wep:GetPhysicsObject():SetMass(0)
			--ply.wep.GunInfo = guninfo
			CheckAmmo(ply, ply.wep)
			if !IsValid(ply.WepCons) then
				local cons = constraint.Weld(ply.wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )),0,true)
				if IsValid(cons) then
					ply.WepCons=cons
				end
			end

			ply.wep.curweapon = ply.curweapon
			net.Start("ebal_chellele")
			net.WriteEntity(ply)
			net.WriteString(ply.curweapon)
			net.Broadcast()
			rag.wep = ply.wep
			rag.wep:CallOnRemove("inv",remove,rag)
			ply.wep.rag = rag
			ply.wep.Clip = ply.Info.Weapons[ply.curweapon].Clip1
			ply.wep.AmmoType = ply.Info.Weapons[ply.curweapon].AmmoType

			ply:SetNWString("curweapon",ply.wep.curweapon)
			if (TwoHandedOrNo[ply.curweapon]) then
				ply.wep:GetPhysicsObject():SetMass(1)
				local vec1=rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetPos()
				local vec22 = vecZero
				vec22:Set(Vectors2[ply.curweapon])
				vec22:Rotate(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetAngles())
				rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ):SetPos(vec1+vec22)
				local modelhuy = ply:GetModel() == "models/knyaje pack/dibil/sso_politepeople.mdl"
				rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ):SetAngles(ply:GetNWEntity("Ragdoll"):GetPhysicsObjectNum( 7 ):GetAngles()-Angle(0,0,modelhuy and 90 or 180))
				if !IsValid(ply.WepCons2) then
					local cons2 = constraint.Weld(ply.wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )),0,true)			--2hand constraint
					if IsValid(cons2) then
						ply.WepCons2=cons2
					end
				end
			end
		end
	end
end

function DespawnWeapon(ply)
	if not ply.Info then return end

	if not ply.Info.Weapons[ply.Info.ActiveWeapon] then return end
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
Items = {
	['bandage']=1
}
function CheckAmmo(ply, wep)
	--print(ply.Info.ActiveWeapon)
	--print(ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1)
	--print(ply.Info.ActiveWeapon2:GetMaxClip1())
	--if Items[wep] then return end
	--if ply.curweapon=="bandage" then wep:SetModelScale(0.4) end
	if ply:Alive() then
		wep.Clip = ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 or 0
		wep.MaxClip = ply.Info.ActiveWeapon2:GetMaxClip1() or 0
		--print(ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType()))
		wep.Amt=ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType()) or 0
		wep.AmmoType=ply.Info.ActiveWeapon2:GetPrimaryAmmoType() or 0
	else
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end

		wep.Clip = wep:Clip1()
		wep.AmmoType=wep:GetPrimaryAmmoType()
		--print(wep.Clip, wep.AmmoType)
	end
end

function SpawnWeaponEnt(weapon, pos, ply)
    local wep = ents.Create("wep")
    wep:SetModel(GunsModel[weapon])
    wep:SetPos(pos)
    wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    wep:Spawn()
    wep:SetAngles(ply:EyeAngles() or Angle(0,0,0))
    wep:GetPhysicsObject():ApplyForceOffset(VectorRand(-2,2),wep:GetPos())
	--wep:GetPhysicsObject():SetMass(500)
    wep.curweapon = ply.curweapon
    wep.Clip = ply.Clip
    wep.AmmoType = ply.AmmoType
    wep.canpickup=true
    return wep
end

function Reload(wep)
	if not wep then return end
	local weptable = weapons.Get(wep.curweapon)
	if !IsValid(wep) then return nil end
	if ShootWait[wep.curweapon]==nil then return nil end
	local ply = wep:GetOwner()
	if !timer.Exists("reload"..wep:EntIndex()) and wep.Clip!=wep.MaxClip and wep.Amt>0 then
		wep:EmitSound( "weapons/smg1/smg1_reload.wav", 75, 100, 1 )
		timer.Create("reload"..wep:EntIndex(), weptable.ReloadTime, 1, function()
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


HMCD_SurfaceHardness={
    [MAT_METAL]=.95,[MAT_COMPUTER]=.95,[MAT_VENT]=.95,[MAT_GRATE]=.95,[MAT_FLESH]=.5,[MAT_ALIENFLESH]=.3,
    [MAT_SAND]=.1,[MAT_DIRT]=.3,[74]=.1,[85]=.2,[MAT_WOOD]=.5,[MAT_FOLIAGE]=.5,
    [MAT_CONCRETE]=.9,[MAT_TILE]=.8,[MAT_SLOSH]=.05,[MAT_PLASTIC]=.3,[MAT_GLASS]=.6
}


local pos = Vector(0,0,0)



function FireShot(wep)
	if not IsValid(wep) then return end

	local weptable = weapons.Get(wep.curweapon)

	function wep:BulletCallbackFunc(dmgAmt,ply,tr,dmg,tracer,hard,multi)
		if(tr.MatType==MAT_FLESH)then
			util.Decal("Blood",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
			local vPoint = tr.HitPos
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			util.Effect( "BloodImpact", effectdata )
		end
		if(self.NumBullet or 1>1)then return end
		if(tr.HitSky)then return end
		if(hard)then self:RicochetOrPenetrate(tr) end
	end
	function wep:RicochetOrPenetrate(initialTrace)
		local AVec,IPos,TNorm,SMul=initialTrace.Normal,initialTrace.HitPos,initialTrace.HitNormal,HMCD_SurfaceHardness[initialTrace.MatType]
		if not(SMul)then SMul=.5 end
		local ApproachAngle=-math.deg(math.asin(TNorm:DotProduct(AVec)))
		local MaxRicAngle=80*SMul
		if(ApproachAngle>(MaxRicAngle*1.25))then -- all the way through
			local MaxDist,SearchPos,SearchDist,Penetrated=(weapons.Get(wep.curweapon).Primary.Damage/SMul)*.15,IPos,5,false
			while((not(Penetrated))and(SearchDist<MaxDist))do
				SearchPos=IPos+AVec*SearchDist
				local PeneTrace=util.QuickTrace(SearchPos,-AVec*SearchDist)
				if((not(PeneTrace.StartSolid))and(PeneTrace.Hit))then
					Penetrated=true
				else
					SearchDist=SearchDist+5
				end
			end
			if(Penetrated)then
				self:FireBullets({
					Attacker=self:GetOwner(),
					Damage=1,
					Force=1,
					Num=1,
					Tracer=0,
					TracerName="",
					Dir=-AVec,
					Spread=Vector(0,0,0),
					Src=SearchPos+AVec
				})
				self:FireBullets({
					Attacker=self:GetOwner(),
					Damage=weapons.Get(wep.curweapon).Primary.Damage*.65,
					Force=weapons.Get(wep.curweapon).Primary.Force / 40 *.65,
					Num=1,
					Tracer=0,
					TracerName="",
					Dir=AVec,
					Spread=Vector(0,0,0),
					Src=SearchPos+AVec
				})
			end
		elseif(ApproachAngle<(MaxRicAngle*.75))then -- ping whiiiizzzz
			sound.Play("snd_jack_hmcd_ricochet_"..math.random(1,2)..".wav",IPos,70,math.random(90,100))
			local NewVec=AVec:Angle()
			NewVec:RotateAroundAxis(TNorm,180)
			NewVec=NewVec:Forward()
			self:FireBullets({
				Attacker=self:GetOwner(),
				Damage=weapons.Get(wep.curweapon).Primary.Damage*.85,
				Force=weapons.Get(wep.curweapon).Primary.Force/60,
				Num=1,
				Tracer=0,
				TracerName="",
				Dir=-NewVec,
				Spread=Vector(0,0,0),
				Src=IPos+TNorm
			})
		end
	end

	if ShootWait[wep.curweapon]==nil then return nil end
	if !IsValid(wep) then return nil end
	if wep.Clip<=0 then
		sound.Play("snd_jack_hmcd_click.wav",wep:GetPos(),65,100)
		wep.NextShot = CurTime() + weptable.ShootWait
	return nil end
	if timer.Exists("reload"..wep:EntIndex()) then return nil end
	local guninfo = wep.GunInfo
	
	wep.NextShot=wep.NextShot or NextShot

	if ( wep.NextShot > CurTime() ) then return end

	wep.NextShot = CurTime() + weptable.ShootWait

	local Attachment = wep:GetAttachment(wep:LookupAttachment("muzzle"))

	local shootOrigin = Attachment and Attachment.Pos or wep:GetPos() + wep:GetAngles():Forward() * 10
	local shootAngles = Attachment and Attachment.Ang or wep:GetAngles()
	local shootDir = shootAngles:Forward()
	local damage = weapons.Get(wep.curweapon).Primary.Damage
	local ply = wep:GetOwner()
	local bullet = {}
		bullet.Num 			= (weptable.NumBullet or 1)
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector(weptable.Primary.Cone or 0,weptable.Primary.Cone or 0,0)
		bullet.Tracer		= 1
		bullet.TracerName 	= 4
		bullet.Force		= weptable.Primary.Force / 90
		bullet.Damage		= damage
		bullet.Attacker 	= ply
		bullet.Callback=function(ply,tr)
			wep:BulletCallbackFunc(damage,ply,tr,damage,false,true,false)
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
	wep:FireBullets( bullet )
	--wep:EmitSound( wep.GetSound, 75, 100, 1, CHAN_WEAPON)
	if SERVER then
		net.Start("huysound")
		net.WriteVector(wep:GetPos())
		net.WriteString(weptable.Primary.Sound)
		net.WriteString(weptable.Primary.SoundFar)
		net.WriteEntity(wep)
		net.Broadcast()
	end
	if wep.curweapon!="weapon_ak74" then
		wep:GetPhysicsObject():ApplyForceCenter(wep:GetAngles():Forward()*-damage*2+wep:GetAngles():Right()*VectorRand(-90,90)+wep:GetAngles():Up()*200)			--сделать зависимым от force потом
	else
		local ply = wep:GetOwner()
		local rag = ply:GetNWEntity("Ragdoll")
		rag:GetPhysicsObjectNum(0):ApplyForceCenter(ply:EyeAngles():Forward()*-damage*0.35)
		wep:GetPhysicsObject():ApplyForceCenter(wep:GetAngles():Forward()*-damage*0.05+wep:GetAngles():Right()*VectorRand(-90,90)+wep:GetAngles():Up()*100)
	end
	wep.Clip=wep.Clip-1
	-- Make a muzzle flash
	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( shootAngles )
	effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )

end
