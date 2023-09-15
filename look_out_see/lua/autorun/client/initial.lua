SIX = SIX or {}

SIX.CurSide = 1
--[[
    0 - Stand
    1 - Left
    2 - Right
]]
SIX.Force = 11 -- Angle 
SIX.Speed = 0.08

SIX.SideAngleRoll = 0
SIX.SideAngleRollFinish = 0
SIX.SideAngleRollOld = 0

SIX.Binds = {
    left = false,
    right = false
}

local holdpush = 0
local oldside = 0

local anng = Angle(0,0,0)
local pppos = Vector(0,0,0)

hook.Add("CalcView","SIX.CalcView",function( ply, pos, angles, fov )

    if LocalPlayer():InVehicle() then return end

    if SIX.Binds.left then
        SIX.CurSide = 1
    elseif SIX.Binds.right then
        SIX.CurSide = 2
    else
        SIX.CurSide = 0
    end

    if SIX.CurSide == 1 then
        SIX.SideAngleRoll = -SIX.Force
    elseif SIX.CurSide == 2 then
        SIX.SideAngleRoll = SIX.Force
    elseif SIX.CurSide == 0 then
        SIX.SideAngleRoll = 0
    end

    if oldside ~= SIX.CurSide then
        net.Start("SIX.SIDETO")
            net.WriteInt( SIX.CurSide,3 )
        net.SendToServer()
        oldside = SIX.CurSide
    end

    SIX.SideAngleRollFinish = Lerp(SIX.Speed,SIX.SideAngleRollOld,SIX.SideAngleRoll)

    SIX.SideAngleRollOld = SIX.SideAngleRollFinish


    anng = Angle(angles.x,angles.y,SIX.SideAngleRollFinish)

    local ispl = LocalPlayer():GetViewEntity() == LocalPlayer()

    local view = {
    }

	return view
end )

print("Look out - Loaded!")

-- I am quite ashamed of this, I do not know how to use this type of command (⊙_⊙;)

concommand.Add("+leanleft", function( ply, cmd, args )
    SIX.Binds.left = true
end)

concommand.Add("-leanleft", function( ply, cmd, args )
    SIX.Binds.left = false
end)

concommand.Add("+leanright", function( ply, cmd, args )
    SIX.Binds.right = true
end)

concommand.Add("-leanright", function( ply, cmd, args )
    SIX.Binds.right = false
end)


