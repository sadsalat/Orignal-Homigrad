
function EFFECT:Init(data)

 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
	self.vEntity = data:GetEntity()
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngles()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	local ang=self.vAng
	ang.p=ang.p+90
	local normal=ang:Up()
	local scale=data:GetScale()
	
	self.emitter=ParticleEmitter(self.vOffset)
	local dlight=DynamicLight(self.vEntity:EntIndex()) 
	if (dlight) then 
		dlight.Pos=self.vOffset+normal
		dlight.r=255
		dlight.g=220
		dlight.b=0
		dlight.Brightness=3
		dlight.Decay=500
		dlight.Size=scale
		dlight.DieTime=CurTime()+0.5
	end
	local particle;
	for i=0, 360, 10 do
		particle=self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset+normal*scale/20)
		particle:SetVelocity((math.cos(i)*self.vUp + normal*math.Rand(0,2) + math.sin(i)*self.vRi)*100)
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.4, 0.8))
		particle:SetStartAlpha(math.Rand(10, 100))
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(30)
		particle:SetAirResistance(300)
		particle:SetRoll(math.Rand(0, 60))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(94, 84, 79)
		particle:SetGravity(Vector(0,0,-100))
		particle=self.emitter:Add("particles/flamelet"..math.random(1,5), self.vOffset+normal*scale/20)
		particle:SetVelocity(math.cos(i)*self.vUp*math.Rand(10,70) + math.sin(i)*self.vRi*math.Rand(10,70) + normal*math.Rand(10,90))
		particle:SetLifeTime(0)
		particle:SetDieTime(0.1)
		particle:SetStartAlpha(250)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(17)
		particle:SetRoll(math.Rand(0, 500))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(220, 220, 220)
	end
	for i=1, math.Rand(3, 5) do
		particle=self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset+normal*scale/20)
		particle:SetVelocity(self.vFw*10+normal*math.Rand(0,50))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.1, 1.2))
		particle:SetStartAlpha(math.Rand(0, 100))
		particle:SetEndAlpha(0)
		particle:SetStartSize(30)
		particle:SetEndSize(50)
		particle:SetAirResistance(200)
		particle:SetRoll(math.Rand(0, 60))
		particle:SetRollDelta(math.Rand(-0.2, 0.2))
		particle:SetColor(94, 84, 79)
	end
	self.emitter:Finish()
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos(self.vOffset)
end 
 
function EFFECT:Think()
 	return (self.LifeTime > CurTime())
 	 
end 
 
function EFFECT:Render()
end  