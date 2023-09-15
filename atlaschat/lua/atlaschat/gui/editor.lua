surface.CreateFont("atlaschat.editor.label", {font = "Open Sans Semibold", size = 18, weight = 400})
surface.CreateFont("atlaschat.editor.button", {font = "Open Sans", size = 15, weight = 400})

local panel = {}

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:DockPadding(12, 58, 12, 48)
	
	self.finish = self:Add("Panel")
	self.finish:SetCursor("hand")
	self.finish:SetSize(72, 24)
	
	function self.finish:Paint(w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(50, 50, 50))
		
		if (self.Hovered) then
			draw.RoundedBox(2, 0, 0, w, h, Color(80, 80, 80))
		end
		
		draw.SimpleText("Complete", "atlaschat.editor.button", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function self.finish.OnMousePressed()
		self:OnFinish()
	end
	
	self.cancel = self:Add("Panel")
	self.cancel:SetCursor("hand")
	self.cancel:SetSize(72, 24)
	
	function self.cancel:Paint(w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(50, 50, 50))
		
		if (self.Hovered) then
			draw.RoundedBox(2, 0, 0, w, h, Color(80, 80, 80))
		end
		
		draw.SimpleText("Cancel", "atlaschat.editor.button", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function self.cancel.OnMousePressed()
		self:OnCancel()
		
		self:Remove()
	end
	
	local label = self:Add("DLabel")
	label:SetText("Enter Text")
	label:SetFont("atlaschat.editor.label")
	label:SizeToContents()
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, 8)
	label:SetZPos(-5)
	
	self.entry = self:Add("DTextEntry")
	self.entry:SetTall(20)
	self.entry:Dock(TOP)
	self.entry:DockMargin(0, 0, 0, 8)
	self.entry:SetZPos(-4)
	
	function self.entry:OnChange()
		local value = self:GetText()
		
		if (ValidPanel(self.preview)) then
			self.preview:Clear()
			self.preview:InvalidateLayout(true)
		
			self.preview.value = value
			self.preview.nextUpdate = CurTime() +0.2
		end
	end
	
	local label = self:Add("DLabel")
	label:SetText("Preview")
	label:SetFont("atlaschat.editor.label")
	label:SizeToContents()
	label:Dock(TOP)
	label:DockMargin(0, 0, 0, 8)
	label:SetZPos(-3)
	
	self.preview = self:Add("Panel")
	self.preview:Dock(FILL)
	self.preview:DockPadding(4, 10, 4, 10)

	local base = self.preview:Add("EditablePanel")
	base:Dock(FILL)

	self.entry.preview = base

	function base:Think()
		if (self.nextUpdate and self.nextUpdate <= CurTime()) then
			atlaschat.ParseExpressionPreview(base)
		
			self.nextUpdate = nil
		end
	end
	
	function self.preview:Paint(w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(50, 50, 50))
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:SetValue(value)
	self.entry:SetText(value)
	self.entry:OnChange()
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:GetValue()
	return self.entry:GetText()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnFinish()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnCancel()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:PerformLayout()
	self.BaseClass.PerformLayout(self)
	
	local w, h = self:GetSize()
	
	self.finish:SetPos(w -84, h -36)
	self.cancel:SetPos(0, h -36)
	self.cancel:MoveLeftOf(self.finish, 10)
end

vgui.Register("atlaschat.editor", panel, "atlaschat.form")

-- vk.com/urbanichka