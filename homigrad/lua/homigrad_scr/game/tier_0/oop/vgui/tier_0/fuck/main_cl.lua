local PANEL = ents.Get("v_panel")
if not PANEL then return end

local manual = {main = vgui.color.main}
local manualFrame1 = {main = vgui.color.frame1}
local manualFrame2 = {main = vgui.color.frame2}

PANEL:Event_Add("Init","Main",function(self)
    self:Color_Manual("main",manual,0.1)
    self:Color_Manual("frame1",manualFrame1,0.1)
    self:Color_Manual("frame2",manualFrame2,0.1)
end)

PANEL:Event_Add("Draw","Main",function(self,w,h,color)
    local main = color.main

    draw.RoundedBox(0,0,0,w,h,main)
    draw.Frame(0,0,w,h,color.frame1,color.frame2)
end)

/*timer.Simple(0,function()
    if IsValid(testPanel) then testPanel:Remove() end

    testPanel = vgui.XCreate("v_panel")
    testPanel.w = 250
    testPanel.h = 250
    testPanel.dx = 0.5
    testPanel.dy = 0.5
    testPanel.ax = 0.5
    testPanel.ay = 0.5
    testPanel:Transform()--always need
end)*/