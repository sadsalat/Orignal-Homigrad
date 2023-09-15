sound.list = {}
local list = sound.list

local meta = {}

local globalEyePos = EyePos()

function meta:Stop()
    if self:IsPlaying() then
        self.snd:Stop()
        self.snd = nil
    end

    if IsValid(self.model) then
        self.model:Remove()
        self.model = nil
    end
end

function meta:IsValid() return not self.remove end

function meta:IsPlaying()
    return self.snd and self.snd:IsPlaying()
end

local SysTime,SoundDuration = SysTime,SoundDuration
local string_sub = string.sub

function meta:Play(name)
    self:Stop()

    if not IsValid(self.model) then
        self.model = ClientsideModel("models/hunter/plates/plate.mdl")
        self.model:SetNoDraw(true)
    end

    if name then self.sndPath = name else name = self.sndPath end
    
    self:Think()
    self.snd = CreateSound(self.model,self.sndPath)

    self.snd:SetSoundLevel(150)
    self:Apply(true)

    self.snd:PlayEx(self.volumeTrue,self.pitch * 100)

    return true
end

local Remove = FindMetaTable("Entity")
function meta:Remove()
    if self.remove then return end
    self:Stop()
    self.remove = true
    list[self.id] = nil
end

local clamp = math.Clamp

local function getDSP(pos,alwaysView)
    local count = sound.InTheWall(pos,3,16)

    if count == 3 then
        return 0
    elseif count == 2 then
        return 15
    elseif count == 1 then
        return 16
    else
        return alwaysView and 16
    end
end

function meta:Think()
    local pos
    local parent = self.parent
    if parent then
        pos = parent:GetPos()
        pos:Add(self.pos)
    else
        pos = self.pos
    end

    local dsp = getDSP(pos,self.alwaysView)

    if dsp then
        self.dsp = dsp
    else
        self.volumeTrue = 0

        return
    end

    local diff = (globalEyePos - pos)
    local dir = diff:GetNormalized()
    local dis = diff:Length()
    local disEnd = self.dis

    local k = 1 - clamp(dis / disEnd,0,1)

    local disK = self.disK

    if k < disK then
        k = k / disK

        self.volumeTrue = k * self.volume
        dis = dis - self.disFadeout * (1 - k)
    else
        self.volumeTrue = self.volume
    end

    if self.fadeStart then
        local k = (self.fadeStart + self.fadeDelay - SysTime()) / self.fadeDelay

        self.volumeTrue = self.volumeTrue * k
        
        if k <= 0 then
            self.remove = nil
            self:Remove()

            return
        end
    end

    dir:Mul(dis)

    self.modelPos = pos + dir
end

function meta:Apply(dontEquial)
    if not IsValid(self.model) then return end

    self.model:SetRenderOrigin((self.modelPos or Vector()) + VectorRand(-0.1,0.1))

    if dontEquial or self.oldDsp ~= self.dsp then
        self.oldDsp = self.dsp

        self.snd:SetDSP(self.dsp)
    end

    self.snd:ChangePitch(self.pitch * 100,0.1)
    self.snd:ChangeVolume(self.volumeTrue,0.1)
end

function meta:FadeOut(value)
    self.remove = true
    self.IsValid = nil
    self.fadeStart = SysTime()
    self.fadeDelay = value
end

sound.count = sound.count or 0

function sound.CreatePoint(id,sndName,pos,dis,disK)
    if not id then
        id = sound.count
        sound.count = sound.count + 1
    end

    local point = list[id]
    if not point then
        point = {}
        list[id] = point

        point.loop = false
        point.pitch = 1
        point.volume = 1
        point.volumeTrue = 1
        point.dsp = 0

        for k,v in pairs(meta) do point[k] = v end

        point.id = id
    end

    point.sndPath = sndName

    if pos then
        if TypeID(pos) == TYPE_ENTITY then point.parent = pos else point.pos = pos end
    end

    if dis == nil then dis = 750 end

    point.fadeStart = nil
    point.IsValid = meta.IsValid
    point.remove = nil
    point.dis = dis
    point.disK = disK or 1
    point.disFadeout = 12
    
    return point
end

local tr = {}
local TraceLine = util.TraceLine
local function filter(ent) return not ent:IsPlayer() and not ent:IsNPC() and not ent:IsRagdoll() end

local PointContents = util.PointContents
local bit_band = bit.band

function sound.InTheWall(pos,count,mul)
    tr.start = pos
    tr.endpos = globalEyePos
    tr.filter = filter

    local dir = globalEyePos - pos
    dir:Normalize()
    dir:Mul(mul)

    local result = TraceLine(tr)

    if result.HitPos:Distance(globalEyePos) <= 32 then return count end
    
    if result.Hit then
        pos = result.HitPos

        for i = 1,count do
            pos:Add(dir)

            if bit_band(PointContents(pos),CONTENTS_EMPTY) then
                count = count - i
                if count <= 0 then return count end

                return sound.InTheWall(pos,count - i + 1,mul)
            end
        end

        return 0
    else
        return count
    end
end

hook.Add("Frame","Sounds",function(pos)
    globalEyePos = pos + VectorRand(-0.0001,0.0001)

    local time = SysTime()

    for id,point in pairs(list) do
        local parent = point.parent
        if parent and not IsValid(parent) then point:Remove() continue end

        if not IsValid(point.model) or not point:IsPlaying() then point:Play() end

        point:Think()
        point:Apply()
    end
end)

function sound.Emit(ent,sndName,level,volume,pitch,dsp)
    local pos = ent:GetPos()
    local _dsp = getDSP(pos)
    if not _dsp then return end

    EmitSound(sndName,pos,ent:EntIndex(),nil,volume,level,nil,pitch,_dsp == 0 and dsp or _dsp)
end

net.Receive("sound",function()
    local packet = net.ReadTable()

    local dsp = getDSP(packet[2])
    if not dsp then return end

    EmitSound(packet[1],packet[2],packet[3],nil,packet[4],packet[5],nil,packet[6],dsp == 0 and packet[7] or dsp)
end)

net.Receive("sound surface",function()
    surface.PlaySound(net.ReadString())
end)

concommand.Add("testsound",function()
     sound.EmitSound("weapons/357_fire2.wav",EyePos())
end)

--бесплоезный модуль..................................