local CLASS = player.RegClass("scp173")

function CLASS:Off()
    self.isSCP = nil

    if CLIENT then return end

    self:GodDisable()
    if IsValid(self.FootstepSound) then self.FootstepSound:Remove() end
end

function CLASS:On()
    self.isSCP = 173

    if CLIENT then return end

    self:SetModel("models/scp/173.mdl")
    self:SetRunSpeed(2000)
    self:SetWalkSpeed(750)
    self:AllowFlashlight(false)

    self:GodEnable()

    for i,wep in pairs(self:GetWeapons()) do
        wep:Remove()
    end

    self:GetPhysicsObject():SetMass(5000)
    self.screamPlayers = {}

    self:SetPlayerColor(Vector(1,0,0))
end

function CLASS:PlayerFootstep(pos,foot,name,volume,filter) return true end

function CLASS:PlayerDeath() self:SetPlayerClass() end

local vecZero = Vector(0,0,0)

function CLASS:Move(mv)
    mv:SetFinalJumpVelocity(vecZero)

    if not self.canMove then
        mv:SetMaxSpeed(0)
        mv:SetMaxClientSpeed(0)
    end
end

local abs = math.abs

function CLASS.CanLook(ply,pos)
    local tr = {}
    local plyPos = ply:EyePos()
    tr.start = pos
    tr.endpos = plyPos
    tr.endpos = tr.endpos + (tr.endpos - tr.start):GetNormalized() * 128
    tr.filter = function(ent)
        return ent == ply or (not ent:IsPlayer() and not ent:IsNPC() and not ent:IsRagdoll())
    end
    tr.mask = MASK_SHOT

    if util.TraceLine(tr).Entity ~= ply then return end

    local diff = pos - plyPos
    diff = ply:GetAimVector():Dot(diff) / diff:Length()

    return diff >= 0
end

function CLASS.IgnoreLook(self,ply)
    if self:GetMoveType() == MOVETYPE_NOCLIP or ply.isSCP or ply:HasGodMode() or not ply:Alive() or ply == self then
        local value = GetGlobalVar("Fog Dis",false)
        if value and self:GetPos():Distance(ply:GetPos()) > value then return false end

        return true--ufff
    end
end

function CLASS.Looking(self,pos)
    local players = {}

    for i,ply in pairs(player.GetAll()) do
        if CLASS.IgnoreLook(self,ply) then continue end

        if CLASS.CanLook(ply,pos) then players[#players + 1] = ply end
    end

    return players
end

local blinkTime = 0.25
local blinkDelay = 3

if SERVER then
    util.AddNetworkString("scp173 blink")
    util.AddNetworkString("scp173 blink hold")
end

function CLASS:MoveLogic(players)
    if #players == 0 then return true end
    local time = CurTime()

    local access = true

    for i,ply in pairs(players) do
        if ply:KeyDown(IN_WALK) then
            if SERVER and not ply.scp173Hold then
                ply.scp173Hold = true

                net.Start("scp173 blink hold")
                net.Send(ply)
            end

            continue
        elseif ply.scp173Hold or (ply.scp173Start or 0) + (ply.scp173Delay or 0) < time then
            ply.scp173Hold = nil

            ply.scp173Delay = ply.scp173Delay or 0
            
            local noblink
            if not (not ply.scp173Start or ply.scp173Start + ply.scp173Delay + 0.25 < time) then
                ply.scp173Delay = blinkDelay - math.Rand(-0.25,0.25)
            else
                noblink = true
            end

            ply.scp173Start = time

            if SERVER then
                net.Start("scp173 blink")
                net.WriteString(tostring(time))
                net.WriteString(tostring(ply.scp173Delay))
                net.WriteBool(noblink)
                net.Send(ply)
            end

            continue
        elseif (ply.scp173Start or 0) + blinkTime > time then
            continue
        end

        access = false
    end

    return access
end

if CLIENT then
    local Open
    local LerpOpen = 0

    local nigger = Color(0,0,0,200)
    local white = Color(255,255,255,200)
    local white2 = Color(255,255,255)

    local SetDrawColor = surface.SetDrawColor
    local DrawRect = surface.DrawRect

    local grtodown = Material("vgui/gradient-u")

    local start,delay = 0,0

    local hold
    local holdK = 0

    local addFov = 0
    local noblink

    net.Receive("scp173 blink",function()
        if start + delay - CurTime() + 0.5 < 0 then
            addFov = 45
        end

        start,delay = Lerp(0.5,tonumber(net.ReadString()),CurTime()),tonumber(net.ReadString())
        hold = false
        holdK = 0

        noblink = net.ReadBool()
    end)

    net.Receive("scp173 blink hold",function()
        hold = true
        holdK = 0
    end)

    hook.Add("CalcAddFOV","SCP173",function(ply)
        ADDFOV = ADDFOV - addFov - 25 * LerpOpen
        addFov = LerpFT(0.025,addFov,0)
    end)

    local max = math.max
    local abs,cos = math.abs,math.cos
    local random,Rand = math.random,math.Rand
    local Clamp = math.Clamp

    local GradientUp,GradientDown = draw.GradientUp,draw.GradientDown
    local SetBG,BGScale = surface.SetBG,draw.BGScale

    hook.Add("HUDPaint","SCP173",function()
        local ply = LocalPlayer()
        if ply.isSCP then return end

        local time = CurTime()

        LerpOpen = LerpFT(0.25,LerpOpen,(start + delay - time + 0.5) / delay >= 0 and 1 or 0)

        if math.Round(LerpOpen,2) == 0 then return end

        local k,k2

        if hold then
            holdK = LerpFT(0.5,holdK,1)

            k = holdK
            k2 = holdK
        else
            k = max(start + delay - time,0) / delay
            k2 = (not noblink and max((start + blinkTime - time) / blinkTime,0) * 3) or 0
        end

        local w,h = ScrW(),ScrH()

        SetDrawColor(0,0,0,255 * LerpOpen)
        DrawRect(0,0,w,h * k2)
        GradientUp(0,h * k2,w,h / 3)

        local kk = abs(cos(CurTime() * 2))
        SetDrawColor(0,0,0,25 * kk)
        GradientUp(0,0,w,h / 4 * kk)

        SetDrawColor(0,0,0,255 * k2)
        DrawRect(0,0,w,h)

        local size = w/ 6

        local y = -100 * (1 - LerpOpen)

        SetDrawColor(nigger)
        DrawRect(w / 2 - size / 2,y + 50,size,15)
        SetDrawColor(white)
        DrawRect(w / 2 - size / 2,y + 50,size * k,15)

        draw.SimpleText("ALT что-бы моргать","HomigradFont",w / 2,y + 25,white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        SetDrawColor(0,0,0,25 * LerpOpen)
        for i = 1,random(4,5) do
            SetBG("points" .. random(4,6) .. "0")
            local x,y = random(0,w),random(0,h)
            BGScale(-x,-y,w + x,h + y,Clamp(abs(cos(time * 10 + Rand(-1,1))) * 25,10,10))
        end
    end)

    function CLASS:HUDPaint()
        SetDrawColor(255,255,255,255)
        DrawRect(ScrW() / 2 - 2,ScrH() / 2 - 2,4,4)

        local count = #self.players

        if count > 0 then
            draw.SimpleText("На тебя смотрят : " .. count,"HomigradFont",ScrW() / 2,25,white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
end

local killDis = 82

CLASS.horrorSounds = {
    "sfx/horror/horror1.mp3",
    "sfx/horror/horror10.mp3",
    "sfx/horror/horror2.mp3",
    "sfx/horror/horror14.mp3",
    "sfx/horror/horror9.mp3"
}

function CLASS:Think()
    local isClient = SERVER or LocalPlayer() == self

    if isClient then
        self.EZflashbanged = nil
        self.EZvisionBlur = 0

        local players = CLASS.Looking(self,self:EyePos())
        self.oldPlayers = players

        if SERVER then
            local screamPlayers = self.screamPlayers
            for i,ply in pairs(players) do
                if (screamPlayers[ply] or 0) <= CurTime() then
                    sound.EmitSurface(ply,table.Random(CLASS.horrorSounds))
                end

                screamPlayers[ply] = CurTime() + 30
            end
        end

        self.canMove = CLASS.MoveLogic(self,players)
        self.players = players

        self:SetNWBool("CanMove",self.canMove)

        if self.canMove then
            self.angle = Angle(0,self:EyeAngles()[2],0)

            self:SetNWAngle("Angle",self.angle)
            self:SetNWVector("Pos",self:GetPos())
        else
            self:SetPos(self:GetNWVector("Pos",self:GetPos()))
        end

        if SERVER then
            if self.canMove then
                if self:KeyDown(IN_ATTACK) then
                    for i,ent in pairs(ents.FindInSphere(self:GetPos(),killDis)) do
                        ent:Fire("Open")
                    end

                    for i,ply in pairs(player.GetAll()) do
                        if CLASS.IgnoreLook(self,ply) or ply:GetPos():Distance(self:GetPos()) > killDis then continue end

                        local tr = {}
                        tr.start = self:EyePos()

                        local ent = ply
                        if ply.fake then
                            ent = ply:GetNWEntity("Ragdoll")
                            tr.endpos = ent:GetPos()
                        else
                            tr.endpos = ply:EyePos()
                        end

                        tr.filter = self
                        
                        if util.TraceLine(tr).Entity ~= ent then continue end--shut the fuck up

                        sound.Emit(ply,"sfx/scp/173/necksnap1.mp3")
                        sound.Emit(ply,"sfx/scp/173/necksnap3.mp3")

                        ply:ChatPrint("Твоя шея была сломана.")

                        local dmgInfo = DamageInfo()
                        dmgInfo:SetAttacker(ply)
                        dmgInfo:SetInflictor(self)
                        dmgInfo:SetDamage(100)
                        dmgInfo:SetDamageForce(Vector(0,0,1) * 1024)

                        ply.LastDMGInfo = {ply:LookupBone("ValveBiped.Bip01_Head1"),dmgInfo}
                        ply.LastHitBoneName = "ValveBiped.Bip01_Head1"
                        ply.LastHitGroup = HITGROUP_HEAD

                        ply:Kill()
                    end
                end

                local active = self:KeyDown(IN_ATTACK2)
                if self.oldKey2 ~= active then
                    self.oldKey2 = active

                    if active then
                        local tr = {}
                        tr.start = self:EyePos()
                        tr.endpos = self:EyePos() + self:GetAimVector() * 750
                        tr.filter = self

                        local result = util.TraceLine(tr)
                        local pos = result.HitPos

                        if #CLASS.Looking(self,pos) == 0 then
                            tr.start = pos
                            local mins,maxs = self:GetHull()
                            tr.endpos = pos + Vector(0,0,maxs[3])

                            if not util.TraceLine(tr).Hit then
                                self.oldTPPos = self:GetPos()
                                self:SetPos(pos + result.HitNormal * maxs[2])
                            end
                        end
                    end
                end

                local active = self:KeyDown(IN_RELOAD)
                if self.oldKeyR ~= active then
                    self.oldKeyR = active

                    if active then
                        if self.oldTPPos and self.oldTPPos:Distance(self:GetPos()) <= 750 then
                            if #CLASS.Looking(self,self.oldTPPos) == 0 then
                                self:SetPos(self.oldTPPos)
                            end
                        else
                            self:ChatPrint("Слишком далеко.")
                        end
                    end
                end
            else
                self.oldKey2 = nil
            end
        end
    else
        self.canMove = self:GetNWBool("CanMove")
    end

    if CLIENT then
        self.FootstepSound = sound.CreatePoint("sc173" .. self:EntIndex(),"sfx/scp/173/stonedrag.mp3",vecZero)
        self.FootstepSound.loop = true
        self.FootstepSound.parent = self

        local vel = self:GetVelocity()
        vel = (abs(vel[1]) + abs(vel[2])) / 2

        if self.canMove and self:IsOnGround() and vel > 0 then
            self.FootstepSound.volume = vel / 250
        else
            self.FootstepSound.volume = 0
        end

        local k = math.max(750 - self:GetPos():Distance(EyePos()),0) / 750

        self.FootstepSound.pitch = math.max(k,0.75)
    end
end

local view = {}
local old = Angle()

function CLASS:CalcView(vec,ang,fov)
    if GetViewEntity() ~= LocalPlayer() then return end

    view.origin = (not self.canMove and self:GetNWVector("Pos",self:GetPos()) or self:GetPos()) + Vector(0,0,72)
    view.angles = ang
    view.fov = fov
    view.drawviewer = false

    return view
end

function CLASS:GuiltLogic(ply) return false end
function CLASS:ShouldFake() return false end
function CLASS:ShouldUpWeapon() return self:GetMoveType() == MOVETYPE_NOCLIP end
function CLASS:ShouldUpItem() return self:GetMoveType() == MOVETYPE_NOCLIP end
function CLASS:JModArmorEquip() return false end

CLASS.color = Color(255,0,0)

function CLASS:TeamName()
	return "SCP173",CLASS.color
end

function CLASS:CanUseSpectateHUD() return true end

function CLASS:CanLisenOutput(input)
    if input:Alive() and input:Team() ~= 1002 and not input.isSCP then return false end
end

if SERVER then return end

Model173 = Model173 or ClientsideModel("models/scp/173.mdl",RENDERGROUP_OPAQUE)
Model173:SetNoDraw(true)

function CLASS:PlayerDraw()
    Model173:SetRenderOrigin(not self.canMove and self:GetNWVector("Pos",self:GetPos()) or self:GetPos())
    Model173:SetRenderAngles(self.angle or self:GetNWAngle("Angle"))
    Model173:DrawModel()

    return true
end