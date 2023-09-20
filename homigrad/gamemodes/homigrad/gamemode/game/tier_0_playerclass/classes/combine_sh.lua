local CLASS = player.RegClass("combine")

CLASS.main_weapons = {
    "weapon_sar2","weapon_spas12","weapon_mp7"
}

function CLASS.Off(self)
    if CLIENT then return end

    self.isCombine = nil
    self.cantUsePer4ik = nil
end

function CLASS.On(self)
    if CLIENT then return end

    self:SetModel("models/player/combine_soldier.mdl")
    self:SetWalkSpeed(250)
    self:SetRunSpeed(350)

    self:SetHealth(150)
    self:SetMaxHealth(150)

    --tdm.GiveSwep(self,CLASS.main_weapons,8)

    self:Give("weapon_hands")
    self:Give("weapon_hg_hl2")

    self.isCombine = true
    self.cantUsePer4ik = true

    self:EmitSound("radio/go.wav")
end

function CLASS.PlayerFootstep(self,pos,foot,name,volume,filter)
    if SERVER then return true end

    sound.Play(Sound("npc/combine_soldier/gear" .. math.random(1,6) .. ".wav"),pos,75,100,1)
    sound.Play(name,pos,75,100,volume)

	return true
end

local function getList(self)
    local list = {}

    for i,ply in RandomPairs(player.GetAll()) do
        if ply == self or not ply.isCombine then continue end
        
        local pos = ply:EyePos()
        local deathPos = self:GetPos()

        if pos:Distance(deathPos) > 1000 then continue end

        local trace = {start = pos}
        trace.endpos = deathPos
        trace.filter = ply
        
        if util.TraceLine(trace).HitPos:Distance(deathPos) <= 512 then
            list[#list + 1] = ply
        end
    end

    return list
end

function CLASS.PlayerDeath(self)
    sound.Play(Sound("npc/overwatch/radiovoice/die" .. math.random(1,3) .. ".wav"),self:GetPos())
    --self:EmitSound("npc/combine_soldier/die" .. math.random(1,3) .. ".wav")

    for i,ply in RandomPairs(getList(self)) do
        ply:EmitSound(Sound("npc/combine_soldier/vo/ripcordripcord.wav"))

        break
    end

    self:SetPlayerClass()
end

function CLASS.Think(self)
end

function CLASS.PlayerStartVoice(self)
    for i,ply in pairs(player.GetAll()) do
        if not ply.isCombine then continue end

        ply:EmitSound("npc/combine_soldier/vo/on" .. math.random(1,3) .. ".wav")
    end
end

function CLASS.PlayerEndVoice(self)
    for i,ply in pairs(player.GetAll()) do
        if not ply.isCombine then continue end

        ply:EmitSound("npc/combine_soldier/vo/off" .. math.random(1,3) .. ".wav")
    end
end

function CLASS.CanLisenOutput(output,input,isChat)
    if input.isCombine then return true end
end

function CLASS.CanLisenInput(input,output,isChat)
    if not output:Alive() then return false end
end

function CLASS.HomigradDamage(self,hitGroup,dmgInfo,rag)
    if (self.delaysoundpain or 0) > CurTime() then
        self.delaysoundpain = CurTime() + math.Rand(0.25,0.5)

        self:EmitSound("npc/combine_soldier/pain" .. math.random(1,3) .. ".wav")
    end
end

function CLASS.GuiltLogic(self,ply)
    return false
end