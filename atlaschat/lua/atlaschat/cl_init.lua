local surface, string = surface, string

atlaschat = atlaschat or {}

atlaschat.ranks = {}
atlaschat.restrictions = {}

----------------------------------------------------------------------
-- Purpose:
--		Reverts the chat font if it does not exist.
----------------------------------------------------------------------

function atlaschat.FixInvalidFont()
	local ok = pcall(draw.SimpleText, "shit", atlaschat.font:GetString(), 0, 0, color_transparent, 1, 1)

	if (!ok) then
		atlaschat.font:SetString("atlaschat.theme.text")

		Msg("Reverting atlaschat font because it is invalid!\n")

		return true
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Include all the files that the client needs.
----------------------------------------------------------------------

include("sh_utilities.lua")
include("sh_config.lua")
include("cl_expression.lua")
include("cl_theme.lua")
include("cl_panel.lua")

include("gui/frame.lua")
include("gui/config.lua")
include("gui/slider.lua")
include("gui/expression_list.lua")
include("gui/form.lua")
include("gui/rank_list.lua")
include("gui/editor.lua")
include("gui/mysql.lua")
include("gui/restrictions.lua")
include("gui/chatroom.lua")

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function atlaschat.ScaleSize(amount, x)
	amount = amount *(x and ScrW() or ScrH()) /(x and 640 or 480)

	return amount
end

----------------------------------------------------------------------
-- Purpose:
--		Add gamemode functions.
----------------------------------------------------------------------

hook.Add("PostGamemodeLoaded", "atlaschat.AddGamemodeFunctions", function()

	----------------------------------------------------------------------
	-- Purpose:
	--		Return false to disable access to all expressions.
	----------------------------------------------------------------------

	function GAMEMODE:AtlasChatCanUseExpressions(player)
		return true
	end

	----------------------------------------------------------------------
	-- Purpose:
	--		Return false to disable access to an expression.
	----------------------------------------------------------------------

	function GAMEMODE:AtlasChatCanUseExpression(player, expression, unique)
		if (IsValid(player)) then
			local data = atlaschat.restrictions[unique]

			if (data) then
				local usergroup = player:GetUserGroup()

				if (data[usergroup]) then
					return false
				end
			end
		end

		return true
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Create the chatbox.
----------------------------------------------------------------------

hook.Add("InitPostEntity", "atlaschat.CreateChatbox", function()
	atlaschat.theme.DeriveThemes()

	local theme = atlaschat.theme.GetCurrent()

	if (!theme) then
		Msg("Invalid atlaschat theme! Reverting back to default.\n")

		atlaschat.themeConfig:SetString("default")
	end

	local panel = atlaschat.theme.GetValue("panel")

	if (!ValidPanel(panel)) then
		atlaschat.theme.Call("Initialize")

		atlaschat.themeConfig:OnChange(atlaschat.themeConfig:GetString())

		atlaschat.FixInvalidFont()

		atlaschat.fontHeight = draw.GetFontHeight(atlaschat.font:GetString())

		net.Start("atlaschat.plload")
		net.SendToServer()
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Draw "Copied text!" notifications.
----------------------------------------------------------------------

local copiedNotify = {}

hook.Add("DrawOverlay", "atlaschat.DrawCopiedNotify", function()
	for i = 1, #copiedNotify do
		local data = copiedNotify[i]

		if (data) then
			draw.SimpleText("Copied text!", "atlaschat.theme.text.shadow", data.x, data.y, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("Copied text!", "atlaschat.theme.text", data.x +1, data.y +1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
			draw.SimpleText("Copied text!", "atlaschat.theme.text", data.x, data.y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

			data.x = data.origin +math.sin(CurTime() *2) *10
			data.y = data.y -0.2

			if (data.time <= CurTime()) then
				table.remove(copiedNotify, i)
			end
		end
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Hides the default chatbox.
----------------------------------------------------------------------

hook.Add("HUDShouldDraw", "atlaschat.HUDShouldDraw", function(id)
	local panel = atlaschat.theme.GetValue("panel")

	if (ValidPanel(panel) and id == "CHudChat") then
		return false
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Opens the chatbox.
----------------------------------------------------------------------

hook.Add("PlayerBindPress", "atlaschat.PlayerBindPress", function(player, bind, pressed)
	if (bind == "messagemode" and pressed) then
		local panel = atlaschat.theme.GetValue("panel")

		if (ValidPanel(panel)) then
			panel.team = false

			atlaschat.theme.Call("OnToggle", true)

			hook.Run("StartChat", false)
	
			return true
		end
	end

	if (bind == "messagemode2" and pressed) then
		local panel = atlaschat.theme.GetValue("panel")

		if (ValidPanel(panel)) then
			panel.team = true

			atlaschat.theme.Call("OnToggle", true)

			hook.Run("StartChat", true)

			return true
		end
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Player connect & disconnect message.
----------------------------------------------------------------------

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "atlaschat.DisconnectMessage", function(data)
	local filtered = atlaschat.filterJoinDisconnect:GetBool()

	if (!filtered) then
		chat.AddText(color_white, ":offline: Player ", color_red, data.name, color_grey, " (" .. data.networkid	.. ") ", color_white, "вышел с сервера: " .. data.reason)
	end
end)

net.Receive("atlaschat.plcnt", function(bits)
	local name = net.ReadString()
	local steamID = net.ReadString()
	local filtered = atlaschat.filterJoinDisconnect:GetBool()

	if (!filtered) then
		chat.AddText(color_white, ":online: Player ", color_limegreen, name, color_grey, " (" .. steamID .. ") ", color_white, "зашел на сервер.")
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Other chat messages.
----------------------------------------------------------------------

hook.Add("ChatText", "atlaschat.ChatText", function(index, name, text, filter)
	if (tonumber(index) == 0) then
		if (filter == "joinleave") then -- Does this even work anymore?
			return ""
		elseif (filter == "none") then
			if (name == "Console") then
				local panel = atlaschat.theme.GetValue("panel")

				if (ValidPanel(panel)) then
					atlaschat.theme.Call("ParseText", nil, color_white, text)
				end
			end
		elseif (filter == "chat") then
			if (name and name != "") then
				chat.AddText(color_grey, name, color_white, text)
			else
				timer.Simple(0, function() chat.AddText(color_white, text) end)
			end
		end
	end
end)

----------------------------------------------------------------------
-- Purpose:
--		Opens the chat window.
----------------------------------------------------------------------

function chat.Open()
	local theme = atlaschat.theme.GetCurrent()

	theme:OnToggle(true)
end

----------------------------------------------------------------------
-- Purpose:
--		Closes the chat window.
----------------------------------------------------------------------

function chat.Close()
	local theme = atlaschat.theme.GetCurrent()

	theme:OnToggle(false)
end

----------------------------------------------------------------------
-- Purpose:
--		Override chat.GetChatBoxPos to return our chatbox position.
----------------------------------------------------------------------

function chat.GetChatBoxPos()
	local panel = atlaschat.theme.GetValue("panel")

	if (ValidPanel(panel)) then
		local x, y = panel:GetPos()

		return x, y
	else
		return 0, 0
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Override chat.GetChatBoxSize to return our chatbox size.
----------------------------------------------------------------------

function chat.GetChatBoxSize()
	local panel = atlaschat.theme.GetValue("panel")
	
	if (ValidPanel(panel)) then
		local w, h = panel:GetSize()

		return w, h
	else
		return 0, 0
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Override chat.AddText to use our theme function.
----------------------------------------------------------------------

if (!atlaschat.chatAddText) then atlaschat.chatAddText = chat.AddText end

function chat.AddText(...)
	local panel = atlaschat.theme.GetValue("panel")

	if (ValidPanel(panel)) then
		atlaschat.theme.Call("ParseText", nil, ...)
	end

	atlaschat.chatAddText(...)
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

local function __clean(s, replacement)
  local p, len = 1, #s

  while p <= len do
    if     p == s:find("[%z\1-\127]", p) then p = p + 1
    elseif p == s:find("[\194-\223][\128-\191]", p) then p = p + 2
    elseif p == s:find(       "\224[\160-\191][\128-\191]", p)
        or p == s:find("[\225-\236][\128-\191][\128-\191]", p)
        or p == s:find(       "\237[\128-\159][\128-\191]", p)
        or p == s:find("[\238-\239][\128-\191][\128-\191]", p) then p = p + 3
    elseif p == s:find(       "\240[\144-\191][\128-\191][\128-\191]", p)
        or p == s:find("[\241-\243][\128-\191][\128-\191][\128-\191]", p)
        or p == s:find(       "\244[\128-\143][\128-\191][\128-\191]", p) then p = p + 4
    else
      s = s:sub(1, p-1)..replacement..s:sub(p+1)
    end
  end

  return s
end

atlaschat.fontCache = atlaschat.fontCache or {}

function atlaschat.BuildFontCache(text, font)
	local text = tostring(text)
	text = __clean(text, " ")
	text = text:gsub("\t", "    ") -- a shitty hack for tabs

	local font = font or atlaschat.font:GetString()
	local lowered = string.lower(font)
	local len = string.utf8len(text)

	if (!atlaschat.fontCache[lowered]) then atlaschat.fontCache[lowered] = {} end

	surface.SetFont(font)

	for i = 1, len do
		local character = string.utf8sub(text, i, i)

		if (!atlaschat.fontCache[lowered][character]) then
			local width = surface.GetTextSize(character)

			atlaschat.fontCache[lowered][character] = width
		end
	end

	width = surface.GetTextSize("�")

	atlaschat.fontCache[lowered]["�"] = width
	
	return text
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------
	
local copiedText = false
local currentPanel
local previousPanel
local lastMouseDown

function atlaschat.NewBasePanel()
	local spacing = atlaschat.theme.GetValue("messageSpacing") or 2

	local panel = vgui.Create("Panel")
	panel:SetTall(atlaschat.fontHeight)
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 0, spacing)

	panel.fade = CurTime() +atlaschat.fadetime:GetInt()
	panel.selection = {}

	function panel:GetChildrenWidth()
		local children = self:GetChildren()
		local childrenWidth = 0

		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				childrenWidth = childrenWidth +child:GetWide()
			end
		end

		return childrenWidth +8
	end

	function panel:Think()
		local chatPanel = atlaschat.theme.GetValue("panel")

		if (ValidPanel(chatPanel) and chatPanel:IsVisible()) then
			local x, y = self:LocalCursorPos()

			if (x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()) then
				local children = self:GetChildren()
				local childrenWidth = self:GetChildrenWidth()

				if (x >= 0 and x <= childrenWidth +8) then
					self:SetCursor("beam")

					for k, child in pairs(children) do
						if (ValidPanel(child) and !child.cursor) then
							child:SetCursor("beam")
						end
					end

					if (input.IsMouseDown(MOUSE_LEFT)) then
						currentPanel = self

						if (!ValidPanel(previousPanel)) then
							previousPanel = self
						else
							local list = chatPanel:GetActiveList()
							local children = list:GetCanvas():GetChildren()
							local _, y = previousPanel:GetPos()
							local _, y2 = self:GetPos()

							if (y2 == y and previousPanel.selection.backup) then
								previousPanel.selection.width = previousPanel.selection.backup

								previousPanel.selection.backup = nil
							end

							-- previousPanel is lower down.
							if (y > y2) then
								self.selection.x = childrenWidth
								previousPanel.selection.backup = previousPanel.selection.width
								previousPanel.selection.width = 4

								for k, child in pairs(children) do
									local _, y3 = child:GetPos()

									if (y3 < y and y3 > y2) then
										child.selection.x = 4
										child.selection.width = child:GetChildrenWidth()
									end

									-- Reset everything that is below or above.
									if (y3 > y or y3 < y2) then
										child.selection.x = nil
										child.selection.width = nil
									end
								end
							else
								if (y2 > y) then
									self.selection.x = 4
									previousPanel.selection.width = previousPanel:GetChildrenWidth()
								end

								for k, child in pairs(children) do
									local _, y3 = child:GetPos()

									if (y3 > y and y3 < y2) then
										child.selection.x = 4
										child.selection.width = child:GetChildrenWidth()
									end

									-- Reset everything that is above or below.
									if (y3 < y or y3 > y2) then
										child.selection.x = nil
										child.selection.width = nil
									end
								end
							end
						end

						if (!self.selection.x) then
							for k, child in pairs(children) do
								if (ValidPanel(child)) then
									local x2 = child:GetPos()

									if (x >= x2 and x <= x2 +child:GetWide()) then
										if (child:GetClassName() == "Label") then
											local text, start, font, totalWidth = child:GetText(), 1, string.lower(child:GetFont()), 0
											local len = string.utf8len(text)

											while start <= len do
												local character = string.utf8sub(text, start, start)
												local width = atlaschat.fontCache[font][character]

												if (x2 +totalWidth +width >= x) then
													self.selection.x = x2 +totalWidth

													break
												end

												totalWidth, start = totalWidth +width, start +1
											end
										else
											self.selection.x = x2
										end
									end
								end
							end
						else
							for k, child in pairs(children) do
								if (ValidPanel(child)) then
									local x2 = child:GetPos()
									local wide = child:GetWide()

									if (x >= x2 and x <= x2 +wide) then
										if (child:GetClassName() == "Label") then
											local text, start, font, totalWidth = child:GetText(), 1, string.lower(child:GetFont()), 0
											local len = string.utf8len(text)

											while start <= len do
												local character = string.utf8sub(text, start, start)
												local width = atlaschat.fontCache[font][character]

												if (x >= x2 +(totalWidth -width /2)) then
													self.selection.width = x2 +totalWidth
												end

												start = start +1
												
												if (start > len and x2 +totalWidth +width >= x2 +wide and x >= x2 +totalWidth) then
													self.selection.width = x2 +wide
												end

												totalWidth = totalWidth +width
											end
										else
											if (x >= x2 +wide) then
												self.selection.width = x2 +wide
											end
										end
									end
								end
							end
						end
					end
				else
					self:SetCursor("arrow")

					for k, child in pairs(children) do
						if (ValidPanel(child) and !child.cursor) then
							child:SetCursor("arrow")
						end
					end
				end
			end
		end

		if (ValidPanel(chatPanel) and !chatPanel:IsVisible()) then
			if (self.fade and self.fade <= CurTime()) then
				self:AlphaTo(0, 1.5, 0)

				self.fade = nil
			end
		end
	end

	function panel:PaintOver(w, h)
		if (self.selection and self.selection.width and self.selection.x) then
			local color = atlaschat.theme.GetValue("color").selection

			if (self.selection.width < self.selection.x) then
				draw.SimpleRect(self.selection.width, 0, self.selection.x -self.selection.width, h, color)
			else
				draw.SimpleRect(self.selection.x, 0, self.selection.width -self.selection.x, h, color)
			end
		end
	end

	function panel:PerformLayout()
		local height = self:GetTall()
		local children = self:GetChildren()

		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				local x = child:GetPos()
				local childHeight = child:GetTall()

				child:SetPos(x, height /2 -childHeight /2)
			end
		end
	end

	function panel:OnChildAdded(child)
		local click = child.OnMousePressed
		local panel = self
		
		function child:OnMousePressed(code)
			if (code == MOUSE_RIGHT) then
				local menu = DermaMenu()
					menu:AddOption("Copy Line", function()
						local clipboardText = ""
						local x, width = 0, panel:GetWide()
						local children = panel:GetChildren()
						local sortedChildren = {}
			
						for k, child in pairs(children) do
							if (ValidPanel(child)) then
								table.insert(sortedChildren, child)
							end
						end
						
						table.sort(sortedChildren, function(a, b) return a.x < b.x end)
			
						for i = 1, #sortedChildren do
							local child = sortedChildren[i]
							local x2, wide = child:GetPos(), child:GetWide()
			
							if ((x >= x2 or x2 >= x) and (width <= x2 +wide or width >= x2 +wide)) then
								if (child:GetClassName() == "Label") then
									local text, start, font, totalWidth, final = child:GetText(), 1, string.lower(child:GetFont()), 0, ""
									local len = string.utf8len(text)
			
									while start <= len do
										local character = string.utf8sub(text, start, start)
										local characterWidth = atlaschat.fontCache[font][character]
			
										if (x2 +totalWidth >= x and x2 +totalWidth +characterWidth <= width) then
											final = final .. character
										end
			
										totalWidth, start = totalWidth +characterWidth, start +1
									end
			
									clipboardText = clipboardText .. final
								else
									if (x2 >= x and width >= x2 +wide) then
										if (child.OnCopiedText) then
											local text = child:OnCopiedText()
			
											clipboardText = clipboardText .. text
										end
									end
								end
							end
						end
		
						-- TextEntry hack thanks to Python1320
						local clipboard = vgui.Create("DTextEntry")
						clipboard:SetAllowNonAsciiCharacters(true)
						clipboard:SetText(clipboardText)
						clipboard:SelectAllText()
						clipboard:CutSelected()
						clipboard:Remove()
			
						local x, y = gui.MousePos()
						local time = CurTime() +4
			
						table.insert(copiedNotify, {origin = x, x = x, y = y, time = time})
					end)
				menu:Open()
			end
			
			if (click) then click(self, code) end
		end
	end
	
	if (atlaschat.messageFadeIn:GetBool()) then
		panel:SetAlpha(0)
		panel:AlphaTo(255, 0.12, 0)
	end

	return panel
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

local function b(parent, noWrap, font)
	local fontHeight = font and draw.GetFontHeight(font) or atlaschat.fontHeight

	local base = parent:Add("Panel")
	base:SetTall(fontHeight)
	base:Dock(TOP)
	base:DockMargin(0, 6, 0, 0)
	base:SetMouseInputEnabled(false)

	function base:PerformLayout()
		local height = self:GetTall()
		local children = self:GetChildren()

		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				local x = child:GetPos()

				if (noWrap) then
					child:SetPos(x, 0)
				else
					local childHeight = child:GetTall()

					child:SetPos(x, height /2 -childHeight /2)
				end
			end
		end
	end

	return base
end

function atlaschat.ParseExpressionPreview(parent, font, noWrap)
	local base = b(parent, noWrap, font)
	local theme = atlaschat.theme.GetCurrent()

	-- Add the base panel to the list so it'll get a size
	parent:InvalidateLayout(true)
	base:InvalidateLayout(true)

	local x = 4
	local titleData = {parent.value}

	theme:ParseExpressions(titleData, base, player)

	for i = 1, #titleData do
		local value, type = titleData[i], GetType(titleData[i])

		if (type == "string" or type == "number") then
			local label = atlaschat.GenericLabel()
			label:SetParent(base)
			label:SetPos(x, 0)
			label:SetText("")
			label:SetColor(color_white)

			if (font) then label:SetFont(font) end

			label:SizeToContents()

			local exploded, start, ending = string.Explode(" ", value), 1, 1

			while ending <= #exploded do
				local text = table.concat(exploded, " ", start, ending)

				label:SetText(text)
				label:SizeToContents()

				-- Too much text, let's cut it off.
				if (x +label:GetWide() >= base:GetWide() -4) then
					local previous = ending -1

					-- This is when it's in the beginning of the text.
					if (previous < start) then
						base = b(parent, noWrap, font)

						-- Add the base panel to the list so it'll get a size
						parent:InvalidateLayout(true)
						base:InvalidateLayout(true)

						x = 4

						label:SetParent(base)
						label:SetPos(x, 0)
						label:SetText(text .. " ")
						label:SizeToContents()

						x = x +label:GetWide()

						-- Create the next label.
						label = atlaschat.GenericLabel()
						label:SetParent(base)
						label:SetPos(x, 0)
						label:SetText("")
						label:SetColor(color_white)

						if (font) then label:SetFont(font) end

						label:SizeToContents()

						start, ending = ending +1, start
					else
						label:SetText(table.concat(exploded, " ", start, previous))
						label:SizeToContents()

						x = 4

						base = b(parent, noWrap, font)

						-- Add the base panel to the list so it'll get a size
						parent:InvalidateLayout(true)
						base:InvalidateLayout(true)

						-- Create the next label.
						label = atlaschat.GenericLabel()
						label:SetParent(base)
						label:SetPos(x, 0)
						label:SetText("")
						label:SetColor(color_white)

						if (font) then label:SetFont(font) end

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

							x = x +label:GetWide()
						else
							label:Remove()
						end
					end
				end
			end
		end

		if (type == "Panel") then
			-- Lol hacky.
			if (base != value:GetParent()) then
				value:SetParent(base)
			end

			if (value:GetTall() > base:GetTall()) then
				base:SetTall(value:GetTall())
			end

			value:SetPos(x, 0)

			-- Wrap the label.
			if (value:GetClassName() == "Label") then
				local label, valueText, font = value, value:GetText(), font or value:GetFont()

				label:SetText("")
				label:SizeToContents()

				local exploded, start, ending, color = string.Explode(" ", valueText), 1, 1, value:GetTextColor()

				while ending <= #exploded do
					local text = table.concat(exploded, " ", start, ending)

					if (font) then label:SetFont(font) end

					label:SetText(text)
					label:SizeToContents()

					-- Too much text, let's cut it off.
					if (x +label:GetWide() >= base:GetWide() -4) then
						local previous = ending -1

						-- This is when it's in the beginning of the text.
						if (previous < start) then
							base = b(parent, noWrap, font)

							-- Add the base panel to the list so it'll get a size
							parent:InvalidateLayout(true)
							base:InvalidateLayout(true)

							x = 4

							label:SetParent(base)
							label:SetPos(x, 0)
							label:SetText(text .. " ")
							label:SizeToContents()

							x = x +label:GetWide()

							local attributes = label:GetTable()

							-- Create the next label.
							label = atlaschat.GenericLabel()

							for k, v in pairs(attributes) do
								label[k] = v
							end

							label:SetParent(base)
							label:SetPos(x, 0)
							label:SetText("")
							label:SetFont(font)
							label:SetColor(color)

							if (font) then label:SetFont(font) end

							label:SizeToContents()

							if (label:GetTall() > base:GetTall()) then
								base:SetTall(label:GetTall())
							end

							start, ending = ending +1, start
						else
							label:SetText(table.concat(exploded, " ", start, previous))
							label:SizeToContents()

							x = 4

							base = b(parent, noWrap, font)

							-- Add the base panel to the list so it'll get a size
							parent:InvalidateLayout(true)
							base:InvalidateLayout(true)

							local attributes = label:GetTable()

							-- Create the next label.
							label = atlaschat.GenericLabel()

							for k, v in pairs(attributes) do
								label[k] = v
							end

							label:SetParent(base)
							label:SetPos(x, 0)
							label:SetText("")
							label:SetFont(font)
							label:SetColor(color)

							if (font) then label:SetFont(font) end

							label:SizeToContents()

							if (label:GetTall() > base:GetTall()) then
								base:SetTall(label:GetTall())
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

								x = x +label:GetWide()
							else
								label:Remove()
							end
						end
					end
				end
			else
				x = x +value:GetWide() +1
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

hook.Add("Think", "atlaschat.TextSelection", function()
	local panel = atlaschat.theme.GetValue("panel")

	if (input.IsKeyDown(KEY_ESCAPE) and ValidPanel(panel) and panel:IsVisible()) then
		atlaschat.theme.Call("OnToggle", false)

		hook.Run("FinishChat")

		timer.Simple(FrameTime() *0.5, function() RunConsoleCommand("cancelselect") end)
	end

	if (input.IsMouseDown(MOUSE_LEFT)) then
		if (!lastMouseDown) then
			lastMouseDown = CurTime()

			copiedText = false
		end
	else
		if (lastMouseDown and CurTime() -lastMouseDown <= 0.16) then
			if (ValidPanel(panel)) then
				local list = panel:GetActiveList()
				local children = list:GetCanvas():GetChildren()

				currentPanel = nil
				previousPanel = nil

				for k, child in pairs(children) do
					if (ValidPanel(child)) then
						child.selection = {}
					end
				end
			end
		end

		lastMouseDown = nil
	end

	if (input.IsKeyDown(KEY_LCONTROL) and input.IsKeyDown(KEY_C) and ValidPanel(previousPanel) and ValidPanel(currentPanel)) then
		if (!copiedText) then
			local table, string = table, string
			local list = panel:GetActiveList()
			local children = list:GetCanvas():GetChildren()
			local clipboardText = ""

			for i = 1, #children do
				local base = children[i] --.child
				local children = base:GetChildren()
				local x, width = base.selection.x, base.selection.width

				if (x and width) then
					local sortedChildren = {}

					for k, child in pairs(children) do
						if (ValidPanel(child)) then
							table.insert(sortedChildren, child)
						end
					end

					table.sort(sortedChildren, function(a, b) return a.x < b.x end)

					-- Going backwards or upwards.
					if (x > width) then
						x = base.selection.width
						width = base.selection.x
					end

					for i = 1, #sortedChildren do
						local child = sortedChildren[i]
						local x2, wide = child:GetPos(), child:GetWide()

						if ((x >= x2 or x2 >= x) and (width <= x2 +wide or width >= x2 +wide)) then
							if (child:GetClassName() == "Label") then
								local text, start, font, totalWidth, final = child:GetText(), 1, string.lower(child:GetFont()), 0, ""
								local len = string.utf8len(text)

								while start <= len do
									local character = string.utf8sub(text, start, start)
									local characterWidth = atlaschat.fontCache[font][character]

									if (x2 +totalWidth >= x and x2 +totalWidth +characterWidth <= width) then
										final = final .. character
									end

									totalWidth, start = totalWidth +characterWidth, start +1
								end

								clipboardText = clipboardText .. final
							else
								if (x2 >= x and width >= x2 +wide) then
									if (child.OnCopiedText) then
										local text = child:OnCopiedText()

										clipboardText = clipboardText .. text
									end
								end
							end
						end
					end
				end
			end

			-- TextEntry hack thanks to Python1320
			local clipboard = vgui.Create("DTextEntry")
			clipboard:SetAllowNonAsciiCharacters(true)
			clipboard:SetText(clipboardText)
			clipboard:SelectAllText()
			clipboard:CutSelected()
			clipboard:Remove()

			local x, y = gui.MousePos()
			local time = CurTime() +4

			table.insert(copiedNotify, {origin = x, x = x, y = y, time = time})

			copiedText = true
		end
	end
end)

---------------------------------------------------------
--
---------------------------------------------------------

local color_shadow = Color(0, 0, 0, 220)

local function shadow(text, font)
	surface.SetFont(font .. ".shadow")
	surface.SetTextPos(0, 0)
	surface.SetTextColor(color_shadow)
	surface.DrawText(text)
end

function atlaschat.GenericLabel()
	local font = atlaschat.font:GetString()

	local label = vgui.Create("DLabel")
	label:SetFont(font)
	label:SetMouseInputEnabled(false)

	function label:Paint(w, h)
		local shadow, text, font, extraShadow, pcall = shadow, self:GetText(), self:GetFont(), atlaschat.extraShadow:GetBool(), pcall

		if (extraShadow) then
			draw.SimpleText(text, font, 1, 1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		end

		surface.DisableClipping(true)

			-- The font used might not have a shadow font to it and we don't want a bunch of lua errors.
			pcall(shadow, text, font)
		surface.DisableClipping(false)
	end

	return label
end

---------------------------------------------------------
-- Creates a label and a DCheckBox.
---------------------------------------------------------

function atlaschat.LabelAndCheckbox(parent, name)
	local base = parent:Add("Panel")
	base:SetTall(15)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)

	local checkbox = base:Add("DCheckBox")
	checkbox:Dock(LEFT)

	local label = base:Add("DLabel")
	label:SetText(name)
	label:SizeToContents()
	label:Dock(LEFT)
	label:DockMargin(6, 0, 8, 0)
	label:SetSkin("atlaschat")

	return checkbox
end

---------------------------------------------------------
-- Creates a label and a Slider.
---------------------------------------------------------

function atlaschat.LabelAndNumSlider(parent, name)
	local base = parent:Add("Panel")
	base:SetTall(20)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)

	local label = base:Add("DLabel")
	label:SetText(name)
	label:SizeToContents()
	label:Dock(LEFT)
	label:SetSkin("atlaschat")

	local slider = base:Add("Slider")
	slider:Dock(FILL)
	slider:SetDecimals(0)

	return slider
end

---------------------------------------------------------
-- Creates a label and a DComboBox.
---------------------------------------------------------

function atlaschat.LabelAndOption(parent, name)
	local base = vgui.Create("Panel")
	base:SetParent(parent)
	base:SetTall(16)
	base:Dock(TOP)
	base:DockMargin(0, 0, 0, 10)

	local label = base:Add("DLabel")
	label:SetText(name)
	label:SizeToContents()
	label:Dock(LEFT)
	label:DockMargin(0, 0, 8, 0)
	label:SetSkin("atlaschat")

	local comboBox = base:Add("DComboBox")
	comboBox:Dock(FILL)

	return comboBox
end

---------------------------------------------------------
-- Creating a private chat.
---------------------------------------------------------

net.Receive("atlaschat.nwpm", function(bits)
	local key = net.ReadUInt(8)
	local panel = atlaschat.theme.GetValue("panel").chatrooms

	local chatroom = panel:AddChatroom(nil, key, true)
	chatroom:AddPlayer(LocalPlayer())
end)

---------------------------------------------------------
-- Receiving a text message in a private chat.
---------------------------------------------------------

net.Receive("atlaschat.rxpm", function(bits)
	local key = net.ReadUInt(8)
	local text = net.ReadString()
	local player = net.ReadEntity()
	local panel = atlaschat.theme.GetValue("panel").chatrooms

	-- Add it to the "GLOBAL" chat.
	if (player != LocalPlayer()) then
		atlaschat.theme.Call("ParseText", nil, color_red, "(PM) ", player, color_white, ": ", text)
	end

	-- Add it to the private chat.
	atlaschat.theme.Call("ParseText", panel:GetListByKey(key), player, color_white, ": ", text)
end)

---------------------------------------------------------
-- Joining a private chat.
---------------------------------------------------------

net.Receive("atlaschat.gtplpm", function(bits)
	local key = net.ReadUInt(8)
	local numPlayers = net.ReadUInt(8)
	local panel = atlaschat.theme.GetValue("panel").chatrooms
	local chatRoom = panel:GetChatroom(key)

	if (!ValidPanel(chatRoom)) then
		chatRoom = panel:AddChatroom(nil, key, true)
	end

	for i = 1, numPlayers do
		local player = net.ReadEntity()

		if (IsValid(player)) then
			chatRoom:AddPlayer(player)
		end
	end

	local creator = net.ReadEntity()

	if (IsValid(creator)) then
		chatRoom:AddPlayer(creator, true)
	end
end)

---------------------------------------------------------
-- Kicking a player a private chat.
---------------------------------------------------------

net.Receive("atlaschat.nkickpm", function(bits)
	local key = net.ReadUInt(8)
	local target = net.ReadEntity()
	local noLocal = util.tobool(net.ReadBit())
	local panel = atlaschat.theme.GetValue("panel").chatrooms:GetChatroom(key)

	if (ValidPanel(panel)) then
		panel:RemovePlayer(target, noLocal)
	end
end)

---------------------------------------------------------
-- Accepting an invite to a private chat.
---------------------------------------------------------

net.Receive("atlaschat.sinvpm", function(bits)
	local key = net.ReadUInt(8)
	local player = net.ReadEntity()

	local accept = atlaschat.GenericLabel()
	accept:SetText("-> ПРИСОЕДЕНИТСЯ <-")
	accept:SetColor(color_limegreen)
	accept:SetMouseInputEnabled(true)

	accept.cursor = true

	function accept:OnCursorEntered()
		self:SetCursor("hand")
	end

	function accept:OnCursorExited()
		self:SetCursor("arrow")
	end

	function accept:OnMousePressed()
		net.Start("atlaschat.jnpm")
			net.WriteUInt(key, 8)
		net.SendToServer()

		self:SetText("ACCEPTED")
		self:SetColor(color_red)
		self:SetMouseInputEnabled(false)
	end

	chat.AddText(color_limegreen, player:Nick(), color_white, " пригласил вас в приватный чат. Нажмите ", accept, " чтобы зайти чтобы к нему!")
end)

---------------------------------------------------------
-- Atlas chat messages.
---------------------------------------------------------

net.Receive("atlaschat.msg", function(bits)
	local text = net.ReadString()

	chat.AddText(color_red, "[atlashchat] ", color_white, text)
end)

function atlaschat.Notify(text)
	chat.AddText(color_red, "[atlashchat] ", color_white, text)
end

---------------------------------------------------------
-- Clears your configuration.
---------------------------------------------------------

net.Receive("atlaschat.clrcfg", function(bits)
	file.Delete("atlaschat_config.cfg", "DATA")

	atlaschat.config.ResetValues()

	local config = atlaschat.theme.GetValue("config")

	if (ValidPanel(config)) then
		config:Remove()
	end
end)

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

net.Receive("atlaschat.crtrnkgt", function(bits)
	local userGroup = net.ReadString()
	local tag = net.ReadString()
	local icon = net.ReadString()
	local special = net.ReadUInt(8)

	if (special == 1) then
		atlaschat.ranks[userGroup] = nil
	else
		atlaschat.ranks[userGroup] = {tag = tag, icon = icon}
	end

	if (LocalPlayer():IsSuperAdmin()) then
		local rankMenu = atlaschat.theme.GetValue("rankMenu")

		if (ValidPanel(rankMenu) and rankMenu:IsVisible()) then
			if (special == 2) then
				rankMenu:UpdateLine(userGroup, icon, tag)
			else
				rankMenu:Populate()
			end
		end
	end
end)

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

net.Receive("atlaschat.rstcs", function(bits)
	local expression = net.ReadString()
	local len = net.ReadUInt(8)

	atlaschat.restrictions[expression] = atlaschat.restrictions[expression] or {}

	local usergroup

	for i = 1, len do
		usergroup = net.ReadString()

		atlaschat.restrictions[expression][usergroup] = true
	end

	local remove = util.tobool(net.ReadBit())

	if (remove and atlaschat.restrictions[expression]) then
		atlaschat.restrictions[expression][usergroup] = nil
	end

	local restrictionPanel = atlaschat.theme.GetValue("restrictionPanel")

	if (ValidPanel(restrictionPanel)) then
		restrictionPanel:RebuildList(expression)
	end
end)

---------------------------------------------------------
-- The chat message.
---------------------------------------------------------

net.Receive("atlaschat.chatText", function(bits)
	local text = net.ReadString()
	local player = net.ReadEntity()
	local team = util.tobool(net.ReadBit())
	local dead = IsValid(player) and !player:Alive() or false

	hook.Run("OnPlayerChat", player, text, team, dead)
end)

----------------------------------------------------------------------	
-- Purpose:
--		Returns true/false if the player is/isn't typing.
----------------------------------------------------------------------

function PLAYER_META:IsTyping()
	return self:GetNetworkedBool("atlaschat.istyping")
end

-- vk.com/urbanichka