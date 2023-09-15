AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Author = "Zippy"
ENT.PrintName = "Gib"

if SERVER then
    ZippyGoreMod3_Gibs = {}
end

ENT.FadeTime = 2
ENT.FadeReps = 30

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
    if SERVER then
        local ent = self.DoGibRagdoll && ents.Create("prop_ragdoll") or self

        ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        ent:SetNWInt("ZippyGoreMod3_BloodColor", ent.BloodColor)

        if self.DoGibRagdoll then
            ent:SetModel(self:GetModel())
            ent:SetPos(self:GetPos())
            ent:SetAngles(self:GetAngles())
            ent.ZippyGoreMod3_IsGibRagdoll = true -- Prevent ragdoll from becoming gibbable

            ent.BloodColor = self.BloodColor
            ent.FadeTime = self.FadeTime
            ent.FadeReps = self.FadeReps
            ent.Fade = self.Fade
            ent:AddCallback( "PhysicsCollide", self.PhysicsCollide )

            ent:Spawn()

            self:SetParent(ent)
            self:SetNoDraw(true)
            self.Ragdoll = ent
        else
            ent:PhysicsInit( SOLID_VPHYSICS )
            ent:GetPhysicsObject():Wake()
        end

        -- if "Insane Blood Effects" installed, do some effects:
        if ent.BloodColor == BLOOD_COLOR_RED && ZGM3_INSANE_BLOOD_EFFECTS then
            local effectdata1 = EffectData()
            effectdata1:SetMagnitude( math.Rand(2, 3) )
            effectdata1:SetStart( ent:WorldSpaceCenter() )
            RealisticBlood_DoEffect("realisticblood_droplets", effectdata1, ent)
        end

        -- Add to global list of gibs:
        table.insert(ZippyGoreMod3_Gibs, ent)
        -- Remove old gib if there are too many:
        while #ZippyGoreMod3_Gibs > GetConVar("zippygore3_gib_limit"):GetInt() do
            if IsValid(ZippyGoreMod3_Gibs[1]) then
                ZippyGoreMod3_Gibs[1]:Fade()
            end
            table.remove(ZippyGoreMod3_Gibs, 1)
        end

        -- Life time stuff:
        local lifetime = GetConVar("zippygore3_gib_lifetime"):GetInt()
        if lifetime != -1 then
            local timer_name = "ZippyGore3_GibFadeTime"..ent:EntIndex()
            timer.Create(timer_name, lifetime, 1, function()
                if IsValid(ent) then ent:Fade() end
            end)
            ent:CallOnRemove("ZippyGore3_GibFadeTime_Remove", function()
                if timer.Exists(timer_name) then timer.Remove(timer_name) end
            end)
        end
    end

    if CLIENT then
        -- Effect:
        local effectdata = EffectData()
        effectdata:SetEntity( self )
        util.Effect("zippygore3_gib_blood", effectdata)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Fade()
    if !SERVER then return end

    self:SetRenderMode(RENDERMODE_TRANSALPHA)

    local timer_name = "ZippyGore3_GibFadeUpdate"..self:EntIndex()
    timer.Create(timer_name, self.FadeTime / self.FadeReps, self.FadeReps, function()
        if !IsValid(self) then
            timer.Remove(timer_name)
            return
        end

        local myCol = self:GetColor()
        local newCol = Color(myCol.r, myCol.g, myCol.b, myCol.a - (255 / self.FadeReps))
        if newCol.a <= 0 then
            self:SetNoDraw(true)
        else
            self:SetColor(newCol)
        end

        if timer.RepsLeft(timer_name) == 0 then self:Remove() end
    end)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Use( activator )
    if GetConVar("zippygore3_gib_edible"):GetBool() && activator:Health() < activator:GetMaxHealth() then
        -- Eat tha gib
        -- Set health:
        local health_to_give = GetConVar("zippygore3_gib_heath_give"):GetInt()
        local set_health = math.Clamp( activator:Health() + health_to_give, 0, activator:GetMaxHealth() )
        activator:SetHealth( set_health )
        -- Do effects and remove the gib:
        local bc = self.BloodColor
        local effect = ( bc==BLOOD_COLOR_RED && "blood_impact_red_01_goop" ) or
        ( ( bc==BLOOD_COLOR_ANTLION or bc==BLOOD_COLOR_ANTLION_WORKER or bc==BLOOD_COLOR_GREEN or bc==BLOOD_COLOR_ZOMBIE or bc==BLOOD_COLOR_YELLOW ) && "blood_impact_yellow_01" )
        if effect then ParticleEffect(effect, self:WorldSpaceCenter(), self:GetAngles()) end
        self:EmitSound("ZippyGore3GibCollision")
        self:Remove()
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PhysicsCollide( data )
    local bc = self.BloodColor
    local decal = ( bc==BLOOD_COLOR_RED && "Blood" ) or
    ( ( bc==BLOOD_COLOR_ANTLION or bc==BLOOD_COLOR_ANTLION_WORKER or bc==BLOOD_COLOR_GREEN or bc==BLOOD_COLOR_ZOMBIE or bc==BLOOD_COLOR_YELLOW ) && "YellowBlood" )

    if data.Speed > 100 then self:EmitSound("ZippyGore3GibCollision") end

    if data.Speed > 400 && decal then
        util.Decal(decal, data.HitPos, data.HitPos+data.HitNormal, self)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
