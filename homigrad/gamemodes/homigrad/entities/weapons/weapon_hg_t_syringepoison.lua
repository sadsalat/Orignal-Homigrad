SWEP.Base = "medkit"

SWEP.PrintName = "Тетродотоксин"
SWEP.Author = "Homigrad"
SWEP.Instructions = "Вколоть в позвоночник и ждать..."

SWEP.Spawnable = true
SWEP.Category = "Примочки убийцы"

SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.ViewModel = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.HoldType = "normal"

SWEP.dwsPos = Vector(7,7,7)
SWEP.dwsItemPos = Vector(2,0,2)

SWEP.dwmModeScale = 0.5
SWEP.dwmForward = 3
SWEP.dwmRight = 1
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 90
SWEP.dwmAForward = 0

local function eyeTrace(ply)
    local att1 = ply:LookupAttachment("eyes")

    if not att1 then return end

    local att = ply:GetAttachment(att1)

    if not att then return end

    local tr = {}
    tr.start = att.Pos
    tr.endpos = tr.start + ply:EyeAngles():Forward() * 50
    tr.filter = ply

    return util.TraceLine(tr)
end

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ent = eyeTrace(self:GetOwner()).Entity
    local ply = ent:IsPlayer() and ent or RagdollOwner(ent)

    if not ply then return end

    self:Poison(ply)
end

function SWEP:SecondaryAttack() end

if SERVER then

    function SWEP:Poison(ent)

        local entreal = ent.fakeragdoll or ent

        local bone = entreal:LookupBone("ValveBiped.Bip01_Spine4")

        if not bone then return end

        local matrix = entreal:GetBoneMatrix(bone)

        if not matrix then return end

        local trace = eyeTrace(self:GetOwner())
        local tracePos = trace.HitPos
        local traceDir = trace.HitPos - trace.StartPos
        traceDir:Normalize()
        traceDir:Mul(4)

        if not tracePos or not traceDir then return end 

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()

        local huy = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-1,-1),Vector(2,0,1))

        local bone = entreal:LookupBone("ValveBiped.Bip01_Spine1")

        if not bone then return end

        local matrix = entreal:GetBoneMatrix(bone)

        if not matrix then return end

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()
        local huy2 = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-3,-1),Vector(2,-2,1))

        if huy or huy2 then
            ent.otravlen = true
            timer.Create("Cyanid"..ent:EntIndex().."1", 30, 1, function()
                if ent:Alive() and ent.otravlen then
                    ent:EmitSound("vo/npc/male01/moan0"..math.random(1,5)..".wav",60)
                end

                timer.Create( "Cyanid"..ent:EntIndex().."2", 10, 1, function()
                    if ent:Alive() and ent.otravlen then
                        ent:EmitSound("vo/npc/male01/moan0"..math.random(1,5)..".wav",60)
                    end
                end)

                timer.Create( "Cyanid"..ent:EntIndex().."3", 15, 1, function()
                    if ent:Alive() and ent.otravlen then
                        ent.KillReason = "poison"
                        ent:Kill()
                    end
                end)
            end)
            self:GetOwner():EmitSound("snd_jack_hmcd_needleprick.wav",30)
            self:Remove()
            self:GetOwner():SelectWeapon("weapon_hands")
        end
        return false
    end


    function SWEP:Think()
        
    end

else

    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        local traceResult = eyeTrace(owner)
        local ent = traceResult.Entity

        if not IsValid(ent) then return end

        local bone = ent:LookupBone("ValveBiped.Bip01_Spine4")

        if not bone then return end

        local matrix = ent:GetBoneMatrix(bone)

        if not matrix then return end

        local trace = eyeTrace(self:GetOwner())
        local tracePos = trace.HitPos
        local traceDir = trace.HitPos - trace.StartPos
        traceDir:Normalize()
        traceDir:Mul(4)

        if not tracePos or not traceDir then return end 

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()

        local huy = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-1,-1),Vector(2,0,1))

        local bone = ent:LookupBone("ValveBiped.Bip01_Spine1")

        if not bone then return end

        local matrix = ent:GetBoneMatrix(bone)

        if not matrix then return end

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()
        local huy2 = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-3,-1),Vector(2,-2,1))

        local hitEnt = (huy or huy2) and 0 or 1
        
        local frac = traceResult.Fraction
        surface.SetDrawColor(Color(255, 255 * hitEnt, 255 * hitEnt, 255))
        draw.NoTexture()
        Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
        draw.DrawText(not tobool(hitEnt) and "Вколоть шприц" or "","TargetID",traceResult.HitPos:ToScreen().x,traceResult.HitPos:ToScreen().y - 40,color_white,TEXT_ALIGN_CENTER)
    end
end