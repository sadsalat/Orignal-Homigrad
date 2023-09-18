

SWEP.PrintName = "База ближнего боя"

SWEP.Category = "Ближний Бой"

SWEP.Spawnable= false
SWEP.AdminSpawnable= false
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/insurgency/w_marinebayonet.mdl"
SWEP.WorldModel = "models/weapons/insurgency/w_marinebayonet.mdl"
SWEP.ViewModelFlip = false

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.UseHands = true

SWEP.FiresUnderwater = false

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.Base = "weapon_base"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.Primary.Damage = 25
SWEP.Primary.Ammo = "none"
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 0.5
SWEP.Primary.Delay = 0.65
SWEP.Primary.Force = 40

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawSound = ""
SWEP.HitSound = ""
SWEP.FlashHitSound = ""
SWEP.ShouldDecal = true
SWEP.HoldTypeWep = ""
SWEP.DamageType = DMG_CLUB

function Circle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

local tr = {}
function EyeTrace(ply)
	tr.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
	tr.endpos = tr.start + ply:GetAngles():Forward() * 80
	tr.filter = ply
	return util.TraceLine(tr)
end

function SWEP:DrawHUD()
	if not (GetViewEntity() == LocalPlayer()) then return end
	if LocalPlayer():InVehicle() then return end
	local ply = self:GetOwner()
	local t = {}
	t.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
	t.endpos = t.start + ply:GetAngles():Forward() * 80
	t.filter = self:GetOwner()
	local Tr = util.TraceLine(t)
	local hitPos = Tr.HitPos
	if Tr.Hit then
		local Size = math.Clamp(1 - ((hitPos - self:GetOwner():GetShootPos()):Length() / 80) ^ 2, .1, .3)
		surface.SetDrawColor(Color(200, 200, 200, 200))
		draw.NoTexture()
		Circle(hitPos:ToScreen().x, hitPos:ToScreen().y, 55 * Size, 32)

		surface.SetDrawColor(Color(255, 255, 255, 200))
		draw.NoTexture()
		Circle(hitPos:ToScreen().x, hitPos:ToScreen().y, 40 * Size, 32)
	end
end


function SWEP:Initialize()
self:SetHoldType( self.HoldTypeWep )
end


function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime())
	self:SetHoldType(self.HoldTypeWep)
	if SERVER then
		self:GetOwner():EmitSound(self.DrawSound,60)
	end
end

function SWEP:Holster()
return true
end

function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay/((self:GetOwner().stamina or 100)/100)-(self:GetOwner():GetNWInt("Adrenaline")/5) )

	if SERVER then
		self:GetOwner():EmitSound( "weapons/slam/throw.wav",60 )
		self:GetOwner().stamina = math.max(self:GetOwner().stamina - self.Primary.Damage / 5,0)
	end
	self:GetOwner():LagCompensation( true )
	local ply = self:GetOwner()

	local tra = {}
	tra.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
	tra.endpos = tra.start + ply:GetAngles():Forward() * 80
	tra.filter = self:GetOwner()
	local Tr = util.TraceLine(tra)
	local t = {}
	local pos1, pos2
	local tr
	if not Tr.Hit then
		t.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
		t.endpos = t.start + ply:GetAngles():Forward() * 80
		t.filter = function(ent) return ent ~= self:GetOwner() and (ent:IsPlayer() or ent:IsRagdoll()) end
		t.mins = -Vector(10,10,10)
		t.maxs = Vector(10,10,10)
		tr = util.TraceHull(t)
	else
		tr = util.TraceLine(tra)
	end

	pos1 = tr.HitPos + tr.HitNormal
	pos2 = tr.HitPos - tr.HitNormal
	if true then
		if SERVER and tr.HitWorld then
			self:GetOwner():EmitSound(  self.HitSound,60  )
		end

		if IsValid( tr.Entity ) and SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( self.DamageType )
			dmginfo:SetAttacker( self:GetOwner() )
			dmginfo:SetInflictor( self )
			dmginfo:SetDamagePosition( tr.HitPos )
			dmginfo:SetDamageForce( self:GetOwner():GetForward() * self.Primary.Force )
			local angle = self:GetOwner():GetAngles().y - tr.Entity:GetAngles().y
			if angle < -180 then angle = 360 + angle end

			if angle <= 90 and angle >= -90 then
				dmginfo:SetDamage( self.Primary.Damage * 1.5 )
			else
				dmginfo:SetDamage( self.Primary.Damage / 1.5 )
			end

			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
				self:GetOwner():EmitSound( self.FlashHitSound,60 )
			else
				if IsValid( tr.Entity:GetPhysicsObject() ) then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( self.DamageType )
					dmginfo:SetAttacker( self:GetOwner() )
					dmginfo:SetInflictor( self )
					dmginfo:SetDamagePosition( tr.HitPos )
					dmginfo:SetDamageForce( self:GetOwner():GetForward() * self.Primary.Force*7 )
					dmginfo:SetDamage( self.Primary.Damage )
					tr.Entity:TakeDamageInfo(dmginfo)
					if tr.Entity:GetClass() == "prop_ragdoll" then
						self:GetOwner():EmitSound(  self.FlashHitSound,60  )
					else
						self:GetOwner():EmitSound(  self.HitSound,60  )
					end
				end
			end
			tr.Entity:TakeDamageInfo( dmginfo )
		end
		--self:GetOwner():EmitSound( Sound( self.HitSound ),60 )
	end

	if SERVER and Tr.Hit and self.ShouldDecal then
		if IsValid(Tr.Entity) and Tr.Entity:GetClass()=="prop_ragdoll" then
			util.Decal("Impact.Flesh",pos1,pos2)
		else
			util.Decal("ManhackCut",pos1,pos2)
		end
	end

	self:GetOwner():LagCompensation( false )
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Think()
end