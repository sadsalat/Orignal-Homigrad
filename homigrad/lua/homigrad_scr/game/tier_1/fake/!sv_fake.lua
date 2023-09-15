local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

Organs = {
	['brain']=5,
	['lungs']=30,
	['liver']=30,
	['stomach']=40,
	['intestines']=40,
	['heart']=10,
	['artery']=1,
	['spine']=10
}

local bonenames = {
    ['ValveBiped.Bip01_Head1']="Голову",
    ['ValveBiped.Bip01_Spine']="Спину",
    ['ValveBiped.Bip01_R_Hand']="Правую руку",
    ['ValveBiped.Bip01_R_Forearm']="Правое предплечье",
    ['ValveBiped.Bip01_R_Foot']="Правую ногу",
    ['ValveBiped.Bip01_R_Thigh']='Правое бедро',
    ['ValveBiped.Bip01_R_Calf']='Правую голень',
    ['ValveBiped.Bip01_R_Shoulder']='Правое плечо',
    ['ValveBiped.Bip01_R_Elbow']='Правый локоть',
	['ValveBiped.Bip01_L_Hand']='Левую руку',
    ['ValveBiped.Bip01_L_Forearm']='Левое предплечье',
    ['ValveBiped.Bip01_L_Foot']='Левую ногу',
    ['ValveBiped.Bip01_L_Thigh']='Левое бедро',
    ['ValveBiped.Bip01_L_Calf']='Левую голень',
    ['ValveBiped.Bip01_L_Shoulder']='Левое плечо',
    ['ValveBiped.Bip01_L_Elbow']='Левый локоть'
}

RagdollDamageBoneMul={		--Умножения урона при попадании по регдоллу
	[HITGROUP_LEFTLEG]=0.5,
	[HITGROUP_RIGHTLEG]=0.5,

	[HITGROUP_GENERIC]=1,

	[HITGROUP_LEFTARM]=0.5,
	[HITGROUP_RIGHTARM]=0.5,

	[HITGROUP_CHEST]=1,
	[HITGROUP_STOMACH]=1,

	[HITGROUP_HEAD]=4,
}

local bonetohitgroup={ --Хитгруппы костей
    ["ValveBiped.Bip01_Head1"]=1,
    ["ValveBiped.Bip01_R_UpperArm"]=5,
    ["ValveBiped.Bip01_R_Forearm"]=5,
    ["ValveBiped.Bip01_R_Hand"]=5,
    ["ValveBiped.Bip01_L_UpperArm"]=4,
    ["ValveBiped.Bip01_L_Forearm"]=4,
    ["ValveBiped.Bip01_L_Hand"]=4,
    ["ValveBiped.Bip01_Pelvis"]=3,
    ["ValveBiped.Bip01_Spine2"]=2,
    ["ValveBiped.Bip01_L_Thigh"]=6,
    ["ValveBiped.Bip01_L_Calf"]=6,
    ["ValveBiped.Bip01_L_Foot"]=6,
    ["ValveBiped.Bip01_R_Thigh"]=7,
    ["ValveBiped.Bip01_R_Calf"]=7,
    ["ValveBiped.Bip01_R_Foot"]=7
}

function GetFakeWeapon(ply)
    ply.curweapon = ply.Info.ActiveWeapon
end

function SavePlyInfo(ply) -- Сохранение игрока перед его падением в фейк
    ply.Info = {}
    local info = ply.Info
    info.HasSuit = ply:IsSuitEquipped()
    info.SuitPower = ply:GetSuitPower()
    info.Ammo = ply:GetAmmo()
    info.ActiveWeapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil
    info.ActiveWeapon2 = ply:GetActiveWeapon()
    GetFakeWeapon(ply)
    info.Weapons={}
    for i,wep in pairs(ply:GetWeapons())do
        info.Weapons[wep:GetClass()]={
            Clip1=wep:Clip1(),
            Clip2=wep:Clip2(),
            AmmoType=wep:GetPrimaryAmmoType()
        }
    end
    info.Weapons2={}
    for i,wep in ipairs(ply:GetWeapons())do
        info.Weapons2[i-1]=wep:GetClass()
    end
    info.AllAmmo={}
    local i
    for ammo, amt in pairs(ply:GetAmmo())do
        i = i or 0
        i = i + 1
        info.AllAmmo[ammo]={i,amt}
    end
    --PrintTable(info.AllAmmo)
    return info
end

function GetFakeWeapon(ply)
	ply.curweapon = ply.Info.ActiveWeapon
end

function ClearFakeWeapon(ply)
	if ply.FakeShooting then DespawnWeapon(ply) end
end

function SavePlyInfoPreSpawn(ply) -- Сохранение игрока перед вставанием
	ply.Info = ply.Info or {}
	local info = ply.Info
	info.Hp = ply:Health()
	info.Armor = ply:Armor()
	return info
end

function ReturnPlyInfo(ply) -- возвращение информации игроку по его вставанию
    ClearFakeWeapon(ply)
	ply:SetSuppressPickupNotices(true)
    local info = ply.Info
    if(!info)then return end

    ply:StripWeapons()
    ply:StripAmmo()
    for name, wepinfo in pairs(info.Weapons or {}) do
        local weapon = ply:Give(name, true)
        if IsValid(weapon) and wepinfo.Clip1!=nil and wepinfo.Clip2!=nil then
            weapon:SetClip1(wepinfo.Clip1)
            weapon:SetClip2(wepinfo.Clip2)
        end
    end
    for ammo, amt in pairs(info.Ammo or {}) do
        ply:GiveAmmo(amt,ammo)
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

end

function Faking(ply) -- функция падения
	if not ply.fake then
		ply.fake = true
		ply:SetNWBool("fake",ply.fake)

		SavePlyInfo(ply)
		ply:DrawViewModel(false)
		if (SERVER) then
		ply:DrawWorldModel(false)
		end
		if ply:InVehicle() then
			ply:ExitVehicle()
		end
		ply:CreateRagdoll()

		if IsValid(ply:GetNWEntity("Ragdoll")) then
			ply.fakeragdoll=ply:GetNWEntity("Ragdoll")
			local rag = ply.fakeragdoll
			rag.bull = ents.Create("npc_bullseye")
			local bull = rag.bull
			local bodyphy = rag:GetPhysicsObjectNum(10)
			bull:SetPos(bodyphy:GetPos()+bodyphy:GetAngles():Right()*7)
			bull:SetMoveType( MOVETYPE_OBSERVER )
			bull:SetParent(rag,rag:LookupAttachment("eyes"))
			bull:SetHealth(1000)
			bull:Spawn()
			bull:Activate()
			bull:SetNotSolid(true)
			FakeBullseyeTrigger(rag,ply)
			ply:HuySpectate(OBS_MODE_CHASE)
			ply:SpectateEntity(ply:GetNWEntity("Ragdoll"))

			ply:SetActiveWeapon(nil)
			ply:DropObject()

			timer.Create("faketimer"..ply:EntIndex(), 2, 1, function() end)

			if table.HasValue(Guns,ply.curweapon) then
				ply.FakeShooting=true
				ply:SetNWInt("FakeShooting",true)
			else
				ply.FakeShooting=false
				ply:SetNWInt("FakeShooting",false)
			end
		end
	else
		local rag = ply:GetNWEntity("Ragdoll")
		if IsValid(rag) then
			if IsValid(rag.bull) then
				rag.bull:Remove()
			end
			ply.GotUp = CurTime()
			if hook.Run("Fake Up",ply,rag) ~= nil then return end

			ply.fake = false
			ply:SetNWBool("fake",ply.fake)

			ply.fakeragdoll=nil
			SavePlyInfoPreSpawn(ply)
			local pos=ply:GetNWEntity("Ragdoll"):GetPos()
			local vel=ply:GetNWEntity("Ragdoll"):GetVelocity()
			--ply:UnSpectate()
			PLYSPAWN_OVERRIDE = true
			ply:SetNWBool("unfaked",PLYSPAWN_OVERRIDE)
			local eyepos=ply:EyeAngles()
			JMod.Иди_Нахуй = true
			ply:Spawn()
			JMod.Иди_Нахуй = nil
			ReturnPlyInfo(ply)
			ply.FakeShooting=false
			ply:SetNWInt("FakeShooting",false)
			ply:SetVelocity(vel)
			ply:SetEyeAngles(eyepos)
			PLYSPAWN_OVERRIDE = nil
			ply:SetNWBool("unfaked",PLYSPAWN_OVERRIDE)

			ply:SetPos(pos - Vector(0,0,64))
			ply:DrawViewModel(true)
			ply:DrawWorldModel(true)
			ply:SetModel(ply:GetNWEntity("Ragdoll"):GetModel())
			ply:GetNWEntity("Ragdoll"):Remove()
			ply:SetNWEntity("Ragdoll",nil)
		end
	end
end

function FakeBullseyeTrigger(rag,owner)
	if not IsValid(rag.bull) then return end
	for i,ent in pairs(ents.GetAll())do
		if(ent:IsNPC() and ent:Disposition(owner)==D_HT)then
			ent:AddEntityRelationship(rag.bull,D_HT,0)
		end
	end
end

hook.Add("OnEntityCreated","hg-bullseye",function(ent)
	ent:SetShouldPlayPickupSound(false)
	if ent:IsNPC() then
		for i, ply in pairs(player.GetAll()) do
			if ply:Team() == 2 then
				ent:AddEntityRelationship(ply,D_LI,0)
			end
		end
		for i,rag in pairs(ents.FindByClass("prop_ragdoll"))do
			if IsValid(rag.bull) then
				ent:AddEntityRelationship(rag.bull,D_HT,0)
			end
		end
	end
	for i,enta in pairs(ents.GetAll())do
		if enta:IsNPC() and ent:IsPlayer() and ent:Team() == 2 then
			enta:AddEntityRelationship(ply, D_LI, 99 )
		end
	end
end)

hook.Add("Think","FakedShoot",function() --функция стрельбы лежа
for i,ply in pairs(player.GetAll()) do
	if IsValid(ply:GetNWEntity("Ragdoll")) and ply.FakeShooting and ply:Alive() then
		SpawnWeapon(ply)
	else
		if IsValid(ply.wep) then
			DespawnWeapon(ply)
		end
	end
end
end)

hook.Add("PlayerSay","huyasds",function(ply,text)
	if ply:IsAdmin() and string.lower(text)=="1" then
		local ent = ply:GetEyeTrace().Entity
		if ent:IsPlayer() then
			ply:ChatPrint(ent:Nick(),ent:EntIndex())
			--[[PrintMessage(HUD_PRINTTALK,tostring(ply:Name()).." связал "..tostring(ent:Name()))
			ent:StripWeapons()
			ent:Give("weapon_hands")
			Faking(ent)
			timer.Simple(0,function()
				local enta = ent:GetNWEntity("Ragdoll")
				enta:GetPhysicsObjectNum(5):SetPos(enta:GetPhysicsObjectNum(7):GetPos())
				for i=1,3 do
					constraint.Rope(enta,enta,5,7,Vector(0,0,0),Vector(0,0,0),-2,2,0,4,"cable/rope.vmt",false,Color(255,255,255))
				end
			end)
			--ent.Hostage = true--]]
		elseif ent:IsRagdoll() then
			ply:ChatPrint(IsValid(RagdollOwner(ent)) and RagdollOwner(ent):Name())
			--[[--ent:StripWeapons()
			--ent:Give("weapon_hands")
			--Faking(ent)
			timer.Simple(0,function()
				local enta = ent
				enta:GetPhysicsObjectNum(5):SetPos(enta:GetPhysicsObjectNum(7):GetPos())
				for i=1,3 do
					constraint.Rope(enta,enta,5,7,Vector(0,0,0),Vector(0,0,0),-2,2,0,4,"cable/rope.vmt",false,Color(255,255,255))
				end
			end)--]]
		end
		return ""
	end
end)

function RagdollOwner(rag) --функция, определяет хозяина регдолла
	for k, v in pairs(player.GetAll()) do
		local ply = v
		if ply:GetNWEntity("Ragdoll") == rag then
			return ply
		end
	end
	return false
end

function PlayerMeta:DropWeapon1()
    local ply = self
    if !IsValid(ply:GetActiveWeapon()) then return end
    if table.HasValue(Guns,ply:GetActiveWeapon():GetClass()) then
        ply.curweapon=ply:GetActiveWeapon():GetClass()
        ply.Clip=ply:GetActiveWeapon():Clip1()
        ply.AmmoType=ply:GetActiveWeapon():GetPrimaryAmmoType()
        SpawnWeaponEnt(ply:GetActiveWeapon():GetClass(), ply:EyePos()+Vector(0,0,-10), ply):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector()*200+ply:GetVelocity())
        ply.curweapon=nil
        ply.Clip=nil
        ply.AmmoType=nil
		local wep = ply:GetActiveWeapon()
        wep:Remove()
		ply.slots = ply.slots or {}
		ply.slots[wep.Slot] = nil
	else
		if ply:GetActiveWeapon():GetClass() == "weapon_hands" then return end
		local wep = ply:GetActiveWeapon()
		ply:DropWeapon(wep)
		wep.Spawned = true
		ply.slots = ply.slots or {}
		ply.slots[wep.Slot] = nil
    end
end

function PlayerMeta:PickupEnt()
local ply = self
local rag = ply:GetNWEntity("Ragdoll")
local phys = rag:GetPhysicsObjectNum(7)
local offset = phys:GetAngles():Right()*5
local traceinfo={
start=phys:GetPos(),
endpos=phys:GetPos()+offset,
filter=rag,
output=trace,
}
local trace = util.TraceLine(traceinfo)
if trace.Entity == Entity(0) or trace.Entity == NULL or !trace.Entity.canpickup then return end
if trace.Entity:GetClass()=="wep" then
    ply:Give(trace.Entity.curweapon,true):SetClip1(trace.Entity.Clip)
    --SavePlyInfo(ply)
    ply.wep.Clip=trace.Entity.Clip
    trace.Entity:Remove()
end
end

--PostPlayerDeath
hook.Add("PostPlayerDeath","resetfakes",function(ply) --обнуление регдолла после вставания
	ply:SetNWEntity("Ragdoll",nil)
	ply.suiciding = nil
	ply:SetNWBool("Suiciding",false)
end)

hook.Add("PlayerDeath","resetfakes",function(ply,inflictor,attacker) --обнуление регдолла после вставания
	if ply.fake then
		local rag=ply:GetNWEntity("Ragdoll")
		if IsValid(rag.bull) then
			rag.bull:Remove()
		end
		if ply.IsBleeding or ply.Bloodlosing > 0 then
			rag.IsBleeding = true
			rag.bloodNext = CurTime()
			rag.Blood = ply.Blood
			table.insert(BleedingEntities,rag)
		end
		ply:SetNWEntity("Ragdoll",nil)
		Faking(ply)
		ply:SetParent()
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(ply:GetNWEntity("Ragdoll"))
		ply:SetNWEntity("Ragdoll",nil)
	end

	if ply.Attacker!=nil and ply.Attacker!=ply:Nick() then
		if table.HasValue(bonenames,ply.LastHit) then
			ply:ChatPrint("Тебя убил "..ply.Attacker.." в "..bonenames[ply.LastHit]..".")
		else
			ply:ChatPrint("Тебя убил "..ply.Attacker..".")
		end
	else
		ply:ChatPrint("Ты умер.")
	end
	ply.FakeRagdoll = nil
end)


hook.Add("PhysgunDrop", "DropPlayer", function(ply,ent)
ent.isheld=false
end)

hook.Add("PhysgunPickup", "DropPlayer2", function(ply,ent)
if ply:GetUserGroup()=="superadmin" then
ent.isheld=true
if ent:IsPlayer() and !ent.fake then Faking(ent) return false end
end
end)

hook.Add("DoPlayerDeath","resetfakes3232",function(ply) --обнуление регдолла после вставания
if ply.fake then
	local rag=ply:GetNWEntity("Ragdoll")
	if IsValid(rag.bull) then
		rag.bull:Remove()
	end
	ply:GetNWEntity("Ragdoll").deadbody=true
	if ply.IsBleeding or ply.Bloodlosing > 0 then
		rag.IsBleeding=true
		rag.bloodNext = CurTime()
		rag.Blood = ply.Blood
		table.insert(BleedingEntities,rag)
	end
	rag:SetEyeTarget(Vector(0,0,0))
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(rag)
	rag.Info=ply.Info
	rag.deadbody = true
    rag.curweapon=ply.curweapon

	if(IsValid(rag.ZacConsLH))then
		rag.ZacConsLH:Remove()
		rag.ZacConsLH=nil
	end

	if(IsValid(rag.ZacConsRH))then
		rag.ZacConsRH:Remove()
		rag.ZacConsRH=nil
	end

	if engine.ActiveGamemode() == "sandbox" or TableRound().Name == "Захват точек" then
		timer.Create("DecayTimer" .. rag:EntIndex(),60,1,function()
			if not IsValid(rag) then return end
			table.RemoveByValue(BleedingEntities,rag)
			rag:Remove()
		end)
	end
	ply:SetNWEntity("Ragdoll",nil)
end
--ply:GetNWEntity("Ragdoll").index=table.MemberValuesFromKey(BleedingEntities,ply:GetNWEntity("Ragdoll"))
end)
util.AddNetworkString("fuckfake")
hook.Add("PlayerSpawn","resetfakebody",function(ply) --обнуление регдолла после вставания
	ply.fake = false
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	net.Start("fuckfake")
	net.Send(ply)

	ply:SetNWBool("fake",false)

	if PLYSPAWN_OVERRIDE then return end

	ply.slots = {}
	if ply.UsersInventory ~= nil then
		for plys,bool in pairs(ply.UsersInventory) do
			ply.UsersInventory[plys] = nil
			send(plys,lootEnt,true)
		end
	end
	ply.suiciding=false
	ply:SetNWEntity("Ragdoll",nil)
	--ply:GetNWEntity("Ragdoll").health=ply:Health()
	ply.Organs = {
	['brain']=20,
	['lungs']=30,
	['liver']=30,
	['stomach']=40,
	['intestines']=40,
	['heart']=10,
	['artery']=1,
	['spine']=10
	}
	ply.InternalBleeding=nil
	ply.InternalBleeding2=nil
	ply.InternalBleeding3=nil
	ply.InternalBleeding4=nil
	ply.InternalBleeding5=nil
	ply.arterybleeding=false
	ply.brokenspine=false
	ply.Attacker = nil
	--table.Merge(Organs,ply.Organs)
end)

hook.Add("EntityTakeDamage", "LastAttacker", function(ent,dmginfo)
--[[local attacker = dmginfo:GetAttacker()
local ply
if IsValid(RagdollOwner(ent)) then ply=RagdollOwner(ent) elseif ent:IsPlayer() then ply=ent else return end

if IsValid(ply) and attacker:IsPlayer() then
	ply.Attacker2 = attacker
	ply.lastattacked[ply.Attacker2] = math.floor(CurTime())
	ply.dmgsbyply[ply.Attacker2] = math.floor((ply.dmgsbyply[ply.Attacker2] or 0) + dmginfo:GetDamage())
elseif IsValid(ply) and attacker:GetClass()=="wep" and IsValid(attacker:GetOwner()) then -- сделать по-другому (тут только если ты себя убиваешь)
    ply.Attacker2 = attacker:GetOwner()
	ply.lastattacked[ply.Attacker2] = math.floor(CurTime())
	ply.dmgsbyply[ply.Attacker2] = math.floor((ply.dmgsbyply[ply.Attacker2] or 0) + dmginfo:GetDamage())
end


if attacker:IsNPC() then dmginfo:ScaleDamage(5) end--]]
end)

util.AddNetworkString("Unload")
net.Receive("Unload",function(len,ply)
	local wep = net.ReadEntity()
	local oldclip = wep:Clip1()
	local ammo = wep:GetPrimaryAmmoType()
	wep:SetClip1(0)
	ply:GiveAmmo(oldclip,ammo)
end)

hook.Add("EntityTakeDamage","ragdamage",function(ent, dmginfo) --урон по разным костям регдолла
if !ent.IsBleeding and dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BLAST+DMG_ENERGYBEAM+DMG_NEVERGIB+DMG_ALWAYSGIB+DMG_PLASMA+DMG_AIRBOAT+DMG_SNIPER) then
	ent.IsBleeding=true
	table.insert(BleedingEntities,ent)
	ent.bloodNext = CurTime()
	ent.Blood = ent.Blood or 5000--wtf
end
local player = RagdollOwner(ent) or ent
if not player:IsPlayer() or not player:Alive() or player:HasGodMode() then return end
local trace = util.QuickTrace(dmginfo:GetDamagePosition(),dmginfo:GetDamageForce():GetNormalized()*100)
local bone = trace.PhysicsBone
local hitgroup
local isfall

local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(bone))

if bonetohitgroup[bonename]!=nil then
	hitgroup=bonetohitgroup[bonename]
end
if(RagdollDamageBoneMul[hitgroup])then
	if RagdollOwner(ent) then
		if RagdollOwner(ent):GetModel() == "models/player/combine_soldier.mdl" then
			if dmginfo:GetDamage()>10 and not RagdollOwner(ent).Otrub and not timer.Exists( "pain"..RagdollOwner(ent):EntIndex() ) then
			RagdollOwner(ent):EmitSound("npc/combine_soldier/pain"..math.random(1,3)..".wav")
			timer.Create( "pain"..RagdollOwner(ent):EntIndex(), 2, 1, function() end)
			end
		end
		timer.Create("faketimer"..RagdollOwner(ent):EntIndex(), math.Clamp(dmginfo:GetDamage()/40,0,1), 1, function() end)
    	if hitgroup == HITGROUP_HEAD then
			if dmginfo:GetDamageType()==1 and dmginfo:GetDamage()>6 and ent:GetVelocity():Length()>500 then
				RagdollOwner(ent):ChatPrint("Твоя шея была сломана")
				ent:EmitSound( "NPC_Barnacle.BreakNeck", 511,200, 1, CHAN_ITEM )
				dmginfo:ScaleDamage(1000000)
			end
		end
    end
	if dmginfo:IsDamageType(DMG_BULLET) then
		dmginfo:ScaleDamage(RagdollDamageBoneMul[hitgroup])
	end

	local ply = RagdollOwner(ent) or ent
	if ply:HasGodMode() then return end--БЛЯАААДЬ

	if hitgroup == HITGROUP_LEFTARM then
		if dmginfo:GetDamage() > 30 and ply.LeftArm == 1 and dmginfo:GetDamage()>6 and ent:GetVelocity():Length()>500 then
			ply:ChatPrint("Твоя левая рука была сломана")
			ply.LeftArm = 0.6
		end
	end
	if hitgroup == HITGROUP_RIGHTARM then
		if dmginfo:GetDamage() > 30 and ply.RightArm == 1 and dmginfo:GetDamage()>6 and ent:GetVelocity():Length()>500 then
			ply:ChatPrint("Твоя правая рука была сломана")
			ply.RightArm = 0.6
		end
	end
	if hitgroup == HITGROUP_LEFTLEG then
		if dmginfo:GetDamage() > 30 and ply.LeftLeg == 1 and dmginfo:GetDamage()>6 and ent:GetVelocity():Length()>500 then
			ply:ChatPrint("Твоя левая нога была сломана")
			ply.LeftLeg = 0.6
		end
	end
	if hitgroup == HITGROUP_RIGHTLEG then
		if dmginfo:GetDamage() > 30 and ply.RightLeg == 1 and dmginfo:GetDamage()>6 and ent:GetVelocity():Length()>500 then
			ply:ChatPrint("Твоя правая нога была сломана")
			ply.RightLeg = 0.6
		end
	end
	local ply
	local penetration
	if IsValid(RagdollOwner(ent)) then ply=RagdollOwner(ent) elseif ent:IsPlayer() then ply=ent end
	if dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH) then penetration=dmginfo:GetDamageForce()*0.015 else penetration=dmginfo:GetDamageForce()*0.004 end
	if !dmginfo:IsDamageType(DMG_CRUSH+DMG_GENERIC) then
		if hitgroup==1 and ent:IsPlayer() and ent.fake==false and ent:Alive() then timer.Simple(0.01,function()if !ply.fake then Faking(ply) end end) end
		if (ent:IsPlayer() or IsValid(RagdollOwner(ent))) then --and ent:LookupBone(bonename)==3 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine2'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine2'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-1,0,-6),Vector(10,6,6))
			if huy!=nil then --ply:ChatPrint("You were hit in the lungs.")
				if ply.Organs['lungs']!=0 then
					ply.Organs['lungs']=math.Clamp(ply.Organs['lungs']-dmginfo:GetDamage(),0,30)
					if ply.Organs['lungs']==0 then timer.Simple(3,function() if ply:Alive() then ply:ChatPrint("Ты чувствуешь, как воздух заполняет твою грудную клетку. ") end end) end
				end
			end
		end
		--lungs
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then --and ent:LookupBone(bonename)==6 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Head1'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(2,-4,-3), Vector(7,4,3))
			--[[if huy then
				if IsValid(RagdollOwner(ent)) then
					RagdollOwner(ent):Kill()
				elseif ent:IsPlayer() then
					ent:Kill()
				end
			end--]] --fuck simplicity
			if huy then --ply:ChatPrint("You were hit in the brain.")
				if ply.Organs['brain']!=0 and dmginfo:IsDamageType(DMG_BULLET) then
					ply.Organs['brain']=math.Clamp(ply.Organs['brain']-dmginfo:GetDamage(),0,20)
					--if ply.Organs['brain']==0 then ply:ChatPrint("Бум. В голову") end
				end
			end
		end
		--brain
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then --and ent:LookupBone(bonename)==2 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine1'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-4,-1,-6),Vector(2,5,-1))
			if huy then --ply:ChatPrint("You were hit in the liver.")
				if ply.Organs['liver']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
					ply.Organs['liver']=math.Clamp(ply.Organs['liver']-dmginfo:GetDamage(),0,30)
					--if ply.Organs['liver']==0 then ply:ChatPrint("Твоя печень была уничтожена.") end
				end
			end
		end
		--liver
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then --and ent:LookupBone(bonename)==2 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine1'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-4,-1,-1),Vector(2,5,6))
			if huy then --ply:ChatPrint("You were hit in the stomach.")
				if ply.Organs['stomach']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
					ply.Organs['stomach']=math.Clamp(ply.Organs['stomach']-dmginfo:GetDamage(),0,40)
					if ply.Organs['stomach']==0 then ply:ChatPrint("Ты чувствуешь острую боль в животе.") end
				end
			end
		end
		--stomach
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then --and ent:LookupBone(bonename)==2 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-4,-1,-6),Vector(1,5,6))
			if huy then --ply:ChatPrint("You were hit in the intestines.")
			if ply.Organs['intestines']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
				ply.Organs['intestines']=math.Clamp(ply.Organs['intestines']-dmginfo:GetDamage(),0,40)
				--if ply.Organs['intestines']==0 then ply:ChatPrint("Твои кишечник был уничтожен.")end
			end
			end
		end
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then --and ent:LookupBone(bonename)==2 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine2'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine2'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(1,0,-1),Vector(5,4,3))
			if huy then --ply:ChatPrint("You were hit in the heart.")
			if ply.Organs['heart']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
				ply.Organs['heart']=math.Clamp(ply.Organs['heart']-dmginfo:GetDamage(),0,10)
				--if ply.Organs['heart']==0 then ply:ChatPrint("Твое сердце уничтожено.") end
			end
			end
		end
		--heart
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) and dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BLAST+DMG_ENERGYBEAM+DMG_NEVERGIB+DMG_ALWAYSGIB+DMG_PLASMA+DMG_AIRBOAT+DMG_SNIPER+DMG_BUCKSHOT) then --and ent:LookupBone(bonename)==2 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Head1'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-3,-2,-2),Vector(0,-1,-1))
			local huy2 = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-3,-2,1),Vector(0,-1,2))
			if huy or huy2 then --ply:ChatPrint("You were hit in the artery.")
			if ply.Organs['artery']!=0 and !dmginfo:IsDamageType(DMG_CLUB) then
				ply.Organs['artery']=math.Clamp(ply.Organs['artery']-dmginfo:GetDamage(),0,1)
				if ply.Organs['artery']==0 then if !ply.fake then Faking(ply)
					end end
				end
			end
		end
		--coronary artery
		if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then --and ent:LookupBone(bonename)==2 then
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine4'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine4'))
			local huy = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-8,-1,-1),Vector(2,0,1))
			local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine1'))
			local ang = matrix:GetAngles()
			local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
			local huy2 = util.IntersectRayWithOBB(dmginfo:GetDamagePosition(),penetration, pos, ang, Vector(-8,-3,-1),Vector(2,-2,1))
			if huy or huy2 then --ply:ChatPrint("You were hit in the spine.")
			if ply.Organs['spine']!=0 then
				ply.Organs['spine']=math.Clamp(ply.Organs['spine']-dmginfo:GetDamage(),0,1)
				if ply.Organs['spine']==0 then if !ply.fake then Faking(ply) ply.brokenspine=true ply:ChatPrint("Твоя спина была сломана.") end end
			end
			end
		end
		--spine
	end
		if IsValid(RagdollOwner(ent)) then
			RagdollOwner(ent).LastHit=bonename
		elseif ent:IsPlayer() then
			ent.LastHit=bonename
		end
	end
	if IsValid(RagdollOwner(ent)) then
		local scale
		if dmginfo:GetDamageType()==1 then
			if dmginfo:GetAttacker():IsRagdoll() or dmginfo:GetAttacker():IsPlayerHolding() then
				RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health()-dmginfo:GetDamage()*0)
				scale = 0
			else
				RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health()-dmginfo:GetDamage()/40)
				scale = 1 / 40
			end
		else
			RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health()-dmginfo:GetDamage()/1.5)
			scale = 1 / 1.5
		end
		dmginfo:SetDamage(dmginfo:GetDamage()*scale)
		RagdollOwner(ent):TakeDamageInfo(dmginfo)
		if RagdollOwner(ent):Health()<=0 and RagdollOwner(ent):Alive() then
			ent.Attacker3 = ent.Attacker
			RagdollOwner(ent):Kill()
		end
	end
end)

function Stun(Entity)
	if Entity:IsPlayer() then
		Faking(Entity)
		timer.Create("StunTime"..Entity:EntIndex(), 8, 1, function() end)
		local fake = Entity:GetNWEntity("Ragdoll")
		timer.Create( "StunEffect"..Entity:EntIndex(), 0.1, 80, function()
			local rand = math.random(1,50)
			if rand == 50 then
			RagdollOwner(fake):Say("*drop")
			end
			RagdollOwner(fake).pain = RagdollOwner(fake).pain + 3
			fake:GetPhysicsObjectNum(1):SetVelocity(fake:GetPhysicsObjectNum(1):GetVelocity()+Vector(math.random(-55,55),math.random(-55,55),0))
			fake:EmitSound("ambient/energy/spark2.wav")
		end)
	elseif Entity:IsRagdoll() then
		if RagdollOwner(Entity) then
			RagdollOwner(Entity):Say("*drop")
			timer.Create("StunTime"..RagdollOwner(Entity):EntIndex(), 8, 1, function() end)
			local fake = Entity
			timer.Create( "StunEffect"..RagdollOwner(Entity):EntIndex(), 0.1, 80, function()
				if rand == 50 then
					RagdollOwner(fake):Say("*drop")
				end
				RagdollOwner(fake).pain = RagdollOwner(fake).pain + 3
				fake:GetPhysicsObjectNum(1):SetVelocity(fake:GetPhysicsObjectNum(1):GetVelocity()+Vector(math.random(-55,55),math.random(-55,55),0))
				fake:EmitSound("ambient/energy/spark2.wav")
			end)
		else
			local fake = Entity
			timer.Create( "StunEffect"..Entity:EntIndex(), 0.1, 80, function()
				fake:GetPhysicsObjectNum(1):SetVelocity(fake:GetPhysicsObjectNum(1):GetVelocity()+Vector(math.random(-55,55),math.random(-55,55),0))
				fake:EmitSound("ambient/energy/spark2.wav")
			end)
		end
	end
end


concommand.Add("fake",function(ply)
if timer.Exists("faketimer"..ply:EntIndex()) then return nil end
if timer.Exists("StunTime"..ply:EntIndex()) then return nil end
if ply:GetNWEntity("Ragdoll").isheld==true then return nil end

if ply.brokenspine then return nil end
if IsValid(ply:GetNWEntity("Ragdoll")) and ply:GetNWEntity("Ragdoll"):GetVelocity():Length()>300 then return nil end
if IsValid(ply:GetNWEntity("Ragdoll")) and table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))>0 then return nil end

--if IsValid(ply:GetNWEntity("Ragdoll")) and table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Weld' ))>0 then return nil end

if ply.pain>(250*(ply.Blood/5000))+(ply:GetNWInt("SharpenAMT")*5) or ply.Blood<3000 then return end
	timer.Create("faketimer"..ply:EntIndex(), 2, 1, function() end)
	if ply:Alive() then
		Faking(ply)
		ply.fakeragdoll=ply:GetNWEntity("Ragdoll")
	end
end)

hook.Add("PreCleanupMap","cleannoobs",function() --все игроки встают после очистки карты
	for i, v in pairs(player.GetAll()) do
		if v.fake then Faking(v) end
	end

	BleedingEntities = {}

end)

local function CreateArmor(ragdoll,info)
	local item = JMod.ArmorTable[info.name]
	if not item then return end

	local Index = ragdoll:LookupBone(item.bon)
	if not Index then return end

	local Pos,Ang = (ply or ragdoll):GetBonePosition(Index)
	if not Pos then return end

	local ent = ents.Create(item.ent)

	local Right,Forward,Up = Ang:Right(),Ang:Forward(),Ang:Up()
	Pos = Pos + Right * item.pos.x + Forward * item.pos.y + Up * item.pos.z

	Ang:RotateAroundAxis(Right,item.ang.p)
	Ang:RotateAroundAxis(Up,item.ang.y)
	Ang:RotateAroundAxis(Forward,item.ang.r)

	ent:SetPos(Pos)
	ent:SetAngles(Ang)

	local color = info.col

	ent:SetColor(Color(color.r,color.g,color.b,color.a))

	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetMaterial("plastic")
	end
	constraint.Weld(ent,ragdoll,0,ragdoll:TranslateBoneToPhysBone(Index),0,true,false)

	ragdoll:DeleteOnRemove(ent)

	return ent
end

local function Remove(self,ply)
	if self.override then return end

	self.ragdoll.armors[self.armorID] = nil
	JMod.RemoveArmorByID(ply,self.armorID,true)
end

local function RemoveRag(self)
	for id,ent in pairs(self.armors) do
		if not IsValid(ent) then continue end

		ent.override = true
		ent:Remove()
	end
end

local CustomWeight = {
	["models/player/police_fem.mdl"] = 50,
	["models/player/police.mdl"] = 60,
	["models/player/combine_soldier.mdl"] = 70,
	["models/player/combine_super_soldier.mdl"] = 80,
	["models/player/combine_soldier_prisonguard.mdl"] = 70,
	["models/player/azov.mdl"] = 10,
	["models/player/Rusty/NatGuard/male_01.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_02.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_03.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_04.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_05.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_06.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_07.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_08.mdl"] = 90,
	["models/player/Rusty/NatGuard/male_09.mdl"] = 90,
	["models/LeymiRBA/Gyokami/Gyokami.mdl"] = 50,
	["models/player/smoky/Smoky.mdl"] = 65,
	["models/player/smoky/Smokycl.mdl"] = 65
}
--НЕ ОТМЕНЯЙ ЗАДРАЛ


function PlayerMeta:CreateRagdoll(attacker, dmginfo) --изменение функции регдолла
	if true then return end
	if !self:Alive() and self.fake then return nil end
	local rag=self:GetNWEntity("Ragdoll")
	if(IsValid(rag.ZacConsLH))then
		rag.ZacConsLH:Remove()
		rag.ZacConsLH=nil
	end
	if(IsValid(rag.ZacConsRH))then
		rag.ZacConsRH:Remove()
		rag.ZacConsRH=nil
	end
	local Data = duplicator.CopyEntTable( self )
	local rag = ents.Create( "prop_ragdoll" )
	duplicator.DoGeneric( rag, Data )
	rag:SetModel(self:GetModel())
	--rag:SetColor(self:GetColor()) --huy sosi garry
	rag:SetNWVector("plycolor",self:GetPlayerColor())
	rag:SetSkin(self:GetSkin())
	rag:Spawn()
	if IsValid(rag:GetPhysicsObject()) then
		rag:GetPhysicsObject():SetMass(CustomWeight[rag:GetModel()] or 20)
	end
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag:SetNWEntity("RagdollOwner", self)
	local vel = self:GetVelocity()/1
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local physobj = rag:GetPhysicsObjectNum( i )
		local ragbonename = rag:GetBoneName(rag:TranslatePhysBoneToBone(i))
		local bone = self:LookupBone(ragbonename)
		if(bone)then
			local bonemat = self:GetBoneMatrix(bone)
			if(bonemat)then
				local bonepos = bonemat:GetTranslation()
				local boneang = bonemat:GetAngles()
				physobj:SetPos( bonepos,true )
				physobj:SetAngles( boneang )
				if !self:Alive() then vel=vel end
				physobj:AddVelocity( vel )
			end
		end
	end
	if self:Alive() then
        self:SetNWEntity("Ragdoll", rag )
    else
        self:SetNWEntity("Ragdoll", rag )
        rag.Info=self.Info
        if IsValid(self:GetActiveWeapon()) then
            self.curweapon=self:GetActiveWeapon():GetClass()
            if table.HasValue(Guns,self.curweapon) then SpawnWeapon(self) end
        end
        SavePlyInfo(self)
        rag.Info=self.Info
        rag.curweapon=self.curweapon
        self:Spectate(OBS_MODE_CHASE)
        self:SpectateEntity(rag)
        rag:SetEyeTarget(Vector(0,0,0))
        rag:SetFlexWeight(9,0)
        if self.IsBleeding or (self.BloodLosing or 0) > 0 then
			rag.IsBleeding=true
			rag.bloodNext = CurTime()
			rag.Blood = self.Blood
			table.insert(BleedingEntities,rag)
		end
        rag.deadbody=true
        self:SetNWEntity("Ragdoll", nil )
    end

	rag:SetNWString("Nickname",self:Name())

	local armors = {}

	for id,info in pairs(self.EZarmor.items) do
		local ent = CreateArmor(rag,info)
		ent.armorID = id
		ent.ragdoll = rag
		ent.Owner = self
		armors[id] = ent

		ent:CallOnRemove("Fake",Remove,self)
	end

	rag.armors = armors
	rag:CallOnRemove("Armors",RemoveRag)

	self.FakeRagdoll = rag
end

hook.Add("JMod Armor Remove","Fake",function(ply,slot,item,drop)
	local fake = ply.FakeRagdoll
	if not IsValid(fake) then return end

	local ent = fake.armors[slot.id]
	if not IsValid(ent) then return end

	ent:Remove()
end)

hook.Add("JMod Armor Equip","Fake",function(ply,slot,item,drop)
	local fake = ply.FakeRagdoll
	if not IsValid(fake) then return end

	local ent = CreateArmor(fake,item)
	ent.armorID = slot.id
	fake.armors[slot.id] = ent
	ent:CallOnRemove("Fake",Remove,ent,ply)
end,2)--lol4ik

local gg = CreateConVar("hg_oldcollidefake","0")
COMMANDS.oldcollidefake = {function(ply,args)
	GetConVar("hg_oldcollidefake"):SetBool(tonumber(args[1]) > 0)
	PrintMessage(3,"Старая система collide fake - " .. tostring(gg:GetBool()))
end}

hook.Add("Player Collide","homigrad-fake",function(ply,hitEnt,data)
	--if not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not ply.fake and not hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 80 then
	if
		(gg:GetBool() and not ply:HasGodMode() and data.Speed > 200) or
		(not gg:GetBool() and not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not ply.fake and not hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 80)
	then
		timer.Simple(0,function()
			if not IsValid(ply) or ply.fake then return end

			Faking(ply)
		end)
	end
end)

hook.Add("OnPlayerHitGround","GovnoJopa",function(ply,a,b,speed)
	if speed > 200 then
		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() - Vector(0,0,10)
		tr.mins = ply:OBBMins()
		tr.maxs = ply:OBBMaxs()
		tr.filter = ply
		local traceResult = util.TraceHull(tr)
		if traceResult.Entity:IsPlayer() and not traceResult.Entity.fake then
			Faking(traceResult.Entity)
		end
	end
end)

hook.Add("Think","VelocityFakeHitPlyCheck",function() --проверка на скорость в фейке (для сбивания с ног других игроков)
	for i,rag in pairs(ents.FindByClass("prop_ragdoll")) do
		if IsValid(rag) then
			if rag:GetVelocity():Length() > 200 then
				rag:SetCollisionGroup(COLLISION_GROUP_NONE)
			else
				rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end
	end
end)
local CurTime = CurTime
hook.Add("StartCommand","asdfgghh",function(ply,cmd)
	local rag = ply:GetNWEntity("Ragdoll")
	--if (ply.GotUp or 0) - CurTime() > -0.1 and not IsValid(rag) then cmd:AddKey(IN_DUCK) end
	if IsValid(rag) then cmd:RemoveKey(IN_DUCK) end
end)

local dvec = Vector(0,0,-64)
hook.Add("Player Think","FakeControl",function(ply,time) --управление в фейке
	ply.holdingartery=false
	local rag = ply:GetNWEntity("Ragdoll")

	if not IsValid(rag) or not ply:Alive() then return end
	local bone = rag:LookupBone("ValveBiped.Bip01_Head1")
	if not bone then return end
	if IsValid(ply.bull) then
		ply.bull:SetPos(rag:GetPos())
	end
	local head1 = rag:GetBonePosition(bone) + dvec
	ply:SetPos(head1)
	ply:SetNWBool("fake",ply.fake)
	local deltatime = CurTime()-(rag.ZacLastCallTime or CurTime())
	rag.ZacLastCallTime=CurTime()
	local eyeangs = ply:EyeAngles()
	local head = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Head1" )) )
	rag:SetFlexWeight(9,0)
	local dist = (rag:GetAttachment(rag:LookupAttachment( "eyes" )).Ang:Forward()*10000):Distance(ply:GetAimVector()*10000)
	local distmod = math.Clamp(1-(dist/20000),0.1,1)
	local lookat = LerpVector(distmod,rag:GetAttachment(rag:LookupAttachment( "eyes" )).Ang:Forward()*100000,ply:GetAimVector()*100000)
	local attachment = rag:GetAttachment( rag:LookupAttachment( "eyes" ) )
	local LocalPos, LocalAng = WorldToLocal( lookat, Angle( 0, 0, 0 ), attachment.Pos, attachment.Ang )
	if !RagdollOwner(rag).Otrub then rag:SetEyeTarget( LocalPos ) else rag:SetEyeTarget( Vector(0,0,0) ) end
	if RagdollOwner(rag):Alive() then
		--RagdollOwner(rag):SetMoveParent( rag )
		--RagdollOwner(rag):SetParent( rag )
	if !RagdollOwner(rag).Otrub and !timer.Exists("StunTime"..ply:EntIndex()) then

		if ply:KeyDown( IN_JUMP ) and table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))>0 and ply.stamina>45 then
			local RopeCount = table.Count(constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' ))
			Ropes = constraint.FindConstraints( ply:GetNWEntity("Ragdoll"), 'Rope' )
			Try = math.random(1,10*RopeCount)
			ply.stamina=ply.stamina - 4*(RopeCount/6)
			local phys = rag:GetPhysicsObjectNum( 1 )
			local speed = 200
			local shadowparams = {
				secondstoarrive=0.05,
				pos=phys:GetPos()+phys:GetAngles():Forward()*20,
				angle=phys:GetAngles(),
				maxangulardamp=30,
				maxspeeddamp=30,
				maxangular=90,
				maxspeed=speed,
				teleportdistance=0,
				deltatime=0.01,
			}
			phys:Wake()
			phys:ComputeShadowControl(shadowparams)
			if Try > (7*RopeCount) then
				if RopeCount>1 then
					ply:ChatPrint("Осталось: "..RopeCount - 1)
				else
					ply:ChatPrint("Ты развязался")
				end
				Ropes[1].Constraint:Remove()
				rag:EmitSound("snd_jack_hmcd_ducttape.wav",90,50,0.5,CHAN_AUTO)
			end
		end


		if(ply:KeyPressed(IN_RELOAD))then
			Reload(ply.wep)
		end
		if(ply:KeyDown(IN_ATTACK))then
			local pos = ply:EyePos()
			pos[3] = head:GetPos()[3]
            if !ply.FakeShooting and !ply.arterybleeding then
				local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
				local ang=ply:EyeAngles()
				ang:RotateAroundAxis(eyeangs:Forward(),90)
				ang:RotateAroundAxis(eyeangs:Right(),75)
				local shadowparams = {
					secondstoarrive=0.4,
					pos=head:GetPos()+eyeangs:Forward()*50+eyeangs:Right()*-5,
					angle=ang,
					maxangular=670,
					maxangulardamp=600,
					maxspeeddamp=50,
					maxspeed=500,
					teleportdistance=0,
					deltatime=0.01,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
		if Automatic[ply.curweapon] then
			if(ply:KeyDown(IN_ATTACK))then--KeyDown if an automatic gun
				if ply.FakeShooting then FireShot(ply.wep) end
			end
		else
			if(ply:KeyPressed(IN_ATTACK))then
				if ply.FakeShooting then FireShot(ply.wep) end
			end
		end
		if(ply:KeyDown(IN_ATTACK2))then
			local physa = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ) --rhand
			local ang=ply:EyeAngles() --LerpAngle(0.5,ply:EyeAngles(),ply:GetNWEntity("Ragdoll"):GetAttachment(1).Ang)
			ang:RotateAroundAxis(eyeangs:Forward(),90)
			ang:RotateAroundAxis(eyeangs:Right(),75)
			local pos = ply:EyePos()
			pos[3] = head:GetPos()[3]
			local shadowparams = {
				secondstoarrive=0.4,
				pos=head:GetPos()+eyeangs:Forward()*50+eyeangs:Right()*5,
				angle=ang,
				maxangular=670,
				maxangulardamp=600,
				maxspeeddamp=50,
				maxspeed=600,
				teleportdistance=0,
				deltatime=0.01,
			}--я расстояние выбирал специально чтобы можно было большую скорость ставить, а че вы сделали что бы оно не улетали модельки, типо алянсеров
			physa:Wake()
			if (!ply.suiciding or TwoHandedOrNo[ply.curweapon]) then
				if TwoHandedOrNo[ply.curweapon] and IsValid(ply.wep) then
					local ang = ply:EyeAngles()
					ang:RotateAroundAxis(ang:Forward(),90)

					--ang:RotateAroundAxis(ang:Up(),-120)
					--ang:RotateAroundAxis(ang:Right(),-40)
					shadowparams.angle = ang

					ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)

					shadowparams.pos=shadowparams.pos+eyeangs:Right()*20
					phys:ComputeShadowControl(shadowparams)
					shadowparams.pos=shadowparams.pos+eyeangs:Forward()*-50+eyeangs:Right()*-15
					physa:ComputeShadowControl(shadowparams)

				elseif IsValid(ply.wep) then
					ang:RotateAroundAxis(eyeangs:Forward(),90)
					ang:RotateAroundAxis(eyeangs:Up(),-45)
					shadowparams.angle=ang
					shadowparams.pos=shadowparams.pos+eyeangs:Right()*-20

					ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
					physa:ComputeShadowControl(shadowparams)
				else
					physa:ComputeShadowControl(shadowparams)
				end
			else
				if ply.FakeShooting and IsValid(ply.wep) then
					shadowparams.maxspeed=500
					shadowparams.maxangular=500
					shadowparams.pos=head:GetPos()-ply.wep:GetAngles():Forward()*12
					shadowparams.angle=ply.wep:GetPhysicsObject():GetAngles()
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
		if(ply:KeyDown(IN_USE))then
			local phys = head
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Forward(),90)
			angs:RotateAroundAxis(angs:Up(),90)
			local shadowparams = {
				secondstoarrive=0.5,
				pos=head:GetPos()+vector_up*(20/math.Clamp(rag:GetVelocity():Length()/300,1,12)),
				angle=angs,
				maxangulardamp=10,
				maxspeeddamp=10,
				maxangular=370,
				maxspeed=40,
				teleportdistance=0,
				deltatime=deltatime,
			}
			head:Wake()
			head:ComputeShadowControl(shadowparams)
		end
		end
		if(ply:KeyDown(IN_SPEED)) and ply.stamina>45 and !RagdollOwner(rag).Otrub and !timer.Exists("StunTime"..ply:EntIndex()) then
			local bone = rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" ))
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
			if ply.arterybleeding and !TwoHandedOrNo[ply.curweapon] then
				local shadowparams = {
				secondstoarrive=0.5,
				pos=head:GetPos(),
				angle=angs,
				maxangulardamp=10,
				maxspeeddamp=10,
				maxangular=370,
				maxspeed=1120,
				teleportdistance=0,
				deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
				ply.holdingartery=true
				if(IsValid(rag.ZacConsLH))then
					rag.ZacConsLH:Remove()
					rag.ZacConsLH=nil
				end
			end
			if(!IsValid(rag.ZacConsLH) and (!rag.ZacNextGrLH || rag.ZacNextGrLH<=CurTime()))then
				rag.ZacNextGrLH=CurTime()+0.1
				for i=1,3 do
					local offset = phys:GetAngles():Up()*-5
					if(i==2)then
						offset = phys:GetAngles():Right()*5
					end
					if(i==3)then
						offset = phys:GetAngles():Right()*-5
					end
					local traceinfo={
						start=phys:GetPos(),
						endpos=phys:GetPos()+offset,
						filter=rag,
						output=trace,
					}
					local trace = util.TraceLine(traceinfo)
					if(trace.Hit and !trace.HitSky)then
						local cons = constraint.Weld(rag,trace.Entity,bone,trace.PhysicsBone,0,false,false)
						if(IsValid(cons))then
							rag.ZacConsLH=cons
						end
						break
					end
				end
			end
		else
			if ply.arterybleeding then ply.holdingartery=false end
			if(IsValid(rag.ZacConsLH))then
				rag.ZacConsLH:Remove()
				rag.ZacConsLH=nil
			end
		end
		if(ply:KeyDown(IN_WALK)) and ply.stamina>45 and !RagdollOwner(rag).Otrub and !timer.Exists("StunTime"..ply:EntIndex()) then
			local bone = rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))
			local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
			if(!IsValid(rag.ZacConsRH) and (!rag.ZacNextGrRH || rag.ZacNextGrRH<=CurTime()))then
				rag.ZacNextGrRH=CurTime()+0.1
				for i=1,3 do
					local offset = phys:GetAngles():Up()*5
					if(i==2)then
						offset = phys:GetAngles():Right()*5
					end
					if(i==3)then
						offset = phys:GetAngles():Right()*-5
					end
					local traceinfo={
						start=phys:GetPos(),
						endpos=phys:GetPos()+offset,
						filter=rag,
						output=trace,
					}
					local trace = util.TraceLine(traceinfo)
					if(trace.Hit and !trace.HitSky)then
						local cons = constraint.Weld(rag,trace.Entity,bone,trace.PhysicsBone,0,false,false)
						if(IsValid(cons))then
							rag.ZacConsRH=cons
						end
						break
					end
				end
			end
		else
			if(IsValid(rag.ZacConsRH))then
				rag.ZacConsRH:Remove()
				rag.ZacConsRH=nil
			end
		end
		if(ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH))then
			local phys = rag:GetPhysicsObjectNum( 1 )
			local lh = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Forward(),90)
			angs:RotateAroundAxis(angs:Up(),90)
			local speed = 30
			ply.stamina=ply.stamina - 0.02
			if(rag.ZacConsLH.Ent2:GetVelocity():LengthSqr()<1000) then
				local shadowparams = {
					secondstoarrive=0.5,
					pos=lh:GetPos(),
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
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
				local angre=ply:EyeAngles()
				angre:RotateAroundAxis(ply:EyeAngles():Forward(),-90)
				shadowparams.angle=angre
				shadowparams.maxangular=100
				shadowparams.pos=rag:GetPhysicsObjectNum( 1 ):GetPos()
				shadowparams.secondstoarrive=1
				rag:GetPhysicsObjectNum( 0 ):Wake()
				rag:GetPhysicsObjectNum( 0 ):ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH))then
			local phys = rag:GetPhysicsObjectNum( 1 )
			local rh = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Forward(),90)
			angs:RotateAroundAxis(angs:Up(),90)
			local speed = 30
			ply.stamina=ply.stamina - 0.02
			if(rag.ZacConsRH.Ent2:GetVelocity():LengthSqr()<1000)then
				local shadowparams = {
					secondstoarrive=0.5,
					pos=rh:GetPos(),
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
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
				local angre2=ply:EyeAngles()
				angre2:RotateAroundAxis(ply:EyeAngles():Forward(),90)
				shadowparams.angle=angre2
				shadowparams.maxangular=100
				shadowparams.pos=rag:GetPhysicsObjectNum( 1 ):GetPos()
				shadowparams.secondstoarrive=1
				rag:GetPhysicsObjectNum( 0 ):Wake()
				rag:GetPhysicsObjectNum( 0 ):ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsLH))then
			local phys = rag:GetPhysicsObjectNum( 1 )
			local chst = rag:GetPhysicsObjectNum( 0 )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Forward(),90)
			angs:RotateAroundAxis(angs:Up(),90)
			local speed = 30
			ply.stamina=ply.stamina - 0.02
			if(rag.ZacConsLH.Ent2:GetVelocity():LengthSqr()<1000)then
				local shadowparams = {
					secondstoarrive=0.5,
					pos=chst:GetPos(),
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
		if(ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsRH))then
			local phys = rag:GetPhysicsObjectNum( 1 )
			local chst = rag:GetPhysicsObjectNum( 0 )
			local angs = ply:EyeAngles()
			angs:RotateAroundAxis(angs:Forward(),90)
			angs:RotateAroundAxis(angs:Up(),90)
			local speed = 30
			ply.stamina=ply.stamina - 0.02
			if(rag.ZacConsRH.Ent2:GetVelocity():LengthSqr()<1000)then
				local shadowparams = {
					secondstoarrive=0.5,
					pos=chst:GetPos(),
					angle=phys:GetAngles(),
					maxangulardamp=10,
					maxspeeddamp=10,
					maxangular=50,
					maxspeed=speed,
					teleportdistance=0,
					deltatime=deltatime,
				}
				phys:Wake()
				phys:ComputeShadowControl(shadowparams)
			end
		end
	end
end)

hook.Add("Player Think","VelocityPlayerFallOnPlayerCheck",function(ply,time)
	if ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:GetVelocity():Length()>600 and ply:Alive() and not ply.fake and not ply:HasGodMode() then
		Faking(ply)
	end
end)


concommand.Add("suicide",function(ply)
	if !ply:Alive() then return nil end
	ply.suiciding=!ply.suiciding
end)

hook.Add("PlayerSwitchWeapon","fakewep",function(ply,oldwep,newwep)
	if ply.Otrub then return true end

	if ply.fake then
		if IsValid(ply.Info.ActiveWeapon2) and IsValid(ply.wep) and ply.wep.Clip!=nil and ply.wep.Amt!=nil and ply.wep.AmmoType!=nil then
			ply.Info.ActiveWeapon2:SetClip1((ply.wep.Clip or 0))
			ply:SetAmmo((ply.wep.Amt or 0), (ply.wep.AmmoType or 0))
		end

		if table.HasValue(Guns,newwep:GetClass()) then

			if IsValid(ply.wep) then DespawnWeapon(ply) end
			ply:SetActiveWeapon(newwep)
			ply.Info.ActiveWeapon=newwep
			ply.curweapon=newwep
			SavePlyInfo(ply)
			ply:SetActiveWeapon(nil)
			SpawnWeapon(ply)
			ply.FakeShooting=true

		else
			if IsValid(ply.wep) then DespawnWeapon(ply) end
			ply:SetActiveWeapon(nil)
			ply.curweapon=newwep
			ply.FakeShooting=false

		end
		return true
	end
end)

function PlayerMeta:HuySpectate()
	local ply = self
	ply:Spectate(OBS_MODE_CHASE)
	ply:UnSpectate()

	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end

OrgansNextThink = 0
InternalBleeding = 10

hook.Add("Player Think","InternalBleeding",function(ply,time)
	if true then return end
	for i,ply in pairs(player.GetAll()) do
		ply.OrgansNextThink = ply.OrgansNextThink or OrgansNextThink
		if not(ply.OrgansNextThink>CurTime())then
			ply.OrgansNextThink=CurTime()+0.2
			if ply.Organs and ply:Alive() then
				if ply.Organs["brain"]==0 then
					ply:Kill()
				end
				if ply.Organs["liver"]==0 then
					ply.InternalBleeding=ply.InternalBleeding or InternalBleeding
					ply.InternalBleeding=math.Clamp(ply.InternalBleeding-0.1,0,10)
					ply.Blood=ply.Blood-ply.InternalBleeding
				end
				if ply.Organs["stomach"]==0 then
					ply.InternalBleeding2=ply.InternalBleeding2 or InternalBleeding
					ply.InternalBleeding2=math.Clamp(ply.InternalBleeding2-0.1,0,10)
					ply.Blood=ply.Blood-ply.InternalBleeding2
				end
				if ply.Organs["intestines"]==0 then
					ply.InternalBleeding3=ply.InternalBleeding3 or InternalBleeding
					ply.InternalBleeding3=math.Clamp(ply.InternalBleeding3-0.1,0,10)
					ply.Blood=ply.Blood-ply.InternalBleeding3
				end
				if ply.Organs["heart"]==0 then
					ply.InternalBleeding4=ply.InternalBleeding4 or InternalBleeding
					ply.InternalBleeding4=math.Clamp(ply.InternalBleeding4*10-0.1,0,10)
					ply.Blood=ply.Blood-ply.InternalBleeding4*3
				end
				if ply.Organs["lungs"]==0 then
					ply.InternalBleeding5=ply.InternalBleeding5 or InternalBleeding
					ply.InternalBleeding5=math.Clamp(ply.InternalBleeding5-0.1,0,10)
					ply.Blood=ply.Blood-ply.InternalBleeding5
				end
				if ply.Organs["spine"]==0 then
					ply.brokenspine=true
					if !ply.fake then Faking(ply) end
				end
				if ply.Organs["artery"]==0 then
					ply.arterybleeding=true
				else
					ply.arterybleeding=false
				end
				if (ply.Blood<=2000 and ply:Alive()) or (ply.pain>1900 and ply:Alive()) then
					ply:ExitVehicle()
					ply:Kill()
					ply.Bloodlosing=0
					ply:SetNWInt("BloodLosing",0)
				end
			end
		end
	end
end)

hook.Add("PlayerUse","nouseinfake",function(ply)
	if ply.fake then return false end
end)

hook.Add("PlayerSay", "unconsay", function(ply,txt)
if ply.Otrub then return false end
end)

hook.Add("PlayerSay","dropweaponhuy",function(ply,text)
    if string.lower(text)=="*drop" then
        if !ply.fake then
            ply:DropWeapon1()
            return ""
        else
            if IsValid(ply.wep) then
                if IsValid(ply.WepCons) then
                    ply.WepCons:Remove()
                    ply.WepCons=nil
                end
                if IsValid(ply.WepCons2) then
                    ply.WepCons2:Remove()
                    ply.WepCons2=nil
                end
                ply.wep.canpickup=true
                ply.wep:SetOwner()
                ply.wep.curweapon=ply.curweapon
                ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
                ply:StripWeapon(ply.Info.ActiveWeapon)
                ply.Info.Weapons[ply.Info.ActiveWeapon]=nil
                ply.wep=nil
                ply.Info.ActiveWeapon=nil
                ply.Info.ActiveWeapon2=nil
                ply:SetActiveWeapon(nil)
                ply.FakeShooting=false
            else
                ply:PickupEnt()
            end
            return ""
        end
    end
	if string.lower(text)=="!viptest" then
		if !ply.fake then
		ply:SetVelocity( Vector(0,0,50000) )
		timer.Simple( 5, function()
			ply:Ban(1,false)
			ply:Kick("Ну как тебе ВИП ТЕСТ!!! минутка бана))))")

		end)
		else
		ply:GetNWEntity("Ragdoll"):GetPhysicsObjectNum(0):SetVelocity( Vector(0,0,50000) )
		timer.Simple( 5, function()
			ply:Ban(1,false)
			ply:Kick("Ну как тебе ВИП ТЕСТ!!! хи фейк не поможет, жди минуту")
		end)
		end
	end
end)

if (SERVER) then
util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("ply_take_ammo")
end

local function send(ply,lootEnt,remove)
	if ply then
		net.Start("inventory")
		net.WriteEntity(not remove and lootEnt or nil)

		net.WriteTable(lootEnt.Info.Weapons)
		net.WriteTable(lootEnt.Info.Ammo)
		net.Send(ply)
	else
		for ply in pairs(lootEnt.UsersInventory) do
			if not IsValid(ply) or not ply:Alive() then lootEnt.UsersInventory[ply] = nil continue end

			send(ply,lootEnt,remove)
		end
	end
end

hook.Add("PlayerSpawn","!!!huyassdd",function(lootEnt)
	if lootEnt.unfaked then
		if lootEnt.UsersInventory ~= nil then
			for plys,bool in pairs(lootEnt.UsersInventory) do
				lootEnt.UsersInventory[plys] = nil
				send(plys,lootEnt,true)
			end
		end
	end
end)

hook.Add("Player Think","Looting",function(ply)
	local key = ply:KeyDown(IN_USE)

	if not ply.fake and ply:Alive() and ply:KeyDown(IN_ATTACK2) then
		if ply.okeloot ~= key and key then
			local tr = {}
			tr.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
			tr.endpos = tr.start + ply:EyeAngles():Forward() * 64
			tr.filter = ply
			local tracea = util.TraceLine(tr)
			local hitEnt = tracea.Entity

			if not IsValid(hitEnt) then return end
			if IsValid(RagdollOwner(hitEnt)) then hitEnt = RagdollOwner(hitEnt) end
			if IsValid(hitEnt) and hitEnt.IsJModArmor then hitEnt = hitEnt.Owner end
			if hitEnt:IsPlayer() and hitEnt:Alive() and not hitEnt.fake then return end
			if not hitEnt.Info then return end

			hitEnt.UsersInventory = hitEnt.UsersInventory or {}
			hitEnt.UsersInventory[ply] = true

			send(ply,hitEnt)
		end
	end

	ply.okeloot = key
end)

local prekol = {
	weapon_physgun = true,
	gmod_tool = true
}

net.Receive("inventory",function(len,ply)
	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end

	lootEnt.UsersInventory[ply] = nil
end)

net.Receive("ply_take_item",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end

	local wep = net.ReadString()
	--local takeammo = net.ReadBool()

	local lootInfo = lootEnt.Info
	local wepInfo = lootInfo.Weapons[wep]

	if not wepInfo then return end

	if prekol[wep] and not ply:IsAdmin() then ply:Kick("xd))00") return end

	if IsValid(wep) and ply:HasWeapon(wep) then
		if wepInfo.Clip1!=nil and wepInfo.Clip1 > 0 then
			ply:GiveAmmo(wepInfo.AmmoType,wepInfo.Clip1)
			wepInfo.Clip1 = 0
		end
	else
		ply.slots = ply.slots or {}
		if not ply.slots[weapons.Get(wep).Slot] then
			ply.slots[weapons.Get(wep).Slot] = true

			if IsValid(lootEnt.wep) and lootInfo.ActiveWeapon == wep then
				lootEnt.wep:Remove()
			end

			local wep1 = ply:Give(wep)
			if IsValid(wep1) and wep1:IsWeapon() then
				wep1:SetClip1(wepInfo.Clip1 or 0)
			end
			if lootEnt:IsPlayer() then lootEnt:StripWeapon(wep) end
			lootInfo.Weapons[wep] = nil
			table.RemoveByValue(lootInfo.Weapons2,wep)
		end
	end

	send(nil,lootEnt)
end)

net.Receive("ply_take_ammo",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end
	local ammo = net.ReadFloat()
	local lootInfo = lootEnt.Info
	if not lootInfo.Ammo[ammo] then return end

	ply:GiveAmmo(lootInfo.Ammo[ammo],ammo)
	lootInfo.Ammo[ammo] = nil

	send(nil,lootEnt)
end)

hook.Add("Player Think","ControlPlayersAdmins",function(ply,time)
	if !ply:IsAdmin() or ply:Alive() then return end

	if ply:KeyDown(IN_ATTACK) and not ply.EnableSpectate and ply.allowGrab then
		local enta = ply:GetEyeTrace().Entity
		if enta:IsPlayer() and !enta.fake and !IsValid(ply.CarryEnt) then
			Faking(enta)
			PrintMessage(HUD_PRINTCONSOLE,tostring(ply:Name()).." поднял игрока "..enta:Name())
		end
		if !IsValid(enta:GetPhysicsObject()) then return end
		ply.CarryEntPhysbone = ply.CarryEntPhysbone or ply:GetEyeTrace().PhysicsBone
		local physbone = ply.CarryEntPhysbone
		ply.CarryEnt = IsValid(ply.CarryEnt) and ply.CarryEnt or enta
		timer.Simple(5, function() ply.AdminAttackerWithPhys = false end)
		if IsValid(ply.CarryEnt) then
			if ply:KeyPressed(IN_ATTACK) then
				PrintMessage(HUD_PRINTCONSOLE,tostring(ply:Name()).." поднял ентити "..tostring(RagdollOwner(ply.CarryEnt) and RagdollOwner(ply.CarryEnt):Name() or ply.CarryEnt:GetClass()))
			end

			ply.CarryEnt:SetPhysicsAttacker(ply,5)

			ply.CarryEntLen = math.max(ply.CarryEntLen or ply.CarryEnt:GetPos():Distance(ply:EyePos()), 50)
			local ent = ply.CarryEnt
			local len = ply.CarryEntLen
			ply.CarryEnt:GetPhysicsObjectNum(ply.CarryEntPhysbone):EnableMotion(true)
			ply.CarryEnt.isheld = true
			local ang = ply:EyeAngles()
			ang[1] = 0
			if ent and len then
				local shadowparams = {}
				shadowparams.pos = ply:EyePos() + ply:EyeAngles():Forward() * len
				shadowparams.angle = ang
				shadowparams.maxangular = 50
				shadowparams.maxangulardamp = 25
				shadowparams.maxspeed = 10000
				shadowparams.maxspeeddamp = 1000
				shadowparams.dampfactor = 0.8
				shadowparams.teleportdistance = 0
				shadowparams.deltatime = CurTime()
				ent:GetPhysicsObjectNum(physbone):Wake()
				ent:GetPhysicsObjectNum(physbone):ComputeShadowControl(shadowparams)
			end
		end
	else
		if IsValid(ply.CarryEnt) then
			ply.CarryEnt.isheld = false
			ply.CarryEnt = nil
			ply.CarryEntLen = nil
			ply.CarryEntPhysbone = nil
		end
	end
	if ply:KeyDown(IN_ATTACK2) and ply.allowGrab then
		if IsValid(ply.CarryEnt) then
			ply.CarryEnt:GetPhysicsObjectNum(ply.CarryEntPhysbone):EnableMotion(false)
			ply.CarryEnt.isheld = true
		end
	end
end)

hook.Add("StartCommand","PickupPlayersAdmin",function(ply, cmd)
	local num = ply:GetInfo("physgun_wheelspeed")
	if !IsValid(ply.CarryEnt) then return end
	if cmd:GetMouseWheel() > 0 then ply.CarryEntLen = ply.CarryEntLen + num end
	if cmd:GetMouseWheel() < 0 then ply.CarryEntLen = ply.CarryEntLen - num end
end)

hook.Add("AllowPlayerPickup","ya_ebal_slona",function(ply,ent)
	return not ent:IsPlayerHolding()
end)

hook.Add("UpdateAnimation","huy",function(ply,event,data)
	--[[if ply:GetActiveWeapon().TwoHands then
		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD, ply:Crouching() and 62 or 98, 0, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, 1 )
		if ply==Entity(3) then
			--p-rint(ply,ply:IsPlayingGesture(ACT_GMOD_NOCLIP_LAYER))
		EntRound
		if ply:IsPlayingGesture(ACT_GMOD_NOCLIP_LAYER) then
			ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, true)
		end
	else
		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD, ply:Crouching() and 139 or 110, 0, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, 1 )
		if ply==Entity(3) then
			--p-rint(ply,ply:IsPlayingGesture(ACT_GMOD_NOCLIP_LAYER))
		end
		if ply:IsPlayingGesture(ACT_GMOD_NOCLIP_LAYER) then
			ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, true)
		end
	end--]]
	ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER)
	--p-rint(ply,ply:LookupSequence(ply:GetSequenceName(ply:GetSequence())))
	--ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_VM_PRIMARYATTACK, true)
	--return ACT_VM_PRIMARYATTACK


	--fuck GARRYSMOD!!!!!!
end)

hook.Add("Player Think","holdentity",function(ply,time)
	--[[if IsValid(ply.holdEntity) then

	end--]]
end)

