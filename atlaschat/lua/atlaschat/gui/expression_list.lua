local panel = {}

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:SetTitle("EXPRESSIONS")
	
	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)
	
	util.ReplaceScrollbarAtlas(self.list)
	
	self:Populate()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:AddItem(item)
	local panel = vgui.Create("Panel")
	panel:SetTall(item:GetTall() +24)
	panel:Dock(TOP)
	
	panel.child = item
	
	item:SetParent(panel)
	
	function panel:Paint(w, h)
		draw.SimpleRect(0, h -1, w, 1, Color(50, 50, 50))
	end
	
	function panel:PerformLayout()
		local w, h = self:GetSize()

		self.child:SetWide(w)
		self.child:SetPos(w /2 -self.child:GetWide() /2, 12)
	end
	
	self.list:AddItem(panel)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Populate()
	local expressions = atlaschat.expression.GetStored()

	for i = 1, #expressions do
		local object = expressions[i]
		
		if (object.GetExample) then
			local base = vgui.Create("Panel")
			base:SetCursor("hand")
			
			base.labelAlpha = 0
			
			local text, panel = object:GetExample(base)
			panel:SetParent(base)
			panel:SetMouseInputEnabled(false)
			
			base:SetTall(panel:GetTall())
			
			local label = base:Add("DLabel")
			label:SetText(text)
			label:SetSkin("atlaschat")
			label:SizeToContents()
			label:SetAlpha(0)
			label:SetMouseInputEnabled(false)
			
			base.panel = panel
			base.label = label
			
			function base:PerformLayout()
				local w, h = self:GetSize()
				
				self.label:SetPos(w /2 -self.label:GetWide() /2, h /2 -self.label:GetTall() /2)
				self.panel:SetPos(w /2 -self.panel:GetWide() /2, h /2 -self.panel:GetTall() /2)
			end
	
			function base:Think()
				if (self.Hovered or self.label.Hovered) then
					self.labelAlpha = math.Approach(self.labelAlpha, 255, 8)
				else
					self.labelAlpha = math.Approach(self.labelAlpha, 0, 8)
				end
				
				self.panel:SetAlpha(255 -self.labelAlpha)
				self.label:SetAlpha(self.labelAlpha)
			end
			
			function base:OnMousePressed(code)
				local entry = atlaschat.theme.GetValue("panel").entry
				
				entry:SetText(entry:GetText() .. label:GetText())
			end
			
			self:AddItem(base)
		end
	end
end

vgui.Register("atlaschat.expressionlist", panel, "atlaschat.frame")

-- vk.com/urbanichka