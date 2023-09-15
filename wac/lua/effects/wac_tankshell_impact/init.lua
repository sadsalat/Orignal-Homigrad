
local mats={				--sound,effect,colormod
	[MAT_ALIENFLESH]	={2,1,{0,0,0}},
	[MAT_ANTLION]		={2,1,{0,0,0}},
	[MAT_BLOODYFLESH]	={2,1,{0,0,0}},
	[MAT_CLIP]			={1,1,{0,0,0}},
	[MAT_COMPUTER]		={1,1,{0,0,0}},
	[MAT_FLESH]			={2,1,{0,0,0}},
	[MAT_GRATE]			={1,1,{0,0,0}},
	[MAT_METAL]			={1,1,{0,0,0}},
	[MAT_PLASTIC]		={2,1,{0,0,0}},
	[MAT_SLOSH]			={2,1,{0,0,0}},
	[MAT_VENT]			={1,1,{0,0,0}},
	[MAT_FOLIAGE]		={2,2,{0,0,0}},
	[MAT_TILE]			={2,2,{0,0,0}},
	[MAT_CONCRETE]		={2,2,{0,0,0}},
	[MAT_DIRT]			={2,2,{0,0,0}},
	[MAT_SAND]			={2,2,{0,0,0}},
	[MAT_WOOD]			={2,2,{0,0,0}},
	[MAT_GLASS]			={2,2,{0,0,0}},
	[MAT_GRASS]			={2,2,{0,0,0}},
	[MAT_SNOW]			={2,2,{0,0,0}},
	[MAT_DEFAULT]		={2,2,{0,0,0}}
}

local sounds={
	[1]={
		Sound("WAC/tank/tank_shell_metal_01.wav"),
		Sound("WAC/tank/tank_shell_metal_02.wav"),
		Sound("WAC/tank/tank_shell_metal_03.wav"),
		Sound("WAC/tank/tank_shell_metal_04.wav"),
	},
	[2]={
		Sound("WAC/tank/tank_shell_01.wav"),
		Sound("WAC/tank/tank_shell_02.wav"),
		Sound("WAC/tank/tank_shell_03.wav"),
		Sound("WAC/tank/tank_shell_04.wav"),
		Sound("WAC/tank/tank_shell_05.wav"),
	},
}

function EFFECT:Init(data)
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time
	self.vEntity = data:GetEntity()
 	self.vOffset = data:GetOrigin()
 	self.vAng = data:GetAngles()
 	self.vFw = self.vAng:Forward()
 	self.vUp = self.vAng:Up()
 	self.vRi = self.vAng:Right()
	self.Mat=math.ceil(data:GetRadius())
	self.Mat=(self.Mat!=0 and self.Mat)and(self.Mat)or(MAT_DIRT)
	self.emitter = ParticleEmitter(self.vOffset)
	local dlight = DynamicLight(self.vEntity:EntIndex()) 
	if (dlight) then 
		dlight.Pos = self.vOffset+self.vFw
		dlight.r = 255
		dlight.g = 220
		dlight.b = 0
		dlight.Brightness = 3
		dlight.Decay = 1700
		dlight.Size = 312
		dlight.DieTime = CurTime() + 0.5
	end
	if mats[self.Mat][2]==1 then
		self:Normal()
	else
		self:Dirt()
		self:Normal()
	end
	sound.Play(sounds[mats[self.Mat][1]][math.random(#sounds[mats[self.Mat][1]])], self.vOffset, 450, 100)
	self.emitter:Finish()
 	self.Entity:SetPos(self.vOffset)
end
 
 function EFFECT:Normal()
	for i = 0, 360, 10 do
		local ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i)*math.Rand(12,120)*self.vUp + math.sin(i)*math.Rand(12,120)*self.vRi+math.Rand(110, 210)*self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(0, 0.7))
			ptc:SetStartAlpha(math.Rand(100, 130))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(20)
			ptc:SetEndSize(50)
			ptc:SetAirResistance(300)
			ptc:SetRoll(math.Rand(0, 10))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(math.Rand(80, 150), 84, 79)
		end
		ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i)*math.Rand(150,250)*self.vUp+math.sin(i)*math.Rand(150,250)*self.vRi+math.Rand(2,110)*self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(0, 0.6))
			ptc:SetStartAlpha(math.Rand(100, 170))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(20)
			ptc:SetEndSize(50)
			ptc:SetAirResistance(300)
			ptc:SetRoll(math.Rand(0, 60))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(math.Rand(80, 150), 94, 89)
		end
		ptc = self.emitter:Add("particles/flamelet"..math.random(1,5), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i) * math.Rand(10,200) * self.vUp + math.sin(i) * math.Rand(10,200) * self.vRi + math.Rand(0,150) * self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(0, 0.22))
			ptc:SetStartAlpha(math.Rand(200, 255))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(14)
			ptc:SetEndSize(60)
			ptc:SetRoll(math.Rand(0, 100))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(255 , 210 , 220)
		end
	end
 end
 
 function EFFECT:Dirt()
	for i = 0, 360, 10 do
		local ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset )
		if (ptc) then
			ptc:SetVelocity(math.cos(i) * math.Rand(100,300) * self.vUp + math.sin(i) * math.Rand(100,300) * self.vRi + math.Rand(2,200) * self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime( math.Rand(0, 4))
			ptc:SetStartAlpha( math.Rand(50, 70))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(40)
			ptc:SetEndSize(50)
			ptc:SetAirResistance(200)
			ptc:SetRoll(math.Rand(0, 60))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(math.Rand(80, 100), 94, 89)
		end
		ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset )
		if (ptc) then
			ptc:SetVelocity(math.cos(i) * math.Rand(300,500) * self.vUp + math.sin(i) * math.Rand(300,500) * self.vRi + math.Rand(0,20) * self.vFw)
			ptc:SetLifeTime( 0 )
			ptc:SetDieTime( math.Rand( 0, 5 ) )
			ptc:SetStartAlpha( math.Rand( 40, 60 ) )
			ptc:SetEndAlpha( 0 )
			ptc:SetStartSize( 60 )
			ptc:SetEndSize( 70 )
			ptc:SetAirResistance( 200 )
			ptc:SetRoll( math.Rand(0, 60) )
			ptc:SetRollDelta( math.Rand(-0.2, 0.2) )
			ptc:SetColor( math.Rand(80, 100), 94, 89 )
		end
		for k=1,2 do
		ptc = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i) * math.Rand(50,400) * self.vUp + math.sin(i) * math.Rand(50,400) * self.vRi + math.Rand(100,900) * self.vFw)
			ptc:SetLifeTime( 0 )
			ptc:SetDieTime( math.Rand( 0, 3 ) )
			ptc:SetStartAlpha( math.Rand( 70, 140 ) )
			ptc:SetEndAlpha( 0 )
			ptc:SetStartSize( 40 )
			ptc:SetEndSize( 50 )
			ptc:SetGravity(Vector(0,0,-150))
			ptc:SetAirResistance( 300 )
			ptc:SetRoll( math.Rand(0, 60) )
			ptc:SetRollDelta( math.Rand(-0.2, 0.2) )
			ptc:SetColor( math.Rand(80, 100), 94, 89 )
			end
		end
		ptc = self.emitter:Add("effects/fleck_cement"..math.random(1, 2 ), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i) * math.Rand(50,60) * self.vUp + math.sin(i) * math.Rand(50,60) * self.vRi + math.Rand(100,140) * self.vFw)
			ptc:SetLifeTime( 0 )
			ptc:SetDieTime( math.Rand( 0, 1.2 ) )
			ptc:SetStartAlpha( math.Rand( 50, 70 ) )
			ptc:SetEndAlpha( 0 )
			ptc:SetStartSize( 40 )
			ptc:SetEndSize( 50 )
			ptc:SetGravity( Vector( 0,0,-200 ) )
			ptc:SetCollide(true)
			ptc:SetAirResistance( 10 )
			ptc:SetRoll( math.Rand(0, 60) )
			ptc:SetRollDelta( math.Rand(-0.2, 0.2) )
			ptc:SetColor( 100, 100, 100 )
		end
		ptc = self.emitter:Add("effects/fleck_cement"..math.random(1, 2), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(math.cos(i)*math.Rand(1,300)*self.vUp+math.sin(i)*math.Rand(1,300)*self.vRi+math.Rand(400,940)*self.vFw)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(0, 2))
			ptc:SetStartAlpha(math.Rand(100, 170))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(5)
			ptc:SetEndSize(10)
			ptc:SetGravity(Vector(0,0,-800))
			ptc:SetCollide(true)
			ptc:SetAirResistance( 100 )
			ptc:SetRoll( math.Rand(0, 60) )
			ptc:SetRollDelta( math.Rand(-0.2, 0.2) )
			ptc:SetColor( 100, 100, 100 )
		end
	end
	local scount = math.Rand(3, 5)
	for i = 0, scount do
		local ptc = self.emitter:Add("particles/flamelet"..math.random(1,5), self.vOffset)
		if (ptc) then
			ptc:SetVelocity(self.vUp * math.Rand(4, 20))
			ptc:SetLifeTime(0)
			ptc:SetDieTime( math.Rand(0, 0.15))
			ptc:SetStartAlpha(150)
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(8)
			ptc:SetEndSize(90)
			ptc:SetRoll(math.Rand(0, 100))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(220 , 220 , 220)
		end
		ptc = self.emitter:Add("particles/smokey", self.vOffset)
		if (ptc) then
			ptc:SetVelocity(self.vFw * 10)
			ptc:SetLifeTime(0)
			ptc:SetDieTime(math.Rand(0, 1.2))
			ptc:SetStartAlpha(math.Rand(150, 160))
			ptc:SetEndAlpha(0)
			ptc:SetStartSize(40)
			ptc:SetEndSize(100)
			ptc:SetAirResistance(200)
			ptc:SetRoll(math.Rand(0, 60))
			ptc:SetRollDelta(math.Rand(-0.2, 0.2))
			ptc:SetColor(104, 94, 89)
		end
	end
 end
 
function EFFECT:Think()
 	return (self.LifeTime > CurTime())
end 

function EFFECT:Render()
end