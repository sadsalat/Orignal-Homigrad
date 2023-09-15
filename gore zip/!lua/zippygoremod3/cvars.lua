ZGM3_CVARS = {
    -- Enable:
    ["zippygore3_enable"] = "1",

    -- Health:
    ["zippygore3_misc_bones_health_mult"] = "1",
    ["zippygore3_root_bone_health_mult"] = "2",

    -- Damage:
    ["zippygore3_phys_damage_mult"] = "0.5",
    ["zippygore3_explosion_damage_mult"] = "4",

    -- Gibbing:
    ["zippygore3_disable_never_gib_damage"] = "0",
    ["zippygore3_disable_always_gib_damage"] = "0",
    ["zippygore3_gib_any_ragdoll"] = "1",
    ["zippygore3_gib_dissolving_ragdoll"] = "1",

    -- Gibs:
    ["zippygore3_gib_limit"] = "200",
    ["zippygore3_gib_lifetime"] = "120",
    ["zippygore3_gib_edible"] = "1",
    ["zippygore3_gib_heath_give"] = "2",

    -- Effects:
    ["zippygore3_bleed_effect"] = "1",

    -- Developer:
    ["zippygore3_print_gibbed_bone"] = "0",

    -- Hidden:
    ["zippygore3_dismemberment"] = "0",
}

for k,v in pairs(ZGM3_CVARS) do
    CreateConVar(k, v, FCVAR_REPLICATED)
end

-- Workaround
local saved_cvars_file = "zippygore3_saved_cvars.json"
if !file.Exists(saved_cvars_file, "DATA") then file.Write(saved_cvars_file, "[]") end
-- Get all saved cvars:
local saved_cvars = util.JSONToTable( file.Read(saved_cvars_file) )
-- Set all saved cvar:
if SERVER then
    for k,v in pairs(saved_cvars) do
        RunConsoleCommand(k, v)
    end
end

-- Always disable dismemberment on startup:
RunConsoleCommand("zippygore3_dismemberment", "0")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
    function ZippyGoreMod3_ChangeCvar( cvar, v )
        net.Start("ZippyGoreMod3_ChangeCvar")
        net.WriteString(cvar)
        net.WriteString(v)
        net.SendToServer()
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if SERVER then
    util.AddNetworkString("ZippyGoreMod3_ChangeCvar")

    net.Receive("ZippyGoreMod3_ChangeCvar", function( _, ply )
        if !ply:IsSuperAdmin() then return end

        local cvar = net.ReadString()
        local v = net.ReadString()

        RunConsoleCommand(cvar, v)

        -- Save cvar:
        saved_cvars[cvar] = v
        file.Write(saved_cvars_file, util.TableToJSON(saved_cvars))
    end)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------