local t = {}
local n, e, r, o
local d = Material('materials/scopes/scope_dbm.png')
CameraSetFOV = 120

CreateClientConVar("hg_fov","120",true,false,nil,90,120)
local smooth_cam = CreateClientConVar("hg_smooth_cam","1",true,false,nil,0,1)

CreateClientConVar("hg_bodycam","0",true,false,nil,0,1)

CreateClientConVar("hg_fakecam_mode","0",true,false,nil,0,1)

CreateClientConVar("hg_deathsound","1",true,false,nil,0,1)
CreateClientConVar("hg_deathscreen","1",true,false,nil,0,1)

function SETFOV(value)
	CameraSetFOV = value or GetConVar("hg_fov"):GetInt()
end

SETFOV()

cvars.AddChangeCallback("hg_fov",function(cmd,_,value)
    timer.Simple(0,function()
		SETFOV()
		print("	hg: change fov")
	end)
end)

surface.CreateFont("HomigradFontBig",{
	font = "Roboto",
	size = 25,
	weight = 1100,
	outline = false,
	shadow = true
})

surface.CreateFont("BodyCamFont",{
	font = "Arial",
	size = 40,
	weight = 1100,
	outline = false,
	shadow = true
})

local function a()
	e = 360
	r = GetRenderTarget('weaponSight-' .. e, e, e)
	if not t[e] then
		t[e] = CreateMaterial('weaponSight-' .. e, 'UnlitGeneric', {})
	end
	o = t[e]
	n = {}
	local r, o, t, e = 0, 0, e / 2, 24
	n[#n+1] = {
		x = r,
		y = o,
		u = .5,
		v = .5
	}
	for a = 0, e do
		local e = math.rad( (a/e)*-360 )
		n[#n+1] = {
			x = r+math.sin(e)*t,
			y = o+math.cos(e)*t,
			u = math.sin(e)/2+.5,
			v = math.cos(e)/2+.5
		}
	end
end

a()
--[[
local a = false
local function i(wep)
	a = true
	local n, t, o = wep:GetShootPos()
	render.PushRenderTarget(r)
	if util.TraceLine({start=n-t*25,endpos=n+t*((wep.SightZNear or 5)+5),filter=LocalPlayer(),}).Hit then
		render.Clear(0,0,0,255)
	else
		render.RenderView({
			origin = n,
			angles = o,
			fov = 100,
			znear = 5,
		})
	end
	render.PopRenderTarget()
	a = false
end

hook.Add("PostDrawOpaqueRenderables","", function()
	local wep = LocalPlayer():GetActiveWeapon()
	if wep.SightPos and wep.aimProgress and wep.aimProgress > 0 and wep:GetReady() then
		local t = wep:GetOwner()
		local a = t:LookupAttachment('anim_attachment_rh')
		if not a then return end
		local t = t:GetAttachment(a)
		local l, a = LocalToWorld(wep.SightPos, wep.SightAng, t.Pos, t.Ang)
		local t = e / -2
		cam.Start3D2D(l, a, wep.SightSize / e * 1.1)
			cam.IgnoreZ(true)
			render.ClearStencil()
			render.SetStencilEnable(true)
			render.SetStencilTestMask(255)
			render.SetStencilWriteMask(255)
			render.SetStencilReferenceValue(42)
			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			surface.SetDrawColor(0,0,0,1)
			draw.NoTexture()
			surface.DrawPoly(n)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilFailOperation(STENCIL_ZERO)
			render.SetStencilZFailOperation(STENCIL_ZERO)
			o:SetTexture('$basetexture',r)
			o:SetFloat('$alpha',math.Clamp(math.Remap(wep.aimProgress,.1,1,0,1),0,1))
			surface.SetMaterial(o)
			surface.DrawTexturedRect(t,t,e,e)
			surface.SetDrawColor(255,255,255)
			surface.SetMaterial(d)
			surface.DrawTexturedRect(t-10,t-10,e+20,e+20)
			render.SetStencilEnable(false)
			cam.IgnoreZ(false)
		cam.End3D2D()
	end
end)

hook.Add('PreDrawEffects', 'octoweapons', function()
	if a then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if LocalPlayer():KeyDown(IN_ATTACK2) then
		i(wep)
	end
end)]]--

local view = {
	x = 0,
	y = 0,
	drawhud = true,
	drawviewmodel = false,
	dopostprocess = true,
	drawmonitors = true
}

local render_Clear = render.Clear
local render_RenderView = render.RenderView

local white = Color(255,255,255)
local HasFocus = system.HasFocus
local oldFocus
local text

local hg_disable_stoprenderunfocus = CreateClientConVar("hg_disable_stoprenderunfocus","0",true)

local prekols = {
	"Get a job",
	"Get a life",
	"возможно, команда hg_disable_stoprenderunfocus 1 выключит этот прикол...",
	"ураааа, ты свернулся... Потрогай траву, играть вечность плохо.",
	"kys"
}

local developer = GetConVar("developer")
local CalcView--fuck
local vel = 0
local diffang = Vector(0,0,0)
local diffpos = Vector(0,0,0)

hook.Add("RenderScene","octoweapons",function(pos,angle,fov)
	local focus = HasFocus()
	if focus ~= oldFocus then
		oldFocus = focus

		if not focus then
			text = table.Random(prekols)
		end
	end

	hook.Run("Frame",pos,angle)
	
	STOPRENDER = not hg_disable_stoprenderunfocus:GetBool() and not developer:GetBool() and not focus

	if STOPRENDER then
		cam.Start2D()
			draw.SimpleText(text,"DebugFixedSmall",ScrW() / 2,ScrH() / 2,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		cam.End2D()

		return true
	end

	RENDERSCENE = true
	local _view = CalcView(LocalPlayer(),pos,angle,fov)

	if not _view then RENDERSCENE = nil return end

	view.fov = fov
	view.origin = _view.origin
	view.angles = _view.angles
	view.znear = _view.znear
	view.drawviewmodel = _view.drawviewmodel

	if CAMERA_ZFAR then
		view.zfar = CAMERA_ZFAR + 250--cl_fog in homigrad gamemode
	else
		view.zfar = nil
	end

	render_Clear(0,0,0,255,true,true,true)
	render_RenderView(view)

	RENDERSCENE = nil

	return true
end)

local ply = LocalPlayer()
local scrw, scrh = ScrW(), ScrH()
local whitelistweps = {
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
	["gmod_camera"] = true,
	["drgbase_possessor"] = true,
}

function RagdollOwner(rag)
	if not IsValid(rag) then return end

	local ent = rag:GetNWEntity("RagdollController")

	return IsValid(ent) and ent
end


--hook.Add("Think","pophead",function()
	--[[for i,ent in pairs(ents.FindByClass("prop_ragdoll")) do
		if !IsValid(RagdollOwner(ent)) or !RagdollOwner(ent):Alive() then
			ent:ManipulateBoneScale(6,Vector(1,1,1))
		end
	end]]--
--end)

hg_cool_camera = CreateClientConVar("hg_cool_camera","1",true,false,"huy",0,1)

local deathtrack = {
	"https://cdn.discordapp.com/attachments/1144224221334097974/1144224389970272388/death1.mp3",
	"https://cdn.discordapp.com/attachments/1144224221334097974/1144226357967065180/death2.mp3",
	"https://cdn.discordapp.com/attachments/1144224221334097974/1144230250465734797/death3.mp3",
	"https://cdn.discordapp.com/attachments/1144224221334097974/1144238942862979142/death4.mp3",
}
local angZero = Angle(0,0,0)
local g_station = nil
local playing = false
local deathtexts = {
	"ТЫ МЁРТВ",
	"ПОХОЖЕ, ТЫ СДОХ",
	"ПОТРАЧЕНО",
	"ВАУ, ТЫ УМЕР",
	"ЖИЗНЬ ЗАКОНЧЕНА",
	"GAME OVER",
	"WASTED",
	"МЁРТВ",
	"ПОМЕР",
	"ТРУПАК",
	"МЕРТВЕЦ",
	"СДОХ",
	"ТВОЯ ОСТОНОВКА",
	"ВРЕМЯ ВЫШЛО",
	"МИССИЯ ПРОВАЛЕНА",
	"ВОТ И ВСЕ!",
	"КОНЕЦ",
	"FILINA?",
	"DEAD",
	"TRY AGAIN"
}
net.Receive("pophead",function(len)
	local rag = net.ReadEntity()
	if GetConVar("hg_deathscreen"):GetBool() then
	deathrag = rag
	deathtext = table.Random(deathtexts)
	LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 0.5, 1 )
	if !playing and GetConVar("hg_deathsound"):GetBool() then
		playing = true
		sound.PlayURL ( table.Random(deathtrack), "mono", function( station )
			if ( IsValid( station ) ) then
				station:SetPos( LocalPlayer():GetPos() )
				station:Play()
				station:SetVolume(3)

				-- Keep a reference to the audio object, so it doesn't get garbage collected which will stop the sound
				g_station = station
		
			else end
		end )
	end
		timer.Create("DeathCam",5,1,function()
			LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 1, 1 )
			playing = false
		end)
	end
	timer.Simple(4,function()
		if GetConVar("hg_deathscreen"):GetBool() then
			LocalPlayer():ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 0.2, 1 )
		end
		if rag:IsValid() then
			rag:ManipulateBoneScale(6,Vector(1,1,1))
		end
	end)
end)

local weps = {
["weapon_glock18"] = true,
["weapon_glock"] = true,
["weapon_ak74"] = true,
["weapon_ar15"] = true,
["weapon_beretta"] = true,
["weapon_fiveseven"] = true,
["weapon_mp5"] = true,
["weapon_m3super"] = true,
["weapon_p220"] = true,
["weapon_hk_usp"] = true,
["weapon_mp7"] = true,
["weapon_hk_usps"] = true,
["weapon_akm"] = true,
["weapon_deagle"] = true,
["weapon_ak74u"] = true,
["weapon_l1a1"] = true,
["weapon_fal"] = true,
["weapon_galil"] = true,
["weapon_galilsar"] = true,
["weapon_m14"] = true,
["weapon_m1a1"] = true,
["weapon_mk18"] = true,
["weapon_m249"] = true,
["weapon_m4a1"] = true,
["weapon_minu14"] = true,
["weapon_mp40"] = true,
["weapon_rpk"] = true,
["weapon_ump"] = true,
["weapon_xm1014"] = true,
["weapon_remington870"] = true,
["weapon_taser"] = true,
["weapon_sar2"] = true,
["weapon_rpgg"] = true,
["weapon_beanbag"] = true,
["weapon_civil_famas"] = true,
["weapon_spas12"] = true
}

local ScopeLerp = 0
local scope
local G = 0
local size = 0.03
local angle = Angle(0)
local possight = Vector(0)

local function scopeAiming()
	local wep = LocalPlayer():GetActiveWeapon()

	return IsValid(wep) and weps[wep:GetClass()] and LocalPlayer():KeyDown(IN_ATTACK2) and not LocalPlayer():KeyDown(IN_SPEED)
end

LerpEyeRagdoll = Angle(0,0,0)

local lply = LocalPlayer()
LerpEye = IsValid(lply) and lply:EyeAngles() or Angle(0,0,0)

local vecZero,vecFull = Vector(0,0,0),Vector(1,1,1)
local firstPerson

local max = math.max
local upang = Angle(-90,0,0)
local oldShootTime
local startRecoil = 0
local angRecoil = Angle(0,0,0)
local recoil = 0
local sprinthuy = 0
local oldview = {}

local whitelistSimfphys = {}
whitelistSimfphys.gred_simfphys_brdm2 = true
whitelistSimfphys.gred_simfphys_brdm2_atgm = true
whitelistSimfphys.gred_simfphys_brdm_hq = true

local view = {}

ADDFOV = 0
ADDROLL = 0

local helmEnt

net.Receive("nodraw_helmet",function()
	helmEnt = net.ReadEntity()
end)

CalcView = function(ply,vec,ang,fov,znear,zfar)
	if STOPRENDER then return end
	local fov = CameraSetFOV + ADDFOV
	local lply = LocalPlayer()

	if !ply:Alive() and timer.Exists("DeathCam") and IsValid(deathrag) then
		--deathrag:ManipulateBoneScale(6,vecZero)
		
		local att = deathrag:GetAttachment(deathrag:LookupAttachment("eyes"))
		
		LerpEyeRagdoll = LerpAngleFT(0.08,LerpEyeRagdoll,att.Ang)

		LerpEyeRagdoll[3] = LerpEyeRagdoll[3] + ADDROLL

		local view = {
			origin = att.Pos,
			angles = LerpEyeRagdoll,
			fov = fov,
			drawviewer = true
		}

		return view
	end

	DRAWMODEL = nil

	ADDFOV = 0
	ADDROLL = 0


	hook.Run("CalcAddFOV",ply)--megaggperkostil
	
	local result = hook.Run("PreCalcView",ply,vec,ang,fov,znear,zfar)
	if result ~= nil then
		result.fov = fov + ADDFOV
		result.angles[3] = result.angles[3] + ADDROLL

		return result
	end

	--[[if lply:InVehicle() then
		local diffvel = lply:GetVehicle():GetPos() - vel
		
		local view = {
			origin = lply:EyePos() + diffvel * 10,
			angles = lply:EyeAngles(),
			fov = fov
		}
		
		vel = lply:GetVehicle():GetPos()
		return view
	end--]]

	firstPerson = GetViewEntity() == lply

	local bone = lply:LookupBone("ValveBiped.Bip01_Head1")
	if bone then lply:ManipulateBoneScale(bone,firstPerson and vecZero or vecFull) end
	if not firstPerson then DRAWMODEL = true return end
	local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
	local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
	local body = ply:LookupBone("ValveBiped.Bip01_Spine2")

	--print(bodypos)

	if GetConVar("hg_bodycam"):GetInt() == 0 then
		angEye = lply:EyeAngles()
		--angEye[3] = 0
		vecEye = (eye and eye.Pos + eye.Ang:Up() * 2 + eye.Ang:Forward() * 1) or lply:EyePos()
	else
		local matrix = ply:GetBoneMatrix(body)
		local bodypos = matrix:GetTranslation()
		local bodyang = matrix:GetAngles()
		--bodyang:RotateAroundAxis(bodyang:Right(),90)

		--bodyang[2] = eye.Ang[2]
		--bodyang[3] = 0
		angEye = eye.Ang--bodyang
		vecEye = (eye and bodypos + bodyang:Up() * 0 + bodyang:Forward() * 14 + bodyang:Right() * -6) or lply:EyePos()
	end
	local ragdoll = ply:GetNWEntity("Ragdoll")

	if ply:Alive() and ply:GetNWBool("fake") and IsValid(ragdoll) then
		ragdoll:ManipulateBoneScale(6,vecZero)
		
		local att = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
		
		local eyeAngs = lply:EyeAngles()
		if GetConVar("hg_bodycam"):GetInt() == 1 then
			local matrix = ragdoll:GetBoneMatrix(body)
			local bodypos = matrix:GetTranslation()
			local bodyang = matrix:GetAngles()
			
			eyeAngs = att.Ang
			att.Pos = (eye and bodypos + bodyang:Up() * 0 + bodyang:Forward() * 10 + bodyang:Right() * -8) or lply:EyePos()
		end
		local anghook = GetConVar("hg_fakecam_mode"):GetFloat()
		LerpEyeRagdoll = LerpAngleFT(0.08,LerpEyeRagdoll,LerpAngle(anghook,eyeAngs,att.Ang))

		LerpEyeRagdoll[3] = LerpEyeRagdoll[3] + ADDROLL

		local view = {
			origin = att.Pos,
			angles = LerpEyeRagdoll,
			fov = fov,
			drawviewer = true
		}

		if IsValid(helmEnt) then
			helmEnt:SetNoDraw(true)
		end

		return view
	end

	local wep = lply:GetActiveWeapon()
	wep = IsValid(wep) and wep

	local traca = lply:GetEyeTrace()
	local dist = traca.HitPos:Distance(lply:EyePos())

	if not RENDERSCENE then
		scope = IsValid(wep) and wep.IsScope and wep:IsScope() and not wep.isClose
		if scope then
			if lply:KeyPressed(IN_WALK) then
				pointshooting = not pointshooting
			end
			if pointshooting then
				ScopeLerp = LerpFT(GetConVar("hg_bodycam"):GetInt() == 0 and 0.1 or 1,ScopeLerp,0.85)
			else
				ScopeLerp = LerpFT(GetConVar("hg_bodycam"):GetInt() == 0 and 0.1 or 1,ScopeLerp,1)
			end
		else
			ScopeLerp = LerpFT(GetConVar("hg_bodycam"):GetInt() == 0 and 0.1 or 1,ScopeLerp,0)
		end
	end

	fov = Lerp(ScopeLerp,fov,75)

	angRecoil[3] = 0
	
	if wep and weps[wep:GetClass()] then
		local weaponClass = wep:GetClass()
		local att = wep.Attachments

		if not RENDERSCENE then
			local lastShootTime = wep:LastShootTime()
			if not oldShootTime then oldShootTime = lastShootTime else
				if oldShootTime ~= lastShootTime then
					oldShootTime = lastShootTime
					startRecoil = CurTime() + 0.05
					recoil = math.Rand(0.9,1.1) * (scope and 0.5 or 0.5)
				end
			end
		end
		
		local anim_pos = max(startRecoil - CurTime(),0) * 5

		fov = fov - anim_pos * (scope and 2 or 1)
		angRecoil[3] = anim_pos * (scope and 10 or 5)

		if weaponClass == "weapon_glock18" then
			--Vector(3.85,10,1.45)
			vecWep = hand.Pos + hand.Ang:Up() * 3.85 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.45
			angWep = hand.Ang + Angle(5,10,0)
		end
		if weaponClass == "weapon_glock" then
			--Vector(2.3,10,0)
			vecWep = hand.Pos + hand.Ang:Up() * 2.3 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0
			angWep = hand.Ang + Angle(-15,5,0)
		end
		if weaponClass == "weapon_ak74" then
			--Vector(5.2,-2,1.1)
			vecWep = hand.Pos + hand.Ang:Up() * 5.2 - hand.Ang:Forward() * -2 + hand.Ang:Right() * 1.1
			angWep = hand.Ang + Angle(-25,20,-25)
		end
		if weaponClass == "weapon_xm1014" then
			--Vector(3.55,4,0.95)
			vecWep = hand.Pos + hand.Ang:Up() * 3.55 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.95
			angWep = hand.Ang + Angle(-8,0,0)
		end
		if weaponClass == "weapon_remington870" then
			--Vector(3.8,4,0.65)
			vecWep = hand.Pos + hand.Ang:Up() * 4.4 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.20
			angWep = hand.Ang + Angle(-1,0,0)
		end
		if weaponClass == "weapon_ar15" then
			--Vector(5.05,7,0.725)
			vecWep = hand.Pos + hand.Ang:Up() * 5.01 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 0.725
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_mp7" then
			--Vector(3.25,7,0.79)
			vecWep = hand.Pos + hand.Ang:Up() * 2.9 - hand.Ang:Forward() * 9 + hand.Ang:Right() * 0.79
			angWep = hand.Ang + Angle(-10,0,0)
		end
		if weaponClass == "weapon_beretta" then
			--Vector(2.5,10,0.05)
			vecWep = hand.Pos + hand.Ang:Up() * 2.5 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.05
			angWep = hand.Ang + Angle(-10,2,0)
		end
		if weaponClass == "weapon_deagle" then
			--Vector(2.7,10,0.4)
			vecWep = hand.Pos + hand.Ang:Up() * 2.7 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.4
			angWep = hand.Ang + Angle(-10,0,0)
		end
		if weaponClass == "weapon_fiveseven" then
			--Vector(2.5,10,0.1)
			vecWep = hand.Pos + hand.Ang:Up() * 2.5 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.05
			angWep = hand.Ang + Angle(-10,3,0)
		end
		if weaponClass == "weapon_mp5" then
			--Vector(4.22,7,0.8)
			vecWep = hand.Pos + hand.Ang:Up() * 4.17 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 0.79	
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_m3super" then
			--Vector(3.66,5,0.65)
			vecWep = hand.Pos + hand.Ang:Up() * 3.66 - hand.Ang:Forward() * 5 + hand.Ang:Right() * 0.65
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_p220" then
			--Vector(2.7,10,0.12)
			vecWep = hand.Pos + hand.Ang:Up() * 2.7 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.12
			angWep = hand.Ang + Angle(-15,02,0)
		end
		if weaponClass == "weapon_hk_usp" then
			--Vector(2.5,10,0.3)
			vecWep = hand.Pos + hand.Ang:Up() * 2.43 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.3
			angWep = hand.Ang + Angle(-15,5,0)
		end
		if weaponClass == "weapon_hk_usps" then
			--Vector(3.9,10,1.09)
			vecWep = hand.Pos + hand.Ang:Up() * 4.25 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.05
			angWep = hand.Ang + Angle(0,0,0)
		end
		if weaponClass == "weapon_akm" then
			--Vector(5.1,5,0.76)
			vecWep = hand.Pos + hand.Ang:Up() * 5.0 - hand.Ang:Forward() * 5 + hand.Ang:Right() * 0.76
			angWep = hand.Ang + Angle(-8,5,0)
		end
		if weaponClass == "weapon_ak74u" then
			--Vector(5.3,4,0.78)
			vecWep = hand.Pos + hand.Ang:Up() * 5.2 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.78
			angWep = hand.Ang + Angle(-8,0,0)
		end
		if weaponClass == "weapon_l1a1" then
			--Vector(5.7,4,1.1)
			vecWep = hand.Pos + hand.Ang:Up() * 5.7 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
			angWep = hand.Ang + Angle(25,35,15)
		end
		if weaponClass == "weapon_fal" then
			--Vector(5.45,10,0.69)
			vecWep = hand.Pos + hand.Ang:Up() * 5.45 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 0.69
			angWep = hand.Ang + Angle(-8,0,0)
		end
		if weaponClass == "weapon_galil" then
			--Vector(5.7,4,0.75)
			vecWep = hand.Pos + hand.Ang:Up() * 5.7 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.75
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_galilsar" then
			--Vector(3.9,7,0.57)
			vecWep = hand.Pos + hand.Ang:Up() * 3.75 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 0.58
			angWep = hand.Ang + Angle(-8,0,0)
		end
		if weaponClass == "weapon_m14" then
			--Vector(6,4,0.95)
			vecWep = hand.Pos + hand.Ang:Up() * 6 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.95
			angWep = hand.Ang + Angle(25,35,15)
		end
		if weaponClass == "weapon_m1a1" then
			--Vector(5.25,4,1.15)
			vecWep = hand.Pos + hand.Ang:Up() * 5.25 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.15
			angWep = hand.Ang + Angle(25,35,15)
		end
		if weaponClass == "weapon_mk18" then
			--Vector(6.2,6,0.88)
			vecWep = hand.Pos + hand.Ang:Up() * 6.15 - hand.Ang:Forward() * 6 + hand.Ang:Right() * 0.88
			angWep = hand.Ang + Angle(-7,0,0)
		end
		if weaponClass == "weapon_m249" then
			--Vector(5.8,8,0.88)
			vecWep = hand.Pos + hand.Ang:Up() * 5.8 - hand.Ang:Forward() * 8 + hand.Ang:Right() * .88
			angWep = hand.Ang + Angle(-6,0,0)
		end
		if weaponClass == "weapon_m4a1" then
			--Vector(5.05,7,0.725)
			vecWep = hand.Pos + hand.Ang:Up() * 5.05 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 0.725
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_minu14" then
			--Vector(5,4,0.95)
			vecWep = hand.Pos + hand.Ang:Up() * 5 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.95
			angWep = hand.Ang + Angle(15,35,15)
		end
		if weaponClass == "weapon_mp40" then
			--Vector(6.5,4,0.67)
			vecWep = hand.Pos + hand.Ang:Up() * 6.5 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.67
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_rpk" then
			--Vector(4.9,4,0.8)
			vecWep = hand.Pos + hand.Ang:Up() * 4.75 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.8
			angWep = hand.Ang + Angle(-7,0,0)
		end
		if weaponClass == "weapon_ump" then
			--Vector(6.6,7,1.35)
			vecWep = hand.Pos + hand.Ang:Up() * 6.6 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 1.35
			angWep = hand.Ang + Angle(25,35,15)
		end
		if weaponClass == "weapon_sar2" then
			--Vector(6,5,1.42)
			vecWep = hand.Pos + hand.Ang:Up() * 6.0 - hand.Ang:Forward() * 5 + hand.Ang:Right() * 0.93
			angWep = hand.Ang + Angle(-10,0,0)
		end
		if weaponClass == "weapon_rpgg" then
			--Vector(7,5,1)
			vecWep = hand.Pos + hand.Ang:Up() * 7 - hand.Ang:Forward() * 5 + hand.Ang:Right() * 1
			angWep = hand.Ang + Angle(0,15,0)
		end
		if weaponClass == "weapon_beanbag" then
			--Vector(4.41,4,0.41)
			vecWep = hand.Pos + hand.Ang:Up() * 4.41 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.41
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_civil_famas" then
			--Vector(6,6,0.69)
			vecWep = hand.Pos + hand.Ang:Up() * 6 - hand.Ang:Forward() * 6 + hand.Ang:Right() * 0.69
			angWep = hand.Ang + Angle(-5,0,0)
		end
		if weaponClass == "weapon_spas12" then
			--Vector(6,6,0.69)
			vecWep = hand.Pos + hand.Ang:Up() * 3.1 - hand.Ang:Forward() * 6 + hand.Ang:Right() * 0.85
			angWep = hand.Ang + Angle(-7,0,0)
		end
		--[[if RENDERSCENE then
			local wep = lply:GetActiveWeapon()
			local angatt = wep:GetAttachment(wep:LookupAttachment("muzzle")).Ang
			angatt:RotateAroundAxis(angatt:Forward(),-90)
			angWep = angatt
			angWep[3] = 0
		end--]]
	end


	if not RENDERSCENE then
		LerpEye = LerpAngleFT(smooth_cam:GetBool() and 0.25 or 1,LerpEye,angEye)
	else
		angEye = LerpAngleFT(0.25,LerpEye,angEye)
		
		if GetConVar("hg_bodycam"):GetInt() == 1 and IsValid(wep) and wep:LookupAttachment("muzzle") and scope then
			vecWep = vecWep + hand.Ang:Up() * 2 - hand.Ang:Forward() * -15 + hand.Ang:Right() * -1.5
			LerpEye = wep:GetAttachment(wep:LookupAttachment("muzzle")).Ang
			--LerpEye[3] = 0
			
			if wep.HoldType == "revolver" then
				angEye[1] = angEye[1] - 10
				angEye[2] = angEye[2] + 5
				--angEye[3] = 0
			end
			if wep.HoldType == "smg" or wep.HoldType == "ar2" then
				angEye[1] = angEye[1] - 10
				angEye[2] = angEye[2] + 10
				--angEye[3] = 0
			end
		end

	end

	angEye = LerpEye
	vecEye = LerpVector(ScopeLerp,vecEye,vecWep or vecEye)
	angEye = LerpAngle(ScopeLerp/2,angEye,angWep or angEye)
	
	if GetConVar("hg_bodycam"):GetInt() == 1 and not scope then
		local wep = lply:GetActiveWeapon()

		if wep.HoldType == "revolver" then
			angEye[1] = angEye[1] - 10
			angEye[2] = angEye[2] + 5
			--angEye[3] = 0
		end
		if wep.HoldType == "smg" or wep.HoldType == "ar2" then
			angEye[1] = angEye[1] - 15
			angEye[2] = angEye[2] + 5
			--angEye[3] = 0
		end
	end

	view.fov = fov

	if lply:InVehicle() or not firstPerson then return end

	if not lply:Alive() or (IsValid(wep) and whitelistweps[wep:GetClass()]) or lply:GetMoveType() == MOVETYPE_NOCLIP then
		view.origin = ply:EyePos()
		view.angles = ply:EyeAngles()
		view.drawviewer = false

		return view
	end

	local output_ang = angEye + angRecoil
	local output_pos = vecEye

	if wep and hand then
		local posRecoil = Vector(recoil * 8,0,recoil * 1.5)
		posRecoil:Rotate(hand.Ang)
		view.znear = Lerp(ScopeLerp,1,max(1 - recoil,0.2))
		output_pos = output_pos + posRecoil

		if not RENDERSCENE then
			recoil = LerpFT(scope and (wep.CLR_Scope or 0.25) or (wep.CLR or 0.1),recoil,0)
		end
	else
		recoil = 0
	end

	vec = Vector(vec[1],vec[2],eye and eye.Pos[3] or vec[3])

	vel = math.max(math.Round(Lerp(0.1,vel,lply:GetVelocity():Length())) - 1,0)
	
	sprinthuy = LerpFT(0.1,sprinthuy,-math.abs(math.sin(CurTime() * 6)) * vel / 400)
	output_ang[1] = output_ang[1] + sprinthuy

	output_ang[3] = 0

	local anim_pos = max(startRecoil - CurTime(),0) * 5

	local tick = 1 / engine.AbsoluteFrameTime()
	playerFPS = math.Round(Lerp(0.1,playerFPS or tick,tick))
	
	local val = math.min(math.Round(playerFPS / 120,1),1)
	
	diffpos = LerpFT(0.1,diffpos,(output_pos - (oldview.origin or output_pos)) / 6)
	diffang = LerpFT(0.1,diffang,(output_ang:Forward() - (oldview.angles or output_ang):Forward()) * 50 + (lply:EyeAngles() + (lply:GetActiveWeapon().eyeSpray or angZero) * 1000):Forward() * anim_pos * 1)

	if RENDERSCENE then
		if hg_cool_camera:GetBool() then
			output_ang[3] = output_ang[3] + math.min(diffang:Dot(output_ang:Right()) * 3 * val,10)
		end
		
		if hg_cool_camera:GetBool() then
			output_ang[3] = output_ang[3] + math.min(diffpos:Dot(output_ang:Right()) * 25 * val,10)
		end
	end

	if diffang then output_pos:Add((diffang * 1.5 + diffpos) * val) end

	local size = Vector(6,6,0)
	local tr = {}
	local dir = (output_pos - vec):GetNormalized()
	tr.start = vec
	tr.endpos = output_pos
	tr.mins = -size
	tr.maxs = size

	tr.filter = ply
	local trZNear = util.TraceHull(tr)
	size = size / 2
	tr.mins = -size
	tr.maxs = size

	tr = util.TraceHull(tr)

	local pos = lply:GetPos()
	pos[3] = tr.HitPos[3] + 1
	local trace = util.TraceLine({start = lply:EyePos(),endpos = pos,filter = ply,mask = MASK_SOLID_BRUSHONLY})
	tr.HitPos[3] = trace.HitPos[3] - 1
	output_pos = tr.HitPos
	output_pos = output_pos

	if trZNear.Hit then view.znear = 0.1 else view.znear = 1 end--САСАТЬ!!11.. не работает ;c

	output_ang[3] = output_ang[3] + ADDROLL
	
	view.origin = output_pos
	view.angles = output_ang
	view.drawviewer = true

	oldview = table.Copy(view)

	DRAWMODEL = true

	return view
end

hook.Add("CalcView","VIEW",CalcView)

hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
}
hook.Add("HUDShouldDraw","HideHUD",function(name)
	if (hide[name]) then return false end
end)

--[[
local allowedRanks = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["operator"] = true,
  ["moderator"] = true,
  ["user"] = true,
  ["viptest"] = true,
  ["kakaha"] = true
}]]--

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
]]--

hook.Add("Think","mouthanim",function()
	for i, ply in pairs(player.GetAll()) do
		local ent = IsValid(ply:GetNWEntity("Ragdoll")) and ply:GetNWEntity("Ragdoll") or ply

		local flexes = {
			ent:GetFlexIDByName( "jaw_drop" ),
			ent:GetFlexIDByName( "left_part" ),
			ent:GetFlexIDByName( "right_part" ),
			ent:GetFlexIDByName( "left_mouth_drop" ),
			ent:GetFlexIDByName( "right_mouth_drop" )
		}

		local weight = ply:IsSpeaking() && math.Clamp( ply:VoiceVolume() * 6, 0, 6 ) || 0

		for k, v in pairs( flexes ) do
			ent:SetFlexWeight( v, weight )
		end
	end
end)

net.Receive("fuckfake",function(len)
	LocalPlayer():SetNWEntity("Ragdoll",nil)
end)

local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0.1,
	[ "$pp_colour_brightness" ] = -0.05,
	[ "$pp_colour_contrast" ] = 1.5,
	[ "$pp_colour_colour" ] = 0.3,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0.5
}

local tab2 = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}


local mat = Material("pp/texturize/plain.png")

local blurMat2, Dynamic2 = Material("pp/blurscreen"), 0

local function BlurScreen(den,alp)
	local layers, density, alpha = 1, den, alph
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blurMat2)
	local FrameRate, Num, Dark = 1 / FrameTime(), 3, 150

	for i = 1, Num do
		blurMat2:SetFloat("$blur", (i / layers) * density * Dynamic2)
		blurMat2:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	Dynamic2 = math.Clamp(Dynamic2 + (1 / FrameRate) * 7, 0, 1)
end

local huy = math.random(1,10)
local triangle = {
	{ x = 1770, y =	150 },
	{ x = 1820, y = 50 },
	{ x = 1870, y = 150 }
}

local addmat_r = Material("CA/add_r")
local addmat_g = Material("CA/add_g")
local addmat_b = Material("CA/add_b")
local vgbm = Material("vgui/black")

local function DrawCA(rx, gx, bx, ry, gy, by)
    render.UpdateScreenEffectTexture()
    addmat_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
    addmat_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
    addmat_b:SetTexture("$basetexture", render.GetScreenEffectTexture())
    render.SetMaterial(vgbm)
    render.DrawScreenQuad()
    render.SetMaterial(addmat_r)
    render.DrawScreenQuadEx(-rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry)
    render.SetMaterial(addmat_g)
    render.DrawScreenQuadEx(-gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy)
    render.SetMaterial(addmat_b)
    render.DrawScreenQuadEx(-bx / 2, -by / 2, ScrW() + bx, ScrH() + by)
end

hook.Add("RenderScreenspaceEffects","BloomEffect-homigrad",function()
	if GetConVar("hg_bodycam"):GetInt() == 1 and LocalPlayer():Alive() then
		local splitTbl = string.Split(util.DateStamp()," ")
		local date,time = splitTbl[1],splitTbl[2]
		time = string.Replace(time,"-",":")

		draw.Text( {
			text = date.." "..time.." -0400",
			font = "BodyCamFont",
			pos = { ScrW() - 650, 50 }
		} )
		draw.Text( {
			text = "AXON BODY "..huy.." XG8A754GH",
			font = "BodyCamFont",
			pos = { ScrW() - 650, 100 }
		} )

		surface.SetDrawColor( 255, 255, 0, 255 )
		draw.NoTexture()
		surface.DrawPoly(triangle)

		DrawBloom( 0.5, 1, 9, 9, 1, 1.2, 0.8, 0.8, 1.2 )
		--DrawTexturize(1,mat)
		DrawSharpen( 1, 1.2 )
		DrawColorModify(tab)
		BlurScreen(0.3,55)
		LocalPlayer():SetDSP(55,true)
		DrawMotionBlur(0.2,0.3,0.001)
		--DrawToyTown(1,ScrH() / 2)
		local k3 = 6
		DrawCA(4 * k3, 2 * k3, 0, 2 * k3, 1 * k3, 0)
	end

	if not LocalPlayer():Alive() then
		LocalPlayer():SetDSP(1)
	end

	if LocalPlayer():Alive() then
		tab2["$pp_colour_colour"] = LocalPlayer():Health() / 150
		DrawColorModify(tab2)
	end

	if !LocalPlayer():Alive() and timer.Exists("DeathCam") then
		DrawMotionBlur(0.5,0.3,0.02)
		DrawSharpen( 1, 0.2 )
		local k3 = 15
		DrawCA(4 * k3, 2 * k3, 0, 2 * k3, 1 * k3, 0)
		tab2["$pp_colour_colour"] = 0.2
		tab2[ "$pp_colour_mulb" ] = 0.5
		DrawColorModify(tab2)
		BlurScreen(1,155)
		draw.Text( {
			text = deathtext,
			font = "BodyCamFont",
			pos = { ScrW()/2, ScrH()/1.2 },
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,35,35,220)
		} )
		LocalPlayer():SetDSP(15)
	elseif not LocalPlayer():Alive() then
		LocalPlayer():SetDSP(1)
	end
	
end)


hook.Add("PostDrawTranslucentRenderables","fuck_off",function()
	--[[local lply = LocalPlayer()
	if lply == Entity(1) then
		local ent = lply:GetEyeTrace().Entity
		ent = ent:IsPlayer() and ent
		if ent then
			local pos,ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
			
			render.DrawBox( pos, ang, Vector(3,-6,-4), Vector(9,4,4), color_white )

			local dmgpos = ply:GetEyeTrace().HitPos
			local penetration = ply:GetAimVector() * 10
			local huy = util.IntersectRayWithOBB(dmgpos,penetration,pos,ang,Vector(2,-4,-3), Vector(7,4,3))

			print(huy)
		end
	end--]]
end )
