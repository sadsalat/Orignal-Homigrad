include("shared.lua")

local healsound1 = Sound("npc/antlion/foot4.wav")
local healsound2 = Sound("npc/antlion/shell_impact2.wav")

util.AddNetworkString("blood_gotten")

bloodtranslate = {
	[1] = "o-",
	[2] = "o+",
	[3] = "a-",
	[4] = "a+",
	[5] = "b-",
	[6] = "b+",
	[7] = "ab-",
	[8] = "ab+"
}

bloodtypes = {
	["o-"] = {["o-"] = true,["o+"] = true,["a-"] = true,["a+"] = true,["b-"] = true,["b+"] = true,["ab-"] = true,["ab+"] = true},
	["o+"] = {["o+"] = true,["a+"] = true,["b+"] = true,["ab+"] = true},
	["a-"] = {["a+"] = true,["a-"] = true,["ab+"] = true,["ab-"] = true},
	["a+"] = {["a+"] = true,["ab+"] = true},
	["b-"] = {["b+"] = true,["b-"] = true,["ab+"] = true,["ab-"] = true},
	["b+"] = {["b+"] = true,["ab+"] = true},
	["ab-"] = {["ab+"] = true,["ab-"] = true},
	["ab+"] = {["ab+"] = true}
}

function SWEP:Think()
	if self.Owner:KeyDown(IN_ATTACK) then
		local owner = self:GetOwner()
		local ent = owner
		if not ent then
			self.zabortime = nil
			return
		end

		self.bloodinside = self.bloodinside or false

		if self.Owner:KeyPressed(IN_ATTACK) then
			self.zabortime = self.zabortime or CurTime()
			ent:EmitSound(healsound2)
			owner:SetAnimation(PLAYER_ATTACK1)
			ent.bloodtype = ent.bloodtype or math.random(1,8)
			owner:ChatPrint(self.bloodinside and bloodtranslate[self.bloodtype].." -> "..bloodtranslate[ent.bloodtype] or bloodtranslate[ent.bloodtype].." -> пакет для крови")
			--local compatible = bloodtypes[bloodtranslate[self.bloodtype]][bloodtranslate[ent.bloodtype]]
			--owner:ChatPrint(not self.bloodinside and tostring(blood_compatibility))
		end
	
		if ent then
			if self.zabortime and (self.zabortime + 2) <= CurTime() then
				self:Heal(ent)
				self:SetSkin(not self.bloodinside and 1 or 0)
			end
		end
	elseif self.Owner:KeyDown(IN_ATTACK2) then
		local owner = self:GetOwner()
		local ent = owner:GetEyeTraceDis(75).Entity
		ent = (ent:IsPlayer() and ent) or (RagdollOwner(ent)) or ((ent.Blood or 0) > 500 and ent)
		if not ent then
			self.zabortime = nil
			return
		end

		if self.Owner:KeyPressed(IN_ATTACK2) then
			self.zabortime = self.zabortime or CurTime()
			ent:EmitSound(healsound2)
			owner:SetAnimation(PLAYER_ATTACK1)
			ent.bloodtype = ent.bloodtype or math.random(1,8)
			owner:ChatPrint(self.bloodinside and bloodtranslate[self.bloodtype].." -> "..bloodtranslate[ent.bloodtype] or bloodtranslate[ent.bloodtype].." -> пакет для крови")
			--local compatible = bloodtypes[bloodtranslate[self.bloodtype]][bloodtranslate[ent.bloodtype]]
			--owner:ChatPrint(not self.bloodinside and tostring(blood_compatibility))
		end
	
		if ent then
			if self.zabortime and (self.zabortime + 2) <= CurTime() then
				self:Heal(ent)
				self:SetSkin(not self.bloodinside and 1 or 0)
			end
		end
	else
		self.zabortime = nil
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:PostInit()
	self.bloodinside = math.random(1,5) > 2 and true or false
	if self.bloodinside then
		self.bloodtype = math.random(1,8)
		net.Start("blood_gotten")
		net.WriteEntity(self)
		net.WriteBool(false)
		net.Broadcast()
	end
	self:SetSkin(not self.bloodinside and 1 or 0)
end

function SWEP:SecondaryAttack()
end

function SWEP:Heal(ent)
	ent:EmitSound(healsound1)
	self.zabortime = nil

	if self.bloodinside then
		self.bloodinside = false
		local compatible = bloodtypes[bloodtranslate[self.bloodtype]][bloodtranslate[ent.bloodtype]]
		--ent:ChatPrint(tostring(compatible))
		ent.Blood = math.min(ent.Blood + (compatible and 500 or 0),5000)
		if not compatible then
			ent.InternalBleeding6 = 20
		end

		net.Start("blood_gotten")
		net.WriteEntity(self)
		net.WriteBool(true)
		net.Broadcast()

		ent:EmitSound(healsound1)
	else
		if ent.Blood > 4000 then
			self.bloodinside = true
			ent.Blood = math.max(ent.Blood - 500,0)
			self.bloodtype = ent.bloodtype

			net.Start("blood_gotten")
			net.WriteEntity(self)
			net.WriteBool(false)
			net.Broadcast()
	
			ent:EmitSound(healsound1)
		end
	end
end