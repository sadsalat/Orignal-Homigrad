local whitelistweps = {
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
	["gmod_camera"] = true,
	["weapon_physcannon"] = true,
	["wep_jack_gmod_eztoolbox"] = true
}

function RagdollOwner(rag)
	for k, v in ipairs(player.GetAll()) do
		local ply = v
		if ply:GetNWEntity("DeathRagdoll") == rag then return ply end
	end

	return false
end

hook.Add(
	"Think",
	"pophead",
	function()
		for i, ent in pairs(ents.FindByClass("prop_ragdoll")) do
			if not IsValid(RagdollOwner(ent)) or not RagdollOwner(ent):Alive() then
				ent:ManipulateBoneScale(6, Vector(1, 1, 1))
			end
		end

		for i, ent in pairs(player.GetAll()) do
			if ent ~= LocalPlayer() and ent:Alive() then
				ent:ManipulateBoneScale(6, Vector(1, 1, 1))
			end
		end
	end
)

surface.CreateFont(
	"Arial",
	{
		font = "Arial",
		size = 50,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = true,
		outline = false,
	}
)

local weps = {
	["glock18"] = true,
	["glock"] = true,
	["ak74"] = true,
	["ar15"] = true,
	["beretta"] = true,
	["fiveseven"] = true,
	["mp5"] = true,
	["m3super"] = true,
	["p220"] = true,
	["hk_usp"] = true,
	["hk_usps"] = true,
	["akm"] = true,
	["deagle"] = true,
	["magnum"] = true,
	["ak74u"] = true,
	["l1a1"] = true,
	["fal"] = true,
	["galil"] = true,
	["galilsar"] = true,
	["m14"] = true,
	["m1a1"] = true,
	["mk18"] = true,
	["m249"] = true,
	["m4a1"] = true,
	["minu14"] = true,
	["mp40"] = true,
	["rpk"] = true,
	["ump"] = true
}

local MyLerp = 0
local ViewPunching
local wep
local ang
local function scopeAiming()
	local wep = LocalPlayer():GetActiveWeapon()

	return IsValid(wep) and LocalPlayer():KeyDown(IN_ATTACK2) and not LocalPlayer():KeyDown(IN_SPEED)
end

--LocalPlayer():ConCommand("cl_new_impact_effects 1")
function SpecCam(ply, vec, ang, fov, znear, zfar)
	if ply:Team() == 1002 then return end
	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
	local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
	local org = eye.Pos
	local ang1 = eye.Ang + Angle(-10, 5, 0)
	local org1 = eye.Pos + eye.Ang:Up() * 4 + eye.Ang:Forward() * -5 + eye.Ang:Right() * 6.5
	if ply:GetNWBool("fake") == true and IsValid(ply:GetNWEntity("DeathRagdoll")) then
		local attach = ply:GetNWEntity("DeathRagdoll"):GetAttachment(1)
		local view = {
			origin = attach.Pos + attach.Ang:Up() * 4 + attach.Ang:Forward() * -5 + attach.Ang:Right() * 6.5,
			angles = attach.Ang + Angle(-10, 5, 0),
			fov = 120,
			drawviewer = true,
			znear = 0.1
		}

		return view
	end

	local view = {
		origin = org1,
		angles = ang1,
		fov = 120,
		drawviewer = true,
		znear = 0.1
	}

	return view
end

hook.Add(
	"HUDPaint",
	"SpecPaint",
	function()
		local lply = LocalPlayer()
		local specPly = lply:GetNWEntity("SpecPly")
		if lply:Alive() then return end
		if not specPly:IsValid() then return end
		local ActivWeapon = specPly:GetActiveWeapon()
		if not IsValid(ActivWeapon) then return end
		ActivWeapon:DrawHUD()
	end
)

local sightAng = Angle(0, 0, 0)
local podkid = 0
local oldFakeOrigin = Vector(0, 0, 0)
local oldFakeAng = Angle(0, 0, 0)
local oldOrigin = Vector(0, 0, 0)
local oldAng = Angle(0, 0, 0)
local lerping = 1
hook.Add("HUDDrawTargetID", "HidePlayerInfo", function() return false end)
function HomigradCam(ply, vec, ang, fov, znear, zfar)
	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
	local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
	local org = eye.Pos
	local ang1 = LerpAngle(0, ply:EyeAngles(), eye.Ang)
	local org1 = eye.Pos + eye.Ang:Up() * 2 + eye.Ang:Forward() * 2.5
	if ply:Team() == 1002 then return end
	if not ply:Alive() then
		local specPly = ply:GetNWEntity("SpecPly")
		if not specPly:IsValid() then
			if not IsValid(ply:GetNWEntity("DeathRagdoll")) then return end
			local attach = ply:GetNWEntity("DeathRagdoll"):GetAttachment(1)
			ply:GetNWEntity("DeathRagdoll"):ManipulateBoneScale(ply:GetNWEntity("DeathRagdoll"):LookupBone("ValveBiped.Bip01_Head1"), vector_origin)
			local view = {
				origin = attach.Pos,
				angles = LerpAngle(0.2, ang1, attach.Ang),
				fov = 110,
				drawviewer = true
			}

			lerping = 1

			return view
		end

		return SpecCam(specPly)
	end

	if ply:GetNWBool("fake") == true and IsValid(ply:GetNWEntity("DeathRagdoll")) then
		local attach = ply:GetNWEntity("DeathRagdoll"):GetAttachment(1)
		ply:GetNWEntity("DeathRagdoll"):ManipulateBoneScale(ply:GetNWEntity("DeathRagdoll"):LookupBone("ValveBiped.Bip01_Head1"), vector_origin)
		lerping = Lerp(3 * FrameTime(), lerping, 0)
		local view = {
			origin = LerpVector(lerping, attach.Pos, oldOrigin),
			angles = LerpAngle(lerping, LerpAngle(0.35, ang1, attach.Ang), oldAng),
			fov = 110,
			drawviewer = true
		}

		oldFakeOrigin = view.origin
		oldFakeAng = view.angles

		return view
	end

	if IsValid(ply) and IsValid(ply:GetActiveWeapon()) then
		wep = ply:GetActiveWeapon()
		if whitelistweps[wep:GetClass()] and not ply:InVehicle() then return end
	end

	sightAng = sightAng or hand.Pos
	if ply:Alive() and IsValid(ply) and IsValid(ply) and IsValid(ply:GetActiveWeapon()) then
		ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), vector_origin)
		local weaponClass = wep:GetClass()
		local guninfo = weapons.Get(weaponClass)
		if guninfo and guninfo.Base == "salat_base" then
			if scopeAiming() then
				MyLerp = Lerp(4 * FrameTime(), MyLerp, 1)
			else
				MyLerp = Lerp(6 * FrameTime(), MyLerp, 0.1)
			end

			podkid = Lerp(0.1, podkid, math.Clamp((guninfo.HoldType ~= "revolver" and ply:GetActiveWeapon():GetNWFloat("VisualRecoil") / 4) or ply:GetActiveWeapon():GetNWFloat("VisualRecoil") / 1, 0, 10))
			org = hand.Pos + hand.Ang:Up() * guninfo.sightPos.x - hand.Ang:Forward() * guninfo.sightPos.y + hand.Ang:Right() * guninfo.sightPos.z + hand.Ang:Up() * podkid
			ang = hand.Ang + guninfo.sightAng + Angle(podkid * 10, 0, 0)
		end
	end

	sightAng = LerpAngle(3 * FrameTime(), sightAng, ang)
	if ply:Alive() then
		ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), vector_origin)
	end

	if ply:InVehicle() == true then
		org = eye.Pos + eye.Ang:Forward() * 0.8
		ang = eye.Ang
		MyLerp = 1
		ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), vector_origin)
		anglerp = LerpAngle(MyLerp, ang1, ang)
	else
		anglerp = LerpAngle(MyLerp / 2, ang1, sightAng or Angle(0, 0, 0))
	end

	--Lerp
	--LocalPlayer():ChatPrint(MyLerp)
	lerping = Lerp(3 * FrameTime(), lerping, 1)
	local view = {
		origin = LerpVector(lerping, oldFakeOrigin, LerpVector(MyLerp, org1, org)),
		angles = LerpAngle(lerping, oldFakeAng, LerpAngle(0.01, anglerp, ang1)),
		fov = 110,
		drawviewer = true,
		znear = 0.8
	}

	oldOrigin = view.origin
	oldAng = view.angles

	return view
end

hook.Add("CalcView", "salat.ahuel.view", HomigradCam)
hook.Add(
	"RenderScene",
	"fwep-viewbobfix",
	function(pos, angle, fov)
		local view = hook.Run("CalcView", LocalPlayer(), pos, angle, fov)
		local view = {
			x = 0,
			y = 0,
			drawhud = true,
			drawviewmodel = false,
			dopostprocess = true,
			drawmonitors = true
		}

		local calcView = HomigradCam(LocalPlayer(), pos, angle, fov)
		if not calcView then return end
		view.fov = calcView.fov
		view.origin = calcView.origin
		view.angles = calcView.angles
		view.drawviewmodel = not calcView.drawviewer
		render.Clear(0, 0, 0, 255, true, true, true)
		render.RenderView(view)

		return true
	end
)

-- Coded by SadSalat
hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = false,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
}

hook.Add(
	"HUDShouldDraw",
	"HideHUD",
	function(name)
		if hide[name] then return false end
	end
)

local allowedRanks = {
	["superadmin"] = true,
	["admin"] = true,
	["operator"] = true,
	["moderator"] = true,
	["user"] = true,
	["viptest"] = true,
	["kakaha"] = true,
}

hook.Add(
	"ContextMenuOpen",
	"hide_spawnmenu",
	function()
		if not allowedRanks[LocalPlayer():GetUserGroup()] then return false end
	end
)

hook.Add(
	"SpawnMenuOpen",
	"hide_spawnmenu",
	function()
		if not allowedRanks[LocalPlayer():GetUserGroup()] then return false end
	end
)
--[[прицелчики
hook.Add("PostDrawOpaqueRenderables", "example", function()
    local hand = LocalPlayer():GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
    local eye = LocalPlayer():GetAttachment(ply:LookupAttachment("eyes"))
    possight = hand.Pos + hand.Ang:Up() * 4.4 - hand.Ang:Forward() * -1 + hand.Ang:Right() * -0.15
    angle = hand.Ang + Angle(-90,0,0)
                        
    
    cam.Start3D2D( possight, angle, 1 )
        surface.SetDrawColor( 255, 0, 0, 200)
        draw.NoTexture()
        draw.Circle(0,0,0.05,25 )
    cam.End3D2D()
end )
]]
--