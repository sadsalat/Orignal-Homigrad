
function EFFECT:Init(data)
 	self.LifeTime = CurTime()+1
	
	self.vEntity = data:GetEntity()
 	local pos=data:GetOrigin()
 	local ang = data:GetAngles()
 	local fwd = ang:Forward()
 	local up = ang:Up()
 	local ri = ang:Right()
	ang.p=ang.p+90
	local normal=ang:Up()
	local scale=data:GetScale()
	
	self.emitter=ParticleEmitter(pos)
	local dlight=DynamicLight(self.vEntity:EntIndex()) 
	if (dlight) then 
		dlight.Pos=pos+normal
		dlight.r=255
		dlight.g=220
		dlight.b=0
		dlight.Brightness=3
		dlight.Decay=500
		dlight.Size=scale
		dlight.DieTime=CurTime()+0.5
	end
	local particle;
	for i=0, 360, 20 do
		particle=self.emitter:Add("particle/smokesprites_000"..math.random(1,9), pos+normal*scale/20)
		particle:SetVelocity(((math.cos(i)*up + normal*math.Rand(0,2) + math.sin(i)*ri)*50+fwd*math.Rand(0,100))*scale/20)
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.4, 0.8))
		particle:SetStartAlpha(math.Rand(10, 100))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0.1*scale)
		particle:SetEndSize(0.5*scale)
		particle:SetAirResistance(300)
		particle:SetRoll(math.Rand(0, 60))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(94, 84, 79)
		particle:SetGravity(Vector(0,0,-100))
		particle=self.emitter:Add("particles/flamelet"..math.random(1,5), pos+normal*scale/20)
		particle:SetVelocity((math.cos(i)*up*math.Rand(10,70) + math.sin(i)*ri*math.Rand(10,70) + normal*math.Rand(10,90))*scale/20)
		particle:SetLifeTime(0)
		particle:SetDieTime(0.1)
		particle:SetStartAlpha(250)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0.1*scale)
		particle:SetEndSize(0.3*scale)
		particle:SetRoll(math.Rand(0, 500))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(220, 220, 220)
	end
	for i=1, math.Rand(3, 5) do
		particle=self.emitter:Add("particle/smokesprites_000"..math.random(1,9), pos+normal*scale/20)
		particle:SetVelocity(fwd*10+normal*math.Rand(0,100))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.1, 1.2))
		particle:SetStartAlpha(math.Rand(0, 100))
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(10)
		particle:SetAirResistance(200)
		particle:SetRoll(math.Rand(0, 60))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(94, 84, 79)
	end
	self.emitter:Finish()
end 
 
function EFFECT:Think()
 	return (self.LifeTime > CurTime())
end 
 
function EFFECT:Render()
end  