
util.AddNetworkString( 'SolidMapVote.start' )
util.AddNetworkString( 'SolidMapVote.end' )
util.AddNetworkString( 'SolidMapVote.sendVotes' )
util.AddNetworkString( 'SolidMapVote.sendNominations' )
util.AddNetworkString( 'SolidMapVote.sendMessage' )
util.AddNetworkString( 'SolidMapVote.sendPlayCounts' )
util.AddNetworkString( 'SolidMapVote.sendMapPool' )

function SolidMapVote.sendVotes( all, ply )
    net.Start( 'SolidMapVote.sendVotes' )
    net.WriteTable( SolidMapVote.votes )

    if all then net.Broadcast()
    else net.Send( ply ) end
end

function SolidMapVote.sendNominations( all, ply )
    net.Start( 'SolidMapVote.sendNominations' )
    net.WriteTable( SolidMapVote.nominations )

    if all then net.Broadcast()
    else net.Send( ply ) end
end

function SolidMapVote.sendMessage( tblMsg, all, ply )
    net.Start( 'SolidMapVote.sendMessage' )
    net.WriteTable( tblMsg )

    if all then net.Broadcast()
    else net.Send( ply ) end
end

function SolidMapVote.sendPlayCounts( maps, all, ply )
    net.Start( 'SolidMapVote.sendPlayCounts' )
    net.WriteTable( maps )

    if all then net.Broadcast()
    else net.Send( ply ) end
end

function SolidMapVote.sendMapPool( all, ply )
    net.Start( 'SolidMapVote.sendMapPool' )
    net.WriteTable( SolidMapVote.mapPool )

    if all then net.Broadcast()
    else net.Send( ply ) end
end


concommand.Add( 'solidmapvote_vote', function( ply, cmd, args )
    local vote = args[1]
    local steamId64 = ply:SteamID64()

    -- Check for errors
    if not SolidMapVote.isOpen then return end -- no vote currently
    if not vote then return end -- no map
    if not ply then return end -- no player

    -- Check if the vote is a valid map or option
    if table.HasValue( SolidMapVote.maps, vote ) or
    (vote == 'extend' and SolidMapVote[ 'Config' ][ 'Enable Extend' ]) or
    (vote == 'random' and SolidMapVote[ 'Config' ][ 'Enable Random' ]) then
        SolidMapVote.vote( steamId64, vote )
    end
end )

concommand.Add( 'solidmapvote_nominate', function( ply, cmd, args )
    local nomination = args[1]
    local steamId64 = ply:SteamID64()
    local name = ply:Nick()

    -- Check for errors
    if SolidMapVote.isOpen then return end -- vote is already going
    if not nomination then return end -- no nomination
    if not ply then return end -- no player

    -- Don't allow nominations from new players when it is full
    -- But well allow players that have alreay nominated to change theirs
    if #SolidMapVote.nominations >= math.min( 6, #SolidMapVote.mapPool ) and
    not SolidMapVote.playerHasNominated( steamId64 ) then
        SolidMapVote.sendMessage( { color_white, 'There is no more room for nominations in the map vote!' }, false, ply )
        return
    end

    -- Player doesn't have permission to nominate maps
    if not SolidMapVote[ 'Config' ][ 'Nomination Permissions' ]( ply ) then
        SolidMapVote.sendMessage( { color_white, 'You do not have permission to nominate maps!' }, false, ply )
        return
    end

    if table.HasValue( SolidMapVote.mapPool, nomination ) and -- needs to be in the map pool
    not table.HasValue( SolidMapVote.nominations, nomination ) and -- needs to not already be nominated
    SolidMapVote[ 'Config' ][ 'Allow Nominations' ] then -- nominations need to enabled
        SolidMapVote.nominate( steamId64, nomination )
        if SolidMapVote.playerHasNominated( steamId64 ) then
            SolidMapVote.sendMessage( { Color( 0, 177, 106 ), name, color_white, ' has changed his map nomination to ', Color( 0, 177, 106 ), nomination }, true )
        else
            SolidMapVote.sendMessage( { Color( 0, 177, 106 ), name, color_white, ' has nominated ', Color( 0, 177, 106 ), nomination, color_white, ' to the map vote.' }, true )
        end
    end
end )

concommand.Add( 'solidmapvote_request_mappool', function( ply, cmd, args )
    SolidMapVote.sendMapPool( false, ply )
end )

concommand.Add( 'solidmapvote_request_nominations', function( ply, cmd, args )
    SolidMapVote.sendNominations( false, ply )
end )
