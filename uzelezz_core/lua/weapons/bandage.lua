AddCSLuaFile()
SWEP.Base = "weapon_base"
SWEP.PrintName = "Туалетная Бумага"
SWEP.Author = "носки?"
SWEP.Purpose = "Лечит Кровотечение"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/props/cs_office/Paper_towels.mdl"
SWEP.WorldModel = "models/props/cs_office/Paper_towels.mdl"
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
	self:SetHoldType("slam")
end

if CLIENT then
	function SWEP:DrawWorldModel()
		self:DrawModel()

		if IsValid(self:GetOwner()) then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

			if Pos and Ang then
				self:SetRenderOrigin(Pos + Ang:Forward() * 3.5 + Ang:Right() * 0.5)
				Ang:RotateAroundAxis(Ang:Up(), 90)
				Ang:RotateAroundAxis(Ang:Right(), 90)
				self:SetModelScale(0.4)
				self:SetRenderAngles(Ang)
				self:DrawModel()
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if SERVER and self:GetOwner():GetNWInt("BloodLosing") > 0 then
		self:Remove()
		self:GetOwner():SelectWeapon("weapon_hands")
		self:GetOwner():SetNWInt("BloodLosing", self:GetOwner():GetNWInt("BloodLosing") - 30)
		sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
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

		local WhomILookinAt = tr.Entity

		if IsValid(WhomILookinAt) and WhomILookinAt:IsPlayer() and WhomILookinAt:GetNWInt("BloodLosing") > 0 then
			self:Remove()
			self:GetOwner():SelectWeapon("weapon_hands")
			WhomILookinAt:SetNWInt("BloodLosing", WhomILookinAt:GetNWInt("BloodLosing") - 30)
			sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
		end

		if WhomILookinAt:IsRagdoll() then
			if not IsValid(RagdollOwner(WhomILookinAt)) then return nil end

			if RagdollOwner(WhomILookinAt):GetNWInt("BloodLosing") > 0 then
				RagdollOwner(WhomILookinAt):SetNWInt("BloodLosing", RagdollOwner(WhomILookinAt):GetNWInt("BloodLosing") - 30)
				self:Remove()
				sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
				self:GetOwner():SelectWeapon("weapon_hands")
			end
		end
	end
end