include("shared.lua")

local doorPrice = 25

util.AddNetworkString("darkrp door buy")
util.AddNetworkString("darkrp door sell")
util.AddNetworkString("darkrp door add")
util.AddNetworkString("darkrp door menu")

util.AddNetworkString("darkrp anim key")

local function animKeys(ply,usekey)
    net.Start("darkrp anim key")
    net.WriteEntity(ply)
    net.WriteBool(usekey)
    net.Broadcast()

    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM,usekeyand and ACT_GMOD_GESTURE_ITEM_PLACE or ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,true)
end

local function doKnock(ply,sound)
    ply:EmitSound(sound,100,math.random(90,110))

    animKeys(ply,false)
end

local function canUse(ply,ent)
    local buy = ent.buy
    if not buy then return end
    if buy.owner == ply then return true end

    for owner in pairs(buy.cowner) do
        if owner == ply then return true end
    end
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    local ent = owner:GetEyeTraceDis(75).Entity

    if not IsValid(ent) then return end

    if canUse(owner,ent) then
        animKeys(owner,true)
        owner:EmitSound("npc/metropolice/gear" .. math.random(1,6) .. ".wav",75,100)

        ent:Fire("Lock")
    else
        doKnock(owner,"physics/wood/wood_crate_impact_hard2.wav")
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    local ent = owner:GetEyeTraceDis(75).Entity
    if not IsValid(ent) then return end

    if canUse(owner,ent) then
        animKeys(owner,true)
        owner:EmitSound("npc/metropolice/gear" .. math.random(1,6) .. ".wav",75,125)

        ent:Fire("UnLock")
    else
        doKnock(owner,"physics/wood/wood_crate_impact_hard2.wav")
    end
end

net.Receive("darkrp door buy",function(len,ply)
    local ent = net.ReadEntity()
    if ent.buy then return end

    if darkrp.GetMoney(ply) < doorPrice then darkrp.Notify("Недостаточно средств.",NOTIFY_ERROR,5,ply) return end

    ent.buy = {
        owner = ply,
        cowner = {}
    }

    darkrp.Notify("Ты приобрёл дверь.",NOTIFY_GENERIC,5,ply)
end)

net.Receive("darkrp door sell",function(len,ply)
    local ent = net.ReadEntity()
    if not canUse(ply,ent) then return end

    ent.buy = nil

    darkrp.Notify("Ты продал дверь за " .. doorPrice .. "$",NOTIFY_GENERIC,5,ply)
end)

net.Receive("darkrp door add",function(len,ply)
    local ent = net.ReadEntity()
    if not ent.buy or net.owner ~= ply then return end

    local add = net.ReadEntity()

    darkrp.Notify("Ты добавил " .. add:Name(),NOTIFY_GENERIC,5,ply)
    --darkrp.Notify("Тебя добавил " .. ply:Name() .. " в качестве совладельца двери",NOTIFY_GENERIC,5,ply)
end)

function SWEP:Think()
    local owner = self:GetOwner()
    local active = owner:KeyDown(IN_RELOAD)

    if active ~= self.oldReload then
        self.oldReload = active

        local ent = owner:GetEyeTraceDis(75).Entity
        if not IsValid(ent) or not darkrp.doors[ent:GetClass()] then return end

        if ent.buy then
            net.Start("darkrp door menu")
            net.WriteEntity(ent)
            net.WriteInt(doorPrice,16)
            net.WriteTable(ent.buy)
            net.Send(owner)
        else
            net.Start("darkrp door buy")
            net.WriteEntity(ent)
            net.WriteInt(doorPrice,16)
            net.Send(owner)
        end
    end
end