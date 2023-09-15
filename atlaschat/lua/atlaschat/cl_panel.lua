local panel = {}

local plusImage = Material("atlaschat/plus.png")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.Dragging = {0, 0}
	
	self.m_iMinWidth = 300
	self.m_iMinHeight = 300
	
	self.hostName = self:Add("DLabel")
	self.hostName:SetFont("atlaschat.theme.default.title")
	self.hostName:SetColor(color_white)
	
	self.bottom = self:Add("Panel")
	self.bottom:SetTall(20)
	self.bottom:Dock(BOTTOM)
	self.bottom:DockMargin(0, 8, 0, 0)
	
	self.iconHolder = self.bottom:Add("Panel")
	self.iconHolder:Dock(RIGHT)
	self.iconHolder:DockMargin(4, 0, 0, 0)
	
	function self.iconHolder:PerformLayout()
		local x, children = 2, self:GetChildren()
		
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				child:SetPos(x, self:GetTall() /2 -child:GetTall() /2)
				
				x = x +child:GetWide() +6
			end
		end
	end
	
	function self.iconHolder:Paint(w, h)
		atlaschat.theme.Call("PaintIconHolder", self, w, h)
		
		return true
	end
	
	function self.iconHolder:Resize()
		local width, children = 0, self:GetChildren()
	
		for k, child in pairs(children) do
			if (ValidPanel(child)) then
				width = width +child:GetWide() +5
			end
		end

		self:SetWide(width)
	end
	
	self.button = self:Add("atlaschat.chat.button")
	self.button:SetSize(16, 16)
	self.button:SetZPos(100)
	
	function self.button.DoClick()
		net.Start("atlaschat.stpm")
		net.SendToServer()
	end
	
	function self.button:Paint(w, h)
		draw.Material(2, 2, 14, 14, self.Hovered and color_red or color_white, plusImage)
		
		return true
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:AddIcon(image, callback, tooltip)
	local icon = self.iconHolder:Add("DImageButton")
	icon:SetSize(16, 16)
	icon:SetToolTip(tooltip)
	icon:SetImage(image)
	
	icon.callback = callback
	
	function icon:DoClick()
		self.callback()
	end
	
	self.iconHolder:Resize()
	
	return icon
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:RemoveIcon(icon)
	icon:Remove()
	
	timer.Simple(0, function() self.iconHolder:InvalidateLayout(true) self.iconHolder:Resize() end)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetActiveList()
	return self.activeList
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:ChangeList(key, list)
	if (ValidPanel(self.activeList)) then
		self.activeList:SetVisible(false)
	end
	
	self.activeList = list
	self.activeList:SetVisible(true)
	
	self.entry.key = key
	
	if (key) then
		if (!ValidPanel(self.userList)) then
			self.userList = self:AddIcon("atlaschat/users.png", function() atlaschat.theme.Call("ToggleUserList") end, "Chat Userlist")
		end
		
		local userListBase = atlaschat.theme.GetValue("userListBase")
		
		if (IsValid(userListBase)) then
			local chatroom = atlaschat.theme.GetValue("current_chatroom")
			
			userListBase:Rebuild(chatroom.players, key)
		end
	else
		if (ValidPanel(self.userList)) then
			self:RemoveIcon(self.userList)
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnMousePressed()
	if (gui.MouseX() > (self.x +self:GetWide() -20) and gui.MouseY() > (self.y +self:GetTall() -20)) then			
		self.Sizing = {gui.MouseX() -self:GetWide(), gui.MouseY() -self:GetTall()}
		self:MouseCapture(true)
		
		return
	end
		
	if (gui.MouseY() < self.y +20) then
		self.Dragging[1] = gui.MouseX() -self.x
		self.Dragging[2] = gui.MouseY() -self.y
		
		self:MouseCapture(true)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnMouseReleased()
	self.Dragging = {0, 0}
	self.Sizing = nil
	
	self:MouseCapture(false)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Think()
	local mousex, mousey = gui.MousePos()
	
	if (self.Dragging[1] != 0) then
		local x = mousex -self.Dragging[1]
		local y = mousey -self.Dragging[2]
		
		x = math.Clamp(x, 0, ScrW() -self:GetWide())
		y = math.Clamp(y, 0, ScrH() -self:GetTall())
		
		self:SetPos(x, y)

		local userListBase = atlaschat.theme.GetValue("userListBase")
		
		if (ValidPanel(userListBase) and userListBase:IsVisible()) then
			local width, height = self:GetSize()

			userListBase:SetPos(x +width +4, y +height -userListBase:GetTall())
		end
		
		atlaschat.chat_x:SetInt(x)
		atlaschat.chat_y:SetInt(y)
	end
	
	if (self.Sizing) then
		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()
		
		if (x < self.m_iMinWidth) then x = self.m_iMinWidth elseif (x > ScrW() -px) then x = ScrW() -px end
		if (y < self.m_iMinHeight) then y = self.m_iMinHeight elseif (y > ScrH() -py) then y = ScrH() -py end
		
		self:SetSize(x, y)
		self:SetCursor("sizenwse")
		
		atlaschat.chat_w:SetInt(x)
		atlaschat.chat_h:SetInt(y)
		
		local x, _y = self:GetPos()
		
		local userListBase = atlaschat.theme.GetValue("userListBase")
		
		if (ValidPanel(userListBase) and userListBase:IsVisible()) then
			local width, height = self:GetSize()

			userListBase:SetPos(x +width +4, _y +height -userListBase:GetTall())
		end
		
		return
	end
	
	if (self.Hovered and mousex > (self.x +self:GetWide() -20) and mousey > (self.y +self:GetTall() -20)) then	
		self:SetCursor("sizenwse")
		
		return
	end
	
	if (self.Hovered and gui.MouseY() < self.y +20) then
		self:SetCursor("sizeall")
		
		return
	end
	
	self:SetCursor("arrow")
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PerformLayout()
	local w, h = self:GetSize()

	self.hostName:SetPos(8, 8)
	self.hostName:SetWide(w /2 -8)
	self.hostName:SizeToContentsY()
	
	self.button:SetPos(w -24, 8)
	
	self.chatrooms:SetMaxWidth(w /2 -40)
	self.chatrooms:InvalidateLayout(true)
	
	self.chatrooms:SetPos(w -(self.chatrooms:GetWide() +32), 8)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintPanel", w, h)
end

vgui.Register("atlaschat.chat", panel, "EditablePanel")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintButton", self, w, h)
	
	return true
end

vgui.Register("atlaschat.chat.button", panel, "DButton")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

AccessorFunc(panel, "m_bScroll", 	"ShouldScroll", FORCE_BOOL)
AccessorFunc(panel, "m_bBottomUp", 	"BottomUp", 	FORCE_BOOL)
AccessorFunc(panel, "deleteHistory", "DeleteHistory", 	FORCE_BOOL)

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self.history = {}
	
	self:SetShouldScroll(true)
	
	function self.VBar:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbar", self, w, h)
	end
	
	function self.VBar.btnGrip:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbarGrip", self, w, h)
	end
	
	function self.VBar.btnUp:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbarUpButton", self, w, h)
	end
	
	function self.VBar.btnDown:Paint(w, h)
		atlaschat.theme.Call("PaintScrollbarDownButton", self, w, h)
	end
	
	local parent = self
	
	function self.VBar:SetScroll(scroll)
		if ( !self.Enabled ) then self.Scroll = 0 return end
		
		if (scroll < self.CanvasSize) then
			if (parent.m_bScroll) then
				parent:SetShouldScroll(false)
			end
			
			self.__scroll = scroll
		else
			if (scroll >= self.CanvasSize) then
				if (!parent.m_bScroll) then
					parent:SetShouldScroll(true)
					
					self.__scroll = nil
				end
			end
		end
		
		if (self.__scroll) then
			self.Scroll = math.Clamp(self.__scroll, 0, self.CanvasSize)
		else
			self.Scroll = math.Clamp(scroll, 0, self.CanvasSize)
		end
		
		self:InvalidateLayout()
		
		-- If our parent has a OnVScroll function use that, if
		-- not then invalidate layout (which can be pretty slow)
		local func = self:GetParent().OnVScroll
		
		if (func) then
			func(self:GetParent(), self:GetOffset())
		else
			self:GetParent():InvalidateLayout()
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:ScrollToBottom()
	self.VBar:SetScroll(self.VBar.CanvasSize)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetScrollbarWidth(width)
	self.VBar:SetWide(width)
	self.VBar.btnGrip:SetWide(width)
	self.VBar.btnUp:SetWide(width)
	self.VBar.btnDown:SetWide(width)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:AddItem(panel)
	panel:SetParent(self:GetCanvas())
	
	local zPosition = table.insert(self.history, panel)
	
	if (self.deleteHistory) then
		local current, maxHistory = #self.history, atlaschat.maxHistory:GetInt()
		
		if (current > maxHistory) then
			for i = 1, math.max(0, current -maxHistory) do
				local panel = self.history[i]
				
				if (IsValid(panel)) then
					panel:Remove()
				end
				
				table.remove(self.history, i)
			end
			
			self:GetCanvas():InvalidateLayout(true)
			self:InvalidateLayout(true)
			self:OnMouseWheeled(0)
		end
	end
	
	if (!self.m_bBottomUp) then
		panel:SetZPos(zPosition)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Rebuild()
	self.pnlCanvas:SizeToChildren(false, true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:PerformLayout()
	if (self.m_bBottomUp) then
		local w, h = self:GetSize()
		
		self:Rebuild()
		
		self.VBar:SetUp(h, self.pnlCanvas:GetTall())
		
		if (self.VBar.Enabled) then
			w = w - self.VBar:GetWide()
			
			self.pnlCanvas:SetPos(0, self.VBar:GetOffset())
		else
			self.pnlCanvas:SetPos(0, h -self.pnlCanvas:GetTall())
		end
		
		self.pnlCanvas:SetWide(w)
		
		self:Rebuild()
	else
		DScrollPanel.PerformLayout(self)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	local panel = self:GetParent():GetParent()
	
	atlaschat.theme.Call("PaintList", panel, w, h, self)

	local panel = atlaschat.theme.GetValue("panel")
	
	if (ValidPanel(panel)) then
		local x, y = self:LocalToScreen(0, 0)
		local children = self:GetCanvas():GetChildren()
		
		render.SetScissorRect(x, y, x +w, y +h, true)
			for k, child in pairs(children) do
				if (ValidPanel(child)) then
					child:SetPaintedManually(false)
						child:PaintManual()
					child:SetPaintedManually(true)
				end
			end
		render.SetScissorRect(0, 0, 0, 0, false)
	end
	
	return true
end

vgui.Register("atlaschat.chat.list", panel, "DScrollPanel")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

AccessorFunc(panel, "m_iKey", "Key")

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetHistoryEnabled(true)
	self:SetAllowNonAsciiCharacters(true)
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnKeyCodeTyped(code)
	local panel = self:GetParent():GetParent()
	
	if (code == KEY_TAB) then
		local value = self:GetText()
		local newText = hook.Run("OnChatTab", value:PatternSafe())

		self:SetText(newText)

		-- Beacuse it loses focus when tabbing.
		timer.Simple(FrameTime() *4, function()
			self:RequestFocus()
			self:SetCaretPos(string.len(self:GetValue()))
		end)
	elseif (code == KEY_ENTER) then
		local value = self:GetText()
		
		-- The "&" character has no size. So let's fix that.
		value = string.gsub(value, "&", "＆")
		
		if (value != "") then
			if (self.key) then
				net.Start("atlaschat.txpm")
					net.WriteUInt(self.key, 8)
					net.WriteString(value)
				net.SendToServer()
			else
				net.Start("atlaschat.chat")
					net.WriteString(value)
					net.WriteBit(panel.team)
				net.SendToServer()
				
				--RunConsoleCommand(panel.team and "say_team" or "say", value)
			end
		end
		
		self:FocusNext()
		self:AddHistory(value)
		
		self.HistoryPos = 0
		
		atlaschat.theme.Call("OnToggle", false)
		
		hook.Run("FinishChat")
	else
		if (self.m_bHistory or IsValid(self.Menu)) then
			if (code == KEY_UP) then
				self.HistoryPos = self.HistoryPos -1
				
				self:UpdateFromHistory()
			end
			
			if (code == KEY_DOWN) then	
				self.HistoryPos = self.HistoryPos +1
				
				self:UpdateFromHistory()
			end
		end
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetText(text, limit)
	DTextEntry.SetText(self, text)
	
	if (!limit) then
		self:OnChange()
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:OnChange()
	local value = self:GetText()
	local length = string.len(value)
	
	if (length >= 127) then
		surface.PlaySound("common/talk.wav")
		
		value = string.sub(value, 0, 127)
		
		local position = self:GetCaretPos()
		
		self:SetText(value, true)
		self:SetCaretPos(position)
	else
		hook.Run("ChatTextChanged", value)
	end
end
	
---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintTextEntry", w, h)
end

vgui.Register("atlaschat.chat.entry", panel, "DTextEntry")

------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------

local panel = {}

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Init()
	self:SetPrefix("SAY")
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:SetPrefix(prefix)
	self.prefix = prefix
	
	local w = util.GetTextSize("atlaschat.theme.prefix", prefix)
	
	self:SetWide(w +10)
	self:InvalidateLayout()
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:GetPrefix()
	return self.prefix
end

---------------------------------------------------------
--
---------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintPrefix", w, h)
end

vgui.Register("atlaschat.chat.prefix", panel, "Panel")

-- vk.com/urbanichka