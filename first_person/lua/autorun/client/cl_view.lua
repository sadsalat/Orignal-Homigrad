local ply = LocalPlayer()
local scrw, scrh = ScrW(), ScrH()
local whitelistweps = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
    ["gmod_camera"] = true,
}

function RagdollOwner(rag)
    for k, v in pairs(player.GetAll()) do
        local ply = v
        if ply:GetNWEntity("DeathRagdoll") == rag then 
            return ply
        end
    end
    return false
end

hook.Add("Think","pophead",function()
for i,ent in pairs(ents.GetAll()) do
if !IsValid(RagdollOwner(ent)) or !RagdollOwner(ent):Alive() then
ent:ManipulateBoneScale(6,Vector(1,1,1))
end
end
end)

surface.CreateFont( "Arial", {
  font = "Arial",
  size = 50,
  weight = 700,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = false,
  additive = true,
  outline = false,
} )

local weps = {
["glock18"] = true,
["ak74"] = true,
["ar15"] = true,
["beretta"] = true,
["fiveseven"] = true,
["mp5"] = true,
["m3super"] = true,
["p220"] = true,
["hk_usp"] = true,
["hk_usps"] = true,
["akm"] = true,
["deagle"] = true,
["ak74u"] = true,
["l1a1"] = true,
["fal"] = true,
["galil"] = true,
["galilsar"] = true,
["m14"] = true,
["m1a1"] = true,
["mk18"] = true,
["m249"] = true,
["m4a1"] = true,
["minu14"] = true,
["mp40"] = true,
["rpk"] = true,
["ump"] = true,
}

local MyLerp = 0
local G = 0
local size = 0.03
local angle = Angle(0)
local possight = Vector(0)


local function scopeAiming()
    local wep = LocalPlayer():GetActiveWeapon()
    return IsValid(wep) and LocalPlayer():KeyDown(IN_ATTACK2) and not LocalPlayer():KeyDown(IN_SPEED)
end


hook.Add("CalcView", "salat.ahuel.view", function(ply, vec, ang, fov, znear, zfar)

    local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    local org = eye.Pos
    local ang = ang
    local ang1 = LerpAngle(0.15,LocalPlayer():EyeAngles(),eye.Ang)
    local org1 = eye.Pos + eye.Ang:Up() * 2 + eye.Ang:Forward() * 2.5 
    
    if LocalPlayer():Team() == 1002 then 
    return end

    if not LocalPlayer():Alive() then 
    return end

    if ply:GetNWBool("fake")==true and IsValid(ply:GetNWEntity("DeathRagdoll")) then
        ply:GetNWEntity("DeathRagdoll"):ManipulateBoneScale(6,Vector(0.1,0.1,0.1))
        local attach = LocalPlayer():GetNWEntity("DeathRagdoll"):GetAttachment(1)
        local view = {
            origin = attach.Pos,
            angles = LerpAngle(0.45,ang1,attach.Ang),
            fov = 90,
            drawviewer = true
        }
            return view
    end


    if IsValid(LocalPlayer()) && IsValid(LocalPlayer():GetActiveWeapon()) then
        wep = LocalPlayer():GetActiveWeapon()
        if whitelistweps[wep:GetClass()] and not LocalPlayer():InVehicle() then
        return end
    end
    
    if LocalPlayer():Alive() and IsValid(LocalPlayer()) && IsValid(LocalPlayer()) && IsValid(LocalPlayer():GetActiveWeapon())  then
        LocalPlayer():ManipulateBoneScale( LocalPlayer():LookupBone( "ValveBiped.Bip01_Head1" ), Vector( 0, 0, 0 ) )
        if weps[wep:GetClass()] then
        weaponClass = wep:GetClass()
        local att = wep.Attachments
        if scopeAiming() then 
            
            MyLerp = Lerp( 4*FrameTime() ,  MyLerp, 1)

            else

            MyLerp = Lerp( 6*FrameTime() ,  MyLerp, 0.1)

        end
            if weaponClass == "glock18" then
                org = hand.Pos + hand.Ang:Up() * 3.9 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.45
                ang = hand.Ang + Angle(10,20,0)
            end
            if weaponClass == "ak74" then
                org = hand.Pos + hand.Ang:Up() * 5.2 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "ar15" then
                org = hand.Pos + hand.Ang:Up() * 6.4 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 1.18
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "beretta" then
                org = hand.Pos + hand.Ang:Up() * 4 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.46
                ang = hand.Ang + Angle(10,20,0)
            end
            if weaponClass == "deagle" then
                org = hand.Pos + hand.Ang:Up() * 4.5 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.45
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "fiveseven" then
                org = hand.Pos + hand.Ang:Up() * 4 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.2
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "mp5" then
                org = hand.Pos + hand.Ang:Up() * 6.3 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 1.2
                ang = hand.Ang + Angle(25,20,0)
            end
            if weaponClass == "m3super" then
                org = hand.Pos + hand.Ang:Up() * 4 - hand.Ang:Forward() * 5 + hand.Ang:Right() * 0.9
                ang = hand.Ang + Angle(0,0,0)
            end
            if weaponClass == "p220" then
                org = hand.Pos + hand.Ang:Up() * 4.1 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.45
                ang = hand.Ang + Angle(10,20,0)
            end
            if weaponClass == "hk_usp" or weaponClass == "hk_usps" then
                org = hand.Pos + hand.Ang:Up() * 4.1 - hand.Ang:Forward() * 10 + hand.Ang:Right() * 1.10
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "akm" then
                org = hand.Pos + hand.Ang:Up() * 5.6 - hand.Ang:Forward() * 2 + hand.Ang:Right() * 0.9
                ang = hand.Ang + Angle(20,20,0)
            end
            if weaponClass == "ak74u" then
                org = hand.Pos + hand.Ang:Up() * 5.8 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(20,20,0)
            end
            if weaponClass == "l1a1" then
                org = hand.Pos + hand.Ang:Up() * 5.7 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(25,20,0)
            end
            if weaponClass == "fal" then
                org = hand.Pos + hand.Ang:Up() * 5.7 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(25,20,0)
            end
            if weaponClass == "galil" then
                org = hand.Pos + hand.Ang:Up() * 6.8 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(25,15,0)
            end
            if weaponClass == "galilsar" then
                org = hand.Pos + hand.Ang:Up() * 6.8 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(25,15,0)
            end
            if weaponClass == "m14" then
                org = hand.Pos + hand.Ang:Up() * 6 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.95
                ang = hand.Ang + Angle(15,15,0)
            end
            if weaponClass == "m1a1" then
                org = hand.Pos + hand.Ang:Up() * 5.25 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.15
                ang = hand.Ang + Angle(10,15,0)
            end
            if weaponClass == "mk18" then
                org = hand.Pos + hand.Ang:Up() * 6.4 - hand.Ang:Forward() * 6 + hand.Ang:Right() * 1.35
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "m249" then
                org = hand.Pos + hand.Ang:Up() * 6.4 - hand.Ang:Forward() * 6 + hand.Ang:Right() * 1.3
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "m4a1" then
                org = hand.Pos + hand.Ang:Up() * 6.4 - hand.Ang:Forward() * 6 + hand.Ang:Right() * 1.335
                ang = hand.Ang + Angle(15,20,0)
            end
            if weaponClass == "minu14" then
                org = hand.Pos + hand.Ang:Up() * 5 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.95
                ang = hand.Ang + Angle(15,15,0)
            end
            if weaponClass == "mp40" then
                org = hand.Pos + hand.Ang:Up() * 5 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 0.95
                ang = hand.Ang + Angle(15,15,0)
            end
            if weaponClass == "rpk" then
                org = hand.Pos + hand.Ang:Up() * 5.4 - hand.Ang:Forward() * 4 + hand.Ang:Right() * 1.1
                ang = hand.Ang + Angle(20,20,0)
            end
            if weaponClass == "ump" then
                org = hand.Pos + hand.Ang:Up() * 6.6 - hand.Ang:Forward() * 7 + hand.Ang:Right() * 1.35
                ang = hand.Ang + Angle(15,20,0)
            end
        else
        end
    else  end

    
    if LocalPlayer():Alive() then 
        LocalPlayer():ManipulateBoneScale( LocalPlayer():LookupBone( "ValveBiped.Bip01_Head1" ), Vector( 0.1 ) )
    end

    if LocalPlayer():InVehicle() == true then
       org = eye.Pos + eye.Ang:Forward() * 0.8
       ang = eye.Ang
       MyLerp = 1
       LocalPlayer():ManipulateBoneScale( LocalPlayer():LookupBone( "ValveBiped.Bip01_Head1" ), Vector( 0,0,0 ) )
        anglerp = LerpAngle(MyLerp,ang1,ang)
    else
        anglerp = LerpAngle(MyLerp/4,ang1,ang)
    end
    --Lerp

        --LocalPlayer():ChatPrint(MyLerp)
        
    local view = {
        origin = LerpVector(MyLerp,org1,org),
        angles = LerpAngle(0.01,anglerp,ang1),
        fov = 90,
        drawviewer = true,
        znear = 0.8
    }
    return view
end)

-- Coded by SadSalat
hide = {
["CHudHealth"] = true,
["CHudBattery"] = true,
["CHudAmmo"] = false   ,
["CHudSecondaryAmmo"] = true,
["CHudCrosshair"] = true,
}
hook.Add( "HUDShouldDraw", "HideHUD", function(name)
if (hide[name] ) then return false end
end )

local allowedRanks = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["operator"] = true,
  ["moderator"] = true,
  ["user"] = true,
  ["viptest"] = true,
  ["kakaha"] = true
  ,
}

hook.Add("ContextMenuOpen", "hide_spawnmenu", function()
    if not allowedRanks[LocalPlayer():GetUserGroup()] then
        return false
    end
end)

hook.Add("SpawnMenuOpen", "hide_spawnmenu", function()
    if not allowedRanks[LocalPlayer():GetUserGroup()] then
        return false
    end
end)
--[[прицелчики
hook.Add("PostDrawOpaqueRenderables", "example", function()
    local hand = LocalPlayer():GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
    local eye = LocalPlayer():GetAttachment(ply:LookupAttachment("eyes"))
    possight = hand.Pos + hand.Ang:Up() * 4.4 - hand.Ang:Forward() * -1 + hand.Ang:Right() * -0.15
    angle = hand.Ang + Angle(-90,0,0)
                        
    
    cam.Start3D2D( possight, angle, 1 )
        surface.SetDrawColor( 255, 0, 0, 200)
        draw.NoTexture()
        draw.Circle(0,0,0.05,25 )
    cam.End3D2D()
end )
]]--
