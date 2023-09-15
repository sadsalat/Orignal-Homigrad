SWEP.Base = 'weapon_base' -- base 

SWEP.PrintName 				= "salat_base"
SWEP.Author 				= "sadsalat"
SWEP.Instructions			= ""
SWEP.Category 				= "Other"

SWEP.Spawnable 				= false
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 100
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/fiveseven/fiveseven-1.wav"
SWEP.Primary.Force = 0
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12
SWEP.NextShot = 0
SWEP.Sight = false
SWEP.ReloadSound = ""
SWEP.TwoHands = false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = ""

------------------------------------------




local pos = Vector(0,0,0)

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	if ( CLIENT ) then return end
end

function SWEP:PrimaryAttack()
	if timer.Exists("reload"..self:EntIndex()) then return nil end
	if self:Clip1()<=0 then return nil end
	if self.Owner:IsSprinting() then return nil end	
	local ply = self:GetOwner()
		self.ShootNext=self.NextShot or NextShot

	if ( self.NextShot > CurTime() ) then return end
	
	self.NextShot = CurTime() + self.ShootWait
	self:EmitSound(self.Primary.Sound)
    self:FireShoting(self.Primary.Damage, 1, 5)
end

function SWEP:Reload()
if timer.Exists("reload"..self:EntIndex()) or self:Clip1()>=self:GetMaxClip1() or self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )<=0 then return nil end
if self.Owner:IsSprinting() then return nil end
if ( self.NextShot > CurTime() ) then return end
self:GetOwner():SetAnimation(PLAYER_RELOAD)
self:EmitSound(self.ReloadSound,60,100,0.8,CHAN_AUTO)
timer.Create( "reload"..self:EntIndex(), self.ReloadTime, 1, function()
	if IsValid(self) and IsValid(self.Owner) and self.Owner:GetActiveWeapon()==self then
		local oldclip = self:Clip1()
		self:SetClip1(math.Clamp(self:Clip1()+self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ),0,self:GetMaxClip1()))
		local needed = self:Clip1()-oldclip
		self.Owner:SetAmmo(self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )-needed, self:GetPrimaryAmmoType())
	end
end)
end

function SWEP:FireShoting(dmg, numbul, spread)
	--PrintTable(self:GetAttachments())
	if !IsValid(self) then return nil end
	if self:Clip1()<=0 then return nil end
	if timer.Exists("reload"..self:EntIndex()) then return nil end

	local obj = self:LookupAttachment( "muzzle" )
	local Attachment = self:GetAttachment( obj )

	local cone = self.Primary.Cone

	local shootOrigin = Attachment.Pos
	local shootAngles = Attachment.Ang
	local shootDir = shootAngles:Forward()

	if(SERVER)then
	local ply = self:GetOwner()

	if ( self:GetOwner():IsPlayer() ) then
		self:GetOwner():LagCompensation( true )
	end


	local bullet = {}
		bullet.Num 			= self.NumBullet or 1
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector(cone, cone, 0)
		bullet.Tracer		= 1
		bullet.TracerName 	= 4
		bullet.Force		= self.Primary.Force/2.2
		bullet.Damage		= dmg or 25
		bullet.AmmoType     = self.Primary.Ammo
		bullet.Attacker 	= self.Owner	
		bullet.IgnoreEntity = self.Owner:GetVehicle() or nil
	--[[local bullet = {}
		bullet.Num 			= 1
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= 0.05
		bullet.Tracer		= guninfo.Trace
		bullet.TracerName 	= nil
		bullet.Force		= 10
		bullet.Damage		= guninfo.Damage
		bullet.Attacker 	= ply
	--]]
	self:FireBullets(bullet)
	self:TakePrimaryAmmo(1)
	ply:LagCompensation(false)
	end
    if(CLIENT)then
    	LocalPlayer():SetEyeAngles(LerpAngle(0.5,LocalPlayer():EyeAngles(),LocalPlayer():EyeAngles()+Angle((-self.Primary.Force*(self.NumBullet or 1))/90,math.random(-self.Primary.Force/80,self.Primary.Force/80),0)))
    end
    // Make a muzzle flash
	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( shootAngles )
		effectdata:SetScale( 0.5 )
	util.Effect( "MuzzleEffect", effectdata )
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)	
	
end

function SWEP:Think()
	local ply = self:GetOwner()
		
		local t = {}
		if not self.TwoHands then
		t.start = ply:GetShootPos()+ply:GetAngles():Right()*2.5
		else
		t.start = ply:GetShootPos()+ply:GetAngles():Right()*7
		end
		t.endpos = t.start + Angle(0,ply:GetAngles().y,ply:GetAngles().z):Forward() * 100
		t.filter = player.GetAll()
		Thinking=Thinking or 0
		if CurTime() then
			Thinking=CurTime()+1
		local tr = util.TraceLine(t)
		
		self.dist = (tr.HitPos - t.start):Length()

	if not self.Owner:IsSprinting() then

		if self.dist<=45 and not self.Owner:KeyPressed(IN_RELOAD) then
				if not self.TwoHands then
					self:SetHoldType( "normal" )
				else
					self:SetHoldType( "passive" )
				end	
		else
		if self.Sight then
			if self.Owner:KeyDown(IN_ATTACK2) and not timer.Exists("reload"..self:EntIndex()) and not self.Owner:KeyPressed(IN_RELOAD) and not self.Owner:KeyDown(IN_DUCK) then
				self:SetHoldType( "rpg" )
			else 
				self:SetHoldType( self.HoldType )
			end
		else
			self:SetHoldType( self.HoldType )
		end
	end
	else
		if not self.TwoHands then
			self:SetHoldType( "normal" )
		else
			self:SetHoldType( "passive" )
		end	
	end
end
end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
self:SetHoldType( "passive" )
end

function SWEP:ShouldDropOnDie()
	return false
end

