SWEP.Base = 'weapon_base'
AddCSLuaFile()

SWEP.PrintName = "Туалетная Бумага"
SWEP.Author = "носки?"
SWEP.Purpose = "Лечит Кровотечение"

SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true

SWEP.ViewModel = "models/props/cs_office/Paper_towels.mdl"
SWEP.WorldModel = "models/props/cs_office/Paper_towels.mdl"
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
local healsound = Sound("snd_jack_hmcd_bandage.wav")
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
				self:SetRenderOrigin(Pos+Ang:Forward()*3.5+Ang:Right()*0.5)
				Ang:RotateAroundAxis(Ang:Up(),90)
				Ang:RotateAroundAxis(Ang:Right(),90)
				self:SetModelScale(0.4)
				self:SetRenderAngles(Ang)
				self:DrawModel()
			end
		end
	end
end
function SWEP:PrimaryAttack()
self.Owner:SetAnimation(PLAYER_ATTACK1)
if(SERVER)then
if self:GetOwner():GetNWInt("BloodLosing")>0 then
self:Remove()
self.Owner:SelectWeapon("weapon_hands")
self:GetOwner():SetNWInt("BloodLosing",self.Owner:GetNWInt("BloodLosing") - 30)
sound.Play(healsound, self:GetPos(),75,100,0.5)
end
end
end
function SWEP:SecondaryAttack()
self.Owner:SetAnimation(PLAYER_ATTACK1)
if(SERVER)then
local tr = util.TraceHull( {
	start = self.Owner:GetShootPos(),
	endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 48 ),
	filter = self.Owner,
	mins = Vector( -10, -10, -10 ),
	maxs = Vector( 10, 10, 10 ),
} )
WhomILookinAt=tr.Entity
if IsValid(WhomILookinAt) then
if WhomILookinAt:IsPlayer() then
if WhomILookinAt:GetNWInt("BloodLosing")>0 then
self:Remove()
self.Owner:SelectWeapon("weapon_hands")
WhomILookinAt:SetNWInt("BloodLosing",WhomILookinAt:GetNWInt("BloodLosing") - 30)
sound.Play(healsound, self:GetPos(),75,100,0.5)
end
end
end
if WhomILookinAt:IsRagdoll() then
		if !IsValid(RagdollOwner(WhomILookinAt)) then return nil end
if RagdollOwner(WhomILookinAt):GetNWInt("BloodLosing")>0 then
RagdollOwner(WhomILookinAt):SetNWInt("BloodLosing",RagdollOwner(WhomILookinAt):GetNWInt("BloodLosing") - 30)
self:Remove()
sound.Play(healsound, self:GetPos(),75,100,0.5)
self.Owner:SelectWeapon("weapon_hands")
end
end
end
end
