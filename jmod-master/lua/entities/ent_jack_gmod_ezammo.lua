-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Ammo Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/ammo.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.AMMO
ENT.JModPreferredCarryAngles = Angle(0, -90, 90)
ENT.Model = "models/hunter/blocks/cube05x075x025.mdl"
ENT.Material = "models/mat_jack_gmod_ezammobox"
ENT.ModelScale = 0.6
ENT.Mass = 50
ENT.ImpactNoise1 = "Metal_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"
ENT.Hint = "ammobox"

---
local ShellEffects = {"RifleShellEject", "PistolShellEject", "ShotgunShellEject"}

if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 30 * JMod.Config.SupplyEffectMult do
			timer.Simple(i / 200, function()
				local Eff = EffectData()
				Eff:SetOrigin(pos)
				Eff:SetAngles((VectorRand() + Vector(0, 0, 1)):GetNormalized():Angle())
				Eff:SetEntity(ent)
				util.Effect(table.Random(ShellEffects), Eff, true, true)
			end)
		end
	end

	function ENT:AltUse(ply)
		JMod.GiveAmmo(ply, self)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 0, 4.2), Angle(0, 0, 0), .03, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.AMMO, self:GetResource(), nil, 0, 0, 250, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
