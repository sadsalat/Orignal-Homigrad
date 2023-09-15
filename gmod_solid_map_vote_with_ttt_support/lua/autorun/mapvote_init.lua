
SolidMapVote = SolidMapVote or {}
SolidMapVote[ 'Config' ] = SolidMapVote[ 'Config' ] or {}

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( 'mapvote_config.lua' )
    AddCSLuaFile( 'core/client/cl_mapvote.lua' )
    AddCSLuaFile( 'core/client/cl_net.lua' )
    AddCSLuaFile( 'core/lib/b-draw_lib.lua' )

    include( 'mapvote_config.lua' )
    include( 'core/server/sv_net.lua' )
    include( 'core/server/sv_hooks.lua' )
    include( 'core/server/sv_mapvote.lua' )
else
    include( 'mapvote_config.lua' )
    include( 'core/client/cl_mapvote.lua' )
    include( 'core/client/cl_net.lua' )
    include( 'core/lib/b-draw_lib.lua' )
end

hook.Add( "Initialize", "AutoTTTMapVote", function()
      if GAMEMODE_NAME == "terrortown" then
        function CheckForMapSwitch()
           -- Check for mapswitch
           local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6) - 1)
           SetGlobalInt("ttt_rounds_left", rounds_left)
 
           local time_left = math.max(0, (GetConVar("ttt_time_limit_minutes"):GetInt() * 60) - CurTime())
           local switchmap = false
           local nextmap = string.upper(game.GetMapNext())
 
            if rounds_left <= 0 then
			timer.Stop("end2prep")
              LANG.Msg("limit_round", {mapname = nextmap})
              SolidMapVote.start()
            elseif time_left <= 0 then
			timer.Stop("end2prep")
              LANG.Msg("limit_time", {mapname = nextmap})
              SolidMapVote.start()
            end
        end
      end
end )