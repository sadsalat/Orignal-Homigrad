
function SWEP:ShootBullet(damage, num_bullets, aimcone)
	local bullet = {}
	bullet.Num = num_bullets
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Spread = Vector(aimcone, aimcone, 0)
	bullet.Tracer	= 1
	bullet.Force = damage/10
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(ent, tr, dmg)
		dmg:SetAttacker(self:GetOwner())
		dmg:SetInflictor(self)
	end
	self:GetOwner():FireBullets(bullet)
	self:ShootEffects()
end
