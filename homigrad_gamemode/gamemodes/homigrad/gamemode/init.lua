AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function GM:PlayerSpawn(ply)
    hook.Run( "homigrad_ply.spawn", ply )
end

function GM:PlayerDeath(ply,inf,att)
    hook.Run( "homigrad_ply.death", ply, inf, att )
end

function GM:PlayerInitialSpawn(ply)
    hook.Run( "homigrad_ply.init", ply )
end

function GM:PlayerDeathThink(ply)
    hook.Run( "homigrad_ply.deaththink", ply )
end

function GM:PlayerDisconnected(ply)
    hook.Run( "homigrad_ply.disconnect", ply )
end

function GM:PlayerDeathSound() return true end

function GM:PlayerCanJoinTeam(ply,teamID) 
    hook.Run( "homigrad_ply.canjoin", ply, teamID )
end

function GM:DoPlayerDeath(ply)
    hook.Run( "homigrad_ply.dodeath", ply )
end

function GM:PlayerStartVoice(ply)
    hook.Run( "homigrad_ply.voicechat", ply )
end
