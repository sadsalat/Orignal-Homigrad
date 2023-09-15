if true then return end

function ApplySuppressionEffect(at, hit, start)
	bruh = start or at:EyePos()
	bruhh = hit

	for _,v in pairs(player.GetAll()) do
		local distance, sup_point = util.DistanceToLine( bruh, bruhh, v:GetPos() )

		if v:IsPlayer() and v:Alive() and distance < 70 and !(v == at) then
			v.adrenaline = math.min(v.adrenaline + 0.1,2)
		end --end alive test
	end --end for
end -- end function


local ENTITY = FindMetaTable( "Entity" )
ENTITY.oFireBullets = ENTITY.oFireBullets or ENTITY.FireBullets

function ENTITY:FireBullets( bul, she )
	local oldcb = bul.Callback
	bul.Callback = function( at, tr, dm )
		if oldcb then oldcb( at, tr, dm ) end
		if SERVER then ApplySuppressionEffect(at, tr.HitPos, tr.StartPos) end
	end

	return self:oFireBullets( bul, she )
end

--[[
hook.Add("EntityFireBullets", "SharpenWhenShotNear", function(ent, bul)

	if SERVER then

		local atk, trac, dmg = nil, nil, nil

		function bul:Callback(at, tr, dm)
			atk, trac, dmg = at, tr, dm
			print( "callback" )
			ApplySuppressionEffect(tr:GetDamagePosition())
		end --what a load of ass

	end
end)]]