local gradient_left = Material("homigrad/vgui/gradient_left.png")
local gradient_right = Material("homigrad/vgui/gradient_right.png")
local gradient_up = Material("homigrad/vgui/gradient_up.png")
local gradient_down = Material("homigrad/vgui/gradient_down.png")

local SetMaterial = surface.SetMaterial
local DrawTexturedRect = surface.DrawTexturedRect

function draw.GradientDown(x,y,w,h)
    SetMaterial(gradient_down)
    DrawTexturedRect(x,y,w,h)
end

function draw.GradientUp(x,y,w,h)
    SetMaterial(gradient_up)
    DrawTexturedRect(x,y,w,h)
end

function draw.GradientRight(x,y,w,h)
    SetMaterial(gradient_right)
    DrawTexturedRect(x,y,w,h)
end

function draw.GradientLeft(x,y,w,h)
    SetMaterial(gradient_left)
    DrawTexturedRect(x,y,w,h)
end

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

function draw.Frame(x,y,w,h,color1,color2)
    SetDrawColor(color1.r,color1.g,color1.b,color1.a)

    DrawRect(x,y,w,1)
    DrawRect(x,y,1,h)

    SetDrawColor(color2.r,color2.g,color2.b,color2.a)

    DrawRect(x,y + h - 1,w,1)
    DrawRect(x + w - 1,y,1,h)
end