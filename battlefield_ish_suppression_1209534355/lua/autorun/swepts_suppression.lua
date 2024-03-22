function ApplySuppressionEffect(at, hit, start)
	bruh = start or at:EyePos()
	bruhh = hit
	for _, ply in ipairs(player.GetAll()) do
		local distance, sup_point = util.DistanceToLine(bruh, bruhh, ply:GetPos())
		if ply:IsPlayer() and ply:Alive() and distance < 70 and not (ply == at) then
			ply:SetNWInt("Adrenaline", math.Clamp(ply:GetNWInt("Adrenaline"), 0, 1) + 0.05 * 1)
			sound.Play("snd_jack_hmcd_bc_" .. math.random(1, 7) .. ".wav", sup_point, 75, 100, 0.5)
			if 1 then end
			timer.Remove(ply:Name() .. "blurreset")
			timer.Create(
				ply:Name() .. "blurreset",
				4,
				1,
				function()
					for i = 1, (ply:GetNWInt("Adrenaline") / 0.05) + 1 do
						timer.Simple(
							1.5 * i,
							function()
								ply:SetNWInt("Adrenaline", math.Clamp(ply:GetNWInt("Adrenaline") - 0.1, 0, 10))
							end
						)
					end
				end
			)
			--end timer function
		end
		--end alive test
	end
	--end for
end

-- end function
local ENTITY = FindMetaTable("Entity")
ENTITY.oFireBullets = ENTITY.oFireBullets or ENTITY.FireBullets
function ENTITY:FireBullets(bul, she)
	local oldcb = bul.Callback
	bul.Callback = function(at, tr, dm)
		if oldcb then
			oldcb(at, tr, dm)
		end

		if SERVER then
			ApplySuppressionEffect(at, tr.HitPos, tr.StartPos)
		end
	end

	return self:oFireBullets(bul, she)
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
hook.Add(
	"RenderScreenspaceEffects",
	"ApplySuppression",
	function()
		DrawSharpen(5, LocalPlayer():GetNWInt("Adrenaline"))
	end
)

hook.Add(
	"PlayerInitialSpawn",
	"SetUpSharpenNWInt",
	function(ply)
		ply:SetNWInt("Adrenaline", 0)
	end
)

hook.Add(
	"PlayerDeath",
	"RemoveSharpenOnDeath",
	function(ply, i, a)
		ply:SetNWInt("Adrenaline", 0)
	end
)