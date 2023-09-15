
function EFFECT:Init(data)
	self.lastpos=data:GetOrigin()
	self.rocket=data:GetEntity()
	self.Time=CurTime()
	self.Scale=data:GetScale()
	self.Length=data:GetRadius()
	self.Density=data:GetMagnitude()
	if self.Scale==0 then self.Scale=10 end
	if !self.rocket.emitter then
		self.rocket.emitter = ParticleEmitter(self:GetPos())
	end
end

function EFFECT:Think()
	if IsValid(self.rocket) then
		local pos=self.rocket:GetPos()
		local diff=pos-self.lastpos
		self.lastpos=pos
		local fwd=self.rocket:GetForward()
		local speed=self.rocket:GetVelocity()
		local frt=FrameTime()
		for i=1, diff:Length()/10*self.Density do
			local particle = self.rocket.emitter:Add("effects/fire_cloud"..math.random(1, 2), pos-diff:GetNormal()*i*10/self.Density)
			particle:SetVelocity(VectorRand():GetNormal()*self.Scale)
			particle:SetDieTime(math.Rand(0.001, 0.0001)*self.Length)
			particle:SetStartAlpha(math.Rand(80, 150)*self.Density)
			particle:SetStartSize(self.Scale)
			particle:SetEndSize(self.Scale*20)
			particle:SetRoll(math.Rand(360,480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(200, 200, 200)
			local particle = self.rocket.emitter:Add("particle/smokesprites_000"..math.random(1,9), pos-diff:GetNormal()*i*10/self.Density)
			particle:SetVelocity(VectorRand():GetNormal()*self.Scale)
			particle:SetDieTime(0.01*self.Length)
			particle:SetStartAlpha(math.Rand(5, 10)*self.Density)
			particle:SetStartSize(math.Rand(5,10))
			particle:SetEndSize(math.Rand(10, 50)*self.Scale)
			particle:SetRoll(math.Rand(360, 480))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(50, 50, 50)
		end
	end
	return IsValid(self.rocket)
end

function EFFECT:Render()
end
