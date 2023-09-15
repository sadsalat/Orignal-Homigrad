hook.Add("PlayerDisconnected","setguilt-fornoobs",function(ply)
    ply:SetPData("Guilt",ply.Guilt)
end)

gameevent.Listen("player_connect")
hook.Add("player_connect","AnnounceConnection",function(data)
    local ply = Entity(data.index)

	if ply.bot == 0 then
        local guilt = ply:GetPData("Guilt")
        ply.Guilt = math.min(guilt,200)
    end
end)
