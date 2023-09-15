local table_insert = table.insert

local maxScale = GetConVar("chloeimpact_max_scale")
local maxChunks = GetConVar("chloeimpact_max_debris_props")
local maxDust = GetConVar("chloeimpact_max_debris_effects")
local lifetime = GetConVar("chloeimpact_impact_lifetime")
local lifetimedebris = GetConVar("chloeimpact_impact_debris_lifetime")
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

local matlist = {}

local DebrisScale = GetConVar("chloeimpact_effects_scale")

local mat_cover = CreateMaterial("impact_rock", "VertexLitGeneric", {
	["$vertexcolor"] = 1,
	["$basetexture"] = "",
	["$translucent"] = 0,
})

local math_Rand = math.Rand
local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_Clamp = math.Clamp
local table_Random = table.Random
local vec15 = Vector(15,15,15)

local gibListByMat = {
	[MAT_DIRT] = rocks,
	[MAT_CONCRETE] = rocks,
	[MAT_METAL] = metal_gibs
}

local physMatByMat = {
	[MAT_DIRT] = "gravel",
	[MAT_CONCRETE] = "concreate",
	[MAT_METAL] = "metal"
}

local colorMatByMat = {
	[MAT_DIRT] = {200,150,100},
	[MAT_CONCRETE] = {100,100,100},

	[MAT_SAND] = {230,200,140}
}

local function Create_Effect(self,mat,origMat)
	local scale = self.Scale
	local normal = self.Normal
	local csmodels,csprops = self.CSModels,self.CSProps
	local distmod = self.Pos:Distance(self.OPos) / 500

	local _maxChunks = maxChunks:GetInt()

	local AttackAngle = self.AttackAngle
	AttackDir = normal * 2 + AttackAngle * 1

	if mat == MAT_METAL then
		for i = 1, math_min(maxDust:GetInt(),scale) do
			self.Pos = self.OPos + AttackDir / 300 * i

			local dir = VectorRand()
			dir.x = dir.x / 55
			dir:Rotate(normal:Angle())
			dir:Normalize()

			local p = self.Emitter:Add("particle/particle_smoke_dust",self.Pos + VectorRand() * scale / 5)
			p:SetDieTime(math_Clamp(math_Rand(1,2) * scale / 50,0.5,1))
			p:SetVelocity(dir * scale * 12)
			p:SetAirResistance(200)
			p:SetStartAlpha(15)
			p:SetEndAlpha(0)
			p:SetStartSize(math_random(36,67) * scale / 100)
			p:SetEndSize(math_random(125,250) * scale / 100)
			p:SetRollDelta(math_Rand(-0.25,0.25))
			p:SetColor(100,100,100)
		end
	elseif mat == MAT_DIRT or MAT_CONCRETE then
		local color = colorMatByMat[origMat] or colorMatByMat[mat]

		local v1 = math_max(0.25,scale / 100)

		for i = 1, math_min(maxDust:GetInt(),scale * 2) do
			self.Pos = self.OPos + AttackDir / 300 * i

			local dir = VectorRand()
			dir.x = dir.x / 55

			dir:Rotate(normal:Angle())
			dir:Normalize()

			local p = self.Emitter:Add("particle/particle_smoke_dust",self.Pos + VectorRand() * scale / 5)
			p:SetDieTime(math_Clamp(math.Rand(0.1,0.5) * scale / 50,0.5,12))
			p:SetVelocity(dir * scale * 40)
			p:SetAirResistance(200)
			p:SetStartAlpha(math_random(25,50))
			p:SetEndAlpha(0)
			p:SetStartSize(math_random(75,125) * v1)
			p:SetEndSize(math_random(250,400) * v1)
			p:SetRollDelta(math_Rand(-0.5,0.5))
			p:SetColor(color[1],color[2],color[3])
		end
	end

	AttackDir = normal * 2 + AttackAngle * 1.3

	for i = 1, math_min(_maxChunks / 2 * math_min(1,scale / 100),scale / distmod) do
		self.Pos = self.OPos + AttackDir * (i / math_min(_maxChunks / 2,scale))
		local pos

		--debugoverlay.Cross(self.Pos, 15)
		if mat ~= MAT_METAL then
			local mdl = ClientsideModel(table_Random(rocks))
			mdl:SetModelScale(math_max(1,math_Rand(scale / 35,scale / 25)))

			local dir = VectorRand()
			dir.x = dir.x / 55

			dir:Rotate(normal:Angle())
			dir:Normalize()

			mdl.IdealPos = (self.Pos + (dir * 100 * math_Rand(0.1, 1) * scale / 200))

			local idealpos = mdl.IdealPos

			if self.HitAngle == 2 then
				self.Pos = self.OPos
			end

			pos = self.Pos

			local tr = util.TraceHull({
				start = idealpos,
				endpos = idealpos,
				mask = MASK_SOLID,
				mins = -vec15,
				maxs = vec15
			})

			if tr.Hit then
				local pos2 = pos - normal + dir * scale * math.Rand(0.6,2)

				local tr = util.TraceLine({
					start = pos2,
					endpos = pos - normal * scale,
				})

				mdl:SetPos(tr.Hit and tr.HitPos or pos2)

				local dir2 = (idealpos - (pos - (normal * 15))):GetNormalized()

				mdl:SetAngles(dir2:Angle())
				mdl:Spawn()
				mdl:Activate()
				mdl:SetNoDraw(true)

				table.insert(csmodels,mdl)
			else
				mdl:Remove()
			end
		else
			pos = self.Pos
		end

		local mdl = ents.CreateClientProp(table_Random(gibListByMat[mat]))
		local dir = VectorRand()

		dir.x = dir.x / 55

		dir:Rotate(normal:Angle())
		dir:Normalize()

		mdl:SetPos(pos + normal * scale / 2 * math_Rand(1,4) + dir * scale / 1.5)

		local ang = (mdl:GetPos() - pos)
		mdl:SetAngles(ang:Angle())

		mdl:Spawn()
		mdl:Activate()
		mdl:SetNoDraw(true)
		mdl:SetModelScale(math_max(1,scale / 60))
		mdl:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

		local phys = mdl:GetPhysicsObject()
		--phys:EnableMotion(false)

		if IsValid(phys) then
			mdl:Activate()

			phys:SetVelocity((dir / 3 + AttackAngle * math_Rand(-0.5,2)) / math_Rand(1,3) * math_max(50,scale) * 12)
			phys:SetAngleVelocity(ang)
			phys:SetMaterial(physMatByMat[origMat] or physMatByMat[mat])
		end

		if mat == MAT_DIRT then mdl:SetMaterial("models/props_wasteland/dirtwall001a") end

		table_insert(csprops,mdl)
	end
end

local matSpecific = {
	[MAT_ANTLION] = function(self)
		local fx = EffectData()
		fx:SetOrigin(self.Pos)
		fx:SetNormal(self.Normal)
		fx:SetMagnitude(self.Scale)
		fx:SetRadius(self.Scale)
		fx:SetScale(self.Scale)
		util.Effect("AntlionGib", fx, true, true)
		for i=1, math.min(maxChunks:GetInt(), self.Scale/20) do
			local mdl = ents.CreateClientProp(table.Random(ant_gibs))
			local dir = VectorRand()
			dir.x = dir.x / 55
			dir:Rotate(self.Normal:Angle())
			dir:Normalize()
			mdl:SetPos(self.Pos + self.Normal * 24)
			local dir2 = ((self.Pos - (self.Normal * 70) + self.AttackAngle)):GetNormalized()
			mdl:SetAngles(dir2:Angle())
			mdl:Spawn()
			mdl:Activate()
			mdl:GetPhysicsObject():SetVelocity((self.AttackAngle)/4)
			table.insert(self.CSProps, mdl)
			mdl:SetNoDraw(true)
		end
	end,
	[MAT_FLESH] = function(self)
	end,
	[MAT_CONCRETE] = function(self,mat)
		Create_Effect(self,MAT_CONCRETE,nat)
	end,
	[MAT_METAL] = function(self,mat)
		Create_Effect(self,MAT_METAL,nat)
	end,
	[MAT_DIRT] = function(self,mat)
		Create_Effect(self,MAT_DIRT,mat)
	end,
	[MAT_EGGSHELL] = function(self) end
}

print(lifetime)
function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.OPos = self.Pos
	self.Normal = data:GetNormal()
	self.HitAngle = data:GetFlags()
	self.AttackAngle = data:GetStart()
	self.Scale = data:GetScale()-- math.min(maxScale:GetInt(), data:GetScale()/5 or 1)
	self.Surface = util.GetSurfaceData(data:GetSurfaceProp())
	self.Emitter = ParticleEmitter(self.Pos)

	self.CSModels = {}
	self.CSProps = {}

	local time = CurTime()

	self.LifeTime = self.LifeTime or time + lifetime:GetFloat()
	self.LifeTimeDebris = self.LifeTimeDebris or time + lifetimedebris:GetFloat()

	local vec = Vector(self.Scale, self.Scale, self.Scale)
	self:SetRenderBounds(-vec, vec)
	self:EmitSound(self.Surface.impactHardSound)
	self:EmitSound(self.Surface.strainSound)

	local mattype,origmattype = self.Surface.material or MAT_CONCRETE
	origmattype = mattype

	if mattype == MAT_TILE then mattype = MAT_CONCRETE end
	if mattype == MAT_DEFAULT then mattype = MAT_CONCRETE end

	if mattype == MAT_GRASS then mattype = MAT_DIRT end
	if mattype == MAT_SAND then mattype = MAT_DIRT end

	if mattype == MAT_BLOODYFLESH then mattype = MAT_FLESH end

	if mattype == MAT_GRATE then mattype = MAT_METAL end
	if mattype == MAT_COMPUTER then mattype = MAT_METAL end

	self.Surface.material = mattype

	if not matSpecific[mattype] then 
		self.Emitter:Finish()

		return
	end

	matSpecific[mattype](self,origmattype)

	self.Emitter:Finish()
end

local table_remove = table.remove

function EFFECT:Think()
	local time = CurTime()

	local csmodels,csprops = self.CSModels,self.CSProps

	if time > self.LifeTimeDebris then
		local v

		for i = 1,#csprops do
			v = csprops[i]

			if IsValid(v) then v:Remove() end

			csprops[i] = nil
		end
	end

	if time > self.LifeTime then
		for i = 1,#csmodels do
			v = csmodels[i]

			if IsValid(v) then v:Remove() end
		end

		for i = 1,#csprops do
			v = csprops[i]

			if IsValid(v) then v:Remove() end
		end

		return false
	end
	
	return true
end

local mdls = {}

local rockmats = {
	[MAT_CONCRETE] = "",
	[MAT_DIRT] = "nature/dirtwall001a"
}

local tra = {}
local trdataa = {
	mask=MASK_VISIBLE,
	output = tra
}

local vec_zero = Vector(0,0,0)

local render_MaterialOverride = render.MaterialOverride
local render_SetBlend = render.SetBlend

function EFFECT:Render()
	local csmodels = self.CSModels
	local normal = self.Normal

	local mdl

	if not self.TexturesSet then
		for i = 1,#csmodels do
			mdl = csmodels[i]

			if not IsValid(mdl) then csmodels[i] = nil continue end

			local pos = mdl:GetPos()

			trdataa.start = pos + normal * 15
			trdataa.endpos = pos - normal * 15

			util.TraceLine(trdataa)

			if tra.Hit then
				local hitTexture = tra.HitTexture

				if hitTexture ~= "**empty**" and hitTexture ~= "**displacement**" and not string.StartWith(hitTexture,"TOOLS") then
					matlist[hitTexture] = matlist[hitTexture] or Material(hitTexture)

					mdl.mat = matlist[hitTexture]:GetTexture("$basetexture")
				else
					local mattype = self.Surface.material

					mdl.mat = rockmats[mattype]
				end
			else
				local mattype = self.Surface.material

				mdl.mat = rockmats[mattype]
			end
		end

		self.TexturesSet = true
	end

	local time = CurTime()
	local time2 = self.LifeTime

	for i = 1,#csmodels do
		mdl = csmodels[i]

		if not IsValid(mdl) then csmodels[i] = nil continue end

		--local pos = mdl:GetPos()

		--[[if bit.band(util.PointContents(pos - normal), CONTENTS_SOLID) == CONTENTS_SOLID then
			mdl:SetPos(pos + normal)

			mdl.CheckIndex = (mdl.CheckIndex or 1) +1
		end

		if mdl.CheckIndex and mdl.CheckIndex > 5 then
			mdl:Remove()

			continue
		end]]--

		local mat = mdl.mat

		if mat and mat ~= "" then
			mat_cover:SetTexture("$basetexture",mat or "")

			render_MaterialOverride(mat_cover)
		end

		if time2 then
			local mult = time2 - time

			if mult < 0.5 then
				render.SetBlend(2 * mult)
			end
		end

		--local normal = vec_zero + normal -- Everything "behind" this normal will be clipped
		--local position = normal:Dot( self.Pos ) -- self:GetPos() is the origin of the clipping plane

		--local oldEC = render.EnableClipping( true ) fuck you!
		--render.PushCustomClipPlane( normal, position )
		mdl:DrawModel()
		--[[render.PopCustomClipPlane()
		render.EnableClipping( oldEC )
		render.SetBlend(1)
		render.MaterialOverride()]]--
	end

	local rockMat = self.RockMat

	if not rockMat then
		local pos = self:GetPos()

		trdataa.start = pos + normal * 555
		trdataa.endpos = pos - normal * 555

		util.TraceLine(trdataa)

		if tra.Hit then
			if tra.HitTexture ~= "**empty**" and tra.HitTexture ~= "**displacement**" and not string.StartWith(tra.HitTexture, "TOOLS") then
				matlist[tra.HitTexture] = matlist[tra.HitTexture] or Material(tra.HitTexture)

				self.RockMat = matlist[tra.HitTexture]:GetTexture("$basetexture")
			else
				local mattype = self.Surface.material

				self.RockMat = rockmats[mattype]
			end
		end
	end

	local csprops = self.CSProps

	time2 = self.LifeTimeDebris

	for i = 1,#csprops do
		mdl = csprops[i]

		if not IsValid(mdl) then csprops[i] = nil continue end

		if rockmat and rockmat ~= "" then
			mat_cover:SetTexture("$basetexture",rockmat or "")

			render_MaterialOverride(mat_cover)
		end

		if time2 then
			local mult = time2 - time

			if mult < 0.5 then
				render_SetBlend(2 * mult)
			end
		end

		mdl:DrawModel()

		render_SetBlend(1)
		render_MaterialOverride()
	end

	render_MaterialOverride()
	
	return false
end
