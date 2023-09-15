local classList = player.classList

local Player = FindMetaTable("Player")

function Player:SetPlayerClass(value)
    value = value or "none"

    local old = self.PlayerClassName
    self.PlayerClassNameOld = old
    old = classList[old]
    if old and old.Off then old.Off(self) end

    self.PlayerClassName = value
    self:PlayerClassEvent("On")

    net.Start("setupclass")
    net.WriteEntity(self)
    net.WriteString(value)
    net.WriteString(self.PlayerClassNameOld or "")
    net.Broadcast()
end

util.AddNetworkString("setupclass")

hook.Add("PlayerInitializeSpawn","PlayerClass",function(plySend)
    for i,ply in pairs(player.GetAll()) do
        if not ply:GetPlayerClass() then continue end
        
        net.Start("setupclass")
        net.WriteEntity(ply)
        net.WriteString(ply:GetNWString("Class"))
        net.WriteString(ply:GetNWString("ClassOld"))
        net.Send(plySend)
    end
end)

hook.Add("PlayerDeath","PlayerClass",function(ply,inf,att)
    if IsValid(att) and att:IsPlayer() then att:PlayerClassEvent("PlayerKill",ply) end

    ply:PlayerClassEvent("PlayerDeath",att)
end)

COMMANDS.playerclass = {function(ply,args)
    for i,ply2 in pairs(player.GetListByName(args[1]) or {ply}) do
        ply2:SetPlayerClass(args[2])
        ply:ChatPrint(ply2:Name())
    end
end}

hook.Add("Player Start Voice","PlayerClass",function(ply)
    ply:PlayerClassEvent("PlayerStartVoice")
end)

hook.Add("Player End Voice","PlayerClass",function(ply)
    ply:PlayerClassEvent("PlayerEndVoice")
end)

hook.Add("HomigradDamage","PlayerClass",function(ply,hitGroup,dmgInfo,rag)
    return ply:PlayerClassEvent("HomigradDamage",hitGroup,dmgInfo,rag)
end)

hook.Add("Player Can Lisen","PlayerClass",function(output,input,isChat)
    local result = output:PlayerClassEvent("CanLisenOutput",input,isChat)
    if result ~= nil then return result end

    local result = input:PlayerClassEvent("CanLisenInput",output,isChat)
    if result ~= nil then return result end
end)

hook.Add("Fake Up","PlayerClass",function(ply)
    return ply:PlayerClassEvent("ShouldFakeUp")
end)

hook.Add("Fake","PlayerClass",function(ply)
    return ply:PlayerClassEvent("ShouldFake")
end)

hook.Add("PlayerCanPickupWeapon","PlayerClass",function(ply,wep)
    return ply:PlayerClassEvent("ShouldUpWeapon",wep)
end)

hook.Add("PlayerCanPickupItem","PlayerClass",function(ply,item)
    return ply:PlayerClassEvent("ShouldUpItem",wep)
end)

hook.Add("Shuold JMod Armor Equip","PlayerClass",function(ply)
    return ply:PlayerClassEvent("JModArmorEquip")
end)