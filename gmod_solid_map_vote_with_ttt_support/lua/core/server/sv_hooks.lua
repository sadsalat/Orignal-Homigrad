
hook.Add( 'InitPostEntity', 'SolidMapVote.Init', function()
    SolidMapVote.votes = {}
    SolidMapVote.isOpen = false
    SolidMapVote.finished = false
    SolidMapVote.RTVs = {}
    SolidMapVote.RTVDelayEnd = RealTime() + SolidMapVote[ 'Config' ][ 'RTV Delay' ]

    SolidMapVote.maps = {}
    SolidMapVote.mapPool = {}
    SolidMapVote.nominations = {}
    SolidMapVote.mapPlayCounts = {}
    SolidMapVote.realWinner = ''
    SolidMapVote.fixedWinner = ''

    SolidMapVote.startTime = 0
    SolidMapVote.endTime = 0
    SolidMapVote.changeTime = 0
    SolidMapVote.loadTime = RealTime()
    SolidMapVote.autoStartTime = SolidMapVote.loadTime + SolidMapVote[ 'Config' ][ 'Vote Autostart Delay' ]
    SolidMapVote.reminded = false
    SolidMapVote.RTVCompleted = false

    -- Some game mode checking for later use
    SolidMapVote.isTTT = string.find( string.lower( GAMEMODE.Name ), 'terrorist town' )
    SolidMapVote.isDeathRun = string.find( string.lower( GAMEMODE.Name ), 'deathrun' )
    SolidMapVote.isMurder = string.find( string.lower( GAMEMODE.Name ), 'murder' )
    SolidMapVote.isZombieSurvival = string.find( string.lower( GAMEMODE.Name ), 'zombie survival' )
    SolidMapVote.isJailBreak = string.find( string.lower( GAMEMODE.Name ), 'jail break' )
    SolidMapVote.startVoteAfterRound = false

    SolidMapVote.poolMaps()
    SolidMapVote.initFairMapRecycling() -- Run it even if disabled, so we can still log map plays
    SolidMapVote.hackRoundBasedGamemodes()
end )

hook.Add( 'PlayerInitialSpawn', 'SolidMapVote.PlayerSpawn', function( ply )
    if SolidMapVote.isOpen then
        net.Start( 'SolidMapVote.start' )
        net.WriteTable( SolidMapVote.maps )
        net.Broadcast()

        SolidMapVote.sendVotes( false, ply )
    end

    SolidMapVote.sendNominations( false, ply )
end )

hook.Add( 'PlayerDisconnected', 'SolidMapVote.PlayerLeave', function( ply )
    local steamId64 = ply:SteamID64()

    if SolidMapVote.playerHasVoted( steamId64 ) then
        SolidMapVote.votes[ steamId64 ] = nil
        SolidMapVote.sendVotes( true )
    end

    if SolidMapVote.playerHasNominated( steamId64 ) then
        SolidMapVote.nominations[ steamId64 ] = nil
        SolidMapVote.sendNominations( true )
    end

    if SolidMapVote.playerHasRTVed( steamId64 ) then
        table.RemoveByValue( SolidMapVote.RTVs, steamId64 )
    end
end )

hook.Add( 'PlayerSay', 'SolidMapVote.PlayerCommands', function( ply, text, tChat )
    local command = string.lower( string.Trim( text ) )
    local steamId64 = ply:SteamID64()
    local name = ply:Nick()

    -- Force mapvote command
    if table.HasValue( SolidMapVote[ 'Config' ][ 'Force Vote Commands' ], command ) and not SolidMapVote.isOpen then
        if SolidMapVote[ 'Config' ][ 'Force Vote Permission' ]( ply ) then
            SolidMapVote.start()
            SolidMapVote.sendMessage( { Color( 0, 177, 106 ), name, color_white, ' has forced the mapvote!' }, true )
            return ''
        end
    end

    -- RTV Command
    if table.HasValue( SolidMapVote[ 'Config' ][ 'Vote Commands' ], command ) and not SolidMapVote.isOpen then
        if NAXYIRTV then ply:ChatPrint("sasi") return end

        if SolidMapVote.RTVDelayEnd > RealTime() then
            local timeRemaining = tostring( math.ceil( SolidMapVote.RTVDelayEnd - RealTime() ) )
            SolidMapVote.sendMessage( { color_white, 'You cannot RTV for another ', Color( 0, 177, 106 ), timeRemaining, color_white, ' seconds!' }, false, ply )
            return ''
        end

        -- Check if the rtv amount is reached
        if not SolidMapVote.RTVCompleted then
            if SolidMapVote.playerHasRTVed( steamId64 ) and SolidMapVote[ 'Config' ][ 'Enable UnVote' ] then
                table.RemoveByValue( SolidMapVote.RTVs, steamId64 )
                SolidMapVote.sendMessage( { Color( 0, 177, 106 ), name, color_white, ' has removed his rock the vote! ', Color( 0, 177, 106 ), '(' .. #SolidMapVote.RTVs .. '/' .. SolidMapVote.getRTVAmount() .. ')' }, true )
                return ''
            else
                table.insert( SolidMapVote.RTVs, steamId64 )
                SolidMapVote.sendMessage( { Color( 0, 177, 106 ), name, color_white, ' wants to rock the vote! ', Color( 0, 177, 106 ), '(' .. #SolidMapVote.RTVs .. '/' .. SolidMapVote.getRTVAmount() .. ')' }, true )
                return ''
            end

        else
            SolidMapVote.sendMessage( { color_white, 'The RTV count has already been reached. The map vote will start soon.' }, false, ply )
            return ''
        end
    end

    -- Nominate Command
    if table.HasValue( SolidMapVote[ 'Config' ][ 'Nomination Commands' ], command ) and not SolidMapVote.isOpen then
        if not SolidMapVote[ 'Config' ][ 'Nomination Permissions' ]( ply ) then
            -- No permission to nominate maps
            SolidMapVote.sendMessage( { color_white, 'You do not have permission to nominate maps!' }, false, ply )
            return ''
        elseif not SolidMapVote[ 'Config' ][ 'Allow Nominations' ] then
            -- Nominations disabled on the server
            SolidMapVote.sendMessage( { color_white, 'Map nominations are currently disabled on the server!' }, false, ply )
            return ''
        else
            -- Send the map pool and open the menu
            ply:ConCommand( 'solidmapvote_nomination_menu' )
            return ''
        end
    end

    -- Time left command
    if table.HasValue( SolidMapVote[ 'Config' ][ 'Time Left Commands' ], command ) and SolidMapVote[ 'Config' ][ 'Enable Vote Autostart' ] and not SolidMapVote.isOpen then
        local timeRemaining = math.ceil( SolidMapVote.autoStartTime - RealTime() )
        SolidMapVote.sendMessage( { color_white, 'There are ', Color( 0, 177, 106 ), tostring( timeRemaining ), color_white, ' seconds util the map vote will start!' }, false, ply )
        return ''
    end
end )

hook.Add( 'Think', 'SolidMapVote.ServerLoop', function()
    -- Players called the vote through RTV
    SolidMapVote.checkForRTV()

    -- Time is up, start figuring out the winning map
    SolidMapVote.checkForVoteEnd()

    -- Post map vote time is up, change the map
    SolidMapVote.postMapVoteChange()

    -- Check to see if it is time to autostart the map vote
    SolidMapVote.checkForAutostart()
end )

-- Checks for when players RTV to choose a new map
-- Will start at end of round on round based gamemodes
function SolidMapVote.checkForRTV()
    if #SolidMapVote.RTVs >= SolidMapVote.getRTVAmount() and not SolidMapVote.isOpen and #player.GetAll() > 0 then
        if (SolidMapVote.isTTT or
        SolidMapVote.isDeathRun or
        SolidMapVote.isMurder or
        SolidMapVote.isZombieSurvival or
        SolidMapVote.isJailBreak) and
        not SolidMapVote.startVoteAfterRound then
            SolidMapVote.startVoteAfterRound = true
            SolidMapVote.RTVCompleted = true
            SolidMapVote.sendMessage( { color_white, 'The map vote will open after the current round!' }, true )

        elseif not SolidMapVote.startVoteAfterRound then
            SolidMapVote.RTVCompleted = true
            SolidMapVote.start()
        end
    end
end

-- Checks to see if the vote should end
function SolidMapVote.checkForVoteEnd()
    if SolidMapVote.endTime < RealTime() and SolidMapVote.isOpen and not SolidMapVote.finished then
        SolidMapVote.close()
    end
end

-- Checks if the map vote is over and changes the level
function SolidMapVote.postMapVoteChange()
    if SolidMapVote.changeTime < RealTime() and SolidMapVote.finished then
        SolidMapVote.isOpen = false

        if SolidMapVote.realWinner == 'extend' then
            if SolidMapVote[ 'Config' ][ 'Enable Vote Autostart' ] then
                -- If were using autostart, close the vote and restart the timer
                -- requested by a user
                SolidMapVote.close()
                SolidMapVote.reset()
            else
                RunConsoleCommand( 'changelevel', game.GetMap() )
            end
        elseif SolidMapVote.realWinner == 'random' then
            RunConsoleCommand( 'changelevel', SolidMapVote.fixedWinner )
        else
            RunConsoleCommand( 'changelevel', SolidMapVote.realWinner )
        end
    end
end

-- Checks to see if we should autostart the map vote
function SolidMapVote.checkForAutostart()
    if SolidMapVote[ 'Config' ][ 'Enable Vote Autostart' ] and not SolidMapVote.isOpen then
        local timeRemaining = math.ceil( SolidMapVote.autoStartTime - RealTime() )

        -- Give players on the server a reminder that the vote will open soon
        if not SolidMapVote.reminded and timeRemaining < SolidMapVote[ 'Config' ][ 'Autostart Reminder' ] then
            SolidMapVote.reminded = true
            SolidMapVote.sendMessage( { color_white, 'The map vote will open in ', Color( 0, 177, 106 ), tostring( timeRemaining ), color_white, ' seconds!' }, true )
        end

        -- Time to open the vote
        if timeRemaining <= 0 then
            SolidMapVote.start()
        end
    end
end

function SolidMapVote.hackRoundBasedGamemodes()
    -- fuck ttt
    if SolidMapVote.isTTT then
        GAMEMODE.StartFrettaVote = function() end

        game.LoadNextMap = function()
            SolidMapVote.start()
        end

        local oldTimerSimple = timer.Simple
        function timer.Simple( time, func, ... )
            if func == game.LoadNextMap then
                SolidMapVote.start()
                return
            end

            oldTimerSimple( time, func, ... )
        end

        hook.Add( 'TTTEndRound', 'SolidMapVote.TTTStartVoteAfterRound', function( result )
            if SolidMapVote.startVoteAfterRound then
                SolidMapVote.start()
            end
        end )
    end


    if SolidMapVote.isDeathRun then
        hook.Add( 'DeathrunShouldMapSwitch', 'SolidMapVote.DeathRunShouldStartVote', function( roundsPlayed )
            if SolidMapVote.startVoteAfterRound then
                return true
            end
        end )

        hook.Add( 'DeathrunStartMapvote', 'SolidMapVote.DeathRunStartVote', function( roundsPlayed )
            SolidMapVote.start()
            return true
        end )
    end

    if SolidMapVote.isMurder then
        hook.Add( 'OnEndRound', 'SolidMapVote.MurderVoteTrigger', function()
            if SolidMapVote.startVoteAfterRound then
                SolidMapVote.start()
            end

            if GAMEMODE.RoundLimit:GetInt() == GAMEMODE.RoundCount+1 then
                SolidMapVote.start()
            end
        end )
    end

    if SolidMapVote.isZombieSurvival then
        hook.Add( 'EndRound', 'SolidMapVote.ZombieSurvivalShouldStartVote', function( teamWinner )
            if SolidMapVote.startVoteAfterRound then
                SolidMapVote.start()
            end
        end )

        hook.Add( 'LoadNextMap', 'SolidMapVote.ZombieSurvivalVoteTrigger', function()
            SolidMapVote.start()
            return true
        end )
    end

    if SolidMapVote.isJailBreak then
        hook.Add( 'JailBreakRoundEnd', 'SolidMapVote.JailBreakShouldStartVote', function( rounds_passed )
            if SolidMapVote.startVoteAfterRound then
                SolidMapVote.start()
            end
        end )

        hook.Add( 'JailBreakStartMapvote', 'SolidMapVote.JailBreakVoteTrigger', function( rounds, extentions )
    	    SolidMapVote.start()
    		return true
    	end )
    end
end
