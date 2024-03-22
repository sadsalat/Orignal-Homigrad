CreateConVar("sbtm_selfset", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, players can set their own team.", 0, 1)
CreateConVar("sbtm_selfset_balance", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, players cannot unbalance teams.", 0, 1)
CreateConVar("sbtm_teamnpcs", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, admins can put NPCs into teams.", 0, 1)
CreateConVar("sbtm_teamnpcs_color", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "If enabled, NPCs with teams will be colored.", 0, 1)
CreateConVar("sbtm_nofriendlyfire", "1", FCVAR_ARCHIVE, "If enabled, players on the same team cannot hurt each other.", 0, 1)
CreateConVar("sbtm_neutralunassigned", "0", FCVAR_ARCHIVE, "If enabled, unassigned players and teamed players cannot hurt each other.", 0, 1)
CreateConVar("sbtm_setplayercolor", "1", FCVAR_ARCHIVE, "If enabled, setting team also sets player color (not enforced).", 0, 1)
CreateConVar("sbtm_shuffle_max", "2", FCVAR_ARCHIVE, "The number of teams used when shuffling players. Also used to consider team balance.", 2, 4)
CreateConVar("sbtm_deathunassign", "0", FCVAR_ARCHIVE, "If enabled, teamed players who die becomes unassigned.", 0, 1)
CreateConVar("sbtm_deathunassign_spec", "1", FCVAR_ARCHIVE, "If enabled, turn dead teamed players into spectators instead.", 0, 1)
CreateConVar("sbtm_mapspawns", "1", FCVAR_ARCHIVE, "If enabled, automatically create team spawns if a map supports it.", 0, 1)
CreateConVar("sbtm_assignonjoin", "0", FCVAR_ARCHIVE, "If enabled, players are auto-assigned a team on connection.", 0, 1)
CreateConVar("sbtm_teamoutline", "1", FCVAR_ARCHIVE, "If enabled, players can see teammates through walls.", 0, 1)
CreateConVar("sbtm_nopickup", "1", FCVAR_ARCHIVE, "If enabled, only admins can pickup SBTM and SBMG entities.", 0, 1)
CreateConVar("sbtm_teamproperties", "1", FCVAR_ARCHIVE, "Apply team properties.", 0, 1)
CreateConVar("sbtm_teamproperties_adminoverride", "0", FCVAR_ARCHIVE, "Admins ignore spawning, noclip and weapon restrictions for the team they're in.", 0, 1)


concommand.Add("sbtm_shuffle", function(ply, cmd, args)
    if SERVER and (not IsValid(ply) or ply:IsAdmin()) then
        SBTM:Shuffle()
    elseif CLIENT and ply:IsAdmin() then
        net.Start("SBTM_Admin")
            net.WriteUInt(1, 2)
        net.SendToServer()
    end
end)

concommand.Add("sbtm_autoassign", function(ply, cmd, args)
    if SERVER and (not IsValid(ply) or ply:IsAdmin()) then
        SBTM:AutoAssign()
    elseif CLIENT and ply:IsAdmin() then
        net.Start("SBTM_Admin")
            net.WriteUInt(2, 2)
        net.SendToServer()
    end
end)

concommand.Add("sbtm_unassignall", function(ply, cmd, args)
    if SERVER and (not IsValid(ply) or ply:IsAdmin()) then
        SBTM:UnassignAll()
    elseif CLIENT and ply:IsAdmin() then
        net.Start("SBTM_Admin")
            net.WriteUInt(3, 2)
        net.SendToServer()
    end
end)