function darkrp.OnPhysgunFreeze(ply,ent)
    if ply:IsAdmin() then return end

    ent:GetPhysicsObject():EnableMotion(false)

    local pos,mins,maxs = ent:GetPos(),ent:OBBMins(),ent:OBBMaxs()

    for i,ply2 in pairs(player.GetAll()) do
        if not ply2:Alive() or ply2:GetMoveType() == MOVETYPE_NOCLIP then continue end

        if util.IsOBBIntersectingOBB(pos,mins,maxs,ply2:GetPos(),ply2:OBBMins(),ply2:OBBMaxs()) then
            ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

            darkrp.Notify("Игрок в пропе.",NOTIFY_ERROR,5,ply)

            return
        end
    end

    ent:COLLISION_GROUP_DEBRIS(COLLISION_GROUP_NONE)
end

darkrp.PhysgunDrop = darkrp.OnPhysgunFreeze

function darkrp.CanUseSpawnMenu(ply,class)
    if ply:IsAdmin() then return true end

    if not limits[class] then darkrp.Notify("Запрещено.",NOTIFY_ERROR,2,ply) return false end
    if (ply.limits and ply.limits[class] or 0) >= limits[class] then darkrp.Notify("Лимит.",NOTIFY_ERROR,2,ply) return false end

    return true
end

local function removelimit(ent,ply,class)
    ply.limits[class] = ply.limits[class] - 1
end

function darkrp.SpawnObject(ply,class,ent)
    ply.limits = ply.limits or {}
    ply.limits[class] = (ply.limits[class] or 0) + 1

    ent:CallOnRemove("removelimit",removelimit,ply,class)
end

function darkrp.ShouldFakePhysgun(ply,ent) return false end