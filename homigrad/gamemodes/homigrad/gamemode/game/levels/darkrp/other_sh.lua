darkrp.doors = {}
local doors = darkrp.doors
doors.func_door = true
doors.func_movelinear = true
doors.prop_door_rotating = true

local Player = FindMetaTable("Player")

function Player:GetEyeTraceDis(dis)
    local dir = Vector(dis,0,0)
    dir:Rotate(self:EyeAngles())
    local tr = {start = self:EyePos(),filter = self}
    tr.endpos = tr.start + dir

    return util.TraceLine(tr)
end

if SERVER then return end

net.Receive("darkrp notify",function()
    notification.AddLegacy(net.ReadString(),net.ReadInt(16),net.ReadInt(16))
end)