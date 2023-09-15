SWEP.Base = 'weapon_base'
AddCSLuaFile()

SWEP.PrintName = "Энергетик"
SWEP.Author = "Monster"
SWEP.Purpose = "Вкусный но по факту безполезен..."

SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/jorddrink/mongcan1a.mdl"
SWEP.WorldModel = "models/jorddrink/mongcan1a.mdl"
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
local healsound = Sound("snd_jack_hmcd_drink"..math.random(1,3)..".wav")
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
	function SWEP:DrawWorldModel()
		self:DrawModel()
		if (IsValid(self:GetOwner())) then 
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")) 
			if((Pos)and(Ang))then
				self:SetRenderOrigin(Pos+Ang:Forward()*3.6+Ang:Right()*1)
				Ang:RotateAroundAxis(Ang:Up(),0)
				Ang:RotateAroundAxis(Ang:Right(),0)
				Ang:RotateAroundAxis(Ang:Forward(),100)
				self:SetModelScale(1)
				self:SetRenderAngles(Ang)
				self:DrawModel()
			end
		end
	end
end
function SWEP:PrimaryAttack()
self.Owner:SetAnimation(PLAYER_ATTACK1)
if(SERVER)then
self.Owner:SetNWInt("hungryregen",self.Owner:GetNWInt("hungryregen")+0.1)
self:Remove()
sound.Play(healsound, self:GetPos(),75,100,0.5)
self.Owner:SelectWeapon("weapon_hands")
end
end

function SWEP:SecondaryAttack()
end

