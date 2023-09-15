SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Aimbot BHop"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "для лохов"
SWEP.Category 				= "Фан"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 1
SWEP.SlotPos				= -100
SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true

SWEP.WorldModel				= "models/weapons/w_pist_deagle.mdl"
SWEP.ViewModel				= "models/weapons/v_pist_deagle.mdl"

SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 75

function SWEP:Initialize()

end

function SWEP:Reload() end

function SWEP:CanPrimaryAttack() return true end

function SWEP:PrimaryAttack()
    if (self.delay or 0) > CurTime() then return end
    self.delay = CurTime() + 0.25

    local owner = self:GetOwner()

    owner:LagCompensation(true)

    local bullet = {}
    bullet.Num 			= 1
    bullet.Src 			= owner:GetShootPos()
    bullet.Dir 			= owner:GetAimVector()
    bullet.Spread 		= Vector(0,0,0)
    bullet.Force		= 1000
    bullet.Damage		= 1000
    bullet.HullSize     = 2
    bullet.AmmoType     = "ar2"
    bullet.Attacker 	= owner
    bullet.Tracer       = 1
    bullet.TracerName   = "Tracer"
    bullet.IgnoreEntity = owner

    if SERVER then
        bullet.Callback = function(ent,tr)
            local ent = tr.Entity
            if ent == game.GetWorld() or not IsValid(ent) then return end

            if JMod.IsDoor(ent) and not ent:GetNoDraw() then
                JMod.BlastThatDoor(ent,owner:GetAimVector() * 1024)

                sound.Emit(ent,"physics/metal/metal_grate_impact_hard" .. math.random(1,3) .. ".wav",120,1,120)
                sound.Emit(ent,"physics/metal/metal_sheet_impact_hard" .. math.random(6,7) .. ".wav",120,1,120)
            end
        end
    end

    self:FireBullets(bullet)
    
    owner:LagCompensation(false)

    if SERVER then
        sound.Emit(self,"pwb/weapons/m590a1/shoot.wav",120,2,75,owner,2)
    else
        sound.Emit(self,"pwb/weapons/m590a1/shoot.wav",120,2,75,2)

        self.eyePunch = (self.eyePunch or Angle()) - Angle(0.5,0,0)
        owner:SetEyeAngles(owner:EyeAngles() + self.eyePunch)
    end

    self:ShootEffects()
end

function SWEP:SecondaryAttack()
    if (self.delay or 0) > CurTime() then return end

    local owner = self:GetOwner()

    local shootPos = owner:GetShootPos()
    local dir
    local plyTarget,disTarget

    for i,ply in pairs(player.GetAll()) do
        if ply:GetMoveType() == MOVETYPE_NOCLIP or not ply:Alive() or ply:HasGodMode() then continue end

        local tr = {}
        tr.start = shootPos
        tr.endpos = ply:EyePos()
        tr.mask = MASK_SHOT
        tr.filter = owner
        
        if util.TraceLine(tr).Entity ~= ply then continue end

        local dis = ply:GetPos():Distance(shootPos)
        if not plyTarget or disTarget < dis then
            plyTarget = ply
            disTarget = dis
        end
    end

    if plyTarget then
        local matrix = plyTarget:LookupBone("ValveBiped.Bip01_Head1")
        local pos
        if matrix then
            matrix = plyTarget:GetBoneMatrix(matrix)
            pos = matrix:GetTranslation()
        else
            pos = plyTarget:GetPos() + plyTarget:OBBCenter()
        end

        dir = pos - shootPos
        dir:Normalize()
    else
        return
    end

    self.delay = CurTime() + 0.05

    local bullet = {}
    bullet.Num 			= 1
    bullet.Src 			= owner:GetShootPos()
    bullet.Dir 			= dir
    bullet.Spread 		= Vector(0,0,0)
    bullet.Force		= 1000
    bullet.Damage		= 1000
    bullet.HullSize     = 2
    bullet.AmmoType     = "ar2"
    bullet.Attacker 	= owner
    bullet.Tracer       = 1
    bullet.TracerName   = "Tracer"
    bullet.IgnoreEntity = owner

    if SERVER then
        bullet.Callback = function(ent,tr)
            local ent = tr.Entity
            if ent == game.GetWorld() or not IsValid(ent) then return end

            if JMod.IsDoor(ent) and not ent:GetNoDraw() then
                JMod.BlastThatDoor(ent,owner:GetAimVector() * 1024)

                sound.Emit(ent,"physics/metal/metal_grate_impact_hard" .. math.random(1,3) .. ".wav",120,1,120)
                sound.Emit(ent,"physics/metal/metal_sheet_impact_hard" .. math.random(6,7) .. ".wav",120,1,120)
            end
        end
    end

    self:FireBullets(bullet)

    if SERVER then
        sound.Emit(self,"pwb/weapons/m590a1/shoot.wav",120,2,75,owner,2)
        plyTarget:Kill()
    else
        sound.Emit(self,"pwb/weapons/m590a1/shoot.wav",120,2,75,2)

        self.eyePunch = (self.eyePunch or Angle()) - Angle(0.5,0,0)
        owner:SetEyeAngles(owner:EyeAngles() + self.eyePunch)
    end

    self:ShootEffects()
end

if CLIENT then
    function SWEP:Deploy()
        self:SendWeaponAnim(ACT_VM_DRAW)

        RunConsoleCommand("-jump")
        timer.Remove("Bhop")
    end

    function SWEP:Think()
        if input.IsKeyDown(KEY_SPACE) then
            if LocalPlayer():IsOnGround() then
                RunConsoleCommand("+jump")

                timer.Create("Bhop",0,0,function() RunConsoleCommand("-jump") end)
            end
        else
            timer.Remove("Bhop")

            RunConsoleCommand("-jump")
        end

        timer.Remove("rubatpidor")
        timer.Create("rubatpidor",0.25,1,function()
            RunConsoleCommand("-jump")
        end)

        local owner = self:GetOwner()
        self.eyePunch = LerpAngleFT(0.25,(self.eyePunch or Angle()),Angle())
        owner:SetEyeAngles(owner:EyeAngles() + self.eyePunch)
    end

    local view = {}
    hook.Add("PreCalcView","Aimbot Bhop",function(ply,pos,ang,fov)
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_aimbot_machine" or ply ~= GetViewEntity() then return end

        view.origin = ply:EyePos()
        view.angles = ply:EyeAngles()
        view.fov = fov
        view.drawviewmodel = true

        return view
    end)

    local white = Color(255,255,255)

    function SWEP:DrawHUD()
        draw.RoundedBox(0,ScrW() / 2 - 2,ScrH() / 2 - 2,4,4,white)
    end
else
    function SWEP:Think()
        local owner = self:GetOwner()
        owner.stamina = 100
        owner.pain = 0
    end

    function SWEP:Deploy()
        self.owner = self:GetOwner()

        self.runSpeed = self.owner:GetRunSpeed()
        self.walkSpeed = self.owner:GetWalkSpeed()
        self.maxSpeed = self.owner:GetMaxSpeed()
        self.owner:SetRunSpeed(500)
        self.owner:SetWalkSpeed(300)
        self.owner:SetMaxSpeed(500)

        return
    end

    function SWEP:Holster()
        self.owner = self:GetOwner()

        self.owner:SetRunSpeed(self.runSpeed)
        self.owner:SetWalkSpeed(self.walkSpeed)
        self.owner:SetMaxSpeed(self.maxSpeed)

        return true
    end

    hook.Add("Fake","Bhop",function(ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_aimbot_machine" then return false end
    end)
end