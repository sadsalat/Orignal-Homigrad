surface.CreateFont("atlaschat.mysql", {font = "Open Sans", size = 18, weight = 400})

local panel = {}

local STATUS_NO_DATABASE = -1
local STATUS_CONNECTING = 1
local STATUS_CONNECTED = 0
local STATUS_UNCONNECTED = 2

----------------------------------------------------------------------	
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:SetTitle("MySQL Settings")
	
	self.statusPanel = vgui.Create("Panel")
	self.statusPanel:SetTall(48)
	self.statusPanel:Dock(TOP)
	
	self.statusPanel.status = ""
	self.statusPanel.color = color_white
	
	function self.statusPanel:Paint(w, h)
		local _, height = util.GetTextSize("atlaschat.mysql", self.status)
		
		draw.DrawText(self.status, "atlaschat.mysql", w /2, h /2 -height /2, self.color, TEXT_ALIGN_CENTER)
		
		draw.SimpleRect(0, h -1, w, 1, Color(50, 50, 50))
	end
	
	self.list:AddItem(self.statusPanel)
	
	self.database = vgui.Create("DTextEntry")
	
	self:AddItem("Database ( Default \"atlaschat\" )", self.database)
	
	self.address = vgui.Create("DTextEntry")
	
	self:AddItem("Host Address", self.address)

	self.port = vgui.Create("DTextEntry")
	
	self:AddItem("Host Port", self.port)
	
	self.username = vgui.Create("DTextEntry")
	
	self:AddItem("Username", self.username)
	
	self.password = vgui.Create("DTextEntry")
	
	self:AddItem("Password", self.password)
	
	self:AddButton("Save & Update", false, function()
		local address = self.address:GetValue()
		local port = tonumber(self.port:GetValue())
		local username = self.username:GetValue()
		local password = self.password:GetValue()
		local database = self.database:GetValue()
		
		net.Start("atlaschat.myin")
			net.WriteBit(false)
			net.WriteString(address)
			net.WriteUInt(port, 16)
			net.WriteString(username)
			net.WriteString(password)
			net.WriteString(database)
		net.SendToServer()
	end)
	
	net.Start("atlaschat.myin")
		net.WriteBit(true)
	net.SendToServer()
end

----------------------------------------------------------------------	
-- Purpose:
--		Updates the 'statusPanel'.
----------------------------------------------------------------------

function panel:SetData(status, message, address, port, username, database)
	self.statusPanel.color = color_white
	
	message = message or ""
	
	if (status == STATUS_NO_DATABASE) then
		self.statusPanel.status = "NO CONNECTION TO DATABASE"
		self.statusPanel.color = color_red
	elseif (status == STATUS_UNCONNECTED) then
		local info = "UNABLE TO CONNECT: " .. message
		
		-- Split up the message.
		local maxLength = 66
		local length = string.len(info)
		
		if (length > maxLength) then
			local exploded, current, final = string.Explode(" ", info), 1, ""
			
			for i = 1, #exploded do
				local text = table.concat(exploded, " ", current, i)
				
				if (string.len(text) > maxLength) then
					final = final .. table.concat(exploded, " ", current, i -1) .. "\n"
					
					current = i
				else
					if (i == #exploded) then
						final = final .. text
					end
				end
			end
			
			info = final
		end
		
		self.statusPanel.status = info
		self.statusPanel.color = color_red
	elseif (status == STATUS_CONNECTED) then
		self.statusPanel.status = "MYSQL CONNECTION ESTABLISHED"
		self.statusPanel.color = color_green
	elseif (status == STATUS_CONNECTING) then
		self.statusPanel.status = "CONNECTING TO DATABASE..."
		self.statusPanel.color = color_yellow
	end
	
	local _, height = util.GetTextSize("atlaschat.mysql", self.statusPanel.status)

	self.statusPanel:SetTall(height +32)
	
	local children = self.list:GetCanvas():GetChildren()
	local height = 32
	
	for k, child in pairs(children) do
		local tall = child:GetTall()
		
		height = height +tall
	end
	
	self:SetTall(height)
	
	self.database:SetText(database)
	self.address:SetText(address)
	self.port:SetText(port)
	self.username:SetText(username)
end

vgui.Register("atlaschat.mysql", panel, "atlaschat.config")

----------------------------------------------------------------------	
-- Purpose:
--		Receive information about mysql.
----------------------------------------------------------------------

net.Receive("atlaschat.myin", function(bits)
	local status = net.ReadInt(8)
	local message = net.ReadString()
	local address = net.ReadString()
	local port = net.ReadUInt(16)
	local username = net.ReadString()
	local database = net.ReadString()
	
	local panel = atlaschat.theme.GetValue("mysqlPanel")
	
	if (ValidPanel(panel)) then
		panel:SetData(status, message, address, port, username, database)
	end
end)

-- vk.com/urbanichka