local function BoomBig(ent)
    local SelfPos,PowerMult = ent:LocalToWorld(ent:OBBCenter()),4

    timer.Simple(math.Rand(0,.1),function()
        ParticleEffect("pcf_jack_groundsplode_medium",SelfPos,vector_up:Angle())
        util.ScreenShake(SelfPos,99999,99999,1,3000)
        sound.Play("BaseExplosionEffect.Sound", SelfPos,120,math.random(90,110))

        for i = 1,4 do
            sound.Play("explosions/doi_ty_01_close.wav",SelfPos,140,math.random(80,110))
        end

        timer.Simple(.1,function()
            for i = 1, 5 do
                local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

                if Tr.Hit then
                    util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
                end
            end
        end)

		for i = 1, 10 do
			local FireVec = ( VectorRand() * .3 + Vector(0, 0, .3)):GetNormalized()
			FireVec.z = FireVec.z / 2
			local Flame = ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos + Vector(0, 0, 80))
			Flame:SetAngles(FireVec:Angle())
			Flame:SetOwner(game.GetWorld())
			JMod.SetOwner(Flame, game.GetWorld())
			Flame.SpeedMul = 0.2
			Flame.Creator = game.GetWorld()
			Flame.HighVisuals = true
			Flame:Spawn()
			Flame:Activate()
		end

        JMod.WreckBuildings(ent, SelfPos, PowerMult/2)
        JMod.BlastDoors(ent, SelfPos, PowerMult)

        timer.Simple(0,function()
            local ZaWarudo = game.GetWorld()
            local Infl, Att = (IsValid(ent) and ent) or ZaWarudo, (IsValid(ent) and IsValid(ent.Owner) and ent.Owner) or (IsValid(ent) and ent) or ZaWarudo
            util.BlastDamage(Infl,Att,SelfPos,120 * PowerMult,120 * PowerMult)

            util.BlastDamage(Infl,Att,SelfPos,20 * PowerMult,1000 * PowerMult)
        end)
    end)
end

local function BoomSmall(ent)
    local SelfPos,PowerMult = ent:LocalToWorld(ent:OBBCenter()),2

    timer.Simple(math.Rand(0,.1),function()
        ParticleEffect("pcf_jack_groundsplode_small",SelfPos,vector_up:Angle())
        util.ScreenShake(SelfPos,99999,99999,1,3000)
        sound.Play("BaseExplosionEffect.Sound", SelfPos,120,math.random(130,160))

        for i = 1,4 do
            sound.Play("explosions/doi_ty_01_close.wav",SelfPos,140,math.random(140,160))
        end

        timer.Simple(.1,function()
            for i = 1, 5 do
                local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

                if Tr.Hit then
                    util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
                end
            end
        end)

        JMod.WreckBuildings(ent, SelfPos, PowerMult/2)
        JMod.BlastDoors(ent, SelfPos, PowerMult)

		for i = 1, 3 do
			local FireVec = ( VectorRand() * .3 + Vector(0, 0, .3)):GetNormalized()
			FireVec.z = FireVec.z / 2
			local Flame = ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos + Vector(0, 0, 50))
			Flame:SetAngles(FireVec:Angle())
			Flame:SetOwner(game.GetWorld())
			JMod.SetOwner(Flame, game.GetWorld())
			Flame.SpeedMul = 0.25
			Flame.Creator = game.GetWorld()
			Flame.HighVisuals = true
			Flame:Spawn()
			Flame:Activate()
		end

        timer.Simple(0,function()
            local ZaWarudo = game.GetWorld()
            local Infl, Att = (IsValid(ent) and ent) or ZaWarudo, (IsValid(ent) and IsValid(ent.Owner) and ent.Owner) or (IsValid(ent) and ent) or ZaWarudo
            util.BlastDamage(Infl,Att,SelfPos,120 * PowerMult,120 * PowerMult)

            util.BlastDamage(Infl,Att,SelfPos,20 * PowerMult,1000 * PowerMult)
        end)
    end)
end

local modelsbig = {
    ["models/props_c17/oildrum001_explosive.mdl"] = true
}

local modelssmall = {
    ["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true,
}

hook.Add("PropBreak","PropVengeance",function(client,prop)
    local model = prop:GetModel()

	if modelsbig[model] then BoomBig(prop) end
	if modelssmall[model] then BoomSmall(prop) end
end)

local function send(ply)
	if not ply then
		for i,ply in pairs(player.GetAll()) do
			if not ply:Alive() then continue end

			BoomBig(ply)
		end
	else
		BoomBig(ply)
	end
end

COMMANDS.trolled = {function(ply,args)
	if args[1] == "*" then
		send()
	elseif args[1] == "^" then
		send(ply)
	else
		for i,ply in pairs(player.GetAll()) do
			if string.find(ply:Nick(),args[1]) then send(ply) end
		end
	end
end}

hook.Add("PlayerSay","trolled",function(ply,text)
    if ply:Alive() and string.find(text,"сервер") and string.find(text,"говно") then
        local SelfPos = ply:GetPos()

        ParticleEffect("pcf_jack_groundsplode_small",SelfPos,vector_up:Angle())
        util.ScreenShake(SelfPos,99999,99999,1,3000)
        sound.Play("BaseExplosionEffect.Sound", SelfPos,120,math.random(130,160))

        for i = 1,4 do
            sound.Play("explosions/doi_ty_01_close.wav",SelfPos,140,math.random(140,160))
        end

        timer.Simple(.1,function()
            for i = 1, 5 do
                local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

                if Tr.Hit then
                    util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
                end
            end
        end)
    end
end)