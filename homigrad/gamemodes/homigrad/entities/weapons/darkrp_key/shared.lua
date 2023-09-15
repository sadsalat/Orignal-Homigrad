AddCSLuaFile()

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.PrintName = "Ключи"
SWEP.Category = "DarkRP"
SWEP.Author = "0oa"

SWEP.AdminOnly = false
SWEP.Spawnable = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Slot = 1
SWEP.SlotPos = -1

local stunstickMaterials
function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()

end

function SWEP:Holster()
    return true
end

function SWEP:Think() end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:Reload() end

if SERVER then return end

net.Receive("darkrp anim key",function()
    net.ReadEntity():AnimRestartGesture(GESTURE_SLOT_CUSTOM,net.ReadBool() and ACT_GMOD_GESTURE_ITEM_PLACE or ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,true)
end)

net.Receive("darkrp door buy",function(len,ply)
    if IsValid(darkrpBuyDoor) then darkrpBuyDoor:Remove() end--lol

    local ent = net.ReadEntity()
    local price = net.ReadInt(16)

    darkrpBuyDoor = vgui.Create("DFrame")
    darkrpBuyDoor:SetSize(200,75)
    darkrpBuyDoor:Center()
    darkrpBuyDoor:MakePopup()

    local button = vgui.Create("DButton",darkrpBuyDoor)
    button:SetText("Купить за " .. price .. "$")
    button:SetSize(180,25)
    button:SetPos(10,darkrpBuyDoor:GetTall() / 2 - button:GetTall() / 2)

    button.DoClick = function()
        net.Start("darkrp door buy")
        net.WriteEntity(ent)
        net.SendToServer()

        darkrpBuyDoor:Remove()
    end
end)

net.Receive("darkrp door menu",function(len,ply)
    if IsValid(darkrpBuyDoor) then darkrpBuyDoor:Remove() end--lol

    local door = net.ReadEntity()
    local price = net.ReadInt(16)
    local buy = net.ReadTable()

    darkrpBuyDoor = vgui.Create("DFrame")
    darkrpBuyDoor:SetSize(200,125)
    darkrpBuyDoor:Center()
    darkrpBuyDoor:MakePopup()

    local button = vgui.Create("DButton",darkrpBuyDoor)
    button:SetText("Продать за " .. price .. "$")
    button:SetSize(180,25)
    button:SetPos(10,30)

    button.DoClick = function()
        net.Start("darkrp door sell")
        net.WriteEntity(door)
        net.SendToServer()

        darkrpBuyDoor:Remove()
    end

    local button = vgui.Create("DButton",darkrpBuyDoor)
    button:SetText("Добавить совладельца")
    button:SetSize(180,25)
    button:SetPos(10,55)

    local lply = LocalPlayer()

    button.DoClick = function()
        local menu = vgui.Create("DMenu")
        menu:SetPos(input.GetCursorPos())

        for i,ply in pairs(player.GetAll()) do
            if ply == lply or buy.cowner[ply] then continue end

            menu:AddOption(ply:Name(),function()
                net.Start("darkrp door add")
                net.WriteEntity(door)
                net.WriteEntity(ply)
                net.SendToServer()
            end)
        end
    end
end)