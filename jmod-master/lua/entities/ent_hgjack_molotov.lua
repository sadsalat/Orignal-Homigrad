-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author = "sadsalat"
ENT.PrintName = "EZHG Molotov"
ENT.Category = "JModHomigrad"
ENT.Spawnable = true
ENT.Material = ""
ENT.MiniNadeDamage = 35
ENT.Model = "models/w_models/weapons/w_eq_molotov.mdl"

ENT.Hints = {"mininade"}

local BaseClass = baseclass.Get(ENT.Base)

if SERVER then
	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 40 and self:IsOnFire() then
			self:Detonate()
		else
			if data.DeltaTime > 0.2 and data.Speed > 30 then
				local sound = Sound("physics/glass/glass_bottle_impact_hard"..math.random(1,3)..".wav")
				self:EmitSound(sound)
			end
		end
	end


	function ENT:Arm()
		self:SetState(JMod.EZ_STATE_ARMING)
		self:SetBodygroup(2, 1)

		timer.Simple(.3, function()
			if IsValid(self) then
				self:SetState(JMod.EZ_STATE_ARMED)
			end
		end)
		self:EmitSound("ambient/fire/mtov_flame2.wav")
		self:Ignite(15)
		--self:SpoonEffect()
	end

	function ENT:CustomThink(state, tim)
		if state == JMod.EZ_STATE_ARMED then
			if IsValid(self.AttachedBomb) then
				if self.AttachedBomb:IsPlayerHolding() then
					self.NextDet = tim + .5
				end

				local CurVel = self.AttachedBomb:GetPhysicsObject():GetVelocity()
				local Change = CurVel:Distance(self.LastVel)
				self.LastVel = CurVel

				if Change > 300 then
					if self.NextDet < tim then
						self:Detonate()
					end

					return
				end

				self:NextThink(tim + .3)

				return true
			end
		end
	end
	
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner, SelfVel = self:LocalToWorld(self:OBBCenter()), self.Owner or self, self:GetPhysicsObject():GetVelocity()
		local Boom = ents.Create("env_explosion")
		Boom:SetPos(SelfPos)
		Boom:SetKeyValue("imagnitude", "50")
		Boom:SetOwner(Owner)
		Boom:Spawn()
		Boom:Fire("explode", 0)
		self:EmitSound("ambient/fire/mtov_flame2.wav")

		for i = 1, 5 do
			local FireVec = (VectorRand() * .3 + Vector(0, 0, .3)):GetNormalized()
			FireVec.z = FireVec.z / 2
			local Flame = ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos + Vector(0, 0, 30))
			Flame:SetAngles(FireVec:Angle())
			Flame:SetOwner(game.GetWorld())
			JMod.SetOwner(Flame, game.GetWorld())
			Flame.SpeedMul = 0.2
			Flame.Creator = game.GetWorld()
			Flame.HighVisuals = true
			Flame:Spawn()
			Flame:Activate()
		end
		
		self:Remove()
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_eznade_impact", "EZminiNade-Impact")
end
