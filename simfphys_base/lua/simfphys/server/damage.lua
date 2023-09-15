
hook.Add( "EntityTakeDamage", "!!!_simfphys_fix_vehicle_explosion_damage", function( target, dmginfo )
	if not target:IsPlayer() then return end

	local veh = target:GetSimfphys()

	if not IsValid( veh ) or dmginfo:IsDamageType( DMG_DIRECT ) then return end

	dmginfo:SetDamage( 0 )
end )