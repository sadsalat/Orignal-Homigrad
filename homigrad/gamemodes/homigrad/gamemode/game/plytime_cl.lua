net.Receive("Time Ply",function()
    local ply,time = net.ReadEntity(),tonumber(net.ReadString())

    ply.Time = time
    ply.TimeStart = CurTime()
end)