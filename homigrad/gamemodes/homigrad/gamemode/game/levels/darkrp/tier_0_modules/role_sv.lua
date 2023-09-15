function darkrp.SetRole(ply,id,idModel)
    ply:SetNWInt("DarkRPRole",id)
    ply.darkrpModelID = idModel
    if ply:Alive() then ply:KillSilent() end
end

util.AddNetworkString("darkrp role")
net.Receive("darkrp role",function(len,ply)
    local roleID = net.ReadInt(16)
    local role = darkrp.roles[roleID]

    local limit = role.limitC or (role.limit and math.floor(#player.GetAll() / role.limit))

    if ply:IsAdmin() then limit = nil end

    if limit then
        local count = 0

        for id,ply2 in pairs(player.GetAll()) do
            local role2 = darkrp.GetRole(ply2)

            if i == roleID then count = count + 1 end
        end

        if count >= limit then
            darkrp.Notify("Лимит на роли.",NOTIFY_ERROR,5,ply)

            return
        end
    end

    darkrp.SetRole(ply,roleID,net.ReadInt(16))
    darkrp.Notify(ply:Name() .. " стал " .. darkrp.roles[roleID][1] .. ".",NOTIFY_HINT,5)
end)