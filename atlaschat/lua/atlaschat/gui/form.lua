surface.CreateFont("atlaschat.form", {font = "Open Sans", size = 24, weight = 400})

local panel = {}

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:DockPadding(12, 58, 12, 12)
end

----------------------------------------------------------------------	
-- Purpose:
--		Called whenever the panels layout was invalidated.
----------------------------------------------------------------------

function panel:PerformLayout()
	local w, h = self:GetSize()
	
	self.close:SetPos(w -34, 22)
end


----------------------------------------------------------------------	
-- Purpose:
--		Called whenever the panel should be drawn.
----------------------------------------------------------------------

function panel:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, Color(37, 37, 37))

	draw.SimpleText(self.title, "atlaschat.form", 12, 26, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	draw.SimpleRect(12, 26 +20, w -24, 1, Color(50, 50, 50))
	
	surface.DisableClipping(true)
		util.PaintShadow(w, h, -w, -h, 3, 0.16)
	surface.DisableClipping(false)
end

vgui.Register("atlaschat.form", panel, "atlaschat.frame")

-- vk.com/urbanichka