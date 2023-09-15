



/*********************************************************
    Checks and Sets
 *********************************************************/
function SolidMapVote.playerHasVoted( steamId64 )
    return SolidMapVote.votes[ steamId64 ]
end

function SolidMapVote.playerHasNominated( steamId64 )
    return SolidMapVote.nominations[ steamId64 ]
end

function SolidMapVote.playerHasRTVed( steamId64 )
    return table.HasValue( SolidMapVote.RTVs, steamId64 )
end

function SolidMapVote.vote( steamId64, vote )
    SolidMapVote.votes[ steamId64 ] = vote
    SolidMapVote.sendVotes( true )
end

function SolidMapVote.nominate( steamId64, nomination )
    SolidMapVote.nominations[ steamId64 ] = nomination
    SolidMapVote.sendNominations( true )
end

function SolidMapVote.getRTVAmount()
    return math.ceil( #player.GetAll()*SolidMapVote[ 'Config' ][ 'RTV Percentage' ] )
end


/*********************************************************
    Start and End
 *********************************************************/
function SolidMapVote.start()
    local maps = SolidMapVote.selectMaps()
    local counts = SolidMapVote.createWeightedPool( maps, SolidMapVote.mapPlayCounts )

    SolidMapVote.isOpen = true
    SolidMapVote.startTime = RealTime()
    SolidMapVote.endTime = SolidMapVote.startTime + SolidMapVote[ 'Config' ][ 'Length' ]

    net.Start( 'SolidMapVote.start' )
    net.WriteTable( maps )
    net.Broadcast()

    SolidMapVote.sendPlayCounts( counts, true )
end

function SolidMapVote.close()
    local winningMaps = SolidMapVote.getWinningMaps()
    local realWinner = table.Random( winningMaps )
    local fixedWinner = ''

    if realWinner == 'random' then
        if SolidMapVote[ 'Config' ][ 'Random Mode' ] == 1 then
            fixedWinner = table.Random( SolidMapVote.maps )
        else
            fixedWinner = table.Random( SolidMapVote.mapPool )
        end
    elseif realWinner == 'extend' then
        fixedWinner = game.GetMap()
    end

    SolidMapVote.realWinner = realWinner
    SolidMapVote.fixedWinner = fixedWinner
    SolidMapVote.finished = true
    SolidMapVote.changeTime = RealTime() + SolidMapVote[ 'Config' ][ 'Post Vote Length' ]

    net.Start( 'SolidMapVote.end' )
    net.WriteTable( winningMaps )
    net.WriteString( realWinner )
    net.WriteString( fixedWinner )
    net.Broadcast()
end

function SolidMapVote.reset()
    SolidMapVote.close()
    SolidMapVote.autoStartTime = RealTime() + SolidMapVote[ 'Config' ][ 'Vote Autostart Delay' ]
    SolidMapVote.reminded = false
    SolidMapVote.finished = false
    SolidMapVote.RTVs = {}
    SolidMapVote.RTVDelayEnd = RealTime() + SolidMapVote[ 'Config' ][ 'RTV Delay' ]

    for _, ply in pairs( player.GetAll() ) do
        ply:ConCommand( 'solidmapvote_close_ui' )
    end
end


/*********************************************************
    Initializing and Stuff
 *********************************************************/
function SolidMapVote.getWinningMaps()
    local mapVoteCounts = {}
    local winningMaps = {}

    -- Add all the maps to the counting table
    for _, map in pairs( SolidMapVote.maps ) do
        mapVoteCounts[ map ] = 0
    end

    -- Add the random and extend options to the count
    if SolidMapVote[ 'Config' ][ 'Enable Extend' ] then
        mapVoteCounts[ 'extend' ] = 0
    end

    if SolidMapVote[ 'Config' ][ 'Enable Random' ] then
        mapVoteCounts[ 'random' ] = 0
    end

    -- Count up all the votes
    for steamId64, vote in pairs( SolidMapVote.votes ) do
        local ply = player.GetBySteamID64( steamId64 )
        local power = IsValid( ply ) and SolidMapVote[ 'Config' ][ 'Vote Power' ]( ply ) or 1

        mapVoteCounts[ vote ] = mapVoteCounts[ vote ] + power
    end

    -- Find the winning amount
    local winningAmount = mapVoteCounts[ table.GetWinningKey( mapVoteCounts ) ]
    -- Search for ties
    for map, voteCount in pairs( mapVoteCounts ) do
        if voteCount == winningAmount then
            table.insert( winningMaps, map )
        end
    end

    return winningMaps
end

function SolidMapVote.poolMaps()
    SolidMapVote.mapPool = {} -- Reset the map pool
    local maps = file.Find( 'maps/*.bsp', 'GAME' )

    if SolidMapVote[ 'Config' ][ 'Manual Map Pool' ] then
        SolidMapVote.mapPool = SolidMapVote[ 'Config' ][ 'Map Pool' ]
        return SolidMapVote.mapPool
    end

    for _, map in pairs( maps ) do
        local realMapName = string.sub( map, 1, string.find( map, '.bsp' )-1 )

        -- Don't include the current map
        if realMapName == game.GetMap() then continue end

        if SolidMapVote[ 'Config' ][ 'Ignore Prefix' ] then
            table.insert( SolidMapVote.mapPool, realMapName )
        else
            for _, prefix in pairs( SolidMapVote[ 'Config' ][ 'Map Prefix' ] ) do
                if string.StartWith( realMapName, prefix ) then
                    table.insert( SolidMapVote.mapPool, realMapName )
                end
            end
        end
    end

    return SolidMapVote.mapPool
end

function SolidMapVote.selectMaps()
    SolidMapVote.maps = {} -- Reset the active maps

    -- Check for map underflow
    if #SolidMapVote.mapPool <= 6 then
        SolidMapVote.maps = SolidMapVote.mapPool
        return SolidMapVote.maps
    end

    -- Do nominations
    if #SolidMapVote.nominations >= 6 then
        -- Maps are only nominations, can't fit random maps
        for steamID64, map in pairs( SolidMapVote.nominations ) do
            table.insert( SolidMapVote.maps, map )
        end

        return SolidMapVote.maps
    else
        -- Theres room for random maps, first add the nominations
        for steamID64, map in pairs( SolidMapVote.nominations ) do
            table.insert( SolidMapVote.maps, map )
        end
    end

    -- Do random map selection
    local i = table.Count( SolidMapVote.nominations )
    while i < 6 do
        local map = SolidMapVote[ 'Config' ][ 'Fair Map Recycling' ] and
                    SolidMapVote.selectRandomMapFairly( SolidMapVote.mapPool, SolidMapVote.mapPlayCounts ) or
                    table.Random( SolidMapVote.mapPool )

        if not table.HasValue( SolidMapVote.maps, map ) and map != nil then
            table.insert( SolidMapVote.maps, map )
            i = i + 1
        end
    end

    return SolidMapVote.maps
end

function SolidMapVote.initFairMapRecycling()
    SolidMapVote.mapPlayCounts = {}

    -- Create the table for map recycling
    if not sql.TableExists( 'solid_map_vote_data' ) then
        sql.Query( 'CREATE TABLE solid_map_vote_data ( Map string, PlayCount int )' )
    end

    -- Checking and updating the current map in the database
    local currentMap = sql.Query( string.format( 'SELECT * FROM solid_map_vote_data WHERE Map = \'%s\'', game.GetMap() ) )
    if not currentMap then
        -- Map not found, insert it into the database with 1 play
        sql.Query( string.format( 'INSERT INTO solid_map_vote_data ( Map, PlayCount ) VALUES ( \'%s\', 1 )', game.GetMap() ) )
    else
        -- Map was found, add one to its play count
        sql.Query( string.format( 'UPDATE solid_map_vote_data SET PlayCount = \'%d\' WHERE Map = \'%s\'', currentMap[1][ 'PlayCount' ]+1, game.GetMap() ) )
    end

    -- Get the rest of the maps in the database
    local allMapPlayCounts = sql.Query( 'SELECT * FROM solid_map_vote_data' )

    -- Check the raw table of map play counts
    if not allMapPlayCounts then
        -- Something fucked up, print an error and disable the feature for now
        ErrorNoHalt( 'There was a problem pulling maps from the local database for the Fair Map Recycling System. It has been disabled.' )
        ErrorNoHalt( sql.LastError() )
        SolidMapVote[ 'Config' ][ 'Fair Map Recycling' ] = false
    else
        -- Map play counts were found, fix the table into a more workable format for later
        for _, mapData in pairs( allMapPlayCounts ) do
            SolidMapVote.mapPlayCounts[ mapData.Map ] = mapData.PlayCount
        end
    end

    return SolidMapVote.mapPlayCounts
end

function SolidMapVote.createWeightedPool( pool, weights, calc )
    local weightedPool = {}
    local calc = calc and calc or false -- Only true when used for cumsum calc

    for _, map in pairs( pool ) do
        weightedPool[ map ] = weights[ map ] or (calc and 1 or 0)
    end

    return weightedPool
end

function SolidMapVote.selectRandomMapFairly( pool, weights )
    local weightedPool = SolidMapVote.createWeightedPool( pool, weights, true )
    local inverseCumulativePoolSum = 0
    local random

    -- Calculate the inverse cumulative sum of the pool weight
    -- Inverse because less played maps should have a higher chance
    for map, weight in pairs( weightedPool ) do
        inverseCumulativePoolSum = inverseCumulativePoolSum + (1/weight)
    end

    -- Select a random number from 0 to the inverse cumsum
    random = math.random() * inverseCumulativePoolSum

    -- Find the bisecting map in the weighted pool
    for map, weight in pairs( weightedPool ) do
        random = random - (1/weight)
        if random <= 0 then return map end
    end

    -- Map not found? Return nil to retry
    return nil
end
