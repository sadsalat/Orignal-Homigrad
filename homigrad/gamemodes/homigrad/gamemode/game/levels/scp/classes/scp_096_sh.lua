local CLASS = player.RegClass("scp096")

local vecZero = Vector(0,0,0)

local function getSound(self,name,sndName)
    self[name] = sound.CreatePoint("scp096_" .. self:EntIndex() .. "_" .. name,sndName,vecZero)
    self[name].parent = self 
    self[name].loop = true

    return self[name]
end

local function muteSound(self,name)
    if IsValid(self[name]) then self[name]:Remove() end
end

function CLASS:Off()
    self.isSCP = nil

    if CLIENT then
        muteSound(self,"sndCry")
        muteSound(self,"sndScream")
        muteSound(self,"sndRuning")

        return
    end

    self:SetNWString("SCP","")
    self:GodDisable()
end

function CLASS:On()
    self.isSCP = 096

    self.playersView = {}

    if CLIENT then return end

    self:SetNWString("SCP","096")
    self:SetNWInt("State",0)
    self:GodEnable()

    self:SetModel("models/player/scp096.mdl")
    self:SetWalkSpeed(250)
    self:SetRunSpeed(250)
    self:SetLadderClimbSpeed(400)
    
    self:GetPhysicsObject():SetMass(5000)

    self:SetPlayerColor(Vector(1,0,0))
end

function CLASS:PlayerDeath() self:SetPlayerClass() end

local max,min = math.max,math.min

local scp096Here
local scp096Volume = 0

local abs,cos = math.abs,math.cos
local random,Rand = math.random,math.Rand
local Clamp = math.Clamp
local roll = 0

if CLIENT then
    local Lerp = 0

    hook.Add("CalcAddFOV","SCP096",function()
        ADDFOV = ADDFOV - 45 * Lerp
        ADDROLL = ADDROLL + cos(CurTime() / 10) * 15 * Lerp
    end)
    
    local Round = math.Round

    local SetDrawColor = surface.SetDrawColor
    local GradientUp,GradientDown = draw.GradientUp,draw.GradientDown
    local SetBG,BGScale = surface.SetBG,draw.BGScale

    hook.Add("HUDPaint","SCP096",function()
        if LocalPlayer().isSCP then return end

        local w,h,time = ScrW(),ScrH(),CurTime()

        SetDrawColor(0,0,0,255)
        GradientUp(0,0,w,h / 4 * Lerp)

        local size = h / 3 * Lerp
        GradientUp(0,0,w,size)
        GradientDown(0,h - size,w,size + 1)

        GradientUp(0,0,w,size * 2)
        GradientDown(0,h - size,w,size * 2 + 1)

        SetDrawColor(0,0,0,Lerp * 200)

        for i = 1,random(4,5) do
            SetBG("points" .. random(4,6) .. "0")
            local x,y = random(0,w),random(0,h)
            BGScale(-x,-y,w + x,h + y,Clamp(abs(cos(time * 10 + Rand(-1,1))) * 25,10,25))
        end
    end)

    function CLASS.GlobalThink(list)
        if (scp096Here or 0) > 0 then
            CLASS.ScaredSound = sound.CreatePoint("scp096scaredmusic","sfx/music/096chase.mp3",vecZero)
            CLASS.ScaredSound.loop = true
            CLASS.ScaredSound.parent = LocalPlayer()
        else
            if IsValid(CLASS.ScaredSound) then CLASS.ScaredSound:FadeOut(2) end
        end

        local ply = LocalPlayer()

        if ply:Alive() and not ply.isSCP then
            Lerp = LerpFT(0.1,Lerp,scp096Here or scp096Volume)
        else
            Lerp = LerpFT(0.1,Lerp,0)
        end

        scp096Here = nil
        scp096Volume = 0
    end
end

local SCP173 = player.classList.scp173
local CanLook = SCP173.CanLook

function CLASS.Looking(self)
    local players = {}

    for i,ply in pairs(player.GetAll()) do
        if SCP173.IgnoreLook(self,ply) then continue end

        if CanLook(self,ply:EyePos()) then players[#players + 1] = ply end
    end

    return players
end

local killDis = 85

function CLASS:Move(mv)
    local state = self:GetNWInt("State")
    local value = (state == 0 and 125) or (state == 1 and 0) or (state == 2 and 1000)

    mv:SetMaxSpeed(value)
    mv:SetMaxClientSpeed(value)
    self:SetJumpPower(state == 2 and 512 or 0)
end

if SERVER then
    util.AddNetworkString("scp096 players")
else
    net.Receive("scp096 players",function()
        LocalPlayer().playersView = net.ReadTable()
    end)
end

function CLASS:Think()
    local isClient = SERVER or self == LocalPlayer()

    local state,oldState = self:GetNWInt("State"),self.oldState
    self.oldState = state

    if oldState ~= state then
        if CLIENT then
            muteSound(self,"sndCry")
            muteSound(self,"sndScream")
            muteSound(self,"sndRuning")
        end

        if SERVER and state == 0 then
            for k in pairs(self.playersView) do self.playersView[k] = nil end
        end
    end

    if SERVER then
        local pos = self:GetPos()

        for i,ply in pairs(CLASS.Looking(self)) do
            if ply:GetPos():Distance(pos) <= 35 or self.playersView[ply] then continue end
            self.playersView[ply] = true

            if SERVER then
                sound.EmitSurface(ply,"sfx/scp/096/triggered.mp3")

                net.Start("scp096 players")
                net.WriteTable(self.playersView)
                net.Send(self)
            end

            if state == 0 then
                if self:GetNWFloat("Panic",0) > CurTime() then
                    self:SetNWFloat("Panic",CurTime() + 60)
                    self:SetNWInt("State",2)
                else
                    self:SetNWInt("State",1)
                    self:SetNWFloat("angryStart",CurTime())
                    self:SetNWFloat("angryDelay",5)
                end
            end
        end
    end

    if state == 0 then
        if CLIENT then
            local snd = getSound(self,"sndCry","sfx/music/096.mp3")
            snd.disK = 0.7

            if self:GetNWFloat("Panic",0) > CurTime() then
                snd.alwaysView = true

                scp096Here = snd.volumeTrue
            else
                snd.alwaysView = false

                if not isClient and snd.dsp == 0 then scp096Here = snd.volumeTrue end
            end
        end
    elseif state == 1 then
        local angryStart,angryDelay = self:GetNWFloat("angryStart"),self:GetNWFloat("angryDelay")

        if CLIENT then
            local snd = getSound(self,"sndCry","sfx/music/096angered.mp3")
            local k = 1 - max(angryStart + angryDelay - CurTime(),0) / angryDelay
            snd.dis = 8000 * max(k,0.2)
            snd.alwaysView = true

            if not isClient and scp096Volume < snd.volumeTrue and snd.dsp == 0 then scp096Volume = snd.volumeTrue end
        else
            if angryStart + angryDelay < CurTime() then
                self:SetNWInt("State",2)
            end

            if (self.delaySequencePanic or 0) < CurTime() then
                self.delaySequencePanic = CurTime() + 0.06
                self:SetNWInt("Sequence",random(1,6))
            end
        end
    elseif state == 2 then
        if CLIENT then
            local snd = getSound(self,"sndCry","sfx/scp/096/scream.mp3")
            snd.dis = 2000
            snd.alwaysView = true

            if not isClient and scp096Volume < snd.volumeTrue and snd.dsp == 0 then scp096Volume = snd.volumeTrue end
        else
            local pos = self:GetPos()
            
            if (self.delayHitDoor or 0) < CurTime() then
                self.delayHitDoor = CurTime() + 0.5

                for i,ent in pairs(ents.FindInSphere(self:GetPos(),killDis)) do
                    if not ent:GetNoDraw() and JMod.IsDoor(ent) then
                        ent.hpDoor = ent.hpDoor or 100
                        ent.hpDoor = math.max(ent.hpDoor - 50,0)

                        if ent.hpDoor <= 0 then
                            JMod.BlastThatDoor(ent,self:GetAimVector() * 1024)

                            sound.Emit(ent,"physics/metal/metal_grate_impact_hard" .. random(1,3) .. ".wav",120,1,120)
                            sound.Emit(ent,"physics/metal/metal_sheet_impact_hard" .. random(6,7) .. ".wav",120,1,120)
                        else
                            sound.Emit(ent,"physics/metal/metal_grate_impact_hard" .. random(1,3) .. ".wav",120,90)
                            sound.Emit(ent,"physics/metal/metal_sheet_impact_hard" .. random(6,7) .. ".wav",120,90)
                        end
                    end
                end
            end

            for i,ply in pairs(player.GetAll()) do
                if SCP173.IgnoreLook(self,ply) or not self.playersView[ply] or ply:GetPos():Distance(pos) > killDis then continue end

                sound.Emit(ply,"sfx/scp/173/necksnap1.mp3")
                sound.Emit(ply,"sfx/scp/173/necksnap3.mp3")

                local dmgInfo = DamageInfo()
                dmgInfo:SetAttacker(ply)
                dmgInfo:SetInflictor(self)
                dmgInfo:SetDamage(100)
                dmgInfo:SetDamageForce(Vector(0,0,1) * 1024)

                ply.LastDMGInfo = {ply:LookupBone("ValveBiped.Bip01_Head1"),dmgInfo}
                ply.LastHitBoneName = "ValveBiped.Bip01_Head1"
                ply.LastHitGroup = HITGROUP_HEAD
                ply:SetVelocity(Vector(0,0,-1000))

                ply:Kill()
                self.playersView[ply] = nil

                net.Start("scp096 players")
                net.WriteTable(self.playersView)
                net.Send(self)
            end

            local have
            for k in pairs(self.playersView) do have = true break end
            if not have then
                self:SetNWFloat("Panic",CurTime() + 60)
                self:SetNWInt("State",0)
            end
        end
    end
end

function CLASS:GuiltLogic(ply) return false end
function CLASS:ShouldFake() return false end
function CLASS:ShouldUpWeapon() return self:GetMoveType() == MOVETYPE_NOCLIP end
function CLASS:ShouldUpItem() return self:GetMoveType() == MOVETYPE_NOCLIP end
function CLASS:JModArmorEquip() return false end

function CLASS:CalcMainActivity(vel)
    local state = self:GetNWInt("State",0)
    vel = vel:Length()

    if state == 0 then
        if vel < 25 then
            return ACT_MP_WALK,225
        else
            return ACT_MP_WALK,-1
        end
    elseif state == 1 then
        return ACT_MP_WALK,236 + self:GetNWInt("Sequence",0)
    elseif state == 2 then
        return ACT_MP_RUN,408
    end
end

function CLASS:CanUseSpectateHUD()
    if self:GetNWInt("State") == 0 and self:GetNWFloat("Panic",0) < CurTime() then return true end

    return false
end

local white = Color(255,255,255)

local keyOld
local empty = {}

function CLASS:HUDPaint()
    if not CLASS.CanUseSpectateHUD(self) then
        local key = self:KeyDown(IN_WALK)
        if keyOld ~= key and key then
            SpectateHideNick = not SpectateHideNick

            chat.AddText("Ники игроков: " .. tostring(not SpectateHideNick))
        end
        keyOld = key
    end

    if not SpectateHideNick then return end

    for ply in pairs(self.playersView or empty) do
        if not IsValid(ply) then self.playersView[ply] = nil continue end

        local pos = ply:GetPos():ToScreen()
        if not pos.visible then continue end

        draw.SimpleText(ply:Nick(),"HomigradFont",pos.x,pos.y,white,TEXT_ALIGN_CENTER,TEXT_ALING_CENTER)
    end
end

CLASS.color = Color(255,0,0)

function CLASS:TeamName()
	return "SCP096",CLASS.color
end

CLASS.CanLisenOutput = SCP173.CanLisenOutput