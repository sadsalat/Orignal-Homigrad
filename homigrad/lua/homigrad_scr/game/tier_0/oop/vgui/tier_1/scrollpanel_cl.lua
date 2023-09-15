local PANEL = ents.Reg("v_scrollpanel","v_panel")
if not PANEL then return end

local vgui_color = vgui.color

PANEL:Event_Add("Init","Main",function(self)
    self:Color_Manual("mainBack",{main = Color(0,0,0,200)},0.1)
    self:Color_Manual("main",{main = vgui_color.main2},0.1)
    self:Color_Manual("bg",{main = vgui_color.whiteBG},0.1)
    self:Color_Manual("gradientLimit",{main = Color(255,255,255,5)},0.1)
    self:Color_Manual("frame1",{main = vgui_color.frame1},0.1)
    self:Color_Manual("frame2",{main = vgui_color.frame2},0.1)

    self.overrideParent = true
    local canvasPanel = vgui.XCreate("v_panel",self)
    self.overrideParent = nil
    self.canvasPanel = canvasPanel
    canvasPanel.isScrollPanel = true
    canvasPanel:Event_Add("Draw","Main",self.DrawHook)
    canvasPanel:Event_Add("Transform","Scroll",self.TransformHook)
    canvasPanel:Event_Add("Mouse Wheel","Scroll",self.MouseWheelHook)
    self.mouse = canvasPanel.mouse--haha

    self.ScrollSetX = 0
    self.ScrollSetY = 0
    self.isScrollPanel = true


    self.scrollAnimLeft = 0
    self.scrollAnimRight = 0
    self.scrollAnimUp = 0
    self.scrollAnimDown = 0
end)

--

function PANEL:TransformHook() self:GetParent():Event_Call("Transform Child") end
function PANEL:MouseWheelHook(wheel) self:GetParent():Event_Call("Mouse Wheel",wheel,true) end

PANEL:Event_Add("Transform Child","Main",function(self)
    if self.OverrideTransform then return end
    self:TransformCanvasPanel()
end)

PANEL:Event_Add("Transform","Main",function(self) self:TransformCanvasPanel() end)

function PANEL:TransformCanvasPanel()
    local panel = self.canvasPanel
    local w,h = panel.contentW,panel.contentH
    if w < self.w then w = self.w else w = w + 1 end
    if h < self.h then h = self.h else h = h + 1 end

    panel.ww = w
    panel.hh = h

    panel:Transform()
end

PANEL:Event_Add("Parent","Main",function(self,parent,child)
    if self.overrideParent or self ~= parent then return end

    return self.canvasPanel
end)

--

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

function PANEL:DrawHook(w,h,color)
    local parent = self:GetParent()
    color = parent.color

    SetDrawColor(color.main)
    DrawRect(0,0,w,h)

    SetDrawColor(color.bg)
    surface.SetBG("box_points")
    draw.BGScale(0,0,w,h,32)
end

local LerpFT = LerpFT

local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect

PANEL:Event_Add("Draw","Main",function(self,w,h,color)
    SetDrawColor(color.main)
    DrawRect(0,0,w,h)
end)

local max = math.max

PANEL:Event_Add("Draw Over","Main",function(self,w,h,color)
    SetDrawColor(color.gradientLimit)

    local v = max(-self.ScrollY,0)
    DrawRect(0,0,w,v)
    draw.GradientUp(0,0,w,v)

    local v = max(self.ScrollY - self.ScrollMaxY,0)
    DrawRect(0,h - v,w,v)
    draw.GradientDown(0,h - v,w,v)

    local v = max(-self.ScrollX,0)
    DrawRect(0,0,v,h)
    draw.GradientLeft(0,0,v,h)

    local v = max(self.ScrollX - self.ScrollMaxX,0)
    DrawRect(w - v,0,v,h)
    draw.GradientRight(w - v,0,v,h)

    draw.Frame(0,0,w,h,color.frame2,color.frame1)

    local size = h * (h / (self.ScrollMaxY + h))
    local k = self.ScrollY / (self.ScrollMaxY + h)
    DrawRect(w - 1,h * k,1,size)

    size = w * (w / (self.ScrollMaxX + w))
    k = self.ScrollX / (self.ScrollMaxX + w)
    DrawRect(w * k,h - 1,size,1)
end)

--

local Clamp,Round = math.Clamp,math.Round
local LerpFT = LerpFT

function PANEL:IsHovered()
    return self.isHovered or self.canvasPanel.isHovered
end

PANEL:Event_Add("Think","Main",function(self)
    if self.ScrollX then
        self.ScrollX = Round(LerpFT(0.1,self.ScrollX,self.ScrollSetX),2)
        self.ScrollMaxX = self.canvasPanel.w - self.w
        self.ScrollSetX = Clamp(self.ScrollSetX,0,self.ScrollMaxX)
        self.canvasPanel.xx = -self.ScrollX
    end

    if self.ScrollY then
        self.ScrollY = Round(LerpFT(0.1,self.ScrollY,self.ScrollSetY),2)
        self.ScrollMaxY = self.canvasPanel.h - self.h
        self.ScrollSetY = Clamp(self.ScrollSetY,0,self.ScrollMaxY)
        self.canvasPanel.yy = -self.ScrollY
    end

    local active = input.IsKeyDown(KEY_LSHIFT) and self.mouse[MOUSE_LEFT] and true or false--LOL??????? ну да..;c;c;c

    if active ~= self.oldShift then
        self.oldShift = active

        if self:IsHovered() and active then
            self.mouseX,self.mouseY = self:GetMousePos()
            self.ScrollSetXStatic = self.ScrollSetX
            self.ScrollSetYStatic = self.ScrollSetY
        else
            self.mouseX = nil
        end
    end

    if self.mouseX then
        local mouseX,mouseY = self:GetMousePos()
        local x,y = self.mouseX - mouseX,self.mouseY - mouseY

        if self.ScrollX then
            self.ScrollSetX = Clamp(self.ScrollSetXStatic - x,0,self.ScrollMaxX)
            --self.ScrollSetX = self.ScrollSetXStatic - x
            self.ScrollX = self.ScrollSetX
        end

        if self.ScrollY then
            self.ScrollSetY = Clamp(self.ScrollSetYStatic - y,0,self.ScrollMaxY)
           -- self.ScrollSetY = self.ScrollSetYStatic - y
            self.ScrollY = self.ScrollSetY
        end
    end
end)

function PANEL:SetScrollX(value)
    self.ScrollSetX = value
end

function PANEL:SetScrollY(value)
    self.ScrollSetY = value
end

PANEL:Event_Add("Mouse Wheel","Main",function(self,wheel,ignore)
    if not ignore and self.getHovered.isScrollPanel and not self.isHovered then return end

    wheel = wheel * 25

    if self.ScrollX then
        if input.IsKeyDown(KEY_LSHIFT) then
            self.ScrollSetX = self.ScrollSetX + wheel
        else
            self.ScrollSetY = self.ScrollSetY + wheel
        end
    else
        self.ScrollSetY = self.ScrollSetY + wheel
    end
end)

/*timer.Simple(0,function()
    if IsValid(testPanel) then testPanel:Remove() end

    testPanel = vgui.XCreate("v_frame")
    testPanel.ww = 250
    testPanel.hh = 250
    testPanel.dx = 0.5
    testPanel.dy = 0.5
    testPanel.ax = 0.5
    testPanel.ay = 0.5
    testPanel:MakePopup()

    local scrollPanel = vgui.XCreate("v_scrollpanel",testPanel)
    scrollPanel.dw = 0.9
    scrollPanel.dh = 0.8
    scrollPanel.dx = 0.5
    scrollPanel.dy = 0.5
    scrollPanel.ax = 0.5
    scrollPanel.ay = 0.5
    scrollPanel.ScrollX = 0
    scrollPanel.ScrollY = 0

    local button = vgui.XCreate("v_button",scrollPanel)
    button.ww = 50
    button.hh = 50
    button.xx = 512
    button.yy = 512

    testPanel:Transform()--always need
end)*/
