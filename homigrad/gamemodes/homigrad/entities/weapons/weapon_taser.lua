SWEP.Base = "medkit"
SWEP.PrintName = "Электрошокер"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Электрическое возбуждение передается нервным клеткам, вызывая в основном болевой шок, а также кратковременные судороги и состояние «ошарашенности», дезориентации."
SWEP.Slot = 2
SWEP.SlotPos = 4
SWEP.Spawnable = true
SWEP.Category = "Разное"

SWEP.ViewModel = "models/realistic_police/taser/w_taser.mdl"
SWEP.WorldModel = "models/realistic_police/taser/w_taser.mdl"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "AR2AltFire"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwmUp = 0.5
SWEP.dwmRight = 0
SWEP.dwmForward = 0

SWEP.dwmARight = 180
SWEP.dwmAUp = 200
SWEP.dwmAForward = 0


function SWEP:Initialize()
	self:SetHoldType("revolver")
end

local hull = Vector(10,10,10)

function SWEP:PrimaryAttack()
	if CLIENT then return end

	if self:Clip1() <= 0 then return nil end
	self:TakePrimaryAmmo(1)

	local ply = self:GetOwner()
	local att = self:GetAttachment(1)
	
	ply:EmitSound("ambient/energy/zap3.wav")

	local dir = ply:EyeAngles():Forward()

	local tr = {
		start = att.Pos,
		endpos = att.Pos + dir * 250,
		filter = ply,
		mins = -hull,
		maxs = hull,
		mask = MASK_SHOT_HULL
	}

	local trResult = util.TraceHull(tr)

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.start)
	effectdata:SetMagnitude(5)
	effectdata:SetNormal(dir * 50)
	util.Effect("Sparks",effectdata)

	local ent = trResult.Entity
	ent = (ent:IsPlayer() and ent) or RagdollOwner(ent)

	if ent and ent:Alive() then
		ent:EmitSound("hostage/hpain/hpain" .. math.random(1,6) .. ".wav")

		Stun(ent)
	end
end

function SWEP:Reload()
if timer.Exists("reload"..self:EntIndex()) or self:Clip1()>=self:GetMaxClip1() or self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )<=0 then return nil end
	if self:GetOwner():IsSprinting() then return nil end
	self:GetOwner():SetAnimation(PLAYER_RELOAD)
	--self:EmitSound(self.ReloadSound,60,100,0.8,CHAN_AUTO)
	timer.Create( "reload"..self:EntIndex(), 1.5, 1, function()
		if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():GetActiveWeapon()==self then
			local oldclip = self:Clip1()
			self:SetClip1(math.Clamp(self:Clip1()+self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ),0,self:GetMaxClip1()))
			local needed = self:Clip1()-oldclip
			self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )-needed, self:GetPrimaryAmmoType())
		end
	end)
end

function SWEP:SecondaryAttack()
end