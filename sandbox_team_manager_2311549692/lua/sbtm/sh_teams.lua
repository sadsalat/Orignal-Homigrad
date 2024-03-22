CreateConVar("sbtm_name_red", "Red Team", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Team name for the first team.")
CreateConVar("sbtm_name_blue", "Blue Team", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Team name for the second team.")
CreateConVar("sbtm_name_green", "Green Team", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Team name for the third team.")
CreateConVar("sbtm_name_yellow", "Yellow Team", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Team name for the fourth team.")

local function colorconvar(t, default)
    CreateConVar("sbtm_clr_" .. t .. "_" .. "r", default.r, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 255)
    CreateConVar("sbtm_clr_" .. t .. "_" .. "g", default.g, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 255)
    CreateConVar("sbtm_clr_" .. t .. "_" .. "b", default.b, FCVAR_ARCHIVE + FCVAR_REPLICATED, "", 0, 255)
end
colorconvar("red", Color(255, 0, 0))
colorconvar("blue", Color(0, 0, 255))
colorconvar("green", Color(0, 255, 0))
colorconvar("yellow", Color(255, 255, 0))

hook.Add("CreateTeams", "SBTM", function()
    team.SetUp(SBTM_RED, GetConVar("sbtm_name_red"):GetString()     or "Red Team",      SBTM:ConVarTeamColor(SBTM_RED), false)
    team.SetUp(SBTM_BLU, GetConVar("sbtm_name_blue"):GetString()    or "Blue Team",     SBTM:ConVarTeamColor(SBTM_BLU), false)
    team.SetUp(SBTM_GRN, GetConVar("sbtm_name_green"):GetString()   or "Green Team",    SBTM:ConVarTeamColor(SBTM_GRN), false)
    team.SetUp(SBTM_YEL, GetConVar("sbtm_name_yellow"):GetString()  or "Yellow Team",   SBTM:ConVarTeamColor(SBTM_YEL), false)
end)

SBTM.TeamProperties = {
    ["noclip"]          = {so = 1, type = "b", default = true},
    ["teamdmg"]         = {so = 2, type = "b", default = true},
    ["deathspec"]       = {so = 3, type = "b", default = false},
    ["physgun"]         = {so = 4, type = "b", default = true, ao = true}, -- ao means "admin override". only affects description
    ["toolgun"]         = {so = 5, type = "b", default = true, ao = true},
    ["spawnprop"]       = {so = 51, type = "b", default = true, ao = true},
    ["spawngun"]        = {so = 52, type = "b", default = true, ao = true},
    ["spawnent"]        = {so = 53, type = "b", default = true, ao = true},
    ["spawnnpc"]        = {so = 54, type = "b", default = true, ao = true},
    ["spawnveh"]        = {so = 55, type = "b", default = true, ao = true},
    ["health"]          = {so = 101, type = "i", min = 1, default = 100},
    ["armor"]           = {so = 102, type = "i", min = 0, max = 255, default = 0},
    ["walkspeed"]       = {so = 103, type = "i", min = 0, default = 200},
    ["runspeed"]        = {so = 104, type = "i", min = 0, default = 400},
    ["slowwalkspeed"]   = {so = 105, type = "i", min = 0, default = 100},
    ["jumppower"]       = {so = 106, type = "i", min = 0, default = 200},
}
SBTM.TeamConfig = {
    --[team_id] = {prop = val, prop2 = val2},
    --[0] applies to all teams without a value
}