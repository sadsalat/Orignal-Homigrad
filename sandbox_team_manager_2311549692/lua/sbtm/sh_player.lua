hook.Add("PlayerSpawn", "SBTM", function(ply)
    local t = ply:Team()
    if GetConVar("sbtm_setplayercolor"):GetBool() then
        SBTM:SetPlayerColor(ply, t)
    end
    if t == TEAM_SPECTATOR then
        timer.Simple(1, function()
            --ply:StripWeapons()
            ply:KillSilent()
            ply:Spectate(OBS_MODE_ROAMING)
        end)
    elseif GetConVar("sbtm_teamproperties"):GetBool() then
        timer.Simple(0, function()
        end)
    end
end)

hook.Add("PlayerChangedTeam", "SBTM", function(ply, oldTeam, newTeam)
    if ply:Alive() and newTeam == TEAM_SPECTATOR then
        --ply:StripWeapons()
        ply:Spawn()
        ply:Spectate(OBS_MODE_ROAMING)
        ply:SetNoTarget(true)
    elseif oldTeam == TEAM_SPECTATOR then
        ply:UnSpectate()
        ply:SetNoTarget(false)
        timer.Simple(0, function() ply:Spawn() end)
    end
end)

hook.Add("PlayerSelectSpawn", "SBTM", function(ply)
    local spawns = {}
    for _, e in pairs(SBTM.Spawns) do
        if e:GetTeam() == ply:Team() then
            local tr = util.TraceHull({
                start = e:GetPos(),
                endpos = e:GetPos(),
                maxs = Vector(16, 16, 72),
                mins = Vector(-16, -16, 0),
                filter = e
            })
            if not tr.Hit then
                table.insert(spawns, e)
            end
        end
    end
    if #spawns > 0 then return spawns[math.random(1, #spawns)] end
end)

hook.Add("PlayerDeathThink", "SBTM", function(ply)
    if ply:Team() == TEAM_SPECTATOR then return false end
end)

hook.Add("PlayerCanPickupWeapon", "SBTM", function(ply, wep)
    if ply:Team() == TEAM_SPECTATOR then return false end
end)

hook.Add("AllowFlashlight", "SBTM", function(ply, wep)
    if ply:Team() == TEAM_SPECTATOR then return false end
end)

hook.Add("PlayerNoClip", "SBTM", function(ply, state)
    if GetConVar("sbtm_teamproperties"):GetBool() and state and not SBTM:GetTeamProperty(ply:Team(), "noclip") and (not GetConVar("sbtm_teamproperties_adminoverride"):GetBool() or not ply:IsAdmin()) then
        return false
    end
end)

hook.Add("PhysgunPickup", "SBTM", function(ply, ent)
    if GetConVar("sbtm_nopickup"):GetBool() and ent.SBTM_NoPickup then return ply:IsAdmin() end
    if (GetConVar("sbtm_teamproperties"):GetBool() and not SBTM:GetTeamProperty(ply:Team(), "physgun")) and (not GetConVar("sbtm_teamproperties_adminoverride"):GetBool() or not ply:IsAdmin()) then
        return false
    end
end)

hook.Add("CanTool", "SBTM", function(ply, ent)
    if GetConVar("sbtm_nopickup"):GetBool() and ent.SBTM_NoPickup then return ply:IsAdmin() end
    if (GetConVar("sbtm_teamproperties"):GetBool() and not SBTM:GetTeamProperty(ply:Team(), "toolgun")) and (not GetConVar("sbtm_teamproperties_adminoverride"):GetBool() or not ply:IsAdmin()) then
        if SERVER then
            SBTM:Hint(ply, "#sbtm.hint.permission_toolgun", NOTIFY_ERROR)
        end
        return false
    end
end)

local function sweplimit(ply, class, swep)
    if not GetConVar("sbtm_teamproperties"):GetBool() or (GetConVar("sbtm_teamproperties_adminoverride"):GetBool() and ply:IsAdmin()) then return end

    if class == "weapon_physgun" and not SBTM:GetTeamProperty(ply:Team(), "physgun") then
        SBTM:Hint(ply, "#sbtm.hint.permission_physgun", NOTIFY_ERROR)
        return false
    end
    if class == "gmod_tool" and not SBTM:GetTeamProperty(ply:Team(), "toolgun") then
        SBTM:Hint(ply, "#sbtm.hint.permission_toolgun", NOTIFY_ERROR)
        return false
    end
    if not SBTM:GetTeamProperty(ply:Team(), "spawngun") then
        SBTM:Hint(ply, "#sbtm.hint.permission_spawn", NOTIFY_ERROR)
        return false
    end
end
hook.Add("PlayerSpawnSWEP", "SBTM", sweplimit)
hook.Add("PlayerGiveSWEP", "SBTM", sweplimit)

local function makethinglimit(hookname, prop)
    hook.Add(hookname, "SBTM", function(ply)
        if not GetConVar("sbtm_teamproperties"):GetBool() or (GetConVar("sbtm_teamproperties_adminoverride"):GetBool() and ply:IsAdmin()) then return end
        if not SBTM:GetTeamProperty(ply:Team(), prop) then
            SBTM:Hint(ply, "#sbtm.hint.permission_spawn", NOTIFY_ERROR)
            return false
        end
    end)
end
makethinglimit("PlayerSpawnObject", "spawnprop")
makethinglimit("PlayerSpawnSENT", "spawnent")
makethinglimit("PlayerSpawnNPC", "spawnnpc")
makethinglimit("PlayerSpawnVehicle", "spawnveh")