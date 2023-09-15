if SERVER then resource.AddWorkshop("2746696467") end

local trh = {}
local trh_data = {
	output = trh,
	mask = MASK_SOLID
}
local tr = {}
local tr_data = {
	output = tr,
	mask = MASK_SOLID
}
local tr2 = {}
local tr2_data = {
	output = tr2,
	mask = MASK_SOLID
}

--CreateClientConVar("chloeimpact_max_scale", 300, true, false, "Maximum scale for impact effects")
CreateClientConVar("chloeimpact_max_debris_props", 25, true, false, "Maximum debris chunks for impact effects")
CreateClientConVar("chloeimpact_max_debris_effects", 100, true, false, "Maximum dust clouds for impact effects")
CreateClientConVar("chloeimpact_impact_lifetime", 5, true, false, "Time in seconds for impact effects to last")
CreateClientConVar("chloeimpact_impact_debris_lifetime", 5, true, false, "Time in seconds for physical impact effects to last")

local VelScale = CreateConVar("chloeimpact_velocity_scale", 1, FCVAR_ARCHIVE, "Scale for velocity for impacts")
local DmgScale = CreateConVar("chloeimpact_damage_scale", 1, FCVAR_ARCHIVE, "Scale for damage taken from velocity")
local AllowPropImpact = CreateConVar("chloeimpact_prop_impact", 0, FCVAR_ARCHIVE, "(EXPERIMENTAL) Prop/Ragdoll Impact")
local AllowPropLodge = CreateConVar("chloeimpact_prop_lodge", 0, FCVAR_ARCHIVE, "(EXPERIMENTAL) Prop/Ragdoll Lodging")
local AllowPlayerLodge = CreateConVar("chloeimpact_player_lodging", 0, FCVAR_ARCHIVE, "Player Wall Lodging")
local gm = {}
local rocks = {
	"models/props_debris/physics_debris_rock1.mdl",
	"models/props_debris/physics_debris_rock2.mdl",
	"models/props_debris/physics_debris_rock3.mdl",
	"models/props_debris/physics_debris_rock5.mdl",
	"models/props_debris/physics_debris_rock7.mdl",
	"models/props_debris/physics_debris_rock8.mdl",
	"models/props_debris/physics_debris_rock9.mdl",
	"models/props_debris/physics_debris_rock10.mdl",
	"models/props_debris/physics_debris_rock11.mdl",
}

local ant_gibs = {
	"models/gibs/antlion_gib_medium_1.mdl",
	"models/gibs/antlion_gib_medium_2.mdl",
	"models/gibs/antlion_gib_medium_3.mdl",
	"models/gibs/antlion_gib_medium_3a.mdl",
	"models/gibs/antlion_gib_small_1.mdl",
	"models/gibs/antlion_gib_small_2.mdl",
	"models/gibs/antlion_gib_small_3.mdl",
}
local metal_gibs = {
	"models/props_debris/metal_panelshard01a.mdl",
	"models/props_debris/metal_panelshard01b.mdl",
	"models/props_debris/metal_panelshard01c.mdl",
	"models/props_debris/metal_panelshard01d.mdl",
}

for k,v in pairs(rocks) do
	util.PrecacheModel(v)
end
for k,v in pairs(ant_gibs) do
	util.PrecacheModel(v)
end
for k,v in pairs(metal_gibs) do
	util.PrecacheModel(v)
end
hook.Add("PostGamemodeLoaded", "Register_Chloeimpact", function()
	gm = GAMEMODE or GM or gmod.GetGamemode()
end)
ChloeImpact = {}
gm.GetChloeImpact = function()
	return ChloeImpact
end

local impact_dmg_timer = CurTime()
ChloeImpact.DamageEffect = function(totalDamage, startPos, endPos, attackNormal, filter)
	if SERVER and CurTime() > impact_dmg_timer then
		tr_data.start = startPos
		tr_data.endpos = endPos
		tr_data.filter = filter
		util.TraceLine(tr_data)
		if tr.Entity:IsNPC() then return end
		if not attackNormal then 
			attackNormal = (tr.Normal + tr.HitNormal):GetNormalized() * totalDamage
		end
		local fx = EffectData()
		fx:SetNormal(tr.HitNormal)
		fx:SetStart(attackNormal)
		fx:SetOrigin(tr.HitPos)
		fx:SetScale(totalDamage * 10)
		fx:SetSurfaceProp(tr.SurfaceProps)
		util.Effect("chloeimpact_groundcrack", fx,  true, true)
		impact_dmg_timer = CurTime() + 0.45
	end
end

--[[hook.Add("EntityFireBullets", "DoChloeImpactEffect", function(entity,data)
	local damage = math.max(data.Damage, game.GetAmmoPlayerDamage(game.GetAmmoID(data.AmmoType)))
	ChloeImpact.DamageEffect(damage, data.Src, data.Src + (data.Dir * data.Distance),nil, entity )
end)]]--

hook.Add("SetupMove", "ChloeImpact_Crater", function(ply, mv, cmd)
	if true then return end

	if ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:Health() > 0 then
		local TickRate = 1 / engine.TickInterval()
		ply.LastCrater = ply.LastCrater or CurTime()
		local VelLength = mv:GetVelocity():Length()
		ply.Crater_OldVelocity = ply.Crater_OldVelocity or mv:GetVelocity()
		local OldVelLength = mv:GetVelocity():Length() + 1
		if SERVER and CurTime() > ply.LastCrater and ply.Crater_OldVelocity and (ply.Crater_OldVelocity - mv:GetVelocity()):LengthSqr() > 300000 then
			local mins, maxs = ply:GetCollisionBounds()
			trh_data.start = ply:WorldSpaceCenter()
			trh_data.endpos = ply:WorldSpaceCenter()
			trh_data.mins = maxs * -1.1
			trh_data.maxs = maxs * 1.1
			trh_data.filter = ply
			util.TraceHull(trh_data)
			if trh.Hit then
				tr_data.start = ply:GetPos()
				tr_data.endpos = ply:GetPos() + ply.Crater_OldVelocity:GetNormalized() * 100
				tr_data.filter = ply
				util.TraceLine(tr_data)
				if not tr.Hit then
					tr_data.endpos = ply:GetPos()
					tr_data.start = ply:GetPos() + ply.Crater_OldVelocity:GetNormalized() * 100
					util.TraceLine(tr_data)
				end
				
				if tr.Hit then
					local attackAngle = (mv:GetVelocity() + tr.HitNormal):GetNormalized() * OldVelLength / (TickRate/15)
					local speed = OldVelLength * TickRate
					local fx = EffectData()
					fx:SetNormal(tr.HitNormal)
					fx:SetStart(attackAngle)
					fx:SetOrigin(tr.HitPos)
					fx:SetScale(speed * VelScale:GetFloat())
					fx:SetSurfaceProp(tr.SurfaceProps)
					util.ScreenShake(ply:GetPos(), speed * 3, speed * 3, 1, speed)
					tr2_data.start=tr.HitPos - tr.HitNormal * (100 * (1 - tr.FractionLeftSolid))
					tr2_data.endpos=tr.HitPos
					tr2_data.filter = ply
					util.TraceLine(tr2_data)
					util.Effect("chloeimpact_groundcrack", fx,  true, true)
					local dmginfo = DamageInfo()
					
					local attacker = ply
					dmginfo:SetAttacker( attacker )
					
					dmginfo:SetInflictor( ply )
					dmginfo:SetDamage( (speed/10000) * DmgScale:GetFloat() )
					
					dmginfo:SetDamageType( DMG_CLUB )
					
					ply:TakeDamageInfo( dmginfo )
					if (ply.Crater_OldVelocity:GetNormalized()):Dot(tr.HitNormal) < -0.7 then
						if not tr2.StartSolid then
							local trh2 = util.TraceHull({
								start = tr2.HitPos + ply.Crater_OldVelocity/TickRate,
								endpos = tr2.HitPos + ply.Crater_OldVelocity/TickRate,
								mins = mins, 
								maxs = maxs,
								filter = ply,
								mask = MASK_SOLID
							})
							if not trh2.Hit and not tr2.StartSolid then
								mv:SetOrigin(tr2.HitPos + ply.Crater_OldVelocity/TickRate)
								mv:SetVelocity(ply.Crater_OldVelocity/2)
								fx:SetNormal(tr2.HitNormal)
								fx:SetOrigin(tr2.HitPos)
								fx:SetSurfaceProp(tr2.SurfaceProps)
								util.Effect("chloeimpact_groundcrack", fx,  true, true)
							end
						elseif tr2.StartSolid and AllowPlayerLodge:GetBool() and (speed/TickRate) > 10 / VelScale:GetFloat() then
							ply.ChloeImpact_InWall_Exit = mv:GetOrigin()
							mv:SetOrigin(tr.HitPos + ply.Crater_OldVelocity:GetNormalized() * 55)
							ply.ChloeImpact_InWall = mv:GetOrigin()
						end
					end
					
					if (ply.Crater_OldVelocity:GetNormalized()):Dot(tr.HitNormal) > -0.7 then
						mv:SetVelocity(attackAngle * OldVelLength/TickRate)
						if math.random(1,5) == 1 then
							mv:SetVelocity(((mv:GetVelocity():GetNormalized() + tr.HitNormal) * 1000))
						end
					end
					ply.LastCrater = CurTime() + 1
				end
			end
		end
		ply.Crater_OldVelocity = mv:GetVelocity()
	end
	
	if ply.ChloeImpact_InWall then
		ply:SetNWBool("ChloeImpact_InWall", true)
		local norm = -(mv:GetOrigin() - ply.ChloeImpact_InWall_Exit):GetNormalized()
		ply:SetEyeAngles(norm:Angle())
		if mv:GetOrigin() ~= ply.ChloeImpact_InWall then
			ply:SetNWBool("ChloeImpact_InWall", false)
			ply.ChloeImpact_InWall = nil
		end
		if cmd:KeyDown(IN_JUMP) or cmd:KeyDown(IN_FORWARD) then
			mv:SetOrigin(ply.ChloeImpact_InWall_Exit)
			ply:SetNWBool("ChloeImpact_InWall", false)
			ply.ChloeImpact_InWall = nil
		end
	end
end)

hook.Add("PlayerSpawnedRagdoll", "ChloeImpact_RagdollCollide", function(ply, model, entity)
	if AllowPropImpact:GetBool() then
		timer.Simple(1, function()
			if IsValid(entity) then
				entity:AddCallback("PhysicsCollide", function(entity, data)
					if (entity.LastCrater and CurTime() > entity.LastCrater or not entity.LastCrater) and data.HitObject == Entity(0):GetPhysicsObject() then
						if data.OurOldVelocity:LengthSqr() >= 300000 then
							local TickRate = 1 / engine.TickInterval()
							local OldVelLength = data.OurOldVelocity:Length()
							local attackAngle = (data.OurNewVelocity + data.HitNormal):GetNormalized() * OldVelLength / (TickRate/15)
							local speed = OldVelLength
							local fx = EffectData()
							tr_data.start = entity:WorldSpaceCenter()
							tr_data.endpos = entity:WorldSpaceCenter() + data.OurOldVelocity:GetNormalized() * 100
							tr_data.filter = entity
							util.TraceLine(tr_data)
							fx:SetNormal(tr.HitNormal)
							fx:SetOrigin(tr.HitPos + tr.HitNormal)
							fx:SetScale(speed)
							fx:SetStart(Vector())
							fx:SetSurfaceProp(tr.SurfaceProps)
							util.Effect("chloeimpact_groundcrack", fx,  true, true)
							local pos = tr.HitPos
							if speed > 550 then
								timer.Simple(0.1, function()
									if IsValid(entity) and AllowPropLodge:GetBool() then
										for i=0, entity:GetPhysicsObjectCount() - 1 do
											if entity:GetPhysicsObjectNum(i):GetPos():DistToSqr(pos) < 400 then
												constraint.Weld(entity, data.HitEntity, i, 0, 5550, true)
											end
										end
									end
								end)
							end
							entity.LastCrater = CurTime() + 1
						end
					end
				end)
			end
		end)
	end
end)

hook.Add("CreateEntityRagdoll", "ChloeImpact_RagdollCollide", function(ply, entity)
	if AllowPropImpact:GetBool() then
		timer.Simple(0.3, function()
			if IsValid(entity) then
				entity:AddCallback("PhysicsCollide", function(entity, data)
					if (entity.LastCrater and CurTime() > entity.LastCrater or not entity.LastCrater) and data.HitObject == Entity(0):GetPhysicsObject() then
						if data.OurOldVelocity:LengthSqr() >= 300000 then
							local TickRate = 1 / engine.TickInterval()
							local OldVelLength = data.OurOldVelocity:Length()
							local attackAngle = (data.OurNewVelocity + data.HitNormal):GetNormalized() * OldVelLength / (TickRate/15)
							local speed = OldVelLength
							local fx = EffectData()
							tr_data.start = entity:WorldSpaceCenter()
							tr_data.endpos = entity:WorldSpaceCenter() + data.OurOldVelocity:GetNormalized() * 100
							tr_data.filter = entity
							util.TraceLine(tr_data)
							fx:SetNormal(tr.HitNormal)
							fx:SetOrigin(tr.HitPos + tr.HitNormal)
							fx:SetScale(speed)
							fx:SetStart(Vector())
							fx:SetSurfaceProp(tr.SurfaceProps)
							util.Effect("chloeimpact_groundcrack", fx,  true, true)
							local pos = tr.HitPos
							if speed > 550 then
								timer.Simple(0.1, function()
									if IsValid(entity) and AllowPropLodge:GetBool() then
										for i=0, entity:GetPhysicsObjectCount() - 1 do
											if entity:GetPhysicsObjectNum(i):GetPos():DistToSqr(pos) < 400 then
												constraint.Weld(entity, data.HitEntity, i, 0, 5550, true)
											end
										end
									end
								end)
							end
							entity.LastCrater = CurTime() + 1
						end
					end
				end)
			end
		end)
	end
end)

hook.Add("CreateClientsideRagdoll", "ChloeImpact_RagdollCollide", function(ply, entity)
	if AllowPropImpact:GetBool() then
		timer.Simple(0.3, function()
			if IsValid(entity) then
				entity:AddCallback("PhysicsCollide", function(entity, data)
					if (entity.LastCrater and CurTime() > entity.LastCrater or not entity.LastCrater) and data.HitEntity == Entity(0) then
						if data.OurOldVelocity:LengthSqr() >= 300000 then
							local TickRate = 1 / engine.TickInterval()
							local OldVelLength = data.OurOldVelocity:Length()
							local attackAngle = (data.OurNewVelocity + data.HitNormal):GetNormalized() * OldVelLength / (TickRate/15)
							local speed = OldVelLength*TickRate
							local fx = EffectData()
							tr_data.start = data.HitPos
							tr_data.endpos = data.HitPos + data.OurOldVelocity:GetNormalized() * 100
							tr_data.filter = entity
							util.TraceLine(tr_data)
							fx:SetNormal(tr.HitNormal)
							fx:SetOrigin(data.HitPos + tr.HitNormal)
							fx:SetScale(speed)
							fx:SetStart(Vector())
							fx:SetSurfaceProp(tr.SurfaceProps)
							util.Effect("chloeimpact_groundcrack", fx,  true, true)
							entity.LastCrater = CurTime() + 1
						end
					end
				end)
			end
		end)
	end
end)

hook.Add("PlayerSpawnedProp", "ChloeImpact_PropCollide", function(ply, model, entity)
	if AllowPropImpact:GetBool() then
		timer.Simple(1, function()
			if IsValid(entity) then
				entity:AddCallback("PhysicsCollide", function(entity, data)
					if (entity.LastCrater and CurTime() > entity.LastCrater or not entity.LastCrater) and data.HitObject == Entity(0):GetPhysicsObject() then
						if data.OurOldVelocity:LengthSqr() >= 300000 then
							local TickRate = 1 / engine.TickInterval()
							local OldVelLength = data.OurOldVelocity:Length()
							local attackAngle = (data.OurNewVelocity + data.HitNormal):GetNormalized() * OldVelLength / (TickRate/15)
							local speed = OldVelLength * 5
							local fx = EffectData()
							tr_data.start = entity:WorldSpaceCenter()
							tr_data.endpos = entity:WorldSpaceCenter() + data.OurOldVelocity
							tr_data.filter = entity
							util.TraceLine(tr_data)
							fx:SetNormal(tr.HitNormal)
							fx:SetOrigin(tr.HitPos + tr.HitNormal)
							fx:SetScale(speed)
							fx:SetStart(Vector())
							fx:SetSurfaceProp(tr.SurfaceProps)
							util.Effect("chloeimpact_groundcrack", fx,  true, true)
							local pos = tr.HitPos
							if speed > 550 then
								timer.Simple(0.01, function()
									if IsValid(entity) and AllowPropLodge:GetBool() then
										entity:GetPhysicsObject():SetVelocity(Vector())
										constraint.Weld(entity, data.HitEntity, 0, 0, 5550, true)
									end
								end)
							end
							entity.LastCrater = CurTime() + 1
						end
					end
				end)
			end
		end)
	end
end)

hook.Add("PlayerSpawnedVehicle", "ChloeImpact_PropCollide", function(ply, entity)
	if AllowPropImpact:GetBool() then
		timer.Simple(1, function()
			if IsValid(entity) then
				entity:AddCallback("PhysicsCollide", function(entity, data)
					if (entity.LastCrater and CurTime() > entity.LastCrater or not entity.LastCrater) and data.HitObject == Entity(0):GetPhysicsObject() then
						if data.OurOldVelocity:LengthSqr() >= 300000 then
							local TickRate = 1 / engine.TickInterval()
							local OldVelLength = data.OurOldVelocity:Length()
							local attackAngle = (data.OurNewVelocity + data.HitNormal):GetNormalized() * OldVelLength / (TickRate/15)
							local speed = OldVelLength * TickRate
							local fx = EffectData()
							tr_data.start = entity:WorldSpaceCenter()
							tr_data.endpos = entity:WorldSpaceCenter() + data.OurOldVelocity
							tr_data.filter = entity
							util.TraceLine(tr_data)
							fx:SetNormal(tr.HitNormal)
							fx:SetOrigin(tr.HitPos + tr.HitNormal)
							fx:SetScale(speed)
							fx:SetStart(Vector())
							fx:SetSurfaceProp(tr.SurfaceProps)
							util.Effect("chloeimpact_groundcrack", fx,  true, true)
							local pos = tr.HitPos
							if speed > 550 then
								timer.Simple(0.01, function()
									if IsValid(entity) and AllowPropLodge:GetBool() then
										entity:GetPhysicsObject():SetVelocity(Vector())
										constraint.Weld(entity, data.HitEntity, 0, 0, 5550, true)
									end
								end)
							end
							entity.LastCrater = CurTime() + 1
						end
					end
				end)
			end
		end)
	end
end)

--[[hook.Add( "RenderScreenspaceEffects", "ChloeImpact_Overlay", function()
	if not LocalPlayer():ShouldDrawLocalPlayer() and LocalPlayer():GetNWBool("ChloeImpact_InWall") then
		DrawMaterialOverlay( "vgui/chloeimpact_overlay", 0 )
	end
end )]]--

if SERVER then return end

function ChloeOptions(panel)
	local box = panel:Help("Clientside options")
	--box = panel:NumSlider("Maximum scale for impact effects", "chloeimpact_max_scale", 1, 1000, 5)
	box = panel:NumSlider("Max derbis", "chloeimpact_max_debris_props", 1, 1000, 5)
	box = panel:NumSlider("Max cloud effect", "chloeimpact_max_debris_effects", 1, 1000, 5)
	--box = panel:NumSlider("Scale of model effects", "chloeimpact_effects_scale", 0.01, 5, 5)
	box = panel:NumSlider("Debris lifetime", "chloeimpact_impact_debris_lifetime", 1, 1000, 5)
	box = panel:NumSlider("Life time", "chloeimpact_impact_lifetime", 1, 1000, 5)
	box = panel:Help("Serverside options")
	box = panel:NumSlider("Scale for velocity thresholds for impacts", "chloeimpact_velocity_scale", 0, 15, 5)
	box = panel:NumSlider("Scale for damage taken from velocity", "chloeimpact_damage_scale", 0, 15, 5)
	box = panel:CheckBox( "Player Wall Lodging", "chloeimpact_player_lodging") 
	box:SetValue(true)
	box = panel:CheckBox( "(EXPERIMENTAL) Prop/Ragdoll Impacts", "chloeimpact_prop_impact") 
	box:SetValue(false)
	box = panel:CheckBox( "(EXPERIMENTAL) Prop/Ragdoll Lodging", "chloeimpact_prop_lodge") 
	box:SetValue(false)
	
end

function ChloeMenu()
	spawnmenu.AddToolMenuOption("Options", "ChloeImpact", "ChloeOptions", "Options", "", "", ChloeOptions)
end

hook.Add("PopulateToolMenu", "ChloeMenu", ChloeMenu)