SWEP.Base                   = "weapon_base"

SWEP.PrintName 				= "Bhop Machine"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Стань настоящей бхоп машиной без какого-либо опыта"
SWEP.Category 				= "Фан"

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
        sound.Emit(self,"pwb/weapons/m590a1/shoot.wav",120,2,90,owner,2)
    else
        sound.Emit(self,"pwb/weapons/m590a1/shoot.wav",120,2,90,2)

        self.eyePunch = (self.eyePunch or Angle()) - Angle(0.5,0,0)
        owner:SetEyeAngles(owner:EyeAngles() + self.eyePunch)
    end

    self:ShootEffects()
end

function SWEP:SecondaryAttack() end

if CLIENT then
    function SWEP:Deploy()
        self:SendWeaponAnim(ACT_VM_DRAW)

        RunConsoleCommand("-jump")
        timer.Remove("Bhop")
    end

    function SWEP:OwnerChanged()
        self:Holster()
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
    hook.Add("PreCalcView","Bhop",function(ply,pos,ang,fov)
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_bhop_machine" or ply ~= GetViewEntity() then return end

        view.origin = ply:EyePos()
        view.angles = ply:EyeAngles()
        view.fov = fov
        view.drawviewmodel = true

        return view
    end)

    local function stop(ply)
        if ply.bhopMusic then ply.bhopMusic:Stop() ply.bhopMusic = nil end
        timer.Remove("bhop" .. ply:UserID())
    end

    net.Receive("stop музончик",function()
        local ply = net.ReadEntity()
        stop(ply)
    end)

    net.Receive("музончик start",function()
        local ply = net.ReadEntity()
        stop(ply)

        local name = "bhop" .. ply:UserID()
        timer.Create(name,0,0,function()
            if not IsValid(ply) then
                timer.Remove(name)

                if bhopMusic and bhopMusic:IsValid() then bhopMusic:Stop() end
                if bhopBlaa and bhopBlaa:IsValid() then bhopBlaa:Stop() end

                return
            end
            local bhopMusic = ply.bhopMusic
            local bhopBlaa = ply.bhopBlaa

            if bhopMusic and bhopMusic:IsValid() then bhopMusic:SetPos(ply:GetPos()) end
            if bhopBlaa and bhopBlaa:IsValid() then bhopBlaa:SetPos(ply:GetPos()) end

            if not ply:Alive() then
                if bhopMusic and bhopMusic:IsValid() then bhopMusic:Stop() ply.bhopMusic = nil end
                if bhopBlaa and bhopBlaa:IsValid() then bhopBlaa:Stop() ply.bhopBlaa = nil end
            end
        end)

        sound.PlayURL("https://cdn.discordapp.com/attachments/1106621848784994356/1136296503657369741/piaterka-upal-v-bezdnu_WxV5k5O.mp3","3d",function(snd)
            local bhopMusic,wtf
            
            if ply.bhopBlaa and ply.bhopBlaa:IsValid() then return end

            ply.bhopBlaa = snd
            snd:SetVolume(0.1)

            sound.PlayURL("https://cdn.discordapp.com/attachments/1106621848784994356/1136296446233153537/La_Caution_-_The_A_La_Menthe_The_Lazer_Dance_Version_67806664.mp3","3d noblock",function(snd)
                bhopMusic = snd
                bhopMusic:SetVolume(0.1)

                if wtf then
                    bhopMusic:EnableLooping(true)
                    ply.bhopMusic = bhopMusic
                else
                    bhopMusic:Pause()
                end
            end)

            timer.Simple(1,function()
                snd:Stop()

                if bhopMusic then
                    bhopMusic:Play()
                    bhopMusic:EnableLooping(true)
                    ply.bhopMusic = bhopMusic
                else
                    wtf = true
                end
            end)
        end)
    end)

    local white = Color(255,255,255)

    function SWEP:DrawHUD()
        draw.RoundedBox(0,ScrW() / 2 - 2,ScrH() / 2 - 2,4,4,white)
    end
else
    util.AddNetworkString("stop музончик")
    util.AddNetworkString("музончик start")

    function SWEP:Think()
        local owner = self:GetOwner()
        owner.stamina = 100
        owner.pain = 0
    end

    function SWEP:Deploy()
        self:GetOwner() = self:GetOwner()

        self.runSpeed = self:GetOwner():GetRunSpeed()
        self.walkSpeed = self:GetOwner():GetWalkSpeed()
        self.maxSpeed = self:GetOwner():GetMaxSpeed()
        self:GetOwner():SetRunSpeed(500)
        self:GetOwner():SetWalkSpeed(300)
        self:GetOwner():SetMaxSpeed(500)

        if roundActiveName == "bhop" then return end

        net.Start("музончик start")
        net.WriteEntity(self:GetOwner())
        net.Broadcast()

        return
    end

    function SWEP:Holster()
        self:GetOwner() = self:GetOwner()

        self:GetOwner():SetRunSpeed(self.runSpeed)
        self:GetOwner():SetWalkSpeed(self.walkSpeed)
        self:GetOwner():SetMaxSpeed(self.maxSpeed)

        if roundActiveName == "bhop" then return true end

        net.Start("stop музончик")
        net.WriteEntity(self:GetOwner())
        net.Broadcast()

        return true
    end

    function SWEP:OwnerChanged()
        if roundActiveName == "bhop" then return end

        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        self:Holster()
    end

    hook.Add("Fake","Bhop",function(ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_bhop_machine" then return false end
    end)
end