util.AddNetworkString("darkrp rules")

function darkrp.RulesSync(ply)
    net.Start("darkrp rules")
    net.WriteString(darkrp.rules or "")
    if ply then net.Send(ply) else net.Broadcast() end
end

function darkrp.SetRules(text)
    darkrp.Notify("Законы изменились!",NOTIFY_GENERIC,15)
    darkrp.rules = text
    darkrp.RulesSync()
end

net.Receive("darkrp rules",function(len,ply)
    local role = darkrp.GetRole(ply)
    if not role.canChangeRule then return end--ban

    darkrp.SetRules(net.ReadString())
end)