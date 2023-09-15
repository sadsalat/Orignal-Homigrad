include("shared.lua")

homigrad_weapons = homigrad_weapons or {}

function SWEP:Initialize()
    self:SetHoldType("normal")

    homigrad_weapons[self] = true

    self.voiceSpeak = 0
    self.lisens = {}
end

function SWEP:BippSound(ent,pitch)
    ent:EmitSound("buttons/button16.wav",75,pitch)
end

function SWEP:CanLisen(output,input,isChat)
    if not output:Alive() or output.Otrub or not input:Alive() or input.Otrub then return false end
    if output:InVehicle() and output:IsSpeaking() then self.voiceSpeak = CurTime() + 0.5 end

    if not input:HasWeapon("weapon_radio") then return end

    if output:GetActiveWeapon() ~= self or (not isChat and not self.Transmit) then return end

    if output:Team() == input:Team() or output:Team() == 1002 then return true end
end

local CurTime = CurTime
local GetAll = player.GetAll

function SWEP:CanTransmit()
    local owner = self:GetOwner()
    return not owner:InVehicle() and (self.voiceSpeak > CurTime() or owner:KeyDown(IN_ATTACK2))
end

function SWEP:Step()
    local output = self:GetOwner()
    if not IsValid(output) then return end

    local Transmit = self:CanTransmit()
    self.Transmit = Transmit

    if Transmit then
        local lisens = self.lisens
        for i,input in pairs(GetAll()) do
            if not self:CanLisen(output,input) then
                if lisens[input] then
                    lisens[input] = nil
                    self:BippSound(input,80)
                end
            elseif not lisens[input] then
                lisens[input] = true
                input:ChatPrint("Вещает : " .. output:Nick())
                self:BippSound(input,100)
            end
        end

        self:SetHoldType("slam")
    else
        local lisens = self.lisens
        for input in pairs(lisens) do
            lisens[input] = nil
            self:BippSound(input,80)
        end

        self:SetHoldType("normal")
    end
end

function SWEP:OnRemove() end

hook.Add("Player Can Lisen","radio",function(output,input,isChat)
    local wep = output:GetWeapon("weapon_radio")

    if IsValid(wep) and wep:CanLisen(output,input,isChat) then
        if isChat then
            for i,input in pairs(GetAll()) do
                if not wep:CanLisen(output,input,isChat) then continue end

                wep:BippSound(input,140)
            end
        end

        return true,false
    end
end)