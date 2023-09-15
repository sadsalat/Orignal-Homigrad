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
hook.Add("EntityTakeDamage","phildcorn",function(victim, dmginfo)
	victim.Blood=victim.Blood or 5000
	victim.Bloodlosing=victim.Bloodlosing or 0
	--[[if dmginfo:IsDamageType(DMG_BLAST) then
        Faking(victim)
    end]]--


	if dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BLAST+DMG_ENERGYBEAM+DMG_NEVERGIB+DMG_ALWAYSGIB+DMG_PLASMA+DMG_AIRBOAT+DMG_SNIPER+DMG_BUCKSHOT) then
	if victim:IsPlayer() or IsValid(RagdollOwner(victim)) then
		damage=dmginfo:GetDamage()
		victim.Bloodlosing=victim.Bloodlosing+(damage/3)
		victim:SetNWInt("BloodLosing",victim.Bloodlosing)
		victim.IsBleeding=true
	end
	end
end)
BLEEDING_NextThink=0
hook.Add("Think","saygex",function()
	for i, v in ipairs( player.GetAll() ) do
		v.Blood=v.Blood or 5000
		v.RightLeg=v.RightLeg or 1
		v.LeftLeg=v.LeftLeg or 1
		v.RightArm = v.RightArm or 1
		v.LeftArm = v.LeftArm or 1
		v.Speed=v:GetNWInt("Adrenaline") or 0
		v.BLEEDING_NextThink=v.BLEEDING_NextThink or BLEEDING_NextThink
		v.arterybloodlosing=v.arterybloodlosing or 0
		if models[v:GetModel()]  then
				v:SetModel("models/player/group01/male_01.mdl")
		end
		local pulse = math.Clamp((2-v.Blood/5000)-((v.Bloodlosing+v.arterybloodlosing)/250),0.1,1)
		if not(v.BLEEDING_NextThink>CurTime())then
		v.BLEEDING_NextThink=CurTime()+pulse
		if v.HasLeft==nil then
			--[[if not v:Alive() then --sync
				v:Kick("you dead fool")
				print("умер")
			end]]--
			v.Bloodlosing=v.Bloodlosing or 0
			if v.Bloodlosing < 0 then
				v.Bloodlosing = 0
				v:SetNWInt("BloodLosing",v.Bloodlosing)
			end
			if (v.Bloodlosing>0 or v.arterybleeding) then
				--print("pain: "..v.Bloodlosing.." - "..v:GetName())
				v.Bloodlosing=v:GetNWInt("BloodLosing")
				v.Bloodlosing=v.Bloodlosing-0.5
				v.Blood=v.Blood-v.Bloodlosing/5-v.arterybloodlosing/5
				v:SetNWInt("BloodLosing",v.Bloodlosing)
				v:SetNWInt("Blood",v.Blood)
				v:SetNWInt("Speed",v.Speed)
				if v.Organs["artery"]==0 and !v.holdingartery then
					v.arterybloodlosing=250
				else
					v.arterybloodlosing=50
				end
				if IsValid(v:GetNWEntity("DeathRagdoll")) then v.pos = v:GetNWEntity("DeathRagdoll"):GetPos() v:GetNWEntity("DeathRagdoll"):EmitSound( "ambient/water/drip"..math.random(1,4)..".wav", 60,math.random(230,240), 0.1, CHAN_AUTO ) else
				v.pos = v:GetPos() v:EmitSound( "ambient/water/drip"..math.random(1,4)..".wav", 60,math.random(230,240), 0.1, CHAN_AUTO ) end
				local rn=math.Rand(-0.35,0.35)
				local rnn=math.Rand(-0.35,0.35)
				local tr={}
				
				tr.start=Vector(v.pos)+Vector(0,0,50)
				tr.endpos=tr.start+Vector(rn,rnn,-1)*8000
				tr.filter={v,v.fakeragdoll}
				local trw=util.TraceHull(tr)
				local Pos1 = trw.HitPos + trw.HitNormal
				local Pos2 = trw.HitPos - trw.HitNormal
                util.Decal("Blood",Pos1,Pos2,v) 
			elseif v.Blood < 5000 then
				--print(v.Blood.." - "..v:GetName())
				v.Blood=v:GetNWInt("Blood")+5
				v:SetNWInt("Blood",v.Blood)
				v:SetNWInt("Speed",v.Speed)
				v.IsBleeding=false
			end
				v:SetWalkSpeed(((120*(v.Blood/5000))*(v.stamina/100)*(v.RightLeg)*(v.LeftLeg)))
				v:SetRunSpeed((((210*((v.Blood/5000))+(v.Speed*50)))*(v.stamina/100)*(v.RightLeg)*(v.LeftLeg)))
				v:SetJumpPower((((205*((v.Blood/5000))+(v.Speed*25)))*(v.stamina/100))*(v.RightLeg)*(v.LeftLeg))
		end
		end
	end
	end)
	BLEEDING_NextThink1 = 0
	hook.Add("Think","BleedingBodies",function()
		for i, ent in pairs(BleedingEntities) do
			if not ent.IsBleeding then return end
			ent.BLEEDING_NextThink1=ent.BLEEDING_NextThink1 or BLEEDING_NextThink1
			if not(ent.BLEEDING_NextThink1>CurTime())then
				ent.BLEEDING_NextThink1=CurTime()+math.random(0.6,0.8)
				local rn=math.Rand(-0.35,0.35)
				local rnn=math.Rand(-0.35,0.35)
				local tr={}
				tr.start=Vector(ent:GetPos(0,0,50))+Vector(0,0,50)
				tr.endpos=tr.start+Vector(rn,rnn,-1)*8000
				tr.filter=ent
				local trw=util.TraceHull(tr)
				local Pos1 = trw.HitPos + trw.HitNormal
				local Pos2 = trw.HitPos - trw.HitNormal
				ent:EmitSound( "ambient/water/drip"..math.random(1,4)..".wav", 60,math.random(230,240), 0.2, CHAN_AUTO )
				util.Decal("Blood",Pos1,Pos2,ent)
			end
		end
	end)
end
Bleeding()

function Bleeding1()

hook.Add( "PlayerSpawn","RefreshBlood",function(v)
v.unfaked=v.unfaked or false
if v.unfaked==false then
	v.IsBleeding=false
    v.Blood=5000
    v:SetNWInt("Blood",v.Blood)
    v.Bloodlosing=0
    v:SetNWInt("BloodLosing",0)
    v:ConCommand( "soundfade 0 1" )
    v.stamina = 100
	v:SetNWInt("stamina",v.stamina)
	v.LeftLeg = 1
	v.RightLeg = 1
	v.RightArm = 1
	v.LeftArm = 1
	v.Attacker = nil
end
end)
hook.Add("PlayerDeath", "deathblood", function(v)
v.Bloodlosing=0
v:SetNWInt("BloodLosing",0)
v.Blood=5000
v:SetNWInt("Blood",v.Blood)
v:ConCommand( "soundfade 0 1" )
v:SetNWInt("painlosing",1)
v.stamina = 100
v.LeftLeg = 1
v.RightLeg = 1
v.RightArm = 1
v.LeftArm = 1
v.arterybleeding = nil
v.Organs = {
		['brain']=20,
		['lungs']=30,
		['liver']=30,
		['stomach']=40,
		['intestines']=40,
		['heart']=10,
		['artery']=1,
		['spine']=10
	}
v.InternalBleeding=nil
v.InternalBleeding2=nil
v.InternalBleeding3=nil
v.InternalBleeding4=nil
v.InternalBleeding5=nil
v.arterybleeding=false
v.brokenspine=false
end)
hook.Add( "PlayerDisconnected", "playerLeave", function(ply)
ply.HasLeft=true
end)
timer.Simple(1, function()
function GAMEMODE:PlayerLoadout( ply )
	ply:Give( "weapon_hands" )
		--ply:Give( "act3_ak" )
		--ply:Give( "act3_knife" )
		--ply:Give( "act3_g17" )
		--ply:Give( "medkit" )
		--ply:Give( "bandage" )
		--ply:Give( "weapon_jmodnade" )
	return false
end
end)
end

Bleeding1()