SWEP.Base = "weapon_base" -- base 
SWEP.PrintName = "salat_base"
SWEP.Author = "sadsalat"
SWEP.Instructions = ""
SWEP.Category = "Other"
SWEP.Spawnable = false
SWEP.AdminOnly = false
------------------------------------------
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * 2
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 100
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "weapons/fiveseven/fiveseven-1.wav"
SWEP.Primary.Force = 0
SWEP.ReloadTime = 2
SWEP.ShootWait = 0.12
SWEP.NextShot = 0
SWEP.Sight = false
SWEP.ReloadSound = "weapons/smg1/smg1_reload.wav"
SWEP.TwoHands = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
------------------------------------------
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.HoldType = ""
SWEP.sightPos = Vector(0, 0, 0)
SWEP.sightAng = Angle(0, 0, 0)
SWEP.fakeHandRight = Vector(0, 0, 0)
SWEP.fakeHandLeft = Vector(0, 0, 0)
SWEP.DoFlash = true
SWEP.Recoil = 0
------------------------------------------
SWEP.ScopeAdjustAng = Angle(0, 0, 0)
SWEP.ScopeAdjustPos = Vector(0, 0, 0)
SWEP.ScopeFov = 90
SWEP.ScopeMat = ""
SWEP.ScopeRot = 0
SWEP.UVAdjust = {0, 0}
SWEP.UVScale = {1, 1}
------------------------------------------
SIB_SurfaceHardness = {
	[MAT_METAL] = .95,
	[MAT_COMPUTER] = .95,
	[MAT_VENT] = .95,
	[MAT_GRATE] = .95,
	[MAT_FLESH] = .5,
	[MAT_ALIENFLESH] = .3,
	[MAT_SAND] = .1,
	[MAT_DIRT] = .3,
	[74] = .1,
	[85] = .2,
	[MAT_WOOD] = .5,
	[MAT_FOLIAGE] = .5,
	[MAT_CONCRETE] = .9,
	[MAT_TILE] = .8,
	[MAT_SLOSH] = .05,
	[MAT_PLASTIC] = .3,
	[MAT_GLASS] = .6
}

local vecZero = vector_origin
local angZero = angle_zero
SWEP.addPos = vector_origin
SWEP.addAng = angle_zero
local defaultBulletPosAng = {
	default = {Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0)},
	revolver = {Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0)},
	ar2 = {Vector(20, -0.8, 11.2), Angle(-9.5, 0, 0)},
	smg = {Vector(14, -0.8, 6.8), Angle(-9.5, 0, 0)},
}

function SWEP:GetDefaultLocalMuzzlePos()
	local pos, ang = unpack(defaultBulletPosAng[self:GetHoldType()] or defaultBulletPosAng.default)

	return pos, ang
end

function SWEP:GetDefaultMuzzlePos()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local att = owner:GetAttachment(owner:LookupAttachment('anim_attachment_rh'))
	if not att then return end
	local lpos, lang = self:GetDefaultLocalMuzzlePos()
	local pos, ang = LocalToWorld(lpos, lang, att.Pos, att.Ang)

	return pos, ang
end

function SWEP:GetBulletSourcePos()
	if self.addPos or self.addAng then
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		local att = owner:GetAttachment(owner:LookupAttachment('anim_attachment_rh'))
		if att then
			local defaultlpos, defaultlang = self:GetDefaultLocalMuzzlePos()
			local pos, ang = LocalToWorld(self.addPos or defaultlpos, self.addAng or defaultlang or angle_zero, att.Pos, att.Ang)

			return pos, ang
		end
	end

	local pos, ang = self:GetDefaultMuzzlePos()

	return pos, ang
end

local mul = 1
function LerpAngleFT(lerp, source, set)
	return LerpAngle(math.min(lerp * mul, 1), source, set)
end

function SWEP:DrawHUD()
	if SERVER then return end
	if not self.DrawScope then return end
	local ply = self:GetOwner()
	local view = HomigradCam(ply) or {
		angles = Angle(0, 0, 0)
	}

	local shootOrigin, shootAng = self:GetBulletSourcePos()
	local ScopeAng = shootAng
	ScopeAng.z = view.angles.z or 0
	z = 0
	local rt = {
		x = 0,
		y = 0,
		w = 512,
		h = 512,
		angles = ScopeAng + self.ScopeAdjustAng,
		origin = shootOrigin + self.ScopeAdjustPos,
		drawviewmodel = false,
		fov = self.ScopeFov,
		znear = 1,
		zfar = 26000
	}

	rt.angles[3] = rt.angles[3] - 180
	render.PushRenderTarget(self.rtmat, 0, 0, 512, 512)
	local old = DisableClipping(true)
	render.Clear(1, 1, 1, 255)
	render.RenderView(rt)
	cam.Start2D()
	surface.SetDrawColor(255, 255, 255, 255) -- Set the drawing color
	surface.SetMaterial(self.ScopeMat) -- Use our cached material
	surface.DrawTexturedRectRotated(256 + self.UVAdjust[1], 256 + self.UVAdjust[2], 512 * self.UVScale[1], 512 * self.UVScale[2], self.ScopeRot or 0) -- Actually draw the rectangl
	cam.End2D()
	DisableClipping(old)
	render.PopRenderTarget()
end

function SWEP:BulletCallbackFunc(dmgAmt, ply, tr, dmg, tracer, hard, multi)
	if tr.MatType == MAT_FLESH then
		util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		local vPoint = tr.HitPos
		local effectdata = EffectData()
		effectdata:SetOrigin(vPoint)
		util.Effect("BloodImpact", effectdata)
	end

	if self.NumBullet or 1 > 1 then return end
	if tr.HitSky then return end
	if hard then
		self:RicochetOrPenetrate(tr)
	end
end

function SWEP:RicochetOrPenetrate(initialTrace)
	local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, SIB_SurfaceHardness[initialTrace.MatType]
	if not SMul then
		SMul = .5
	end

	local ApproachAngle = -math.deg(math.asin(TNorm:DotProduct(AVec)))
	local MaxRicAngle = 60 * SMul
	-- all the way through
	if ApproachAngle > (MaxRicAngle * 1.25) then
		local MaxDist, SearchPos, SearchDist, Penetrated = ((self.Primary.Damage / 5) / SMul) * .25, IPos, 5, false
		while (not Penetrated) and (SearchDist < MaxDist) do
			SearchPos = IPos + AVec * SearchDist
			local PeneTrace = util.QuickTrace(SearchPos, -AVec * SearchDist)
			if (not PeneTrace.StartSolid) and PeneTrace.Hit then
				Penetrated = true
			else
				SearchDist = SearchDist + 5
			end
		end

		if Penetrated then
			self:FireBullets(
				{
					Attacker = self:GetOwner(),
					Damage = 1,
					Force = 1,
					Num = 1,
					Tracer = 0,
					TracerName = "",
					Dir = -AVec,
					Spread = vector_origin,
					Src = SearchPos + AVec
				}
			)

			self:FireBullets(
				{
					Attacker = self:GetOwner(),
					Damage = self.Primary.Damage * .65,
					Force = (self.Primary.Force / 20) / 15,
					Num = 1,
					Tracer = 0,
					TracerName = "",
					Dir = AVec,
					Spread = vector_origin,
					Src = SearchPos + AVec
				}
			)
		end
	elseif ApproachAngle < (MaxRicAngle * .25) then
		-- ping whiiiizzzz
		if math.random(1, 5) <= 2 then return end
		sound.Play("salatbase/ricochet/ricochet" .. math.random(1, 12) .. ".wav", IPos, 70, math.random(90, 100))
		local NewVec = AVec:Angle()
		NewVec:RotateAroundAxis(TNorm, 180)
		NewVec = NewVec:Forward()
		self:FireBullets(
			{
				Attacker = self:GetOwner(),
				Damage = self.Primary.Damage * .85,
				Force = (self.Primary.Force / 20) / 15,
				Num = 1,
				Tracer = 0,
				TracerName = "",
				Dir = -NewVec,
				Spread = vector_origin,
				Src = IPos + TNorm
			}
		)
	end
end

local pos = vector_origin
slbweps = slbweps or {}
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	slbweps[self] = true
	if CLIENT then return end
end

hook.Add(
	"Think",
	"fwep-customThinker",
	function()
		for wep in pairs(slbweps) do
			if not IsValid(wep) then
				slbweps[wep] = nil
				continue
			end

			local owner = wep:GetOwner()
			if not IsValid(owner) or (owner:IsPlayer() and not owner:Alive()) or owner:GetActiveWeapon() ~= wep then continue end --wtf i dont know
			if wep.Step then
				wep:Step()
			end
		end
	end
)

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if timer.Exists("reload" .. self:EntIndex()) then return nil end
	if self:Clip1() <= 0 then return nil end
	if self:GetOwner():IsSprinting() then return nil end
	local ply = self:GetOwner()
	self.ShootNext = self.NextShot or NextShot
	if self.NextShot > CurTime() then return end
	self.NextShot = CurTime() + self.ShootWait
	self:EmitSound(self.Primary.Sound)
	self:FireShoting(self.Primary.Damage, 1, 5)
	self:SetNWFloat("VisualRecoil", self:GetNWFloat("VisualRecoil") + self.Recoil)
end

function SWEP:IsLocal()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:Step()
	self.animProg = self:GetNWFloat("VisualRecoil") or 0
	self.animLerp = self.animLerp or Angle(0, 0, 0)
	self.animLerp = LerpAngle(0.25, self.animLerp, Angle(5, 0, self.HoldType == "revolver" and 0 or -2) * self.animProg)
	local ply = self:GetOwner()
	if self:GetNWFloat("VisualRecoil") > 0 then
		if self.HoldType ~= "revolver" then
			ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, -self.animLerp.x / 3, -self.animLerp.x / 3), false)
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Angle(0, 0, -self.animLerp.x), false)
		end

		ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), self.animLerp * 2, false)
		--print(animProg)
		self:SetNWFloat("VisualRecoil", Lerp(4 * FrameTime(), self:GetNWFloat("VisualRecoil") or 0, 0))
	end

	if SERVER then
		ply:SetNWInt("RightArm", ply.RightArm)
		ply:SetNWInt("LeftArm", ply.LeftArm)
	end

	local isLocal = self:IsLocal()
	if isLocal then
		self.eyeSpray = self.eyeSpray or Angle(0, 0, 0)
		ply:SetEyeAngles(ply:EyeAngles() + self.eyeSpray)
		self.eyeSpray = LerpAngleFT(0.5, self.eyeSpray, Angle(0, 0, 0))
		local p = 0.005
		self.eyeSpray = self.eyeSpray + Angle(math.Rand(-p, p), math.Rand(-p, p), 0)
	end

	if isLocal then
		--self.eyeSpray = self.eyeSpray + Angle(math.Rand(-0.03,0.03),math.Rand(-0.03,0.03),math.Rand(-0.03,0.03))
		if ply:GetNWInt("LeftArm") < 1 or ply:GetNWInt("RightArm") < 1 then
			local p = 0.1
			self.eyeSpray = self.eyeSpray + Angle(math.Rand(-p, p), math.Rand(-p, p), 0)
		end
	end
end

function SWEP:Reload()
	if timer.Exists("reload" .. self:EntIndex()) or self:Clip1() >= self:GetMaxClip1() or self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then return nil end
	if self:GetOwner():IsSprinting() then return nil end
	if self.NextShot > CurTime() then return end
	self:GetOwner():SetAnimation(PLAYER_RELOAD)
	self:EmitSound(self.ReloadSound, 60, 100, 0.8, CHAN_AUTO)
	timer.Create(
		"reload" .. self:EntIndex(),
		self.ReloadTime,
		1,
		function()
			if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():GetActiveWeapon() == self then
				local oldclip = self:Clip1()
				self:SetClip1(math.Clamp(self:Clip1() + self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()), 0, self:GetMaxClip1()))
				local needed = self:Clip1() - oldclip
				self:GetOwner():SetAmmo(self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) - needed, self:GetPrimaryAmmoType())
			end
		end
	)
end

local vecZero = vector_origin
local angZero = angle_zero
local hg_show_hitposmuzzle = CreateClientConVar("hg_show_hitposmuzzle", 0, false, false, "Shows debug weapon hitpos", 0, 2)
local x = Vector(1, 0.025, 0.025)
hook.Add(
	"HUDPaint",
	"admin_hitpos",
	function()
		if hg_show_hitposmuzzle:GetInt() <= 0 then return end
		if not LocalPlayer():IsAdmin() then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep.Base ~= "salat_base" then return end
		local att = wep:LookupAttachment("muzzle")
		if not att then return end
		local att = wep:GetAttachment(att)
		if not att then return end
		local shootOrigin, shootAngles = wep:GetBulletSourcePos()
		local tr = util.QuickTrace(shootOrigin, shootAngles:Forward() * 1000, LocalPlayer())
		local hit = tr.HitPos:ToScreen()
		surface.SetDrawColor(color_white)
		surface.DrawRect(hit.x - 2.5, hit.y - 2.5, 5, 5)
	end
)

hook.Add(
	"PostDrawTranslucentRenderables",
	"Boxxie",
	function()
		if hg_show_hitposmuzzle:GetInt() <= 1 then return end
		if not LocalPlayer():IsAdmin() then return end
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep.Base ~= "salat_base" then return end
		local att = wep:LookupAttachment("muzzle")
		if not att then return end
		local att = wep:GetAttachment(att)
		if not att then return end
		local shootOrigin, shootAngles = wep:GetBulletSourcePos()
		render.SetColorMaterial() -- white material for easy coloring
		cam.IgnoreZ(true) -- makes next draw calls ignore depth and draw on top
		render.DrawBox(shootOrigin, shootAngles, x, -x, color_white) -- draws the box 
		cam.IgnoreZ(false) -- disables previous call
	end
)

function SWEP:FireShoting(dmg, numbul, spread)
	--PrintTable(self:GetAttachments())
	if not IsValid(self) then return nil end
	if self:Clip1() <= 0 then return nil end
	if timer.Exists("reload" .. self:EntIndex()) then return nil end
	--[[local obj = self:LookupAttachment("muzzle")
	local Attachment = self:GetAttachment(obj)
	local cone = self.Primary.Cone
	local shootOrigin = Attachment.Pos
	local vec = vecZero
	vec:Set(self.addPos)
	vec:Rotate(Attachment.Ang)
	shootOrigin:Add(vec)
	local shootAngles = Attachment.Ang
	local ang = angZero
	ang:Set(self.addAng)
	shootAngles:Add(ang)
	local shootDir = shootAngles:Forward()]]
	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(true)
	end

	local shootOrigin, shootAngles = self:GetBulletSourcePos()
	local shootDir = shootAngles:Forward()
	local ply = self:GetOwner()
	local bullet = {}
	local cone = self.Primary.Cone
	bullet.Num = self.NumBullet or 1
	bullet.Src = shootOrigin
	bullet.Dir = shootDir
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 1
	bullet.TracerName = 4
	bullet.Force = self.Primary.Force / 20
	bullet.Damage = dmg or 25
	bullet.AmmoType = self.Primary.Ammo
	bullet.Attacker = ply
	bullet.IgnoreEntity = ply:GetVehicle() or nil
	bullet.Callback = function(ply, tr)
		self:BulletCallbackFunc(dmg or 25, ply, tr, dmg, false, true, false)
	end

	self:FireBullets(bullet)
	if self:GetOwner():IsPlayer() then
		self:GetOwner():LagCompensation(false)
	end

	if SERVER then
		self:TakePrimaryAmmo(1)
	end

	if CLIENT then
		self.eyeSpray = self.eyeSpray or Angle(0, 0, 0)
		self.eyeSpray:Add(Angle(-self.Primary.Force / 400, math.Rand(-self.Primary.Force / 400, self.Primary.Force / 400), 0))
	end

	-- Make a muzzle flash
	if self.DoFlash then
		local ef = EffectData()
		ef:SetEntity(self)
		ef:SetAttachment(1) -- self:LookupAttachment( "muzzle" )
		ef:SetFlags(1) -- Sets the Combine AR2 Muzzle flash
		util.Effect("MuzzleFlash", ef)
	end
	--self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	--ply:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:Think()
	local ply = self:GetOwner()
	local t = {}
	if not self.TwoHands then
		t.start = ply:GetShootPos() + ply:GetAngles():Right() * 2.5
	else
		t.start = ply:GetShootPos() + ply:GetAngles():Right() * 7
	end

	t.endpos = t.start + Angle(0, ply:GetAngles().y, ply:GetAngles().z):Forward() * 100
	t.filter = player.GetAll()
	Thinking = Thinking or 0
	if CurTime() then
		Thinking = CurTime() + 1
		local tr = util.TraceLine(t)
		self.dist = (tr.HitPos - t.start):Length()
		if not self:GetOwner():IsSprinting() then
			if self.dist <= 45 and not self:GetOwner():KeyPressed(IN_RELOAD) then
				if not self.TwoHands then
					self:SetHoldType("normal")
				else
					self:SetHoldType("passive")
				end
			else
				if self.Sight then
					if self:GetOwner():KeyDown(IN_ATTACK2) and not timer.Exists("reload" .. self:EntIndex()) and not self:GetOwner():KeyPressed(IN_RELOAD) and not self:GetOwner():KeyDown(IN_DUCK) then
						self:SetHoldType("rpg")
					else
						self:SetHoldType(self.HoldType)
					end
				else
					self:SetHoldType(self.HoldType)
				end
			end
		else
			if not self.TwoHands then
				self:SetHoldType("normal")
			else
				self:SetHoldType("passive")
			end
		end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	self:SetHoldType("passive")
	local obj = self:LookupAttachment("muzzle")
	if not obj then
		self:GetOwner():ChatPrint("лох скачай контент")

		return false
	end

	return true
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:Holster(wep)
	if not IsFirstTimePredicted() then return end
	local ply = self:GetOwner()
	ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, 0, 0), true)
	ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Angle(0, 0, 0), true)

	return true
end