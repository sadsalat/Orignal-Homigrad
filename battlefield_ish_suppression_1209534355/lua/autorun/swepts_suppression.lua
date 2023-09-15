function ApplySuppressionEffect(at, hit, start)
	bruh = start or at:EyePos()
	bruhh = hit
	for _,v in pairs(player.GetAll()) do
		local distance, sup_point = util.DistanceToLine( bruh, bruhh, v:GetPos() )
			v:SetNWInt("Adrenaline", math.Clamp(v:GetNWInt("Adrenaline"), 0, 2) + 0.1)
			sound.Play("bul_snap/supersonic_snap_" .. math.random(1,12) .. ".wav", bhit, 75, 100, 1)
			timer.Remove(v:Name() .. "sharpenreset")
			timer.Create(v:Name() .. "sharpenreset", 2, 1, function()
				for i=1,(v:GetNWInt("Adrenaline") / 0.05) + 1 do
					timer.Simple(2 * i, function()
						v:SetNWInt("Adrenaline", math.Clamp(v:GetNWInt("Adrenaline") - 0.1, 0, 10))
					end)
				end
			end) --end timer function
		end --end alive test
	end --end for
function ApplySuppressionEffect(at, hit, start)
	bruh = start or at:EyePos()
	bruhh = hit
	for _,v in pairs(player.GetAll()) do
		local distance, sup_point = util.DistanceToLine( bruh, bruhh, v:GetPos() )
		if v:IsPlayer() and v:Alive() and distance < 70 and !(v == at) then
			v:SetNWInt("Adrenaline", math.Clamp(v:GetNWInt("Adrenaline"), 0, 1) + 0.05 * 1)
			sound.Play("bul_snap/supersonic_snap_" .. math.random(1,18) .. ".wav", sup_point, 75, 100, 1)
			if 1 then
			v:ViewPunch( Angle( math.Rand(-1, 1) * (v:GetNWInt("Adrenaline")) * (1), math.Rand(-1, 1) * (v:GetNWInt("Adrenaline")) * (1), math.Rand(-1, 1) * (v:GetNWInt("Adrenaline")) * (1) ) ) 
			end
			timer.Remove(v:Name() .. "blurreset")
			timer.Create(v:Name() .. "blurreset", 4, 1, function()
				for i=1,(v:GetNWInt("Adrenaline") / 0.05) + 1 do
					timer.Simple(1.5 * i, function()
						v:SetNWInt("Adrenaline", math.Clamp(v:GetNWInt("Adrenaline") - 0.1, 0, 10))
					end)
				end 
			end) --end timer function
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

hook.Add("RenderScreenspaceEffects", "ApplySuppression", function()
	DrawSharpen(5, LocalPlayer():GetNWInt("Adrenaline"))
end)

hook.Add("PlayerInitialSpawn", "SetUpSharpenNWInt", function(ply)

	ply:SetNWInt("Adrenaline", 0)

end)

hook.Add("PlayerDeath", "RemoveSharpenOnDeath", function(ply, i, a)

	ply:SetNWInt("Adrenaline", 0)

end)