surface.CreateFont("atlaschat.ranks.column", {font = "Open Sans", size = 15, weight = 400})

local color_column = color_white
local color_line =  Color(50, 50, 50)
local color_line_background = Color(244, 244, 244)

local panel = {}

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:DockPadding(12, 44, 12, 12)
	self:SetTitle("RANK CONFIGURATION")
	
	self.columns = {}
	
	self.columnBase = self:Add("Panel")
	self.columnBase:SetTall(22)
	self.columnBase:Dock(TOP)
	
	function self.columnBase:Paint(w, h)
		draw.SimpleRect(0, h -1, w, 1, color_line)
	end
	
	self.list = self:Add("DScrollPanel")
	self.list:Dock(FILL)

	util.ReplaceScrollbarAtlas(self.list)
	
	self.button = self:Add("Panel")
	self.button:SetTall(32)
	self.button:Dock(BOTTOM)
	self.button:SetCursor("hand")
	
	function self.button:Paint(w, h)
		draw.SimpleRect(0, 0, w, h, Color(50, 50, 50))
		
		if (self.Hovered) then
			draw.SimpleRect(0, 0, w, h, Color(80, 80, 80))
		end
		
		draw.SimpleText("SETUP NEW RANK", "atlaschat.config", w /2, h /2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	function self.button:OnMousePressed()
		Derma_StringRequest("Add Usergroup", "Enter the name/unique of the usergroup", "", function(text) if (text != "") then net.Start("atlaschat.crtrnk") net.WriteString(text) net.SendToServer() end end, function(text) end, "Accept")
	end
	
	self:AddColumn("USERGROUP", (420 -40) /2)
	self:AddColumn("IMAGE", 40):SetAlignX(TEXT_ALIGN_CENTER)
	self:AddColumn("TAG", 206):SetAlignX(TEXT_ALIGN_RIGHT)
	
	self:Populate()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Clear()
	self.list:Clear()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:AddColumn(name, width)
	local column = self.columnBase:Add("atlaschat.ranks.column")
	column:SetWide(width)
	column:SetText(name)
	column:Dock(LEFT)
	
	column.id = table.insert(self.columns, column)
	
	return column
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:AddLine(unique, ...)
	local data = {...}
	
	local base = vgui.Create("Panel")
	base:SetTall(28)
	base:Dock(TOP)

	base.unique = unique
	
	function base:Paint(w, h)
		draw.SimpleRect(0, h -1, w, 1,	color_line)
	end
	
	for i = 1, #data do
		local panel = data[i]
		local width = self.columns[i]:GetWide()
		
		panel:SetMouseInputEnabled(false)
		panel:SetParent(base)
		panel:SetWide(width)
		panel:Dock(LEFT)
		
		if (panel.path) then
			base.image = panel
		end
		
		if (panel.tagPanel) then
			base.tag = panel
		end
	end
	
	self.list:AddItem(base)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:UpdateLine(unique, image, tag)
	local children = self.list:GetCanvas():GetChildren()
	
	for k, child in pairs(children) do
		if (child.unique == unique) then
			child.image.path = Material(image)
			child.image.tag = tag
		
			child.tag:Clear()
			child.tag.value = tag
			child.tag.image = image
			
			atlaschat.ParseExpressionPreview(child.tag, "DermaDefault", true)
		end
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

local icons = file.Find("materials/icon16/*.png", "MOD")
local deleteImage = Material("atlaschat/cross.png", "smooth")

function panel:Populate()
	self:Clear()
	
	for unique, data in pairs(atlaschat.ranks) do
		local usergroup = vgui.Create("Panel")
		
		usergroup.text = unique
		
		function usergroup:Paint(w, h)
			draw.SimpleText(self.text, "DermaDefault", 22, h /2 -1, Color(209, 209, 209), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	
		usergroup.button = usergroup:Add("Panel")
		usergroup.button:SetPos(5, 0)
		usergroup.button:SetSize(8, 28)
		usergroup.button:SetCursor("hand")
		
		function usergroup.button:Paint(w, h)
			draw.Material(0, h /2 -4, w, 8, self.Hovered and color_red or color_white, deleteImage)
		end
		
		function usergroup.button:OnMousePressed()
			Derma_Query("Are you sure you want to delete this rank?", "Delete Rank", "Accept", function() net.Start("atlaschat.rmvrnk") net.WriteString(usergroup.text) net.SendToServer() end, "Cancel", function() end)
		end
		
		local image = vgui.Create("Panel")
		image:SetCursor("hand")
		
		image.unique = unique
		image.tag = data.tag
		image.path = Material(data.icon) or ""

		function image:Paint(w, h)
			if (self.path and self.path != "") then
				draw.Material(w /2 -8, h /2 -8, 16, 16, self.Hovered and color_green or color_white, self.path)
			end
		end
		
		function image:OnMousePressed()
			local menu = DermaMenu()
				menu:AddOption("Change Image", function()
					local x, y = self:LocalToScreen()
					local width = 12
					
					local base = vgui.Create("atlaschat.frame")
					base:SetSize(266, 384)
					base:SetPos(x, y)
					base:SetTitle("SELECT ICON")
					base:MakePopup()
					
					local iconList = base:Add("atlaschat.chat.list")
					iconList:Dock(FILL)
					iconList:GetCanvas():DockPadding(12, 12, 12, 12)
					
					util.ReplaceScrollbarAtlas(iconList)
					
					local iconBase = vgui.Create("Panel")
					iconBase:SetTall(16)
					iconBase:Dock(TOP)
					iconBase:DockMargin(0, 0, 0, 12)
					
					iconList:AddItem(iconBase)
					
					timer.Simple(0.05, function()
						for k, path in pairs(icons) do
							local image = iconBase:Add("DImage")
							image:SetImage("icon16/" .. path)
							image:SetSize(16, 16)
							image:Dock(LEFT)
							image:DockMargin(0, 0, 12, 0)
							image:SetMouseInputEnabled(true)
							image:SetCursor("hand")
							
							image.tag = self.tag
							image.path = "icon16/" .. path
							image.unique = unique
							
							function image:OnMousePressed()
								net.Start("atlaschat.chnric")
									net.WriteString(self.unique)
									net.WriteString(self.tag)
									net.WriteString(self.path)
								net.SendToServer()
								
								base:Remove()
							end
					
							width = width +20
							
							if (width +16 >= iconList:GetWide()) then
								iconBase = vgui.Create("Panel")
								iconBase:SetTall(16)
								iconBase:Dock(TOP)
								iconBase:DockMargin(0, 0, 0, 12)
								
								iconList:AddItem(iconBase)
								
								width = 12
							end
						end
					end)
				end)
				
				menu:AddOption("Remove Image", function()
					net.Start("atlaschat.chnric")
						net.WriteString(self.unique)
						net.WriteString(self.tag)
						net.WriteString("")
					net.SendToServer()
				end)
			menu:Open()
		end
		
		local tag = vgui.Create("Panel")
		tag:SetCursor("hand")
		
		tag.unique = unique
		tag.value = data.tag
		tag.image = data.icon
		tag.tagPanel = true
		
		function tag:OnMousePressed()
			local editor = vgui.Create("atlaschat.editor")
			editor:SetTitle("Tag Editor")
			editor:SetSize(420, 400)
			editor:Center()
			editor:MakePopup()
			editor:SetValue(self.value)
			
			function editor:OnFinish()
				local value = self:GetValue()
				
				net.Start("atlaschat.chnric")
					net.WriteString(tag.unique)
					net.WriteString(value)
					net.WriteString(tag.image)
				net.SendToServer()
				
				self:Remove()
			end
		end
		
		timer.Simple(0.1, function() atlaschat.ParseExpressionPreview(tag, "DermaDefault", true) end)
		
		self:AddLine(unique, usergroup, image, tag)
	end
end

vgui.Register("atlaschat.ranks", panel, "atlaschat.frame")


local panel = {}

AccessorFunc(panel, "text", "Text")
AccessorFunc(panel, "align_x", "AlignX")

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:Init()
	self:SetText("Untitled column")
	self:SetAlignX(TEXT_ALIGN_LEFT)
end

----------------------------------------------------------------------	
-- Purpose:
--		Called whenever the panel should be drawn.
----------------------------------------------------------------------

function panel:Paint(w, h)
	draw.SimpleText(self.text, "atlaschat.ranks.column", self.align_x == TEXT_ALIGN_CENTER and w /2  or self.align_x == TEXT_ALIGN_RIGHT and w -3 or 4, 0, color_column, self.align_x, TEXT_ALIGN_TOP)
end

vgui.Register("atlaschat.ranks.column", panel, "Panel")

-- vk.com/urbanichka