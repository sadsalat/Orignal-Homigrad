-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZHG RGD5 Granade"
ENT.Category = "JModHomigrad"
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, -140, 0)
ENT.Model = "models/pwb/weapons/w_rgd5_thrown.mdl"
ENT.SpoonScale = 2

if SERVER then
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		self:SpoonEffect()

		
		local time = math.random(3.2,4.2)
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
		plooie:SetScale(.2)
		plooie:SetRadius(1)
		plooie:SetNormal(vector_up)
		ParticleEffect("pcf_jack_groundsplode_small",SelfPos,vector_up:Angle())
		util.ScreenShake(SelfPos, 20, 20, 1, 1000)

		local OnGround = util.QuickTrace(SelfPos + Vector(0, 0, 5), Vector(0, 0, -15), {self}).Hit

		local Spred = Vector(0, 0, 0)
		JMod.FragSplosion(self, SelfPos + Vector(0, 0, 20), 650, 500, 3500, self.Owner or game.GetWorld())
		self:Remove()
	end
elseif CLIENT then
	local GlowSprite = Material("sprites/mat_jack_circle")

	function ENT:Draw()
		self:DrawModel()
		-- sprites for calibrating the lethality/casualty radius
		
		--[[local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==JMod.EZ_STATE_ARMED)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),15*52*2,15*52*2,Color(255,0,0,128))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),5*52*2,5*52*2,Color(255,255,255,128))
		end]]--
		
	end

	language.Add("ent_jack_gmod_ezfragnade", "EZ Frag Grenade")
end
