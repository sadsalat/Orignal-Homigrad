SWEP.Base = 'weapon_base'
AddCSLuaFile()

SWEP.PrintName = "Банка ананасов"
SWEP.Author = "Homigrad"
SWEP.Purpose = "Консервированные ананасы"
SWEP.Category = "Вкусности"

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/jordfood/can.mdl"
SWEP.WorldModel = "models/jordfood/can.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.DrawCrosshair = false



local healsound = Sound("snd_jack_hmcd_eat"..math.random(1,4)..".wav")
function SWEP:Initialize()
	self:SetHoldType( "slam" )
	if ( CLIENT ) then return end
end

if(CLIENT)then
	function SWEP:PreDrawViewModel(vm,wep,ply)
	end
	function SWEP:GetViewModelPosition(pos,ang)
		pos=pos-ang:Up()*10+ang:Forward()*30+ang:Right()*7
		ang:RotateAroundAxis(ang:Up(),90)
		ang:RotateAroundAxis(ang:Right(),-10)
		ang:RotateAroundAxis(ang:Forward(),-10)
		return pos,ang
	end
	if CLIENT then
		local WorldModel = ClientsideModel(SWEP.WorldModel)
	
		WorldModel:SetNoDraw(true)
	
		function SWEP:DrawWorldModel()
			local _Owner = self:GetOwner()
	
			if (IsValid(_Owner)) then
				-- Specify a good position
				local offsetVec = Vector(4,-1,0)
				local offsetAng = Angle(180, -45, 90)
				
				local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
				if !boneid then return end
	
				local matrix = _Owner:GetBoneMatrix(boneid)
				if !matrix then return end
	
				local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
	
				WorldModel:SetPos(newPos)
				WorldModel:SetAngles(newAng)
	
				WorldModel:SetupBones()
			else
				WorldModel:SetPos(self:GetPos())
				WorldModel:SetAngles(self:GetAngles())
			end
	
			WorldModel:DrawModel()
		end
	end
end
function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if(SERVER)then
		self:GetOwner().hungryregen = self:GetOwner().hungryregen + 1
		self:Remove()
		sound.Play(healsound, self:GetPos(),75,100,0.5)
		self:GetOwner():SelectWeapon("weapon_hands")
	end
end

function SWEP:SecondaryAttack()
end

