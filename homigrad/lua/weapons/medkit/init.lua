include("shared.lua")

SWEP.Dealy = 0.25

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Dealy)
	self:SetNextSecondaryFire(CurTime() + self.Dealy)

	local owner = self:GetOwner()
	if self:Heal(owner) then owner:SetAnimation(PLAYER_ATTACK1) self:Remove() self.Owner:SelectWeapon("weapon_hands") end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Dealy)
	self:SetNextSecondaryFire(CurTime() + self.Dealy)

	local owner = self:GetOwner()
	local ent = owner:GetEyeTraceDis(75).Entity
	ent = (ent:IsPlayer() and ent) or (RagdollOwner(ent)) or (ent:GetClass() == "prop_ragdoll" and ent)
	if not ent then return end

	if self:Heal(ent) then
		if ent:IsPlayer() then
			local dmg = DamageInfo()
			dmg:SetDamage(-5)
			dmg:SetAttacker(self)

			local att = self:GetOwner()
				
			if GuiltLogic(att,ent,dmg,true) then
				att.Guilt = math.max(att.Guilt - 20,0)
			end
		end
		owner:SetAnimation(PLAYER_ATTACK1)
		self:Remove()
		self.Owner:SelectWeapon("weapon_hands")
	end
end

local healsound = Sound("snd_jack_bandage.wav")

function SWEP:Heal(ent)
	if not ent or not ent:IsPlayer() then sound.Play(healsound,ent:GetPos(),75,100,0.5) return true end

	if ent.pain > 50 then
		ent.painlosing = math.Clamp(ent.painlosing + 2.5,1,15)

		sound.Play(healsound,ent:GetPos(),75,100,0.5)

		return true
	end

	if ent.Bloodlosing > 0 then
		ent.Bloodlosing = math.max(ent.Bloodlosing - 30,0)
		sound.Play(healsound,ent:GetPos(),75,100,0.5)

		return true
	end

	if ent:Health() < 150 then
		ent:SetHealth(math.Clamp(self.Owner:Health() + 10,0,150))
		ent.hungryregen = ent.hungryregen + 6
		sound.Play(healsound,ent:GetPos(),75,100,0.5)

		return true
	end
end