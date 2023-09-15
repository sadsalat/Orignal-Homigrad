surface.CreateFont("atlaschat.restrictions", {font = "Open Sans", size = 14, weight = 400})

local panel = {}

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:SetTitle("EXPRESSION RESTRICTIONS - ( BLACKLIST )")

	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	
	util.ReplaceScrollbarAtlas(self.list)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:RebuildList(unique)
	local children = self.list:GetCanvas():GetChildren()
	
	for k, child in pairs(children) do
		if (child.expression == unique) then
			child:Rebuild()
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Populate()
	local expressions = atlaschat.expression.GetStored()
	
	for i = 1, #expressions do
		local expression = expressions[i]
		local text = expression:GetCleanName()
		local unique = expression:GetUnique()
		
		local base = vgui.Create("atlaschat.restrictions.row")
		base:SetTall(40)
		base:Dock(TOP)
		base:SetText(text)
		base:SetCursor("hand")
		
		base.expression = unique
		
		self.list:AddItem(base)
	end
end

vgui.Register("atlaschat.restrictions", panel, "atlaschat.frame")

local panel = {}

AccessorFunc(panel, "text", "Text")

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:SetText("")
	self:SetToolTip("Click to view what usergroups are filtered")
	
	self.expander = self:Add("Panel")
	self.expander:SetVisible(false)

	self.expander.usergroups = {}
	
	self.button = self:Add("DImageButton")
	self.button:SetSize(12, 12)
	self.button:SetImage("atlaschat/plus.png")
	self.button:SetToolTip("Add Usergroup")
	
	function self.button:Think()
		if (self.Hovered) then
			self:SetColor(color_green)
		else
			self:SetColor(color_white)
		end
	end
	
	function self.button.DoClick()
		Derma_StringRequest("Add Usergroup", "Enter the name/unique of the usergroup", "", function(text)
			if (text != "") then
				net.Start("atlaschat.rstcs")
					net.WriteBit(false)
					net.WriteString(self.expression)
					net.WriteString(text)
				net.SendToServer()
			end
		end,
		
		function(text) end, "Accept")
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

local color_hovered = Color(255, 0, 0, 100)

function panel:AddUsergroup(usergroup)
	local width, height = util.GetTextSize("atlaschat.restrictions", usergroup)
	
	local panel = vgui.Create("Panel")
	panel:SetWide(width +8)
	panel:Dock(LEFT)
	panel:DockMargin(0, 0, 8, 0)
	panel:SetVisible(false)
	panel:SetCursor("hand")
	panel:SetToolTip("Click to remove this usergroup")
	
	panel.color = Color(69, 69, 69)
	panel.usergroup = usergroup
	
	function panel:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, self.color)
		
		if (self.Hovered) then
			draw.RoundedBox(4, 0, 0, w, h, color_hovered)
		end
		
		draw.SimpleText(self.usergroup,"atlaschat.restrictions", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function panel.OnMousePressed(_self, code)
		Derma_Query("Are you sure you want to delete this usergroup?", "Delete Usergroup", "Accept", function()
			net.Start("atlaschat.rstcs")
				net.WriteBit(true)
				net.WriteString(self.expression)
				net.WriteString(_self.usergroup)
			net.SendToServer()
		end,
		
		"Cancel", function() end)
	end
	
	table.insert(self.expander.usergroups, panel)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:GetBase()
	local width, height = util.GetTextSize("atlaschat.restrictions", "M")
	
	local panel = self.expander:Add("Panel")
	panel:SetTall(height +6)
	panel:Dock(TOP)
	panel:DockPadding(12, 0, 4, 0)
	panel:DockMargin(0, 0, 0, 8)

	return panel
end

----------------------------------------------------------------------
-- Purpose:
--		Rebuilds the usergroup list.
----------------------------------------------------------------------

function panel:Rebuild()
	self.expander:SetVisible(true)
	
	for k, panel in ipairs(self.expander.usergroups) do
		panel:Remove()
	end
	
	self.expander.usergroups = {}
	
	self.expander:Clear()
	self.expander:InvalidateLayout(true)
	
	local data = atlaschat.restrictions[self.expression]
	
	if (data) then
		for usergroup, _ in pairs(data) do
			self:AddUsergroup(usergroup)
		end
	end
	
	local base, width, height = self:GetBase(), 0, 40

	height = height +20
	
	for k, panel in ipairs(self.expander.usergroups) do
		panel:SetVisible(true)
		panel:SetParent(base)
		
		base:InvalidateLayout(true)
		
		if (panel:GetWide() +width >= self:GetWide() -6) then
			base, width, height = self:GetBase(), 0, height +panel:GetTall() +8
			
			panel:SetParent(base)
		
			base:InvalidateLayout(true)
		end
		
		width = width +panel:GetWide() +12
	end
	
	height = height +12

	self:SetTall(height)	
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnMousePressed(code)
	if (code == MOUSE_LEFT) then
		local visible = self.expander:IsVisible()
	
		if (visible) then
			self:SetTall(40)
			
			self.expander:SetVisible(false)
		else
			self.expander:SetVisible(true)
			
			self:Rebuild()
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:PerformLayout()
	local w, h = self:GetSize()
	
	self.expander:SetPos(0, 40)
	self.expander:SetSize(w, h -40)
	
	self.button:SetPos(w -26, 40 /2 -6)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Paint(w, h)
	draw.SimpleRect(0, h -1, w, 1, Color(50, 50, 50))
	
	draw.SimpleText(self.text, "atlaschat.config", 12, 40 /2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
end

vgui.Register("atlaschat.restrictions.row", panel, "Panel")

-- vk.com/urbanichka