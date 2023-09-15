local panel = {}

AccessorFunc(panel, "title", "Title")
AccessorFunc(panel, "deleteOnClose", "DeleteOnClose")

local closeImage = Material("atlaschat/cross.png", "smooth")

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self.Dragging = {0, 0}
	
	self:DockPadding(0, 32, 0, 0)
	self:SetTitle("Untitled frame")
	self:SetDeleteOnClose(true)
	
	self.close = self:Add("DImageButton")
	self.close:SetSize(10, 10)

	function self.close:Paint(w, h)
		draw.Material(0, 0, w, h, self.Hovered and color_red or color_white, closeImage)
	end
	
	function self.close.DoClick()
		self:OnClose()
		
		if (self.deleteOnClose) then
			self:Remove()
		else
			self:ToggleVisible()
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnClose()
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnMousePressed()
	if (gui.MouseY() < self.y +20) then
		self.Dragging[1] = gui.MouseX() -self.x
		self.Dragging[2] = gui.MouseY() -self.y
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnMouseReleased()
	self.Dragging = {0, 0}
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Think()
	if (self.Dragging[1] != 0) then
		local x = gui.MouseX() -self.Dragging[1]
		local y = gui.MouseY() -self.Dragging[2]
		
		x = math.Clamp(x, 0, ScrW() -self:GetWide())
		y = math.Clamp(y, 0, ScrH() -self:GetTall())
		
		self:SetPos(x, y)
	end
	
	if (self.Hovered and gui.MouseY() < self.y +20) then
		self:SetCursor("sizeall")
		
		return
	end
	
	self:SetCursor("arrow")
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:PerformLayout()
	local w, h = self:GetSize()
	
	self.close:SetPos(w -25, 12)
end

----------------------------------------------------------------------	
-- Purpose:
--		Called whenever the panel should be drawn.
----------------------------------------------------------------------

function panel:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, Color(37, 37, 37))
	draw.RoundedBoxEx(4, 0, 0, w, 32, Color(41, 128, 185), true, true, false, false)
	
	draw.SimpleText(self.title, "atlaschat.theme.default.title", 12, 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	surface.DisableClipping(true)
		util.PaintShadow(w, h, -w, -h, 3, 0.16)
	surface.DisableClipping(false)
end

vgui.Register("atlaschat.frame", panel, "EditablePanel")

-- vk.com/urbanichka