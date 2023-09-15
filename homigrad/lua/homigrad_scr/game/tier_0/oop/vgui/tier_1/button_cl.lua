local PANEL = ents.Reg("v_button","v_panel")
if not PANEL then return end

local vgui_color = vgui.color

local nocolor = Color(0,0,0,0)

PANEL:Event_Add("Init","Main",function(self)
    self:Color_Manual("main",{main = vgui_color.main},0.1)

    self.Title = "Example"
    self.TitleFont = "DefaultFixedDropShadow"

    self.TitleDownX = 1
    self.TitleDownY = 1

    self.lerpDown = 0
    self.lerpHovered = 0
end)

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

local nigger = Color(0,0,0)

local LerpFT = LerpFT

PANEL:Event_Add("Draw","Main",function(self,w,h,color)
    local topHeight = self.TopHeight

    SetDrawColor(nigger)
    DrawRect(0,0,w,h)

    SetDrawColor(color.main)
    DrawRect(1,1,w - 2,h - 2)

    local down,hovered = self.mouseDown,self.isHovered

    self.lerpDown = LerpFT(0.5,self.lerpDown,down and 1 or 0)
    self.lerpHovered = LerpFT(0.5,self.lerpHovered,(hovered and not down and 1) or 0)

    SetDrawColor(0,0,0,50 * self.lerpDown)
    DrawRect(1,1,w - 2,h - 2)

    SetDrawColor(255,255,255,5 * self.lerpHovered)
    DrawRect(1,1,w - 2,h - 2)

    draw.SimpleText(
        self.Title,
        self.TitleFont,
        (down and self.TitleDownX or 0) + w / 2,
        (down and self.TitleDownY or 0) + h / 2,
        color.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER
)
end)

PANEL:Event_Add("Mouse","Main",function(self,key,down,inSelf)
    if not down and inSelf then
        self:Event_Call("Click",key)
    end
end)

/*timer.Simple(0,function()
    if IsValid(testPanel) then testPanel:Remove() end

    testPanel = vgui.XCreate("v_frame")
    testPanel.w = 250
    testPanel.h = 250
    testPanel.dx = 0.5
    testPanel.dy = 0.01
    testPanel.ax = 0.5
    testPanel.ay = 0
    testPanel:MakePopup()

    local button = vgui.XCreate("v_button",testPanel)
    button.dw = 0.5
    button.dh = 0.5
    button.ax = 0.5
    button.ay = 0.5
    button.dx = 0.5
    button.dy = 0.5--lol
    
    button:Event_Add("Click","Main",function(self,key)
        button.ax = button.ax + (key == MOUSE_LEFT and 0.1 or -0.1)
        button:Transform()
    end)

    testPanel:Transform()--always need
end)*/