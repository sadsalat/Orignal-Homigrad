local function create_materials( mat_names )
    local mats = {}

    for _, v in ipairs(mat_names) do
        local imat = Material(v)
        table.insert(mats, imat)
    end

    return mats
end

local blood_materials = create_materials({
    "decals/blood1",
    "decals/blood2",
    "decals/blood3",
    "decals/blood4",
    "decals/blood5",
    "decals/blood6",
})

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init( data )

    self.Entity = data:GetEntity()
    self.Bone = data:GetAttachment()
    self.Emitter = ParticleEmitter(self.Entity:GetPos(), false)
    self.Emitter3D = ParticleEmitter(self.Entity:GetPos(), true)
    self.NextEmit = CurTime()
    self.DieTime = CurTime()+math.Rand(3, 6)

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think()

    if self.DieTime < CurTime() or !IsValid(self.Entity) then
        self.Emitter:Finish()
        return false
    end

    if self.NextEmit > CurTime() then return true end

    local length = math.Rand(20, 60)
    local sizeMult = 2
    local particle = self.Emitter:Add( table.Random(blood_materials), self.Entity:GetBonePosition(self.Bone) )
    particle:SetDieTime( 1.8 )
    particle:SetStartSize( math.Rand(1.9, 3.8)*sizeMult )
    particle:SetEndSize(0)
    particle:SetStartLength( length*0.45*sizeMult )
    particle:SetEndLength( length*sizeMult )
    particle:SetGravity( Vector(0,0,-500) )
    particle:SetCollide( true )
    --particle:SetVelocity( self.Entity:GetVelocity() )

    -- particle:SetCollideCallback(function( _, collidepos, normal )

    --     local particle3D = 


    -- end)

    self.NextEmit = CurTime()+math.Rand(0.15, 0.35)
    return true

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render()

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- local nextEffect = CurTime()

-- hook.Add("Think", "ThinkBruhTest", function() if LocalPlayer():KeyDown(IN_ATTACK2) && nextEffect < CurTime() then

--     if true then return end

--     local effectdata = EffectData()
--     effectdata:SetEntity(LocalPlayer())
--     effectdata:SetAttachment(0)
--     util.Effect("zippygore3_blood_gush", effectdata, true, true)

--     nextEffect = CurTime()+0.25

-- end end)