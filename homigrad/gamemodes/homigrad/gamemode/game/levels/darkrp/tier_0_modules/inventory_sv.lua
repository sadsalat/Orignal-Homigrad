function darkrp.Inv_SetupDef(ply)
    darkrp.Inv_Init(ply)

    darkrp.Inv_SetCountSlot(ply,4)
    darkrp.Inv_Sync(ply)
end

function darkrp.Inv_Init(ply)
    ply.darkrpInv = ply.darkrpInv or {}
end

function darkrp.Inv_SetCountSlot(ply,count)
    for k in pairs(ply.darkrpInv) do ply.darkrpInv[k] = nil end

    for i = 1,count do
        ply.darkrpInv[i] = {}
    end
end

function darkrp.Inv_Pickup(ply,ent)
    local access

    for i,slot in pairs(ply.darkrpInv) do
        if not slot[1] then
            access = true

            slot[1] = ent:GetClass()
            local data = duplicator.Copy(ent).Entities

            for id,ent2 in pairs(data) do
                if id ~= ent:EntIndex() then data[id] = nil end
            end

            slot[2] = data
            slot[3] = ent:GetModel()
            slot[4] = ent.PrintName

            ent:Remove()

            darkrp.Inv_Sync(ply)
        end
    end

    if not access then return false end
end

function darkrp.Inv_Drop(ply,slot)
    local item = ply.darkrpInv[slot]
    if not item[1] then return end

    local list = duplicator.Paste(ply,slot[2])
    for k in pairs(slot) do slot[k] = nil end

    darkrp.Inv_Sync(ply)

    PrintTable(list)

    return true
end

util.AddNetworkString("darkrp inv")

function darkrp.Inv_Sync(ply)
    net.Start("darkrp inv")
    net.WriteTable(ply.darkrpInv)
    net.Send(ply)
end

COMMANDS.pickup = {function(ply,args)

    if darkrp.Inv_Pickup(ply,ply:GetEyeTraceDis(75).Entity) then
        sound.Play(Sound(""),ply:GetPos())
    else
        darkrp.Notify("Лимит.",NOTIFY_ERROR,5,ply)
    end
end,0}

util.AddNetworkString("darkrp inv drop")

net.Receive("darkrp ivn drop",function(len,ply)
    if darkrp.Inv_Drop(ply,net.ReadInt(16)) then
        sound.Play(Sound(""),ply:GetPos())
    else
        --lol?
    end
end)