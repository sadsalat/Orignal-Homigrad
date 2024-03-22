SWEP.Base = "weapon_base"
AddCSLuaFile()
SWEP.PrintName = "Обезболивающее"
SWEP.Author = "Painkillers"
SWEP.Purpose = "Снижает боль"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/w_models/weapons/w_eq_painpills.mdl"
SWEP.WorldModel = "models/w_models/weapons/w_eq_painpills.mdl"
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
local healsound = Sound("snds_jack_gmod/ez_medical/15.wav")

function SWEP:Initialize()
	self:SetHoldType("slam")
end

if CLIENT then
	function SWEP:DrawWorldModel()
		self:DrawModel()

		if IsValid(self:GetOwner()) then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

			if Pos and Ang then
				self:SetRenderOrigin(Pos + Ang:Forward() * 3.2 + Ang:Right() * 2 + Ang:Up() * 2)
				Ang:RotateAroundAxis(Ang:Up(), 0)
				Ang:RotateAroundAxis(Ang:Right(), 0)
				Ang:RotateAroundAxis(Ang:Forward(), 180)
				self:SetModelScale(1)
				self:SetRenderAngles(Ang)
				self:DrawModel()
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		self:GetOwner():SetNWInt("painlosing", math.Clamp(self:GetOwner():GetNWInt("painlosing") + 5, 1, 15))
		self:Remove()
		sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
		self:GetOwner():SelectWeapon("weapon_hands")
	end
end

function SWEP:SecondaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		local tr = util.TraceHull({
			start = self:GetOwner():GetShootPos(),
			endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 48),
			filter = self:GetOwner(),
			mins = Vector(-10, -10, -10),
			maxs = Vector(10, 10, 10),
		})

		WhomILookinAt = tr.Entity

		if IsValid(WhomILookinAt) then
			if WhomILookinAt:IsRagdoll() then
				if not IsValid(RagdollOwner(WhomILookinAt)) then return nil end
				RagdollOwner(WhomILookinAt):SetNWInt("painlosing", math.Clamp(RagdollOwner(WhomILookinAt):GetNWInt("painlosing") + 5, 1, 15))
				self:Remove()
				sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
				self:GetOwner():SelectWeapon("weapon_hands")
			end
		end
	end
end