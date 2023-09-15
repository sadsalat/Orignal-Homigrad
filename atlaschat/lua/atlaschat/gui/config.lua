surface.CreateFont("atlaschat.config", {font = "Open Sans", size = 18, weight = 400})
surface.CreateFont("atlaschat.config.category", {font = "Open Sans", size = 18, weight = 400})

local panel = {}

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:SetTitle("CONFIG")
	
	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	
	util.ReplaceScrollbarAtlas(self.list)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Clear(value)
	if (value != nil) then
		local children = self.list:GetCanvas():GetChildren()
		
		for k, child in pairs(children) do
			if (child[value] != nil) then
				child:Remove()
			end
		end
	else
		self.list:Clear()
	end
	
	timer.Simple(0.05, function() self.list:GetCanvas():InvalidateLayout(true) end)
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:AddButton(name, admin, callback)
	local button = vgui.Create("Panel")
	button:SetTall(40)
	button:Dock(TOP)
	button:SetCursor("hand")
	
	button.name = name
	button.admin = admin
	button.callback = callback
	
	function button:Paint(w, h)
		draw.SimpleRect(0, h -1, w, 1, Color(50, 50, 50))
		
		if (self.Hovered) then
			draw.SimpleRect(0, 0, w, h, Color(50, 50, 50))
		end
		
		draw.SimpleText(self.name, "atlaschat.config", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function button:OnMousePressed()
		self.callback()
	end
	
	self.list:AddItem(button)
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:AddItem(left, right)
	local panel = vgui.Create("Panel")
	panel:SetTall(40)
	panel:Dock(TOP)
	
	panel.name = left
	panel.child = right
	panel.admin = right.admin
	
	right:SetParent(panel)
	
	function panel:Paint(w, h)
		draw.SimpleRect(0, h -1, w, 1, Color(50, 50, 50))
		
		draw.SimpleText(self.name, "atlaschat.config", 12, h /2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	function panel:PerformLayout()
		local w, h = self:GetSize()
		
		if (self.child.checkBox) then
			self.child:SetSize(16, 16)
			self.child:SetPos(w -28, h /2 -8)
		else
			self.child:SetSize(w /2.3, 18)
			self.child:SetPos(w -w /2.3 -12, h /2 -9)
		end
	end
	
	self.list:AddItem(panel)
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:AddCategory(name, value)
	local panel = vgui.Create("Panel")
	panel:SetTall(44)
	panel:Dock(TOP)
	
	panel.name = name
	
	if (value != nil) then
		panel[value] = true
	end
	
	function panel:Paint(w, h)
		draw.SimpleRect(0, h -1, w, 1, Color(50, 50, 50))

		draw.SimpleText(self.name, "atlaschat.config.category", 12, h /2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	self.list:AddItem(panel)
end

vgui.Register("atlaschat.config", panel, "atlaschat.frame")

-- vk.com/urbanichka