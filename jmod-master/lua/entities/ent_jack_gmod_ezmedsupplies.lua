-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Medical Supplies Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/medical supplies.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES
ENT.JModPreferredCarryAngles = Angle(0, -90, 90)
ENT.Model = "models/hunter/blocks/cube05x075x025.mdl"
ENT.Material = "models/kali/props/cases/hardcase/jardcase_b"
ENT.ModelScale = 0.6
ENT.Mass = 30
ENT.ImpactNoise1 = "drywall.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"

ENT.PropModels = {"models/jmod/items/healthkit.mdl", "models/healthvial.mdl", "models/jmod/items/medjit_medium.mdl", "models/jmod/items/medjit_small.mdl", "models/weapons/w_models/w_bonesaw.mdl", "models/bandages.mdl"}

-- todo: missing texture
---
if SERVER then
	function ENT:AltUse(ply)
		local Wep = ply:GetActiveWeapon()

		if Wep and Wep.EZaccepts and (table.HasValue(Wep.EZaccepts, self.EZsupplies)) then
			local ExistingAmt = Wep:GetSupplies()
			local Missing = Wep.EZmaxSupplies - ExistingAmt

			if Missing > 0 then
				local AmtToGive = math.min(Missing, self:GetResource())
				Wep:SetSupplies(ExistingAmt + AmtToGive)
				sound.Play("items/ammo_pickup.wav", self:GetPos(), 65, math.random(90, 110))
				self:SetResource(self:GetResource() - AmtToGive)

				if self:GetResource() <= 0 then
					self:Remove()

					return
				end
			end
		end
	end

	local healkits = {
		"medkit",
		"med_band_big",
		"med_band_small",
		"morphine"
	}

	function ENT:Use(activator)
		local Alt = activator:KeyDown(JMod.Config.AltFunctionKey)

		if Alt then
			for k,v in pairs(healkits) do
				if not activator:HasWeapon( v ) then
					activator:Give(v)
					self:SetResource(self:GetResource() - 2.5)
					sound.Play("items/ammo_pickup.wav", self:GetPos(), 65, math.random(90, 110))
					self:FlingProp(table.Random(self.PropModels))
				end
			end
		else
			activator:PickupObject(self)
		end
	end

	function ENT:UseEffect(pos, ent)
		for i = 1, 4 * JMod.Config.SupplyEffectMult do
			self:FlingProp(table.Random(self.PropModels))
		end

		local effectdata = EffectData()
		effectdata:SetOrigin(pos + VectorRand())
		effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(1, 2)) --length of strands
		effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 0, 4.2), Angle(0, 0, 0), .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES, self:GetResource(), nil, 0, 0, 200, true, "JMod-Stencil-MS")
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
