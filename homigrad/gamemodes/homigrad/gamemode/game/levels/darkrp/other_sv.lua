util.AddNetworkString("darkrp notify")
function darkrp.Notify(text,type,decay,ply)
    net.Start("darkrp notify")
    net.WriteString(text)
    net.WriteInt(type,16)
    net.WriteInt(decay,16)
    if ply then net.Send(ply) else net.Broadcast() end
end