local PANEL = ents.Reg("v_frame","v_panel")
if not PANEL then return end

PANEL.Base = "EditablePanel"

local vgui_color = vgui.color

PANEL:Event_Add("Init","Main",function(self)
    self:Color_Manual("main",{main = vgui_color.main},0.1)
    self:Color_Manual("top",{main = vgui_color.white,focus = vgui_color.use3},0.1)
    self:Color_Manual("text",{main = vgui_color.white},0.1)
    self:Color_Manual("bg",{main = vgui_color.whiteBG},0.1)
    self:Color_Manual("frame1",{main = vgui_color.frame1},0.1)
    self:Color_Manual("frame2",{main = vgui_color.frame2},0.1)

    self.Title = "Example"
    self.TitleFont = "DefaultFixedDropShadow"

    self.TopHeight = 15
end)

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

local nigger = Color(0,0,0)

PANEL:Event_Add("Draw","Main",function(self,w,h,color)
    local topHeight = self.TopHeight

    SetDrawColor(nigger)
    DrawRect(0,0,w,h)

    SetDrawColor(color.main)
    DrawRect(1,2 + topHeight,w - 2,h - topHeight - 3)

    self:SetFocusColor(self:IsActive() and "focus" or "main")

    SetDrawColor(color.bg)
    surface.SetBG("lines_dense_d_r")
    draw.BGScale(1,topHeight + 2,w - 2,h - topHeight - 3,32)

    SetDrawColor(color.top)
    draw.GradientLeft(1,1,w,topHeight)
    SetDrawColor(nigger)

    draw.SimpleText(self.Title,self.TitleFont,5,(topHeight + 1) / 2,color.text,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

    draw.Frame(1,1,w - 2,h - 2,color.frame1,color.frame2)
end)

function PANEL:SetFocusColor(name)
    self:Color_Set("top",name)
end

function PANEL:IsActive()
    return self:HasFocus() or vgui.FocusedHasParent(self)
end

/*timer.Simple(0,function()
    if IsValid(testPanel) then testPanel:Remove() end

    testPanel = vgui.XCreate("v_frame")
    testPanel.w = 250
    testPanel.h = 250
    testPanel.dx = 0.5
    testPanel.dy = 0.5
    testPanel.ax = 0.5
    testPanel.ay = 0.5
    testPanel:MakePopup()
    testPanel:Transform()--always need
end)*/