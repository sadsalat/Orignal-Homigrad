include("shared.lua")

local green,red = Color(0,255,0),Color(255,0,0)

function SWEP:PrimaryAttack()
    self:SetHoldType("melee")
    self:SetNextPrimaryFire(CurTime() + 0.51)

    local owner = self:GetOwner()
    owner:SetAnimation(PLAYER_ATTACK1)

    owner:EmitSound("weapons/stunstick/stunstick_swing1.wav")

    self.delayNormalType = CurTime() + 5
    self:SetColor(red)

    local tr = {start = owner:EyePos()}
    local dir = Vector(75,0,0)
    dir:Rotate(owner:EyeAngles())
    tr.endpos = tr.start + dir

    local ent = tr.Entity
    if not IsValid(ent) or not ent:IsPlayer() or ent:GetNWBool("DarkRPArest") then return end

    darkrp.Arest(ent,true)
end

function SWEP:SecondaryAttack()
    self:SetHoldType("melee")
    self:SetNextSecondaryFire(CurTime() + 0.51)

    local owner = self:GetOwner()
    owner:SetAnimation(PLAYER_ATTACK1)

    owner:EmitSound("weapons/stunstick/stunstick_swing1.wav",75,125)

    self.delayNormalType = CurTime() + 5
    self:SetColor(green)

    local tr = {start = owner:EyePos()}
    local dir = Vector(75,0,0)
    dir:Rotate(owner:EyeAngles())
    tr.endpos = tr.start + dir

    local ent = tr.Entity
    if not IsValid(ent) or not ent:IsPlayer() or not ent:GetNWBool("DarkRPArest") then return end

    darkrp.Arest(ent,false)
end

function SWEP:Reload()
    if self.reloadNext > CurTime() then return end
    self.reloadNext = CurTime() + 0.5
    self:SetHoldType("melee")
    self.delayNormalType = CurTime() + 0.5

    self:GetOwner():EmitSound("weapons/stunstick/spark" .. math.random(1,3) .. ".wav")
end

function SWEP:Think()
    if self.delayNormalType and self.delayNormalType < CurTime() then
        self.delayNormalType = nil

        self:SetHoldType("normal")
    end
end

function SWEP:Holster()
    self.delayNormalType = nil

    return true
end

function darkrp.Arest(ply,value)
    local list = ReadDataMap("darkrp_jail")
    if #list == 0 then ply:ChatPrint("Скажи админам что нету darkrp_jail point") return end

    local value = ply:GetNWFloat("Arest")

    if value - CurTime() <= 0 then
        ply:SetNWFloat("Arest",CurTime() + darkrp.ArestTime)

        local point = table.Random(list)
        ply:SetPos(point[1])
    else
        ply:SetNWFloat("Arest",false)

        local point = table.Random(homicide.Spawns())
        ply:SetPoint(point[1])
    end
end
