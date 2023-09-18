SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "MINIGUN"
SWEP.Author 				= "ADMINI"
SWEP.Instructions			= "MINIGUN АДМИНХУЙ! БАМ БАМ БАМ!"
SWEP.Category 				= "Оружие"
SWEP.WepSelectIcon			= "pwb/sprites/m134"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true

------------------------------------------

SWEP.Primary.ClipSize		= 9999
SWEP.Primary.DefaultClip	= 9999
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 9999
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/ak47/ak47-1.wav"
SWEP.Primary.Force = 110
SWEP.ReloadTime = 5
SWEP.ShootWait = 0.02
SWEP.ReloadSound = "weapons/ar2/ar2_reload.wav"
SWEP.TwoHands = true


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "crossbow"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb/weapons/w_m134.mdl"
SWEP.WorldModel				= "models/pwb/weapons/w_m134.mdl"

function SWEP:PrimaryAttack()
	self.ShootNext=self.NextShot or NextShot

	if ( self.NextShot > CurTime() ) then return end

	if timer.Exists("reload"..self:EntIndex()) then return nil end
	if self:Clip1()<=0 then return nil end
	if self:GetOwner():IsSprinting() then return nil end
	local ply = self:GetOwner()
	self.NextShot = CurTime() + self.ShootWait
	self:EmitSound(self.Primary.Sound)
    self:FireBullet(self.Primary.Damage, 1, 5)
    self:GetOwner():SetVelocity(self:GetOwner():EyeAngles():Forward()*-200)
end

SWEP.vbwPos = Vector(-4,-4,4)