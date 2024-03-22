SWEP.Base = "weapon_base"
AddCSLuaFile()
SWEP.PrintName = "Адреналин"
SWEP.Author = "Вколи в себя и убей всех с ножа!"
SWEP.Purpose = "Твои адреналин будет на макисмалке"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/w_models/w_jyringe_jroj.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_jyringe_jroj.mdl"
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
	self:SetHoldType("normal")
end

if CLIENT then
	function SWEP:DrawWorldModel()
		self:DrawModel()

		if IsValid(self:GetOwner()) then
			local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

			if Pos and Ang then
				self:SetRenderOrigin(Pos + Ang:Forward() * 3.7 + Ang:Right() * 1 + Ang:Up() * 2)
				Ang:RotateAroundAxis(Ang:Up(), 90)
				Ang:RotateAroundAxis(Ang:Right(), 90)
				self:SetModelScale(1)
				self:SetRenderAngles(Ang)
				self:DrawModel()
			end
		end
	end
end

local function ApplyAdrenaline()
	for _, v in ipairs(player.GetAll()) do
		for i = 1, (v:GetNWInt("Adrenaline") / 0.05) + 1 do
			timer.Simple(2 * i, function()
				v:SetNWInt("Adrenaline", math.Clamp(v:GetNWInt("Adrenaline") - 0.05, 0, 10))
			end)
		end
	end
end

function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if SERVER then
		-- if 1 then -- ЧТО ОДИН ЧТО ОДИН НАХУЙ Я НЕ ПОНИМАЮ СУКА ААААААААААААААААА БЛЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ Я СУМАСШЕДШИЙ ПСИХ Я СБЕЖАЛ ИЗ ДУРКИ И СЕЛ КОДИТЬ ХОМИГРАД ХАХАХАХАХААА АААААААААААААААААААААА ААААААААААААААААААААААААААААААААААААА
		self:Remove()
		self:GetOwner():SetNWInt("Adrenaline", 2)

		if self:GetOwner():Health() < 120 then
			self:GetOwner():SetHealth(math.Clamp(self:GetOwner():Health() + 20, 0, 120))
		end

		ApplyAdrenaline()
		self:GetOwner():SelectWeapon("weapon_hands")
		sound.Play(healsound, self:GetPos(), 75, 100, 0.5)
	end
end