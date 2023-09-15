local black = Color(0,0,0)

net.Receive("radio_use",function(len,ply)
	local radio = net.ReadEntity()
	local link = net.ReadString()
	local play = net.ReadBool()
	
	if IsValid(radio) then
		radpanel = vgui.Create("DFrame")
		radpanel:SetAlpha(255)
		radpanel:SetSize(500, 400)
		radpanel:Center()
		radpanel:SetDraggable(false)
		radpanel:MakePopup()
		radpanel:SetTitle("")

		function radpanel:OnRemove()
			net.Start("radio_use")
			net.WriteEntity(radio)
			net.SendToServer()
		end

		radpanel.Paint = function(self, w, h)
			if not IsValid(radio) or not LocalPlayer():Alive() then radpanel:Remove() return end
			draw.RoundedBox(0,0,0,w,h,black)
			surface.SetDrawColor(255,255,255,128)
			surface.DrawOutlinedRect(1,1,w - 2,h - 2)
		end

		local TextEntry = vgui.Create("DTextEntry",radpanel)
		TextEntry:Dock(TOP)
		TextEntry:SetPlaceholderText("Введите ссылку.")
		TextEntry:SetUpdateOnType(true)

		function TextEntry:OnChange()
			link = TextEntry:GetValue()
		end

		local button2 = vgui.Create("DButton",radpanel)

		button2:Dock(RIGHT)
		button2:Dock(BOTTOM)
		button2:SetText("Stop")

		button2.DoClick = function()
			play = false
			net.Start("radio_set")
			net.WriteEntity(radio)
			net.WriteString(link or "")
			net.WriteBool(play)
			net.SendToServer()
		end

		button2.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w,h,Color(255,0,0))
		end

		local button = vgui.Create("DButton",radpanel)

		button:Dock(LEFT)
		button:Dock(BOTTOM)
		button:SetText("Play!")

		button.DoClick = function()
			play = true
			net.Start("radio_set")
			net.WriteEntity(radio)
			net.WriteString(link or "")
			net.WriteBool(play)
			net.SendToServer()
		end

		button.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w,h,Color(0,255,0))
		end
	end
end)

g_station = g_station or {}
net.Receive("play_snd",function(len)
	local link = net.ReadString()
	local play = net.ReadBool()
	local radio = net.ReadEntity()

	if play then
		if not g_station[radio:EntIndex()] or not IsValid(g_station[radio:EntIndex()][1]) then
			if g_station[radio:EntIndex()] and not IsValid(g_station[radio:EntIndex()][1]) then
				link = link or g_station[radio:EntIndex()][2]
			end
			sound.PlayURL(link,"3d",function(station,err,errName)
				if IsValid(station) then
					station:Set3DEnabled(true)
					if not IsValid(radio) then station:Stop() end
					station:SetPos(radio:GetPos())


					station:Play()

					g_station[radio:EntIndex()] = {station,link,radio}
				else
					print("Error!", err or "", errName or "")
				end
			end)

		elseif g_station[radio:EntIndex()] and IsValid(g_station[radio:EntIndex()][1]) then
			g_station[radio:EntIndex()][1]:Stop()
		end
	else
		if g_station[radio:EntIndex()] and IsValid(g_station[radio:EntIndex()][1]) then
			g_station[radio:EntIndex()][1]:Stop()
		end
	end
	radio:CallOnRemove("deleteradio",function()
		if IsValid(g_station[radio:EntIndex()][1]) then
			g_station[radio:EntIndex()][1]:Stop()
			g_station[radio:EntIndex()] = nil
		end
	end)
	--PrintTable(g_station)
end)
local stationThink, CurTime = CurTime(), CurTime
hook.Add("Think","station_think",function()
	if stationThink < CurTime() then
		stationThink = stationThink + 0.25
		for i,tabl in pairs(g_station) do
			if IsValid(g_station[i][1]) then
				g_station[i][1]:SetPos(IsValid(g_station[i][3]) and g_station[i][3]:GetPos() or Vector(0,0,0))
			end
		end
	end
end)