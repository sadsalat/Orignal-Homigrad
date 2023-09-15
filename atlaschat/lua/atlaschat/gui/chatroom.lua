local panel = {}

AccessorFunc(panel, "spacing", "Spacing")
AccessorFunc(panel, "maxWidth", "MaxWidth")

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self.canvas = self:Add("Panel")

	self:SetSpacing(4)
	self:SetMaxWidth(100)

	self.scrollbar = self:Add("atlaschat.scrollbar")
	self.scrollbar:SetVertical(false)
	self.scrollbar:SetZPos(10)
	self.scrollbar:AddCanvas(self.canvas)
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:GetChatroom(key)
	local children = self.canvas:GetChildren()

	for k, child in pairs(children) do
		if (ValidPanel(child)) then
			local info = child:GetKey()

			if (info == key) then
				return child
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:GetListByKey(key)
	local children = self.canvas:GetChildren()

	for k, child in pairs(children) do
		if (ValidPanel(child)) then
			local info = child:GetKey()

			if (info == key) then
				return child:GetList()
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:AddChatroom(name, key, newList)
	local panel = self.canvas:Add("atlaschat.chatroom")
	panel:SetName(name)
	panel:SetKey(key)

	if (newList) then
		local chatPanel = atlaschat.theme.GetValue("panel")

		local list = chatPanel:Add("atlaschat.chat.list")
		list:Dock(FILL)
		list:GetCanvas():DockPadding(0, 2, 0, 2)
		list:SetVisible(false)
		list:SetBottomUp(true)
		list:SetDeleteHistory(true)

		panel:SetList(list)
	end

	return panel
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:PerformLayout()
	local w, h = self:GetSize()
	local x, y = 0, 0
	local children = self.canvas:GetChildren()

	for k, child in pairs(children) do
		if (ValidPanel(child)) then
			child:SetPos(x, y)
			child:SetTall(h -y)

			x = x +child:GetWide() +self.spacing
		end
	end

	x = x -self.spacing

	self.canvas:SetSize(x, h)

	self:SetWide(math.min(self.maxWidth, x))

	if (ValidPanel(self.scrollbar)) then
		self.scrollbar:SetPos(0, h -7)
		self.scrollbar:SetSize(w, 7)
		self.scrollbar:InvalidateLayout(true)
	end
end

vgui.Register("atlaschat.chatroom.container", panel, "Panel")

local panel = {}

AccessorFunc(panel, "key", "Key")
AccessorFunc(panel, "new", "New")
AccessorFunc(panel, "name", "Name")
AccessorFunc(panel, "list", "List")
AccessorFunc(panel, "maxWidth", "MaxWidth")

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self.blink = 0
	self.players = {}

	self:SetMaxWidth(200)

	self:SetCursor("hand")
	self:SetToolTip("Right-click to leave this chat room")
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:ThrowIntoBlackHole()
	local parent, list = self:GetParent(), self:GetList()
	local chatroom, userList = atlaschat.theme.GetValue("mainChat"), atlaschat.theme.GetValue("userListBase")

	chatroom:OnMousePressed(MOUSE_LEFT)

	if (ValidPanel(userList)) then
		userList:SetVisible(false)
	end

	list:Remove()
	self:Remove()

	timer.Simple(0.1, function() parent:InvalidateParent() parent:GetParent().scrollbar:OnScroll(1) end)
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:AddPlayer(player, creator)
	local exists = false

	for i = 1, #self.players do
		local info = self.players[i]

		if (info == player) then
			exists = true

			break
		end
	end

	if (!exists or creator) then
		if (!ValidPanel(self.label)) then
			self.label = self:Add("DLabel")
			self.label:SetFont("atlaschat.theme.list.name")
			self.label:SetColor(color_white)
			self.label:SetMouseInputEnabled(false)
		end

		if (creator) then
			self.players.creator = player
		else
			table.insert(self.players, player)

			local userListBase = atlaschat.theme.GetValue("userListBase")

			if (IsValid(userListBase)) then
				userListBase:Rebuild(self.players, self:GetKey())
			end
		end

		self:InvalidateLayout()
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:RemovePlayer(player, left)

	-- If "left" is true then it means you left the chatroom,
	-- if not then it means you were kicked from the chatroom.
	
	-- Did we get kicked?
	if (player == LocalPlayer()) then

		-- I WAS KICKED :((
		if (!left) then
			self:ThrowIntoBlackHole()

			chat.AddText(color_red, ":exclamation: You have been kicked from the chatroom!")
		end

	-- Some other player was kicked or left the chatroom
	else
		local nick, list = player:Nick(), self:GetList()

		if (left) then
			atlaschat.theme.Call("ParseText", list, ":information: " .. nick .. " has left the chatroom.")
		else
			atlaschat.theme.Call("ParseText", list, color_red, ":exclamation: " .. nick .. " was kicked from the chatroom!")
		end

		for i = 1, #self.players do
			local info = self.players[i]

			if (info == player) then
				table.remove(self.players, i)

				break
			end
		end

		local userListBase = atlaschat.theme.GetValue("userListBase")

		if (IsValid(userListBase)) then
			userListBase:Rebuild(self.players, self:GetKey())
		end

		self:InvalidateLayout()
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:PerformLayout()
	if (ValidPanel(self.label)) then
		local text = ""

		for i = 1, #self.players do
			local player = self.players[i]

			if (IsValid(player)) then
				local name = player:Nick()

				text = text .. name .. (i != #self.players and ", " or "")
			end
		end

		self.label:SetText(text)

		local width = util.GetTextSize("atlaschat.theme.list.name", text)

		width = width +28

		self:SetWide(math.min(self.maxWidth, width))

		local w = self:GetWide()

		self.label:SetPos(5, -1)
		self.label:SetWide(w -28)

		self:GetParent():InvalidateParent()
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:OnMousePressed(code)
	local key = self:GetKey()

	if (code == MOUSE_LEFT) then
		self:SetNew(false)

		local chatPanel = atlaschat.theme.GetValue("panel")
		local list = self:GetList()

		atlaschat.theme.Set("current_chatroom", self)

		chatPanel:ChangeList(key, list)

		if (self.name) then
			local userListBase = atlaschat.theme.GetValue("userListBase")

			if (ValidPanel(userListBase)) then
				userListBase:SetVisible(false)
			end
		end
	elseif (code == MOUSE_RIGHT and !self.name) then
		local menu = DermaMenu()
			local option = menu:AddOption("Leave chatroom", function()
				net.Start("atlaschat.lvpm")
					net.WriteUInt(key, 8)
				net.SendToServer()

				self:ThrowIntoBlackHole()
			end)

			option:SetImage("icon16/delete.png")
		menu:Open()
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:Paint(w, h)
	atlaschat.theme.Call("PaintChatroom", self, w, h)

	return true
end

vgui.Register("atlaschat.chatroom", panel, "Panel")

local panel = {}

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:Init()
	self.panels = {}

	self.grip = self:Add("atlaschat.scrollbar.grip")
	self.grip:SetPos(0, 0)
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:OnMousePressed()
	local x, y = self:ScreenToLocal(gui.MousePos())
	local vertical = self:IsVertical()

	if (vertical) then
		y = y -self.grip:GetTall() /2

		self.grip:SetPos(2, y)

		self.grip.depressed = true
		self.grip.hold_y = self.grip:GetTall() /2
			self.grip:OnCursorMoved(2, y)
		self.grip.depressed = false
	else
		x = x -self.grip:GetWide() /2

		self.grip:SetPos(x, 2)

		self.grip.depressed = true
		self.grip.hold_x = self.grip:GetWide() /2
			self.grip:OnCursorMoved(x, 2)
		self.grip.depressed = false
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:AddCanvas(...)
	local data = {...}

	for k, canvas in pairs(data) do
		local x, y = canvas:GetPos()

		canvas.origin_x, canvas.origin_y = x, y

		table.insert(self.panels, canvas)
	end

	self:InvalidateLayout()
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:SetVertical(bool)
	self.vertical = bool
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:IsVertical()
	return self.vertical
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:OnScroll(scroll)
	local vertical = self:IsVertical()

	if (vertical) then
		local _, y = self:GetPos()

		for k, panel in pairs(self.panels) do
			if (ValidPanel(panel)) then
				local parent = panel:GetParent()

				panel:SetPos(panel.x, panel.origin_y +(panel:GetTall() -(parent:GetTall() -panel.origin_y)) *scroll *-1)
			end
		end
	else
		local x = self:GetPos()

		for k, panel in pairs(self.panels) do
			if (ValidPanel(panel)) then
				local parent = panel:GetParent()

				panel:SetPos(panel.origin_x +(panel:GetWide() -(parent:GetWide() -panel.origin_x)) *scroll *-1, panel.y)
			end
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:PerformLayout()
	local w, h = self:GetSize()
	local vertical = self:IsVertical()

	if (vertical) then
		local tallest = 0
		local disable = false

		for k, panel in pairs(self.panels) do
			if (ValidPanel(panel)) then
				local height = panel:GetTall() +panel.origin_y

				if (height > tallest) then
					tallest = height
				end

				local _, y = panel:GetPos()
				local parent = panel:GetParent()

				y = y +panel.origin_y

				disable = math.abs(y) +height <= parent:GetTall()
			end
		end

		self.grip:SetSize(w -4, math.max(h -(math.abs(h -tallest)), 32))
		self.grip:SetVisible(!disable)
	else
		local widest = 0
		local disable = false

		for k, panel in pairs(self.panels) do
			if (ValidPanel(panel)) then
				local width = panel:GetWide() +panel.origin_x

				if (width > widest) then
					widest = width
				end

				local x = panel:GetPos()
				local parent = panel:GetParent()

				x = x +panel.origin_x

				disable = math.abs(x) +width <= parent:GetWide()
			end
		end

		self:SetMouseInputEnabled(!disable)

		self.grip:SetSize(math.max(w -(math.abs(w -widest)), 32), h)
		self.grip:SetVisible(!disable)
	end
end


vgui.Register("atlaschat.scrollbar", panel, "Panel")

--------------------------------------------------------------------------------------------------------------------------------------------

local panel = {}

AccessorFunc(panel, "scroll", "Scroll")

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:Init()
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:OnMousePressed()
	self.depressed = true
	self.hold_x, self.hold_y = self:ScreenToLocal(gui.MousePos())

	self:MouseCapture(true)
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:OnMouseReleased()
	self.depressed = false

	self:MouseCapture(false)
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:OnCursorMoved(x, y)
	if (self.depressed) then
		local parent = self:GetParent()
		local vertical = parent:IsVertical()

		if (vertical) then
			local mouseY = gui.MouseY()
			local _, y = parent:ScreenToLocal(0, mouseY)

			self:SetPos(self.x, math.Clamp(y -self.hold_y, 0, parent:GetTall() -self:GetTall()))

			local _, y = self:GetPos()

			parent:OnScroll(y /(parent:GetTall() -self:GetTall()))
		else
			local mouseX = gui.MouseX()
			local position = parent:ScreenToLocal(mouseX, 0)

			self:SetPos(math.Clamp(position -self.hold_x, 0, parent:GetWide() -self:GetWide()), self.y)

			local x = self:GetPos()

			parent:OnScroll(x /(parent:GetWide() -self:GetWide()))
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--
----------------------------------------------------------------------

function panel:Paint(w, h)
	local hovered = self.Hovered or self:GetParent().Hovered or self.depressed

	draw.RoundedBox(2, 0, 0, w, h, hovered and Color(224, 224, 224) or color_transparent)
end

vgui.Register("atlaschat.scrollbar.grip", panel, "Panel")

-- vk.com/urbanichka