util.AddNetworkString("jailbreak_point")
util.AddNetworkString("jailbreak_door")

net.Receive("jailbreak_point",function(len,ply)
    if ply:Team() ~= 2 then return end--ban

    net.Start("jailbreak_point")
    net.WriteVector(net.ReadVector())
    net.Broadcast()
end)

net.Receive("jailbreak_door",function(len,ply)
    if ply:Team() ~= 1002 and ply:Team() ~= 2 then return end--ban

    local ent = net.ReadEntity()
    ent:Fire("Open")
end)

COMMANDS.jailbreak_add = {function(ply,args)
    if roundActiveName ~= "jailbreak" then return false end

    local setRank = tonumber(args[2])

    if not setRank then
        for i,rank in pairs(jailbreak.ranksList) do
            if string.find(args[2],rank[1]) then setRank = i PrintMessageChat(ply,setRank) end
        end
    end

    if setRank ~= 0 and not jailbreak.ranksList[setRank] then PrintMessageChat(ply,"такого ранга нет") return end

    for i,ply2 in pairs(player.GetListByName(args[1]) or {ply}) do
        if ply:IsAdmin() or setRank < ply:GetNWInt("JailBreakRank",0) then
            local rank = jailbreak.ranksList[setRank or 0]

            PrintMessageChat(ply,ply2:Name() .. " - " .. tostring(rank and rank[1] or "уволен"))

            if rank then
                PrintMessageChat(ply2,"Тебе дали - " .. rank[1])
            else
                PrintMessageChat(ply2,"Тебя уволили.")
            end

            jailbreak.SetRank(ply2,setRank)
        else
            PrintMessageChat(ply,"no")
        end

        return
    end

    PrintMessageChat(ply,"никого не нашлось")
end,0}

if GetGlobalBool("JailBreakGuilt") == nil then SetGlobalBool("JailBreakGuilt",true) end
function jailbreak.GuiltLogic(ply,att,dmgInfo)
    if ply:Team() == 1 and att:Team() == 1 and not GetGlobalBool("JailBreakGuilt") then return false end

    if ply:Team() == 2 and att:Team() == 2 then
        local rank1,rank2 = ply:GetNWInt("JailBreakRank",0),att:GetNWInt("JailBreakRank",0)

        if rank2 > rank1 then return false end
    end
end

COMMANDS.jailbreak_guilt = {function(ply,args)
    if roundActiveName ~= "jailbreak" then return false end
    if not (ply:Team() == 2 or ply:IsAdmin()) then return false end

    SetGlobalBool("JailBreakGuilt",tonumber(args[1]) > 0)

    PrintMessageChat(3,"Гилт : " .. tostring(GetGlobalBool("JailBreakGuilt")))
end,0}

COMMANDS.jailbreak_ranks = {function(ply,args)
    if roundActiveName ~= "jailbreak" then return false end

    local text = ""
    for i,rank in pairs(jailbreak.ranksList) do
        text = text .. i .. " - " .. rank[1] .. "\n"
    end

    text = string.sub(text,2,#text)
    PrintMessageChat(ply,text)
end,0}

local vecZero,angZero = Vector(0,0,0),Angle(0,0,0)

COMMANDS.jailbreak_open = {function(ply,args)
    if roundActiveName ~= "jailbreak" then return false end
    if not (ply:IsAdmin() or ply:Team() == 2) then return false end

    local point = ReadDataMap("jailbreak_doors")
    if #point == 0 then PrintMessageChat(ply,"попроси админа чтоб добавил на эту карту данные.") end

    for i,ent in pairs(ents.FindByClass("func_door")) do
        local access

        local pos = ent:GetPos()
        for i,point in pairs(point) do
            if point[1]:Distance(pos) < point[3] then access = true break end
        end

        if access then
            if tonumber(args[1]) > 0 then
                ent:Fire("Open")

                PrintMessageChat(ply,"Открываем...")
            else
                ent:Fire("Close")

                PrintMessageChat(ply,"Закрываем...")
            end
        end
    end
end,0}

COMMANDS.jailbreak_random = {function(ply,args)
    if roundActiveName ~= "jailbreak" then return false end
    if not (ply:IsAdmin() or ply:Team() == 2 or jailbreak.GetRank(ply)) then return false end

    SetGlobalBool("JailBreakRandom",tonumber(args[1]) > 0)

    PrintMessageChat(ply,"Рандомные кт : " .. tostring(GetGlobalBool("JailBreakRandom")))
end,0}

function jailbreak.PlayerCanLisen(output,input,isChat)
    if output:Team() == 2 and output:KeyDown(IN_WALK) then
        output.JB_Speak = true

        return true,false
    end
end

local function CanLisen(self,output,input,isChat)
    if not output:Alive() or output.Otrub or input.Otrub then return false end
    if (isChat and output:GetActiveWeapon() == self) or output:KeyDown(IN_ATTACK) then return true end

    if output:InVehicle() and output:IsSpeaking() then self.voiceSpeak = CurTime() + 0.5 end

    if not input:HasWeapon("weapon_radio") then return end

    if output:GetActiveWeapon() ~= self or (not isChat and not self.Transmit) then return end

    if output:Team() == input:Team() or output:Team() == 1002 then return true end
end

local function CanTransmit(self)
    local owner = self:GetOwner()

    return self.voiceSpeak > CurTime() or owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)
end

hook.Add("WeaponEquip","JailBreakRadio",function(wep,ply)
    if roundActiveName ~= "jailbreak" then return end

    if wep:GetClass() == "weapon_radio" then
        wep.CanLisen = CanLisen
        wep.CanTransmit = CanTransmit
    end
end)