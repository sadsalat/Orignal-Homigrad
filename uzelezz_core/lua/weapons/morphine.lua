SWEP.Base = "weapon_base"
AddCSLuaFile()
SWEP.PrintName = "Морфий"
SWEP.Author = "Morphine"
SWEP.Purpose = "Уберает всю боль"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_adrenaline.mdl"
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
local healsound = Sound("Underwater.BulletImpact")

function SWEP:Initialize()
	self:SetHoldType("slam")
end

if CLIENT then
	function SWEP:DrawWorldModel()
		self:DrawModel()

		if IsValid(self:GetOwner()) then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

			if Pos and Ang then
				self:SetRenderOrigin(Pos + Ang:Forward() * 3.6 + Ang:Right() * 1)
				Ang:RotateAroundAxis(Ang:Up(), 0)
				Ang:RotateAroundAxis(Ang:Right(), 0)
				Ang:RotateAroundAxis(Ang:Forward(), 100)
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
		self:GetOwner():SetNWInt("pain", self:GetOwner():GetNWInt("pain") - 50)
		self:GetOwner():SetNWInt("painlosing", math.Clamp(self:GetOwner():GetNWInt("painlosing") + 15, 1, 15))
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

		if WhomILookinAt:IsRagdoll() then
			if not IsValid(RagdollOwner(WhomILookinAt)) then return nil end
			RagdollOwner(WhomILookinAt):SetNWInt("pain", RagdollOwner(WhomILookinAt):GetNWInt("pain") - 50)
			RagdollOwner(WhomILookinAt):SetNWInt("painlosing", math.Clamp(RagdollOwner(WhomILookinAt):GetNWInt("painlosing") + 15, 1, 15))
			self:Remove()
			sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
			self:GetOwner():SelectWeapon("weapon_hands")
		end
	end
end