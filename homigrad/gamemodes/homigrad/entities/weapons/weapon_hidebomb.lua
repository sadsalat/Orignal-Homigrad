SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Бомба в пропе"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "ЛКМ, чтобы заложить в проп/поставить; ПКМ, чтобы взорвать"
SWEP.Category 				= "Примочки убийцы"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 4
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/props_junk/cardboard_jox004a.mdl"
SWEP.WorldModel				= "models/props_junk/cardboard_jox004a.mdl"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(20,20,15)
SWEP.dwsItemPos = Vector(0,0,5)

if SERVER then
    local BigFireModels = {
        ["models/props_c17/oildrum001_explosive.mdl"] = true,
        ["models/props_c17/canister_propane01a.mdl"] = true
    }

    local FireModels = {
        ["models/props_junk/gascan001a.mdl"] = true,
        ["models/props_junk/propane_tank001a.mdl"] = true,
        ["models/props_junk/PropaneCanister001a.mdl"] = true,
        ["models/props_junk/metalgascan.mdl"] = true,
        ["models/props_c17/canister01a.mdl"] = true,
        ["models/props_c17/canister02a.mdl"] = true

    }

    local function Bomb(ent)
        local SelfPos,PowerMult,Model = ent:LocalToWorld(ent:OBBCenter()),6,ent:GetModel()

        ent:EmitSound("snds_jack_gmod/plunger.wav")

		timer.Simple(math.Rand(0.3,0.4),function()
            ParticleEffect("pcf_jack_groundsplode_large",SelfPos,vector_up:Angle())
            util.ScreenShake(SelfPos,99999,99999,1,3000)
            sound.Play("BaseExplosionEffect.Sound", SelfPos,120,math.random(90,110))

            for i = 1,4 do
                sound.Play("explosions/doi_ty_01_close.wav",SelfPos,140,math.random(80,110))
            end

            if util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 3 or util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 66 then
                JMod.FragSplosion(ent, SelfPos + Vector(0, 0, 20), 1024, 50, 3500, ent.owner or game.GetWorld())
            end

            timer.Simple(.1,function()
                for i = 1, 5 do
                    local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

                    if Tr.Hit then
                        util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
                    end
                end
            end)

            JMod.WreckBuildings(ent, SelfPos, PowerMult)
            JMod.BlastDoors(ent, SelfPos, PowerMult)

            if BigFireModels[Model] then
                for i = 1, 25 do
                    local FireVec = ( VectorRand() * .3 + Vector(0, 0, .3)):GetNormalized()
                    FireVec.z = FireVec.z / 2
                    local Flame = ents.Create("ent_jack_gmod_eznapalm")
                    Flame:SetPos(SelfPos + Vector(0, 0, 50))
                    Flame:SetAngles(FireVec:Angle())
                    Flame:SetOwner(game.GetWorld())
                    JMod.SetOwner(Flame, game.GetWorld())
                    Flame.SpeedMul = 0.25
                    Flame.Creator = game.GetWorld()
                    Flame.HighVisuals = true
                    Flame:Spawn()
                    Flame:Activate()
                end
            elseif FireModels[Model] then
                for i = 1, 7 do
                    local FireVec = ( VectorRand() * .3 + Vector(0, 0, .3)):GetNormalized()
                    FireVec.z = FireVec.z / 2
                    local Flame = ents.Create("ent_jack_gmod_eznapalm")
                    Flame:SetPos(SelfPos + Vector(0, 0, 50))
                    Flame:SetAngles(FireVec:Angle())
                    Flame:SetOwner(game.GetWorld())
                    JMod.SetOwner(Flame, game.GetWorld())
                    Flame.SpeedMul = 0.25
                    Flame.Creator = game.GetWorld()
                    Flame.HighVisuals = true
                    Flame:Spawn()
                    Flame:Activate()
                end
            end

            if IsValid(ent) then
                ent:RemoveCallOnRemove("homigrad-bomb")
                --if RagdollOwner(ent) then RagdollOwner(ent):KillSilent() end
                ent:Remove()
            end
            timer.Simple(0,function()
                local ZaWarudo = game.GetWorld()
                local Infl, Att = (IsValid(ent) and ent) or ZaWarudo, (IsValid(ent) and IsValid(ent.owner) and ent.owner) or (IsValid(ent) and ent) or ZaWarudo
                util.BlastDamage(Infl,Att,SelfPos,60 * PowerMult,120 * PowerMult)

                --util.BlastDamage(Infl,Att,SelfPos,20 * PowerMult,1000 * PowerMult)
            end)
		end)
        if IsValid(ent.parentBomb) then ent.parentBomb:Remove() end
    end

    function SWEP:Initialize()
        self:SetHoldType("normal")
        --self:SetNWBool("hasbomb",false)
    end

    --local cyka = {}

    function SWEP:PrimaryAttack()
        local owner = self:GetOwner()
        if IsValid(owner.bomb) then return end

        local tr = {}
        tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos
        local dir = Vector(1,0,0)
        dir:Rotate(owner:EyeAngles())
        tr.endpos = tr.start + dir * 75
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity
        --owner:ChatPrint(ent:GetMaterialType())

        if not IsValid(ent) then
            ent = ents.Create("prop_physics")
            ent:SetModel("models/props_junk/cardboard_box004a.mdl")

            ent:SetPos(traceResult.HitPos)
            ent:Spawn()
        end

        self:GetOwner().gg = true

        owner = ent
        self:GetOwner().bomb = owner
        ent.parentBomb = self
        ent.owner = self:GetOwner()
        ent:CallOnRemove("homigrad-bomb",Bomb)
        ent:EmitSound("buttons/button24.wav",75,50)
        self:SetNWBool("hasbomb",true)
    end

    function SWEP:SecondaryAttack()
        --local bomb = cyka[self:GetOwner()]
        if not IsValid(self:GetOwner().bomb) then return end

        Bomb(self:GetOwner().bomb)
        self:GetOwner().bomb = nil
        self:Remove()
        --cyka[self:GetOwner()] = nil
    end
else
    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()

        if not IsValid(owner) then self:DrawModel() return end
        --if self:GetNWBool("hasbomb") then return end

        self.mdl = self.mdl or false
        if not IsValid(self.mdl) then
            self.mdl = ClientsideModel("models/props_junk/cardboard_jox004a.mdl")
            self.mdl:SetNoDraw(true)
            self.mdl:SetModelScale(0.5)
        end
        self:CallOnRemove("huyhuy",function() self.mdl:Remove() end)
        local matrix = self:GetOwner():GetBoneMatrix(11)
        if not matrix then return end

        self.mdl:SetRenderOrigin(matrix:GetTranslation()+matrix:GetAngles():Forward()*3+matrix:GetAngles():Right()*3)
        self.mdl:SetRenderAngles(matrix:GetAngles())
        self.mdl:DrawModel()
    end
    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        local tr = {}
        tr.start = owner:GetAttachment(owner:LookupAttachment("eyes")).Pos
        local dir = Vector(1,0,0)
        dir:Rotate(owner:EyeAngles())
        tr.endpos = tr.start + dir * 75
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity

        if not IsValid(ent) then
            local hit = traceResult.Hit and 1 or 0
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
            draw.NoTexture()
            Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
        else
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255))
            draw.NoTexture()
            Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
            draw.DrawText( "Заложить бомбу "..tostring((util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 3 or util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 66) and "в металлический проп" or ""), "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, color_white, TEXT_ALIGN_CENTER )
        end
    end
end