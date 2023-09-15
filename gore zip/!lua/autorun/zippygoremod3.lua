-- Decide if custom blood effects are installed:
if CLIENT then

    net.Receive("ZippyGore3_CustomBloodInstalled", function()
        ZGM3_INSANE_BLOOD_EFFECTS = net.ReadBool()
        ZGM3_ANIMATED_BLOOD = net.ReadBool()
    end)
    hook.Add("InitPostEntity", "ZippyGore3_InitPostEntity", function()
        net.Start("ZippyGore3_CheckCustomBloodInstalled")
        net.SendToServer()
    end)

end
if SERVER then

    ZGM3_INSANE_BLOOD_EFFECTS = file.Exists("autorun/server/zippy_realistic_blood.lua", "LUA")
    ZGM3_ANIMATED_BLOOD = file.Exists("autorun/server/zippy_realistic_blood2.lua", "LUA")
    util.AddNetworkString("ZippyGore3_CheckCustomBloodInstalled")
    util.AddNetworkString("ZippyGore3_CustomBloodInstalled")
    net.Receive("ZippyGore3_CheckCustomBloodInstalled", function()
        net.Start("ZippyGore3_CustomBloodInstalled")
        net.WriteBool(ZGM3_INSANE_BLOOD_EFFECTS)
        net.WriteBool(ZGM3_ANIMATED_BLOOD)
        net.Broadcast()
    end)

    -- Animated blood: Splatter effect from client
    if ZGM3_ANIMATED_BLOOD then
        util.AddNetworkString("ZGM3AnimBloodSplatter")
        net.Receive("ZGM3AnimBloodSplatter", function()
            ANIMATED_SPLATTER_EFFECT(net.ReadVector(), net.ReadNormal(), math.random(1, 100), net.ReadVector())
        end)
    end

end

-- New synth blood color:
BLOOD_COLOR_ZGM3SYNTH = 7

-- Run files:
local function lua_file( name, cl )
    local full_name = "zippygoremod3/"..name..".lua"

    AddCSLuaFile(full_name)

    if !(cl && SERVER) then
        include(full_name)
    end
end
-- Shared
lua_file("cvars")
lua_file("sounds")
lua_file("particles")
lua_file("dismemberment")
lua_file("default_gibs")
-- Client
lua_file("toolmenu", true)
-- Server
if SERVER then
    lua_file("setup")
    lua_file("damage")
    lua_file("dmginfo_ext")
    lua_file("gibs")
end