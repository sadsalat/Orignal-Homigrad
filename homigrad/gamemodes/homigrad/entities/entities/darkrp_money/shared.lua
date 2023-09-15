AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Деньги"
ENT.Author = "Jackarunda"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = false

if SERVER then return end

local color_red = Color(140,0,0,100)
local color_white = color_white

function ENT:Draw()
    self:DrawModel()

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    surface.SetFont("ChatFont")
    local text = self:GetNWInt("Amount",0) .. "$"
    local TextWidth = surface.GetTextSize(text)

    cam.Start3D2D(Pos + Ang:Up() * 0.82, Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.5, -10, text, "ChatFont", color_red, color_white)
    cam.End3D2D()

    Ang:RotateAroundAxis(Ang:Right(), 180)

    cam.Start3D2D(Pos, Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.5, -10, text, "ChatFont", color_red, color_white)
    cam.End3D2D()
end

function ENT:Think() end