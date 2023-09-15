---------------------------------------------------------
-- Theme variables.
---------------------------------------------------------

-- The theme's unique key.
theme.unique = "default"

-- A pretty name for this theme.
theme.name = "Default"

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

-- Default fonts for this theme.
surface.CreateFont("atlaschat.theme.default.title", {font = "Open Sans", size = 19, weight = 400})
surface.CreateFont("atlaschat.theme.userlist", 		{font = "Roboto Lt", size = 18, weight = 400})
surface.CreateFont("atlaschat.theme.userlist.player", {font = "Arial", size = 15, weight = 800})
surface.CreateFont("atlaschat.theme.prefix", 		{font = "Roboto", size = 16, weight = 400})
surface.CreateFont("atlaschat.theme.list.name", 	{font = "Arial", size = 14, weight = 400})
surface.CreateFont("atlaschat.theme.list.close", 	{font = "Arial", size = 12, weight = 800, antialias = false})
surface.CreateFont("atlaschat.theme.add", 			{font = "Tahoma", size = 18, weight = 800})
surface.CreateFont("atlaschat.theme.invite", 		{font = "Tahoma", size = 12, weight = 400})
surface.CreateFont("atlaschat.theme.row",			 {font = "Arial", size = 18, weight = 800})

----------------------------------------------------------------------	
-- Purpose:
--		Creates the default chat fonts.
----------------------------------------------------------------------

local chatFonts = {}

function atlaschat.CreateFont(name, unique, font, size, weight, antialias)
	surface.CreateFont(unique, {font = font, size = size, weight = weight, antialias = antialias == nil and true or antialias})
	surface.CreateFont(unique .. ".shadow", {font = font, size = size, weight = weight, antialias = false, outline = true, blursize = 1})
	
	table.insert(chatFonts, {name, unique})
end

atlaschat.CreateFont("Default", 				"atlaschat.theme.oss",	 	"Open Sans Semibold", 18, 400)
atlaschat.CreateFont("DejaVu Sans", 			"atlaschat.theme.text", 	"DejaVu Sans", 14, 580)
atlaschat.CreateFont("Tahoma", 					"atlaschat.tahoma", 		"Tahoma", 14, 1000)
atlaschat.CreateFont("Tiny Tahoma", 			"atlaschat.tahoma.tiny", 	"Tahoma", 11, 0)
atlaschat.CreateFont("Huge Tahoma", 			"atlaschat.tahoma.huge",	"Tahoma", 24, 0)
atlaschat.CreateFont("Arial", 					"atlaschat.arial", 			"Arial", 16, 0)
atlaschat.CreateFont("Coolvetica", 				"atlaschat.coolvetica", 	"Coolvetica", 20, 0)
atlaschat.CreateFont("Verdana", 				"atlaschat.verdana", 		"Verdana", 16, 0)
atlaschat.CreateFont("Akbar", 					"atlaschat.akbar", 			"Akbar", 22, 0)
atlaschat.CreateFont("Courier New", 			"atlaschat.courier.new", 	"Courier New", 16, 0)
atlaschat.CreateFont("Source Engine Chat Font", "atlaschat.verdana.se", 	"Verdana", 14, 700, false)

function atlaschat.GetFonts()
	return chatFonts
end

----------------------------------------------------------------------	
-- Purpose:
--		Configuration variables.
----------------------------------------------------------------------

atlaschat.chat_x 				= atlaschat.config.New(nil, 								"chat_x", 			-1, 					true)
atlaschat.chat_y 				= atlaschat.config.New(nil, 								"chat_y", 			-1, 					true)
atlaschat.chat_w				= atlaschat.config.New(nil, 								"size_width", 		0, 						true)
atlaschat.chat_h 				= atlaschat.config.New(nil, 								"size_height", 		0, 						true)
atlaschat.font 					= atlaschat.config.New("Chatbox font", 						"font", 			"atlaschat.theme.oss", 	true)
atlaschat.chatSound				= atlaschat.config.New("Play chat sound", 					"chat_sound", 		true, 					true)
atlaschat.fadetime 				= atlaschat.config.New("Message fade out speed",			"fadetime", 		12, 					true)
atlaschat.timestamp 			= atlaschat.config.New("Enable timestamp", 					"timestamp", 		true, 					true)
atlaschat.snowFlakes 			= atlaschat.config.New("Snow flake amount", 				"snow", 			0, 						true)
atlaschat.enableAvatarsLocal 	= atlaschat.config.New("Enable avatars", 					"avatars_local", 	true, 					true)
atlaschat.smallAvatar 			= atlaschat.config.New("Use small avatars", 				"small_avatar", 	false, 					true)
atlaschat.maxHistory 			= atlaschat.config.New("Max chat history", 					"max_history", 		25, 					true)
atlaschat.extraShadow 			= atlaschat.config.New("Extra font shadow", 				"extra_shadow", 	false, 					true)
atlaschat.filterJoinDisconnect 	= atlaschat.config.New("Hide join/disconnect messages", 	"filter_jndc", 		false, 					true)
atlaschat.messageFadeIn 		= atlaschat.config.New("Chat message fade in", 				"fadein", 			true, 					true)

function atlaschat.font:OnChange(value)
	local invalid = atlaschat.FixInvalidFont()
	
	if (!invalid) then
		atlaschat.fontHeight = draw.GetFontHeight(value)
		
		atlaschat.BuildFontCache(" - ")
		atlaschat.BuildFontCache("ACCEPTED")
		atlaschat.BuildFontCache("-> ACCEPT <-")
	end
end

local flakes = {}
local snowMaterial = Material("icon16/bullet_blue.png")

function atlaschat.snowFlakes:OnChange(value)
	value = tonumber(value)
	
	flakes = {}
	
	if (value > 0) then
		local w = atlaschat.chat_w:GetInt()
		
		for i = 1, value do
			flakes[i] = {x = math.random(0, w), y = math.random(-50, 0), sign = math.Round(math.random(-1, 1)), counter = 0, speed = math.random(5, 40), size = math.random(2, 10)}
		end
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		Called when the chatbox should be created.
----------------------------------------------------------------------

function theme:Initialize()
	local w, h, x, y = atlaschat.ScaleSize(200, true), atlaschat.ScaleSize(150), atlaschat.ScaleSize(10, true), atlaschat.ScaleSize(230)
	
	local panel = vgui.Create("atlaschat.chat")
	panel:SetAlpha(0)
	panel:SetSize(w, h)
	panel:SetPos(x, y)
	panel:DockPadding(6, 40, 6, 6)
	panel:MakePopup()
	
	panel.team = false
	
	if (atlaschat.chat_x:GetInt() == -1) 	then atlaschat.chat_x:SetInt(x) end
	if (atlaschat.chat_y:GetInt() == -1) 	then atlaschat.chat_y:SetInt(y) end
	if (atlaschat.chat_w:GetInt() == 0) 	then atlaschat.chat_w:SetInt(w) end
	if (atlaschat.chat_h:GetInt() == 0) 	then atlaschat.chat_h:SetInt(h) end

	panel.prefix = panel.bottom:Add("atlaschat.chat.prefix")
	panel.prefix:Dock(LEFT)
	
	panel.entry = panel.bottom:Add("atlaschat.chat.entry")
	panel.entry:Dock(FILL)
	panel.entry:DockMargin(2, 0, 0, 0)

	panel.list = panel:Add("atlaschat.chat.list")
	panel.list:Dock(FILL)
	panel.list:GetCanvas():DockPadding(0, 2, 0, 2)
	panel.list:SetScrollbarWidth(12)
	panel.list:SetDeleteHistory(true)
	panel.list:SetBottomUp(true)
	
	panel.chatrooms = panel:Add("atlaschat.chatroom.container")
	panel.chatrooms:SetTall(18)
	
	self.panel = panel
	
	self.mainChat = panel.chatrooms:AddChatroom("GLOBAL")
	self.mainChat:SetList(panel.list)
	self.mainChat:OnMousePressed(MOUSE_LEFT)
	
	self.settingsIcon = panel:AddIcon("atlaschat/settings.png", function() atlaschat.theme.Call("ToggleConfigPanel") end, "Configuration")
	
	self.informationIcon = panel:AddIcon("atlaschat/emotes.png", function()
		if (!ValidPanel(self.expressionPanel)) then
			self.expressionPanel = vgui.Create("atlaschat.expressionlist")
			self.expressionPanel:SetSize(374, 460)
			self.expressionPanel:Center()
			self.expressionPanel:SetDeleteOnClose(false)
			self.expressionPanel:MakePopup()
		else
			self.expressionPanel:SetVisible(!self.expressionPanel:IsVisible())
		end
	end, "Expressions")
	
	-- Hide the chat panel.
	timer.Simple(0.1, function()
		atlaschat.BuildFontCache(" - ")
		atlaschat.BuildFontCache("ACCEPTED")
		atlaschat.BuildFontCache("-> ACCEPT <-")
		
		self:OnToggle(false)
	end)
	
	local flakeAmount = atlaschat.snowFlakes:GetInt()
	
	if (flakeAmount > 0) then
		local w = atlaschat.chat_w:GetInt()
		
		for i = 1, flakeAmount do
			flakes[i] = {x = math.random(0, w), y = math.random(-50, 0), sign = math.Round(math.random(-1, 1)), counter = 0, speed = math.random(5, 40), size = math.random(2, 10)}
		end
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		Called when you change the theme.
----------------------------------------------------------------------

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

theme.color.generic_background = Color(37, 37, 37)
theme.color.generic_background_dark = Color(50, 50, 50)

function theme:PaintGenericBackground(panel, w, h, text, x, y, xAlign, yAlign)
	draw.RoundedBox(2, 0, 0, w, h, panel.dark and self.color.generic_background_dark or self.color.generic_background)
	
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
-- Paints the snow flakes.
---------------------------------------------------------

function theme:PaintSnowFlakes(w, h)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(snowMaterial)

	if (#flakes > 0) then
		local flakeAmount = atlaschat.snowFlakes:GetInt()
		
		for i = 1, flakeAmount do
			flakes[i].counter = flakes[i].counter +flakes[i].speed /500
			flakes[i].x = flakes[i].x +(flakes[i].sign *math.cos(flakes[i].counter) /20)
			flakes[i].y = flakes[i].y +math.sin(flakes[i].counter) /40 +flakes[i].speed /30
			
			if (flakes[i].y > h) then
				flakes[i].y = math.random(-50,0)
				flakes[i].x = math.random(0, w)
			end
		end
		
		for i = 1, flakeAmount do
			surface.DrawTexturedRect(flakes[i].x, flakes[i].y, flakes[i].size, flakes[i].size)
		end
	end
end

---------------------------------------------------------
-- Paints the chatbox base panel (background).
---------------------------------------------------------

theme.color.top = Color(41, 128, 185)
theme.color.background = Color(37, 37, 37)

function theme:PaintPanel(w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.background)
	draw.RoundedBoxEx(4, 0, 0, w, 33, self.color.top, true, true, false, false)
	
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
 
theme.color.list_background = Color(50, 50, 50)

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

theme.color.entry_background = Color(50, 50, 50)

function theme:PaintTextEntry(w, h, entry)
	entry = entry or self.panel.entry
	
	draw.RoundedBox(2, 0, 0, w, h, self.color.entry_background)
	
	entry:DrawTextEntryText(self.color.generic_label, entry.m_colHighlight or entry:GetSkin().colTextEntryTextHighlight, self.color.generic_label)
end

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

----------------------------------------------------------------------	
-- Purpose:
--		Paints the up button of the scrollbar.
----------------------------------------------------------------------

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

----------------------------------------------------------------------	
-- Purpose:
--		Paints the down button of the scrollbar.
----------------------------------------------------------------------

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
-- Purpose:
--		
----------------------------------------------------------------------

theme.color.list_container_new = Color(255, 165, 0, 160)
theme.color.list_container_hover = Color(211, 211, 211, 160)
theme.color.list_container_selected = Color(41 -12, 128 -12, 185 -12)
theme.color.list_container_background = Color(41 +32, 128 +32, 185 +32)
theme.color.list_container_background_dark = Color(41 +12, 128 +12, 185 +12)

function theme:PaintChatroom(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.color.list_container_background)
	
	local active = atlaschat.theme.GetValue("current_chatroom")
	
	if (panel == active) then
		draw.RoundedBox(4, 0, 0, w, h, self.color.list_container_selected)
	end
	
	if (panel.Hovered) then
		draw.RoundedBox(4, 0, 0, w, h, self.color.list_container_hover)
	end
	
	if (panel.new) then
		if (panel.blink <= CurTime()) then
			draw.RoundedBox(4, 0, 0, w, h, self.color.list_container_new)
			
			if (panel.blink +1 <= CurTime()) then
				panel.blink = CurTime() +1.5
			end
		end
	end
	
	local name = panel:GetName()
	
	if (name) then
		draw.SimpleText(name, "atlaschat.theme.list.name", w /2, h /2, self.color.generic_label, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("(" .. #panel.players .. ")", "atlaschat.theme.list.name", w -4, h /2, self.color.generic_label, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

theme.color.icon_hold_background = Color(50, 50, 50)

function theme:PaintIconHolder(panel, w, h)
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

local checkImage = Material("atlaschat/check.png", "smooth")

local function ParseConfig(sorted, list, admin)
	for i = 1, #sorted do
		local info = sorted[i]
		local object = atlaschat.config.Get(info.name)
		local text = object:GetText()
		
		local panel
		
		if (info.index == 1) then
			local value = object:GetBool()
			
			panel = vgui.Create("DCheckBox")
			panel:SetChecked(value)
			
			panel.object = object
			panel.checkBox = true
			
			function panel:OnChange(value)
				if (admin) then
					net.Start("atlaschat.gtcfg")
						net.WriteString(self.object:GetName())
						net.WriteType(value)
					net.SendToServer()
				else
					self.object:SetBool(value)
				end
			end
			
			function panel:Paint(w, h)
				if (self.Hovered) then
					draw.RoundedBox(2, 0, 0, w, h, Color(70, 70, 70))
				else
					draw.RoundedBox(2, 0, 0, w, h, Color(50, 50, 50))
				end
				
				if (self:GetChecked()) then
					draw.Material(4, 4, 8, 8, color_white, checkImage)

				end
			end
		end
		
		if (info.index == 2) then
			local value = object:GetInt()
			
			panel = vgui.Create("atlaschat.slider")
			panel:SetDecimals(0)
			panel:SetMinMax(0, 1000)
			panel:SetValue(value)
			
			panel.object = object
	
			function panel:OnValueChanged(value)
				if (admin) then
					self.nextUpdate = CurTime() +0.5
				else
					self.object:SetInt(math.Round(value))
				end
			end
			
			if (admin) then
				function panel:Think()
					if (self.nextUpdate and self.nextUpdate <= CurTime()) then
						local value = self:GetValue()
						
						net.Start("atlaschat.gtcfg")
							net.WriteString(self.object:GetName())
							net.WriteType(value)
						net.SendToServer()
						
						self.nextUpdate = nil
					end
				end
			end
		end
		
		if (info.index == 3) then
			if (info.name == "theme") then
				local themes = atlaschat.theme.GetStored()
				
				panel = vgui.Create("DComboBox")
				
				for unique, data in pairs(themes) do
					panel:AddChoice(data.name, unique)
				end
				
				function panel:OnSelect(index, value, data)
					atlaschat.themeConfig:SetValue(data)
				end
			end
			
			if (info.name == "font") then
				panel = vgui.Create("DComboBox")
				
				local color_shadow = Color(0, 0, 0, 220)

				local function shadow(text, font, x, y)
					surface.SetFont(font .. ".shadow")
					surface.SetTextPos(x, y)
					surface.SetTextColor(color_shadow)
					surface.DrawText(text)
				end

				function panel:OnMousePressed()
					if (ValidPanel(self.menu)) then self.menu:Remove() end
					
					self.menu = vgui.Create("Panel")
					
					AccessorFunc(self.menu, "m_bDeleteSelf", "DeleteSelf")
					AccessorFunc(self.menu, "m_bIsMenuComponent", "IsMenu", FORCE_BOOL)
					
					self.menu:SetDeleteSelf(true)
					self.menu:SetIsMenu(true)
					self.menu:MakePopup()
					
					RegisterDermaMenuForClose(self.menu)
					
					function self.menu:Paint(w, h)
						draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50))
					end
					
					local list = self.menu:Add("DScrollPanel")
					list:Dock(FILL)
					
					util.ReplaceScrollbarAtlas(list)
					
					local fonts = atlaschat.GetFonts()
					local x, y = panel:LocalToScreen(0, 24)
					local width, height = 0, 0
					local material = Material("icon16/accept.png")
					
					for i = 1, #fonts do
						local data = fonts[i]
						
						local text = "This is the font \"" .. data[1] .. "\""
						local w, h = util.GetTextSize(data[2], text)
						
						local panel = vgui.Create("Panel")
						panel:SetTall(h +16)
						panel:Dock(TOP)
						panel:SetCursor("hand")
						
						function panel:Paint(w2, h2)
							pcall(shadow, text, data[2], 8, h2 /2 -h /2)
							
							draw.SimpleText(text, data[2], 8, h2 /2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
							
							draw.SimpleRect(0, h2 -1, w2, 1, Color(64, 64, 64))
							
							if (atlaschat.font:GetString() == data[2]) then
								draw.Material(w2 -24, h2 /2 -8, 16, 16, color_white, material)
							end
						end
						
						function panel.OnMousePressed()
							atlaschat.font:SetString(data[2])
							
							chat.AddText("Chat font changed to \"" .. data[1] .. "\"")
						end
						
						height = height +h +16
						
						if (w > width) then width = w end
						
						list:AddItem(panel)
					end
					
					width = width +64
					
					if (y +height > ScrH()) then height = ScrH() -(y +5) end
					
					self.menu:SetPos(x, y)
					self.menu:SetSize(width, height)
				end
			end
		end
		
		if (admin) then
			panel.admin = true
		end
		
		list:AddItem(text, panel)
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

local function int(v) return type(tonumber(v)) == "number" end
local function bool(v) return v == true or v == false or v == "true" or v == "false" end

local config = atlaschat.config.GetStored()

local adminSorted = {}
local generalSorted = {}

for name, object in pairs(config) do
	if (object:GetText() and !object.server) then
		local value = object:GetValue()
		local isNumber, isBool = int(value), bool(value)
		local index
		
		if (isBool) then index = 1 end
		if (isNumber) then index = 2 end
		
		-- It has to be a string!
		if (!isBool and !isNumber) then index = 3 end
		
		table.insert(generalSorted, {name = name, index = index})
	end
end

for name, object in pairs(config) do
	if (object:GetText() and object.server) then
		local value = object:GetValue()
		local isNumber, isBool = int(value), bool(value)
		local index
		
		if (isBool) then index = 1 end
		if (isNumber) then index = 2 end
		
		-- It has to be a string!
		if (!isBool and !isNumber) then index = 3 end
		
		table.insert(adminSorted, {name = name, index = index})
	end
end

table.sort(adminSorted, function(a, b) return a.index < b.index end)
table.sort(generalSorted, function(a, b) return a.index < b.index end)

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function theme:ToggleConfigPanel()
	if (!ValidPanel(self.config)) then
		self.config = vgui.Create("atlaschat.config")
		self.config:SetSize(400, 492)
		self.config:Center()
		self.config:SetDeleteOnClose(false)
		self.config:MakePopup()

		ParseConfig(generalSorted, self.config)

		self.config:AddButton("Reset configuration", nil, function()
			if (LocalPlayer():IsAdmin()) then
				local menu = DermaMenu()
					local players = player.GetAll()
					
					for k, v in pairs(players) do
						menu:AddOption(v:Nick(), function()
							local steamID = v:SteamID()
				
							net.Start("atlaschat.rqclrcfg")
								net.WriteString(steamID)
							net.SendToServer()
						end)
					end
				menu:Open()
			else
				local steamID = LocalPlayer():SteamID()
				
				net.Start("atlaschat.rqclrcfg")
					net.WriteString(steamID)
				net.SendToServer()
			end
		end)
		
		if (LocalPlayer():IsSuperAdmin()) then
			self.config:AddButton("Reset everyone's configuration", true, function()
				net.Start("atlaschat.rqclrcfg")
				net.SendToServer()
			end)
			
			self.config:AddButton("Configure ranks", true, function()
				atlaschat.theme.Call("ToggleRankMenu")
			end)
			
			self.config:AddButton("Configure MySQL", true, function()
				self.mysqlPanel = vgui.Create("atlaschat.mysql")
				self.mysqlPanel:SetSize(464, 280)
				self.mysqlPanel:Center()
				self.mysqlPanel:MakePopup()
				
				self.config:SetVisible(false)
			end)
			
			self.config:AddButton("Configure Restrictions", true, function()
				self.restrictionPanel = vgui.Create("atlaschat.restrictions")
				self.restrictionPanel:SetSize(512, 420)
				self.restrictionPanel:Center()
				self.restrictionPanel:MakePopup()
				
				self.restrictionPanel:Populate()
				
				self.config:SetVisible(false)
			end)
			
			self.config.admin = true
			
			self.config:AddCategory("GLOBAL VALUES", "admin")
			
			ParseConfig(adminSorted, self.config, true)
		end
	else
		self.config:ToggleVisible()
		
		if (LocalPlayer():IsSuperAdmin()) then
			if (!self.config.admin) then
				self.config:AddButton("Reset everyone's configuration", true, function()
					net.Start("atlaschat.rqclrcfg")
					net.SendToServer()
				end)
				
				self.config:AddButton("Configure ranks", true, function()
					atlaschat.theme.Call("ToggleRankMenu")
				end)
				
				self.config:AddButton("Configure MySQL", true, function()
					self.mysqlPanel = vgui.Create("atlaschat.mysql")
					self.mysqlPanel:SetSize(464, 280)
					self.mysqlPanel:Center()
					self.mysqlPanel:MakePopup()
					
					self.config:SetVisible(false)
				end)
				
				self.config:AddButton("Configure Restrictions", true, function()
					self.restrictionPanel = vgui.Create("atlaschat.restrictions")
					self.restrictionPanel:SetSize(512, 420)
					self.restrictionPanel:Center()
					self.restrictionPanel:MakePopup()
					
					self.restrictionPanel:Populate()
					
					self.config:SetVisible(false)
				end)
			
				self.config.admin = true
				
				self.config:AddCategory("GLOBAL VALUES", "admin")
				
				ParseConfig(adminSorted, self.config, true)
			end
		else
			if (self.config.admin) then
				self.config:Clear("admin")
				
				self.config.admin = false
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function theme:ToggleUserList()
	if (!ValidPanel(self.userListBase)) then
		self.userListBase = vgui.Create("Panel")
		self.userListBase:DockPadding(6, 32, 6, 6)

		local x, y = self.panel:GetPos()
		local width, height = self.panel:GetSize()
		
		self.userListBase:SetSize(250, 300)
		self.userListBase:SetPos(x +width +4, y +height -self.userListBase:GetTall())
		
		self.userListBase.dark = true
		
		function self.userListBase:PerformLayout()
			if (ValidPanel(self.button)) then
				local w = self:GetWide()
				
				self.button:SetPos(w -(75 +8), 10)
			end
		end
		
		function self.userListBase:Paint(w, h)
			atlaschat.theme.Call("PaintGenericBackground", self, w, h, "User List")
		end
		
		function self.userListBase:Rebuild(data, key)
			self.list:Clear()
	
			if (IsValid(data.creator)) then
				local nick = data.creator:Nick()
				
				local base = vgui.Create("Panel")
				base:Dock(TOP)
				base:SetTall(16)
				base:DockMargin(4, 2, 4, 0)

				local icon = base:Add("DImage")
				icon:SetImage("icon16/star.png")
				icon:SetSize(12, 12)
				icon:SetPos(0, 2)
				
				local creator = base:Add("DLabel")
				creator:SetPos(18, 1)
				creator:SetText(nick)
				creator:SetFont("atlaschat.theme.userlist.player")
				creator:SizeToContents()
				creator:SetSkin("atlaschat")
				
				self.list:AddItem(base)
			end
			
			for i = 1, #data do
				local player = data[i]
				
				if (IsValid(player) and player != data.creator) then
					local nick = player:Nick()
					
					local base = vgui.Create("Panel")
					base:Dock(TOP)
					base:SetTall(16)
					base:DockMargin(4, 2, 4, 0)
					
					if (data.creator == LocalPlayer()) then
						local icon = base:Add("DImageButton")
						icon:SetImage("icon16/cross.png")
						icon:SetSize(12, 12)
						icon:SetPos(0, 2)
						
						icon.player = player
						
						function icon:DoClick()
							net.Start("atlaschat.kickpm")
								net.WriteUInt(key, 8)
								net.WriteEntity(self.player)
							net.SendToServer()
						end
						
						local label = base:Add("DLabel")
						label:SetPos(18, 1)
						label:SetText(nick)
						label:SetFont("atlaschat.theme.userlist.player")
						label:SizeToContents()
						label:SetSkin("atlaschat")
					else
						local label = base:Add("DLabel")
						label:SetText(nick)
						label:SetFont("atlaschat.theme.userlist.player")
						label:Dock(TOP)
						label:SizeToContents()
						label:SetSkin("atlaschat")
					end
					
					self.list:AddItem(base)
				end
			end
		end
		
		self.userListBase.list = self.userListBase:Add("atlaschat.chat.list")
		self.userListBase.list:Dock(FILL)
		self.userListBase.list:SetScrollbarWidth(12)
		self.userListBase.list:GetCanvas():DockPadding(4, 4, 4, 4)
		
		local active = atlaschat.theme.GetValue("current_chatroom")
	
		if (IsValid(active)) then
			self.userListBase:Rebuild(active.players, active:GetKey())
		end
		
		self.userListBase.button = self.userListBase:Add("atlaschat.chat.button")
		self.userListBase.button:SetSize(75, 16)
		self.userListBase.button:SetText("Invite Player")
		self.userListBase.button:SetFont("atlaschat.theme.invite")
		
		function self.userListBase.button.DoClick()
			local active = atlaschat.theme.GetValue("current_chatroom")
			
			if (IsValid(active)) then
				local data = active.players
				local players = player.GetAll()
				
				local menu = DermaMenu()
					for k, player in pairs(players) do
						if (player != LocalPlayer()) then
							local nick = player:Nick()
							local steamID = player:SteamID()
							
							menu:AddOption(nick, function()
								net.Start("atlaschat.invpm")
									net.WriteUInt(active:GetKey(), 8)
									net.WriteString(steamID)
								net.SendToServer()
							end)
						end
					end
				menu:Open()
			end
		end
	else
		self.userListBase:SetVisible(!self.userListBase:IsVisible())
		
		if (self.userListBase:IsVisible()) then
			local x, y = self.panel:GetPos()
			local width, height = self.panel:GetSize()
		
			self.userListBase:SetPos(x +width +4, y +height -self.userListBase:GetTall())
			
			local active = atlaschat.theme.GetValue("current_chatroom")
		
			if (IsValid(active)) then
				self.userListBase:Rebuild(active.players, active:GetKey())
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function theme:ToggleRankMenu()
	if (!ValidPanel(self.rankMenu)) then
		self.rankMenu = vgui.Create("atlaschat.ranks")
		self.rankMenu:SetSize(466, 400)
		self.rankMenu:Center()
		self.rankMenu:SetDeleteOnClose(false)
		self.rankMenu:MakePopup()
	else
		self.rankMenu:ToggleVisible()
	end
	
	self.config:SetVisible(false)
end

----------------------------------------------------------------------
-- Purpose:
--		Called when we open and close the chatbox.
----------------------------------------------------------------------

function theme:OnToggle(show)
	self.panel:SetVisible(show)
	
	local list = self.panel:GetActiveList()
	
	if (show) then
		local x, y = atlaschat.chat_x:GetInt(), atlaschat.chat_y:GetInt()
		local w, h = atlaschat.chat_w:GetInt(), atlaschat.chat_h:GetInt()
		
		if (atlaschat.chat_x:GetInt() == -1) then x = atlaschat.ScaleSize(10, true)	atlaschat.chat_x:SetInt(x) end
		if (atlaschat.chat_y:GetInt() == -1) then y  = atlaschat.ScaleSize(230)	 	atlaschat.chat_y:SetInt(y) end
		if (atlaschat.chat_w:GetInt() == 0) then w = atlaschat.ScaleSize(200, true)	atlaschat.chat_w:SetInt(w) end
		if (atlaschat.chat_h:GetInt() == 0) then h = atlaschat.ScaleSize(150) 		atlaschat.chat_h:SetInt(h) end
		
		x, y = math.Clamp(x, 0, ScrW() -w), math.Clamp(y, 0, ScrH() -h)
		
		self.panel:SetPos(x, y)
		self.panel:SetSize(w, h)
		self.panel:SetAlpha(255)
		
		self.panel.chatrooms.canvas:InvalidateChildren()
		
		list:SetParent(self.panel)
		list:Dock(FILL)
		list:SetMouseInputEnabled(true)
		list:SetKeyboardInputEnabled(true)
		list:ScrollToBottom()
		
		self.panel:MakePopup()
		self.panel.entry:RequestFocus()
	
		local children = list:GetCanvas():GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				child:SetAlpha(255)
				
				child.m_AnimList = nil
			end
		end
	else
		local x, y = self.panel:LocalToScreen(list:GetPos())
		local w, h = list:GetSize()
		
		list:SetParent()
		list:Dock(NODOCK)
		list:SetPos(x, y)
		list:SetSize(w, h)
		list:SetMouseInputEnabled(false)
		list:SetKeyboardInputEnabled(false)
		list:ScrollToBottom()
		
		local children = list:GetCanvas():GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child) and (child.fade and child.fade <= CurTime()) or !child.fade) then
				child:SetAlpha(0)
			end
		end
	end
	
	if (self.panel.entry.key) then
		self.panel.prefix:SetPrefix("PM")
	else
		if (self.panel.team) then
			self.panel.prefix:SetPrefix("TEAM")
		else
			self.panel.prefix:SetPrefix("SAY")
		end
	end
	
	if (ValidPanel(self.userListBase) and self.userListBase:IsVisible()) then
		self.userListBase:SetVisible(show)
	end
	
	self.panel.entry:SetText("")
	
	net.Start("atlaschat.istyping")
		net.WriteBit(show)
	net.SendToServer()
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

local table = table
local pairs = pairs
local string = string
local unpack = unpack
local GetType = type
local expressions = atlaschat.expression.GetStored()

function theme:PlayerLabelPressed(label)
	local theme = self
	
	local menu = DermaMenu()
		menu:AddOption("View Community Profile", function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. label.steamID64)
		end)
		
		menu:AddOption("Copy SteamID To Clipboard", function() SetClipboardText(label.steamID) end)
		
		if (LocalPlayer():IsSuperAdmin()) then
			menu:AddSpacer()
			
			menu:AddOption("Set Title", function()
				local title = ""
				
				if (IsValid(label.player)) then
					title = label.player:GetNetworkedString("ac_title", "")
				end
				
				local editor = vgui.Create("atlaschat.editor")
				editor:SetTitle("Title Editor")
				editor:SetSize(420, 400)
				editor:Center()
				editor:MakePopup()
				editor:SetValue(title)
				
				editor.steamID = label.steamID
				
				function editor:OnFinish()
					local value = self:GetValue()
					
					net.Start("atlaschat.stplttl")
						net.WriteString(self.steamID)
						net.WriteString(value)
					net.SendToServer()
					
					self:Remove()
				end
			end)
		end
		
		menu:AddSpacer()
		menu:AddOption("Cancel", function() end)
	menu:Open()
end

----------------------------------------------------------------------
-- Purpose:
--		Parses all the expressions.
----------------------------------------------------------------------

function theme:ParseExpressions(data, panel, player, title)
	local loop = true

	while loop do
		for i = 1, #data do
			local value, type = data[i], GetType(data[i])
	
			if (type == "string" or type == "number") then
				value = atlaschat.BuildFontCache(value)
				
				-- Break the loop if we don't find anything.
				loop = false
				
				local found, firstType, firstLocation = nil, nil, -1
				
				for i = 1, #expressions do
					local object = expressions[i]
					local expression = object:GetExpression()
					local result = {string.find(value, expression, 0, object.noPattern)}
					
					-- Did we find anything?
					if (result and #result > 1) then
						
						-- If we found something then we want to continue the loop.
						loop = true
						
						-- Set the first location where the expression is in the text.
						if (firstLocation == -1) then
							firstLocation = result[1]
						else
							
							-- If we found an expression that is before the first one we found, use that one.
							firstLocation = math.min(firstLocation, result[1])
						end
						
						-- We have located the first expression!
						if (result[1] == firstLocation) then
							found, firstType = result, object
						end
					end
				end

				-- Execute the function of the expression.
				if (firstType) then
					firstType.player = player
					
					local expression = firstType:GetExpression()
					local canUse = title and true or hook.Run("AtlasChatCanUseExpression", player, expression, firstType:GetUnique())
					local panelObject
					
					if (canUse) then
						panelObject = firstType:Execute(panel, unpack(found, 3))
					else
						panelObject = atlaschat.GenericLabel()
						panelObject:SetText("") --firstType.noPattern and expression or found[3] or "")
						panelObject:SetColor(color_white)
						panelObject:SizeToContents()
					end
					
					if (panelObject != nil) then
						local startPos, endPos = found[1], found[2]
						
						data[i] = string.sub(value, 1, startPos -1)
						
						table.insert(data, i +1, panelObject)
						
						local text = string.sub(value, endPos +1)
						
						if (text != "") then
							table.insert(data, i +2, text)	
						end
					end
				end
			end
		end
	end
end

---------------------------------------------------------
-- This is where we add all the panels.
---------------------------------------------------------

local parseX, parseColor, titleColor, parseBase = nil, nil, nil, nil

function theme:ParseData(data, list, isTitle)
	local realColor = isTitle and titleColor or parseColor
	
	for i = 1, #data do
		local value, type = data[i], GetType(data[i])

		if (type == "Player") then
			local avatarsEnabled = atlaschat.enableAvatars:GetBool()
			local avatarsEnabledLocal = atlaschat.enableAvatarsLocal:GetBool()
			local rankIconsEnabled = atlaschat.enableRankIcons:GetBool()
			local rankTitleEnabled = atlaschat.enableRankTitle:GetBool()
			
			local darkrpAllChat = false
			
			if (atlaschat.darkrpChat) then
				darkrpAllChat = atlaschat.darkrpChat:GetBool()
			end
			
			if (!DarkRP or (DarkRP and (data[2] == "(OOC) " or i == 1 or darkrpAllChat))) then
				if (avatarsEnabledLocal and avatarsEnabled) then
					local canUse = hook.Run("AtlasChatCanUseExpression", value, "<avatar=" .. value:SteamID() .. ">", "avatar_steamid")
					
					if (DarkRP and canUse) then
						canUse = false
						
						if (data[2] == "(OOC) " or i == 1) then
							canUse = true
						end
					end
					
					if (canUse) then
						local size = atlaschat.smallAvatar:GetBool() and 24 or 32
					
						if (parseBase:GetTall() < size) then
							parseBase:SetTall(size)
						end
					
						local avatar = parseBase:Add("AvatarImage")
						avatar:SetPos(parseX, 0)
						avatar:SetSize(size, size)
						avatar:SetPlayer(value, size)
						
						avatar.steamID = value:SteamID()
						
						function avatar:OnCopiedText()
							return "<avatar=" .. self.steamID .. ">"
						end
						
						parseX = parseX +avatar:GetWide() +4
					end
				end
				
				local wyoziteEnabled = atlaschat.enableWyoziteTags:GetBool()
				
				if (wyozite and wyoziteEnabled) then
					local tag = value:GetNetworkedString("wte_sbtstr", "")
					
					if (tag != "") then
						local color = value:GetNetworkedVector("wte_sbtclr")
						
						color = Color(color.x, color.y, color.z)
						
						local tagData = {color, tag}
				
						self:ParseExpressions(tagData, parseBase, value, true)
						self:ParseData(tagData, list, true)
					end
				end
				
				if (rankTitleEnabled) then
					for userGroup, data in pairs(atlaschat.ranks) do
						local isUserGroup = value:IsUserGroup(userGroup)
						
						if (isUserGroup and data.tag != "") then
							local tagData = {data.tag}
					
							self:ParseExpressions(tagData, parseBase, value, true)
							self:ParseData(tagData, list, true)
						end
					end
				end
				
				if (rankIconsEnabled) then
					for userGroup, data in pairs(atlaschat.ranks) do
						if (data.icon != "") then
							local isUserGroup = value:IsUserGroup(userGroup)
							
							if (isUserGroup) then
								local icon = parseBase:Add("DImage")
								icon:SetImage(data.icon)
								icon:SetSize(16, 16)
								icon:SetPos(parseX +2, 0)
								icon:SetToolTip(userGroup)
								
								function icon:OnCopiedText()
									return userGroup
								end
								
								parseX = parseX +icon:GetWide() +4
							end
						end
					end
				end
				
				local title = value:GetNetworkedString("ac_title", "")
				
				if (title != "") then
					local titleData = {title}
		
					self:ParseExpressions(titleData, parseBase, value, true)
					self:ParseData(titleData, list, true)
				end
			end
			
			-- Check if the previous entry in the table is a color object, if it is then use it instead of the player team color.
			local color, text = data[i -1] and IsColor(data[i -1]) and realColor or team.GetColor(value:Team()), value:Nick() --GAMEMODE.GetAmMurderer and value:Team() == 2 and value:GetBystanderName() or value:Nick()

			local label = atlaschat.GenericLabel()
			label:SetParent(parseBase)
			label:SetPos(parseX, 0)
			label:SetText(text)
			label:SetColor(color)
			label:SizeToContents()
			label:SetMouseInputEnabled(true)
			
			label.cursor = true
			label.player = value
			label.steamID = value:SteamID()
			label.steamID64 = value:SteamID64()
			
			function label:OnCursorEntered()
				self:SetCursor("hand")
			end
			
			function label:OnCursorExited()
				self:SetCursor("arrow")
			end
			
			function label:OnMousePressed(code)
				if (code == MOUSE_LEFT) then
					self.wasPressed = CurTime()
				end
			end
			
			function label:OnMouseReleased()
				if (self.wasPressed and CurTime() -self.wasPressed <= 0.16) then
					atlaschat.theme.Call("PlayerLabelPressed", self)
				end
				
				self.wasPressed = nil
			end
			
			atlaschat.BuildFontCache(text)
			
			parseX = parseX +label:GetWide()
		end
		
		if (type == "table") then
			if (value.r and value.g and value.b) then
				realColor = value
			end
		end
		
		if (type == "string" or type == "number") then
			value = atlaschat.BuildFontCache(value)
			
			local label = atlaschat.GenericLabel()
			label:SetParent(parseBase)
			label:SetPos(parseX, 0)
			label:SetText("")
			label:SetColor(realColor)
			label:SizeToContents()
			
			local exploded, start, ending, seperator = string.Explode(" ", value), 1, 1, " "
			
			if (#exploded <= 2) then
				exploded, seperator = string.Explode("", value), ""
			end
			
			while ending <= #exploded do
				local text = table.concat(exploded, seperator, start, ending)
				
				-- Search for newlines.
				local head, tail = string.find(text, "\n", 1, true)
			
				if (head) then
					if (seperator == "") then
						local text = string.sub(text, 1, head -1)
						
						label:SetText(text)
						label:SizeToContents()
						
						parseBase = atlaschat.NewBasePanel()
						
						-- Add the base panel to the list so it'll get a size
						list:AddItem(parseBase)
						list:GetCanvas():InvalidateLayout(true)
	
						parseBase:InvalidateLayout(true)
						
						parseX = 4

						label = atlaschat.GenericLabel()
						label:SetParent(parseBase)
						label:SetPos(parseX, 0)
						label:SetText("")
						label:SetColor(realColor)
						label:SizeToContents()
						
						table.remove(exploded, ending)
						
						start, ending = ending, start
					else
						local newText = string.sub(text, 1, head -1)
						local leftOver = string.sub(text, tail +1)

						label:SetText(newText)
						label:SizeToContents()
						
						parseBase = atlaschat.NewBasePanel()
						
						-- Add the base panel to the list so it'll get a size
						list:AddItem(parseBase)
						list:GetCanvas():InvalidateLayout(true)
	
						parseBase:InvalidateLayout(true)
						
						parseX = 4

						label = atlaschat.GenericLabel()
						label:SetParent(parseBase)
						label:SetPos(parseX, 0)
						label:SetText(leftOver)
						label:SetColor(realColor)
						label:SizeToContents()
						
						parseX = parseX +label:GetWide()

						exploded[ending] = leftOver
						
						start, ending = ending, start
					end
				else
					label:SetText(text)
					label:SizeToContents()
				
					-- Too much text, let's cut it off.
					if (parseX +label:GetWide() >= parseBase:GetWide() -(list.VBar.btnGrip:GetWide() +2)) then
						local previous = ending -1
						
						-- This is when it's in the beginning of the text.
						if (previous < start) then
							parseBase = atlaschat.NewBasePanel()
							
							-- Add the base panel to the list so it'll get a size
							list:AddItem(parseBase)
							list:GetCanvas():InvalidateLayout(true)
		
							parseBase:InvalidateLayout(true)
							
							parseX = 4
	
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText(text .. " ")
							label:SizeToContents()
							
							parseX = parseX +label:GetWide()
							
							-- Create the next label.
							label = atlaschat.GenericLabel()
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText("")
							label:SetColor(realColor)
							label:SizeToContents()
							
							start, ending = ending +1, start
						else
							label:SetText(table.concat(exploded, seperator, start, previous))
							label:SizeToContents()
				
							parseX = 4
		
							parseBase = atlaschat.NewBasePanel()
							
							-- Add the base panel to the list so it'll get a size
							list:AddItem(parseBase)
							list:GetCanvas():InvalidateLayout(true)
		
							parseBase:InvalidateLayout(true)
							
							-- Create the next label.
							label = atlaschat.GenericLabel()
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText("")
							label:SetColor(realColor)
							label:SizeToContents()
	
							start, ending = ending, start
						end
					else
						ending = ending +1
						
						-- We're at the end.
						if (ending > #exploded) then
							if (text != "") then
								label:SetText(text)
								label:SizeToContents()
								
								parseX = parseX +label:GetWide()
							else
								label:Remove()
							end
						end
					end
				end
			end
		end
		
		if (type == "Panel") then
			-- Lol hacky.
			if (parseBase != value:GetParent()) then
				value:SetParent(parseBase)
			end
			
			if (value:GetTall() > parseBase:GetTall()) then
				parseBase:SetTall(value:GetTall())
			end
			
			value:SetPos(parseX, 0)
			
			-- Wrap the label.
			if (value:GetClassName() == "Label") then
				local label, valueText, font = value, value:GetText(), value:GetFont()
				
				atlaschat.BuildFontCache(valueText, font)
				
				label:SetText("")
				label:SizeToContents()
				
				local exploded, start, ending, color, seperator = string.Explode(" ", valueText), 1, 1, value:GetTextColor(), " "
	
				if (#exploded <= 2) then
					exploded, seperator = string.Explode("", valueText), ""
				end
			
				while ending <= #exploded do
					local text = table.concat(exploded, seperator, start, ending)
					
					label:SetText(text)
					label:SizeToContents()
				
					-- Too much text, let's cut it off.
					if (parseX +label:GetWide() >= parseBase:GetWide() -(self.panel.list.VBar.btnGrip:GetWide() +2)) then
						local previous = ending -1
						
						-- This is when it's in the beginning of the text.
						if (previous < start) then
							parseBase = atlaschat.NewBasePanel()
							
							-- Add the base panel to the list so it'll get a size
							list:AddItem(parseBase)
							list:GetCanvas():InvalidateLayout(true)
		
							parseBase:InvalidateLayout(true)
							
							parseX = 4
	
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText(text .. " ")
							label:SizeToContents()
							
							parseX = parseX +label:GetWide()
							
							local attributes = label:GetTable()
							
							-- Create the next label.
							label = atlaschat.GenericLabel()
							
							for k, v in pairs(attributes) do
								label[k] = v
							end
							
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText("")
							label:SetFont(font)
							label:SetColor(color)
							label:SizeToContents()
							
							if (label:GetTall() > parseBase:GetTall()) then
								parseBase:SetTall(label:GetTall())
							end
							
							start, ending = ending +1, start
						else
							label:SetText(table.concat(exploded, seperator, start, previous))
							label:SizeToContents()
				
							parseX = 4
		
							parseBase = atlaschat.NewBasePanel()
							
							-- Add the base panel to the list so it'll get a size
							list:AddItem(parseBase)
							list:GetCanvas():InvalidateLayout(true)
		
							parseBase:InvalidateLayout(true)
							
							local attributes = label:GetTable()
							
							-- Create the next label.
							label = atlaschat.GenericLabel()
							
							for k, v in pairs(attributes) do
								label[k] = v
							end
							
							label:SetParent(parseBase)
							label:SetPos(parseX, 0)
							label:SetText("")
							label:SetFont(font)
							label:SetColor(color)
							label:SizeToContents()
							
							if (label:GetTall() > parseBase:GetTall()) then
								parseBase:SetTall(label:GetTall())
							end
							
							start, ending = ending, start
						end
					else
						ending = ending +1
						
						-- We're at the end.
						if (ending > #exploded) then
							if (text != "") then
								label:SetText(text)
								label:SizeToContents()
								
								parseX = parseX +label:GetWide()
							else
								label:Remove()
							end
						end
					end
				end
			else
				parseX = parseX +value:GetWide() +1
			end
		end
	end
end

---------------------------------------------------------
-- When text is added this is where we add it to the
-- chatbox text list.
---------------------------------------------------------

function theme:ParseText(list, ...)
	local data = {...}
	local list = list or self.panel.list

	-- This is the panel that the text rests on.
	parseBase = atlaschat.NewBasePanel()

	-- We'll use this to set the position of the next item and to see if width is overflowing.
	parseX = 4
	
	-- This is the color of the text.
	parseColor = Color(255, 255, 255)
	
	-- Special for the title.
	titleColor = Color(255, 255, 255)
	
	-- Add the base panel to the list so it'll get a size
	list:AddItem(parseBase)
	list:GetCanvas():InvalidateLayout(true)
	
	parseBase:InvalidateLayout(true)

	-- DarkRP support.
	if (DarkRP and GetType(data[2]) == "string") then
		local player = util.FindPlayerAtlaschat(data[2])
		
		-- data[2] = "(OOC) Name"
		
		if (IsValid(player)) then
			local nick = player:Nick()
			local nickStart, nickEnd = string.find(data[2], nick, 1, true)
			
			if (nickStart and nickEnd) then
				local leftOver = string.sub(data[2], nickEnd +1)
				
				data[2] = string.sub(data[2], 1, nickStart -1)
				
				local color = data[1]
				
				if (IsColor(color)) then
					table.insert(data, 3, color)
					table.insert(data, 4, player)
					
					if (leftOver and leftOver != "") then
						table.insert(data, 5, leftOver)
					end
				else
					table.insert(data, 3, player)
					
					if (leftOver and leftOver != "") then
						table.insert(data, 4, leftOver)
					end
				end
			end
		end

	-- TTT Support.
	elseif (GAMEMODE.round_state) then
		local check = 	data[2] == Format("(%s) ", string.upper(LANG.GetTranslation("traitor"))) or
						data[2] == Format("(%s) ", string.upper(LANG.GetTranslation("detective"))) or
						data[2] == Format("(%s) ", string.upper(LANG.GetTranslation("last_words")))
		
		if (GetType(data[4]) == "string" and GetType(data[2]) == "string") then
			if (check) then
				local player = util.FindPlayerAtlaschat(data[4])
		
				if (IsValid(player)) then
					data[4] = player
				end
			else
				if (#data > 6 and GetType(data[6]) == "string") then
					local player = util.FindPlayerAtlaschat(data[6])
		
					if (IsValid(player)) then
						data[6] = player
					end
				else
					if (#data == 6) then
						local player = util.FindPlayerAtlaschat(data[4])
				
						if (IsValid(player)) then
							data[4] = player
						end
					else
						local player = util.FindPlayerAtlaschat(data[2])
				
						if (IsValid(player)) then
							data[2] = player
						end
					end
				end
			end
		end
	
	-- Hide and Seek support.
	elseif (SeekerBlinded != nil) then
		if (GetType(data[2]) == "string" and IsColor(data[1]) and IsColor(data[3])) then
			local player = util.FindPlayerAtlaschat(data[2])
	
			if (IsValid(player)) then
				data[2] = player
			end
		end
	
	-- Murder support. || 2015-07-08 -> WHY THE HELL DID I ADD THIS??
	--elseif (GAMEMODE.SetAmMurderer) then
	--	if (GetType(data[2]) == "string") then
	--		local player = util.FindPlayerAtlaschat(data[2])
	
	--		if (IsValid(player)) then
	--			data[2] = player
	--		end
	--	end

	-- Surf support.
	elseif (Core and Core.StyleName) then
		local surf_color = Color(98, 176, 255)

		for i = 1, #data do
			if (IsColor(data[i]) and data[i] == surf_color and isstring(data[i +1])) then
				local player = util.FindPlayerAtlaschat(data[i +1])
	
				if (IsValid(player)) then
					data[i +1] = player
	
					break
				end
			end
		end
	end

	-- Parse expressions.
	local expressionPlayer

	for i = 1, #data do
		local value, type = data[i], GetType(data[i])
	
		if (type == "Player") then
			expressionPlayer = value
			
			break
		end
	end

	if (IsValid(expressionPlayer)) then
		local canUse = hook.Run("AtlasChatCanUseExpressions", expressionPlayer)
		
		if (canUse) then
			self:ParseExpressions(data, parseBase, expressionPlayer)
		end
	else
		self:ParseExpressions(data, parseBase, expressionPlayer)
	end
	
	-- A nice little timestamp!
	if (atlaschat.timestamp:GetBool()) then
		local date = os.date("%H:%M:%S", os.time())
		
		local label = atlaschat.GenericLabel()
		label:SetParent(parseBase)
		label:SetPos(parseX, 0)
		label:SetText(date)
		label:SetColor(self.color.timestamp)
		label:SizeToContents()
		
		atlaschat.BuildFontCache(date)
		
		parseX = parseX +label:GetWide()
		
		local label = atlaschat.GenericLabel()
		label:SetParent(parseBase)
		label:SetPos(parseX, 0)
		label:SetText(" - ")
		label:SetColor(color_white)
		label:SizeToContents()

		parseX = parseX +label:GetWide()
	end
	
	-- Add all the panels.
	self:ParseData(data, list)
	
	-- Make the chat category blink.
	if (self.panel:GetActiveList() != list) then
		self.mainChat:SetNew(true)
	end
	
	local canvas = list:GetCanvas()

	canvas:InvalidateLayout(true)
	canvas:InvalidateChildren(true)
	
	if (self.panel:IsVisible()) then
		if (list:GetShouldScroll()) then
			timer.Simple(0.1, function() list.VBar:SetScroll(list:GetCanvas():GetTall()) end)
		end
	else
		timer.Simple(0.1, function() list.VBar:SetScroll(list:GetCanvas():GetTall()) end)
	end
	
	local playSound = atlaschat.chatSound:GetBool()
	
	if (playSound) then
		chat.PlaySound()
	end
	
	-- Reset the values.
	parseX, parseColor, titleColor, parseBase = nil, nil, nil, nil
end

-- vk.com/urbanichka