local PANEL = ents.Reg("v_panel","lib_event",true)
if not PANEL then return INCLUDE_BREAK end

PANEL.Base = "Panel"

vgui.Panels = vgui.Panels or {}
local Panels = vgui.Panels

vgui.CreatePanels = vgui.CreatePanels or {}
local CreatePanels = vgui.CreatePanels

PANEL.IsX = true--мы люди икс

PANEL:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class.NonRegisterGMOD then return end

    Panels[content.ClassName] = class

    for panel in pairs(CreatePanels) do
        if not IsValid(panel) then CreatePanels[panel] = nil continue end
        if panel.ClassName ~= content.ClassName then continue end

        util.tableLink(panel:GetTable(),content)
    end
end)

concommand.Add("hg_removeallvgui",function()
    for panel in pairs(CreatePanels) do
        if IsValid(panel) then panel:Remove() end

        CreatePanels[panel] = nil
    end
end)

function vgui.XCreate(class,parent)
    local object = Panels[class]
    local content = object[1]

    local panel = vgui.CreateFromTable(content)
    panel:SetParent(parent)
    CreatePanels[panel] = true

    return panel
end

function PANEL:Init()
    self.mouse = {}
    self.mouseCount = 0
    self.keyboard = {}
    self.keyboardCount = 0

    self:Event_Call("Init")
    self:SetVisible(true)
end

local input_IsMouseDown = input.IsMouseDown
local input_IsKeyDown = input.IsKeyDown

function PANEL:Paint(w,h)
    self:Event_Call("Draw",w,h,self.color)
end

function PANEL:PaintOver(w,h)
    self:Event_Call("Draw Over",w,h,self.color)
end

local GetHoveredPanel = vgui.GetHoveredPanel

function PANEL:Think()
    self.isHovered = self:IsHovered()
    self.getHovered = GetHoveredPanel()

    self:Event_Call("Think")
end

PANEL:Event_Add("Think","Mouse",function(self)
    local mouse = self.mouse
    for key in pairs(mouse) do
        if input_IsMouseDown(key) then continue end

        self:OnMouseReleased(key,true)
    end

    local keyboard = self.keyboard
    for key in pairs(keyboard) do
        if input_IsKeyDown(key) then continue end

        self:OnKeyCodeReleased(key,true)
    end
end,-1)

function PANEL:OnMousePressed(key)
    self.mouse[key] = true
    self.mouseCount = self.mouseCount + 1
    self.mouseDown = true

    self:Event_Call("Mouse",key,true,true)
end

function PANEL:OnMouseReleased(key,inNonSelf)
    if not self.mouse[key] then return end
    self.mouse[key] = nil
    self.mouseCount = self.mouseCount - 1
    self.mouseDown = self.mouseCount > 0

    self:Event_Call("Mouse",key,false,not inNonSelf)
end

function PANEL:OnKeyCodePressed(key)
    self.keyboard[key] = true

    self:Event_Call("Key",key,true,true)
end

function PANEL:OnKeyCodeReleased(key,inNonSelf)
    if not self.keyboard[key] then return end
    self.keyboard[key] = nil

    self:Event_Call("Key",key,false,not inNonSelf)
end

function PANEL:OnMouseWheeled(wheel) self:Event_Call("Mouse Wheel",-wheel) end

function PANEL:OnRemove()
    CreatePanels[self] = nil

    self:Event_Call("Remove")
end

local Panel = FindMetaTable("Panel")

if not vgui.hSetParent then vgui.hSetParent = Panel.SetParent end
local SetParent = vgui.hSetParent

function Panel:SetParent(panel)
    if not IsValid(panel) then return end

    local result,result2

    if self.Event_Call then result = self:Event_Call("Parent",panel,self) end
    if panel.Event_Call then result2 = panel:Event_Call("Parent",panel,self) end

    if result == false or result2 == false then return end--;c

    local parent,child = self,panel

    if TypeID(result) == TYPE_PANEL then parent = result end
    if TypeID(result2) == TYPE_PANEL then panel = result2 end

    SetParent(parent,panel)--lol......
end

local MouseX,MouseY = gui.MouseX,gui.MouseY

function PANEL:GetMousePos()
    local x,y = self:LocalToScreen(0,0)

    return x - MouseX(),y - MouseY()
end