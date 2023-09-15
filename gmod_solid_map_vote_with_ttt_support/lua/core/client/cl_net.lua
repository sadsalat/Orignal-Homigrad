

net.Receive( 'SolidMapVote.start', function( len )
    local maps = net.ReadTable()
    SolidMapVote.open( maps )
end )

net.Receive( 'SolidMapVote.sendVotes', function( len )
    local votes = net.ReadTable()
    if table.Count( votes ) < 1 then return end

    hook.Run( 'SolidMapVote.UpdateVotes', votes )
end )

net.Receive( 'SolidMapVote.sendNominations', function( len )
    local nominations = net.ReadTable()
    if table.Count( nominations ) < 1 then return end

    hook.Run( 'SolidMapVote.UpdateNominations', nominations )
end )

net.Receive( 'SolidMapVote.sendMessage', function( len )
    local tblMsg = net.ReadTable()
    chat.AddText( unpack( tblMsg ) )
end )

net.Receive( 'SolidMapVote.end', function( len )
    local winningMaps = net.ReadTable() -- All the votes that tied for 1st
    local realWinner = net.ReadString() -- The Randomly chosen winner
    local fixedWinner = net.ReadString() -- The fixed map if 'extend' or 'random' won

    hook.Run( 'SolidMapVote.WinningMaps', winningMaps, realWinner, fixedWinner )
end )

net.Receive( 'SolidMapVote.sendPlayCounts', function( len )
    local playCounts = net.ReadTable()

    hook.Run( 'SolidMapVote.MapPlayCounts', playCounts )
end )

net.Receive( 'SolidMapVote.sendMapPool', function( len )
    local mapPool = net.ReadTable()

    hook.Run( 'SolidMapVote.UpdateMapPool', mapPool )
end )
