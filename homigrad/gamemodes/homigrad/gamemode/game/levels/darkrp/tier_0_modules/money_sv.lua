function darkrp.SetMoney(ply,value)
    ply:SetNWInt("DarkRPMoney",value)
end

function darkrp.AddMoney(ply,value)
    ply:SetNWInt("DarkRPMoney",ply:GetNWInt("DarkRPMoney",0) + value)
end

local function send(ply,money)
    darkrp.AddMoney(ply,money)
    darkrp.Notify("Тебе выдали: " .. money .. "$",NOTIFY_GENERIC,5,ply)
end

COMMANDS.addmoney = {function(ply,args)
    local money = tonumber(args[2])

    if args[1] == "^" then
        send(ply,money)
    else
        for i,ply2 in pairs(player.GetAll()) do
            if string.find(ply2:Name(),args[1]) then

                send(ply2,money)

                return
            end
        end
    end
end}

COMMANDS.dropmoney = {function(ply,args)
    local money = darkrp.GetMoney(ply)
    local subMoney = tonumber(args[1])
    if subMoney <= 0 or subMoney > money then darkrp.Notify("Недостаточно средств.",NOTIFY_ERROR,2,ply) return end

    local trace = {start = ply:EyePos()}
    local dir = Vector(75,0,0)
    dir:Rotate(ply:EyeAngles())
    tr.endpos = tr.start + dir

    local ent = ents.Create("darkrp_money")
    ent:SetNWInt("Amount",subMoney)
    ent:SetPos(trace.HitPos)
    ent:Spawn()

    darkrp.AddMoney(ply,-subMoney)
end,0}