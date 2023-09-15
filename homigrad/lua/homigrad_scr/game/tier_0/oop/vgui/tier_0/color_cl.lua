local PANEL = ents.Get("v_panel")
if not PANEL then return end

PANEL:Event_Add("Init","Color",function(self)
    self.colorList = {}
    self.color = {}
end,-1)

vgui.color = vgui.color or {}
local color = vgui.color
local function createColor(name,r,g,b,a)
    color[name] = color[name] or Color(0,0,0,255)
    local color = color[name]
    color.r = 255 * r
    color.g = 255 * g
    color.b = 255 * b
    color.a = 255 * (a or 1)
end

createColor("main",0.2,0.2,0.2)
createColor("main2",0.15,0.15,0.15)
createColor("white",1,1,1)
createColor("whiteBG",1,1,1,0.005)
createColor("black",0,0,0)

createColor("use",0.5,1,0.1)
createColor("use2",1,0.5,0.25)
createColor("use3",0.25,0.25,1)

createColor("frame1",1,1,1,0.05)
createColor("frame2",0,0,0,0.4)

function PANEL:Color_Manual(name,manual,l)
    local color = Color(0,0,0)
    local colorSet = manual.main

    color.r = colorSet.r
    color.g = colorSet.g
    color.b = colorSet.b
    color.a = colorSet.a

    self.colorList[name] = {l,color,colorSet,manual,"main"}
    self.color[name] = color
end

local LerpFT = LerpFT

local function LerpColor(t,to,from)
    to.r = LerpFT(t,to.r,from.r)
    to.g = LerpFT(t,to.g,from.g)
    to.b = LerpFT(t,to.b,from.b)
    to.a = LerpFT(t,to.a,from.a)
end

PANEL:Event_Add("Draw","Color",function(self)
    for name,color in pairs(self.colorList) do
        LerpColor(color[1],color[2],color[3])
    end
end,-1)

function PANEL:Color_Set(name,nameColor)
    local color = self.colorList[name]
    color[3] = color[4][nameColor]
    color[5] = nameColor
end

function PANEL:Color_ChangeManual(name,nameColor,color)
    name = self.colorList[name]
    name[4][nameColor] = color

    if color[5] == nameColor then name[3] = color end
end

function PANEL:Color_Lerp(name,lerp)
    self.colorList[name][1] = lerp
end