---------------------------------------------------------
-- Theme variables.
---------------------------------------------------------

-- The base theme.
theme.base = "default"

-- The theme's unique key.
theme.unique = "dark"

-- A pretty name for this theme.
theme.name = "Dark"

-- Holds all the colors.
theme.color = {}

-- The color of the text selection.
theme.color.selection = Color(60, 255, 60, 60)

-- The color of the timestamp.
theme.color.timestamp = Color(140, 189, 255)

-- The "X" button on the private chat card.
theme.color.privatecard_close = color_white
theme.color.privatecard_close_hover = color_red

-- A generic label color.
theme.color.generic_label = color_white

-- How much space between each message.
theme.messageSpacing = 2


---------------------------------------------------------
-- Called when you change the theme.
---------------------------------------------------------

function theme:OnThemeChange()
	surface.CreateFont("atlaschat.theme.default.title", {font = "Open Sans", size = 19, weight = 400})
	surface.CreateFont("atlaschat.theme.prefix", 		{font = "Roboto", size = 16, weight = 400})
	surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 400})
	
	self.panel:DockPadding(8, 41, 8, 8)
	self.panel:InvalidateLayout()
end

---------------------------------------------------------
-- Paints a generic background.
---------------------------------------------------------

theme.color.generic_background = Color(0, 0, 0, 200)
theme.color.generic_background_dark = Color(0, 0, 0, 200)

function theme:PaintGenericBackground(panel, w, h, text, x, y, xAlign, yAlign)
	draw.SimpleRect(0, 0, w, h, panel.dark and self.color.generic_background_dark or self.color.generic_background)
	
	if (text) then
		draw.SimpleText(text, "atlaschat.theme.default.title", x or 6, y or 8, self.color.generic_label, xAlign or TEXT_ALIGN_LEFT, yAlign or TEXT_ALIGN_BOTTOM)
	end
end

---------------------------------------------------------
-- Paints a generic button.
---------------------------------------------------------

theme.color.button = Color(10, 10, 10, 160)
theme.color.button_hovered = Color(212, 213, 212, 160)

function theme:PaintButton(button, w, h)
	draw.SimpleRect(0, 0, w, h, self.color.button)
	
	if (button.Hovered) then
		draw.SimpleRect(0, 0, w, h, self.color.button_hovered)
	end
	
	local text, font, color = button:GetText(), button:GetFont(), button:GetTextColor()
	
	draw.SimpleText(text, font, w /2, h /2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

theme.color.top = Color(41, 128, 185)
theme.color.background = Color(0, 0, 0, 200)

function theme:PaintPanel(w, h)
	draw.SimpleRect(0, 0, w, h, self.color.background)
	--draw.RoundedBoxEx(4, 0, 0, w, 33, self.color.top, true, true, false, false)
	
	local hostName = GetHostName():upper()

	if (ValidPanel(self.panel.hostName) and self.panel.hostName:GetText() != hostName) then
		self.panel.hostName:SetText(hostName)
		self.panel.hostName:SizeToContents()
	end
	
	self:PaintSnowFlakes(w, h)
end

---------------------------------------------------------
-- Paints the chatbox text list (where the text is).
---------------------------------------------------------
 
theme.color.list_background = Color(0, 0, 0, 160)

function theme:PaintList(panel, w, h)
	if (ValidPanel(panel) and panel:IsVisible()) then
		draw.RoundedBox(2, 0, 0, w, h, self.color.list_background)
	end
end

---------------------------------------------------------
-- Paints the chatbox prefix.
---------------------------------------------------------

theme.color.prefix_background = Color(50, 50, 50)

function theme:PaintPrefix(w, h)
	draw.RoundedBox(2, 0, 0, w, h, self.color.entry_background)
	
	local prefix = self.panel.prefix:GetPrefix()
	
	if (prefix) then
		draw.SimpleText(prefix, "atlaschat.theme.prefix", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the chatbox text entry (where you write your text).
---------------------------------------------------------

theme.color.entry_background = Color(0, 0, 0, 160)

--[[
function theme:PaintTextEntry(w, h, entry)
	entry = entry or self.panel.entry
	
	draw.RoundedBox(2, 0, 0, w, h, self.color.entry_background)
	
	entry:DrawTextEntryText(self.color.generic_label, entry.m_colHighlight or entry:GetSkin().colTextEntryTextHighlight, self.color.generic_label)
end
]]

---------------------------------------------------------
-- Paints the background of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_background = Color(69, 69, 69, 160)

function theme:PaintScrollbar(panel, w, h)
end

---------------------------------------------------------
-- Paints the scrollbar grip.
---------------------------------------------------------

theme.color.scrollbar_grip = Color(162, 163, 162, 40)
theme.color.scrollbar_grip_hovered = Color(162, 163, 162, 160)

function theme:PaintScrollbarGrip(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_grip_hovered)
		else
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_grip)
		end
	end
end

---------------------------------------------------------
-- Paints the up button of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_buttonup = Color(162, 163, 162, 40)
theme.color.scrollbar_buttonup_hovered = Color(162, 163, 162, 160)

function theme:PaintScrollbarUpButton(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttonup_hovered)
		else
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttonup)
		end
	
		draw.SimpleText("t", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

---------------------------------------------------------
-- Paints the down button of the scrollbar.
---------------------------------------------------------

theme.color.scrollbar_buttondown = Color(162, 163, 162, 40)
theme.color.scrollbar_buttondown_hovered = Color(162, 163, 162, 160)

function theme:PaintScrollbarDownButton(panel, w, h)
	if (self.panel:IsVisible()) then
		if (panel.Hovered) then
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttondown_hovered)
		else
			draw.SimpleRect(0, 0, w, h, self.color.scrollbar_buttondown)
		end
		
		draw.SimpleText("u", "Marlett", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

----------------------------------------------------------------------
-- Function:
--		
-- Purpose:
--		
----------------------------------------------------------------------

theme.color.icon_hold_background = Color(50, 50, 50)

function theme:PaintIconHolder(panel, w, h)
end

-- vk.com/urbanichka