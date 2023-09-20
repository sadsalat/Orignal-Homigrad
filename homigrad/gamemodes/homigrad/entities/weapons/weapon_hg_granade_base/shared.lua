SWEP.Base = "weapon_base"

SWEP.PrintName = "База Гаранаты"
SWEP.Author = "sadsalat"
SWEP.Purpose = "Бах Бам Бум, Бадабум!"

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.Spawnable = false

SWEP.ViewModel = "models/pwb/weapons/w_f1.mdl"
SWEP.WorldModel = "models/pwb/weapons/w_f1.mdl"

SWEP.Granade = ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

function TrownGranade(ply,force,granade)
    local granade = ents.Create(granade)
    granade:SetPos(ply:GetShootPos() +ply:GetAimVector()*10)
	granade:SetAngles(ply:EyeAngles()+Angle(45,45,0))
	granade:SetOwner(ply)
	granade:SetPhysicsAttacker(ply)
    granade:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	granade:Spawn()       
	granade:Arm()
	local phys = granade:GetPhysicsObject()              
	if not IsValid(phys) then granade:Remove() return end                         
	phys:SetVelocity(ply:GetVelocity() + ply:GetAimVector() * force)
	phys:AddAngleVelocity(VectorRand() * force/2)
end

function SWEP:Deploy()
    self:SetHoldType( "melee" )
end

function SWEP:Initialize()
    self:SetHoldType( "melee" )
end

function SWEP:PrimaryAttack()
    if SERVER then    
        TrownGranade(self:GetOwner(),750,self.Granade)
        self:Remove()
        self:GetOwner():SelectWeapon("weapon_hands")
    elseif CLIENT then
    end
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/m67/handling/m67_throw_01.wav")
end

function SWEP:SecondaryAttack()
    if SERVER then
        TrownGranade(self:GetOwner(),250,self.Granade)
        self:Remove()
        self:GetOwner():SelectWeapon("weapon_hands")
    elseif CLIENT then
    end
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/m67/handling/m67_throw_01.wav")
end