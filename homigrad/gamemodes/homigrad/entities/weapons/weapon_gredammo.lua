SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Установка боеприпасов"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Установить боеприпасы (для миномета) (шайгу)"
SWEP.Category 				= "Разное"

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

SWEP.Slot					= 5
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/Items/BoxSRounds.mdl"
SWEP.WorldModel				= "models/Items/BoxSRounds.mdl"

SWEP.ViewBack = true

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

local function getPos(ply,ent)
    local tr = {}
    tr.start = ply:EyePos()
    local dir = Vector(75,0,0)
    dir:Rotate(ply:EyeAngles())
    tr.endpos = tr.start + dir
    tr.filter = ply

    tr = util.TraceLine(tr)

    return tr.HitPos + Vector(0,0,15),tr.Hit
end

homigrad_weapons = homigrad_weapons or {}

function SWEP:Initialize()
    homigrad_weapons[self] = true
end

if SERVER then
    function SWEP:PrimaryAttack()
        local owner = self:GetOwner()
        local pos,hit = getPos(owner)

        if not hit then return end

        local ent = ents.Create("gred_ammobox")
        ent:SetPos(pos)
        ent:SetAngles(Angle(0,owner:EyeAngles()[2] + 180,0))
        ent:Spawn()
        ent:SetPos(pos)
        ent:GetPhysicsObject():EnableMotion(false)

        owner:EmitSound("garrysmod/balloon_pop_cute.wav")

        self:Remove()
    end

    hook.Add("Gred Ammo Box Use","Grab",function(ent,ply)
        if not ply:KeyDown(IN_WALK) then return end
        if ply:HasWeapon("weapon_gredammo") then return true end

        ply:Give("weapon_gredammo")

        ent:Remove()

        return true
    end)
else
    function SWEP:PrimaryAttack() end

    function SWEP:OnRemove()
        if IsValid(self.model) then self.model:Remove() end
        if IsValid(self.model2) then self.model2:Remove() end
    end

    function SWEP:DrawWorldModel()
        self:SetWeaponHoldType("normal")

        local owner = self:GetOwner()
        if not IsValid(owner) then self:DrawModel() return end

        local mdl = self.worldModel
        if not IsValid(mdl) then
            mdl = ClientsideModel(self.WorldModel)
            mdl:SetNoDraw(true)

            self.worldModel = mdl
        end
        self:CallOnRemove("huyhuy",function() mdl:Remove() end)

        local matrix = self:GetOwner():GetBoneMatrix(11)
        if not matrix then return end

        mdl:SetRenderOrigin(matrix:GetTranslation())
        mdl:SetRenderAngles(matrix:GetAngles() + Angle(90,180,0))
        mdl:DrawModel()
    end

    local green = Color(0,255,0)
    local red = Color(255,0,0)

    function SWEP:Step()
        local owner = self:GetOwner()

        local model = self.model
        if not IsValid(model) then
            model = ClientsideModel("models/Items/ammocrate_smg1.mdl")
            self.model = model
        end

        local pos,hit = getPos(owner)
        model:SetPos(pos)
        model:SetAngles(Angle(0,owner:EyeAngles()[2] + 180,0))

        model:SetColor(hit and green or red)
    end

    function SWEP:Holster()
        if IsValid(self.model) then self.model:Remove() end
    end

    function SWEP:OwnerChanged()
        self:Holster()
    end

    local hg_hint = CreateClientConVar("hg_hint","1",true,false)

    function SWEP:DrawHUD()
        if not hg_hint:GetBool() then return end

        draw.SimpleText("Что-бы забрать зажми 'ALT' и нажми 'E'","DebugFixedSmall",ScrW() / 2,ScrH() - 125,white,TEXT_ALIGN_CENTER)
        draw.SimpleText("Убрать подсказки hg_hint 0","DebugFixedSmall",ScrW() / 2,ScrH() - 100,white,TEXT_ALIGN_CENTER)
    end
end

