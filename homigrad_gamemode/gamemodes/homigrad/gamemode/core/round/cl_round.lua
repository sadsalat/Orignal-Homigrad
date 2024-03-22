--
homigrad = homigrad or {}

net.Receive("homigrad.Sync",function()
    homigrad.CLroundInfo = net.ReadTable()
    homigrad.CLroundState  = net.ReadString() 
end)

net.Receive("homigrad.SyncNextRound",function()
    homigrad.CLNextRound = net.ReadString()
end)

PrintTable(homigrad.CLroundInfo)

homigrad.RoundCLHud = function()
    if homigrad.Modes[homigrad.CLroundInfo.Mode] and homigrad.Modes[homigrad.CLroundInfo.Mode].RoundCLHud then
        homigrad.Modes[homigrad.CLroundInfo.Mode].RoundCLHud()
    end
end