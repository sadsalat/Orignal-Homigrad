-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZHG HL2 Granade"
ENT.Category = "JModHomigrad"
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, -140, 0)
ENT.Model = "models/weapons/w_grenade.mdl"
ENT.SpoonScale = 2

if SERVER then
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		self:SpoonEffect()

		
		local time = 5
		timer.Simple(time - 1,function()
			player.EventPoint(self:GetPos(),"fragnade pre detonate",1024,self)
		end)

		timer.Simple(time, function()
			if IsValid(self) then
				self:Detonate()
			end
		end)
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()
		JMod.Sploom(self.Owner, self:GetPos(), math.random(10, 20))
		self:EmitSound("weapons/m67/m67_detonate_0"..math.random(1,3)..".wav", 551, 100)
		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(.01)
		plooie:SetRadius(.5)
		plooie:SetNormal(vector_up)
		ParticleEffect("pcf_jack_groundsplode_small",SelfPos,vector_up:Angle())
		util.ScreenShake(SelfPos, 20, 20, 1, 1000)

		local OnGround = util.QuickTrace(SelfPos + Vector(0, 0, 5), Vector(0, 0, -15), {self}).Hit

		local Spred = Vector(0, 0, 0)
		JMod.FragSplosion(self, SelfPos + Vector(0, 0, 20), 1200, 550, 3500, self.Owner or game.GetWorld())
		self:Remove()
	end
elseif CLIENT then
	local GlowSprite = Material("sprites/mat_jack_circle")

	function ENT:Draw()
		self:DrawModel()
		-- sprites for calibrating the lethality/casualty radius
	end

	function ENT:Think()
		local State = self:GetState()
		if(State==JMod.EZ_STATE_ARMED)then 
		self.nextpip = self.nextpip or CurTime() + 1
		self.delay = self.delay or 0
			if self.nextpip <= CurTime() then
				self.nextpip = CurTime() + (1-self.delay)
				self.delay = math.Clamp(self.delay + 0.15,0,0.85) or 0
				self:EmitSound( "weapons/grenade/tick1.wav", 75, 100, 1, CHAN_WEAPON )
			end
		end
	end

	language.Add("ent_jack_gmod_ezfragnade", "EZ Frag Grenade")
end
