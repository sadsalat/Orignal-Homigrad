
surface.CreateFont("HomigradFont",{
	font = "Roboto",
	size = 18,
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontBig",{
	font = "Roboto",
	size = 25,
	weight = 1100,
	outline = false
})


surface.CreateFont("HomigradFontLarge",{
	font = "Roboto",
	size = ScreenScale(30),
	weight = 1100,
	outline = false
})

surface.CreateFont("HomigradFontSmall",{
	font = "Roboto",
	size = ScreenScale(10),
	weight = 1100,
	outline = false
})

local red,green = Color(255,0,0),Color(0,255,0)
local specColor = Color(155,155,155)
local whiteAdd = Color(255,255,255,5)
local unmutedicon = Material( "icon32/unmuted.png", "noclamp smooth" )
local mutedicon = Material( "icon32/muted.png", "noclamp smooth" )

local function ToggleScoreboard(toggle)
	if toggle then
		gui.EnableScreenClicker(true)

		showRoundInfo = CurTime() + 10

		local scrw,scrh = ScrW(),ScrH()

		HomigradScoreboard = vgui.Create("DFrame")
		HomigradScoreboard:SetTitle("")
		HomigradScoreboard:SetSize(scrw*.7,scrh*.9)
		HomigradScoreboard:Center()
		HomigradScoreboard:ShowCloseButton(false)

		HomigradScoreboard.Paint = function(self,w,h)
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,w,h)

			draw.SimpleText("Статус","HomigradFont",100,h * .005,color_white,TEXT_ALIGN_CENTER)
			draw.SimpleText("Имя","HomigradFont",w / 2,h * .005,color_white,TEXT_ALIGN_CENTER)
			draw.SimpleText("Пинг","HomigradFont",w - 200,h * .005,color_white,TEXT_ALIGN_CENTER)
			draw.SimpleText("Количество игроков: " .. table.Count(player.GetAll()) .. " из " .. game.MaxPlayers() .. " возможных","HomigradFont",15,h - 15,color_green,TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM)
			draw.SimpleText("Server Tick: " .. math.Round(1 / engine.ServerFrameTime()),"HomigradFont",w - 15,h - 15,color_green,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
		end

		local tabl = player.GetAll()
		table.sort(tabl,function(a,b) return a:Team() > b:Team() end)

		local ypos = 25
		for i,ply in pairs(tabl) do
			local playerPanel = vgui.Create("DButton",HomigradScoreboard)
			playerPanel:SetText("")
			playerPanel:SetPos(0,ypos)
			playerPanel:SetSize(HomigradScoreboard:GetWide(),30)
			playerPanel.DoClick = function()
				HomigradScoreboard.playerMenu = vgui.Create("DMenu")
				HomigradScoreboard.playerMenu:SetPos(input.GetCursorPos())
				HomigradScoreboard.playerMenu:AddOption("Скопировать SteamID", function()
					SetClipboardText(ply:SteamID())
					LocalPlayer():ChatPrint("SteamID " .. ply:Name() .. " скопирован! (" .. ply:SteamID() .. ")")
				end)
				HomigradScoreboard.playerMenu:AddOption("Открыть профиль", function()
					ply:ShowProfile()
				end)
			end

			local name1 = ply:Name()
			local alive = ply:Alive() and "Живой" or "Мертвый"
			local alivecol = ply:Alive() and green or red

			if ply:Alive() then
				alive = "Живой"
				alivecol = Color(55,205,55)
			else
				alive = "Мертв"
				alivecol = Color(205,55,55)
			end

			playerPanel.Paint = function(self,w,h)
				surface.SetDrawColor(playerPanel:IsHovered() and 122 or 0,playerPanel:IsHovered() and 122 or 0,playerPanel:IsHovered() and 122 or 0,100)
				surface.DrawRect(0,0,w,h)

				if ply == LocalPlayer() then
					draw.RoundedBox(0,0,0,w,h,whiteAdd)
				end

				draw.SimpleText(alive,"HomigradFont",100,h / 4,alivecol,TEXT_ALIGN_CENTER)
				draw.SimpleText(name1,"HomigradFont",w / 2,h / 4,color_white,TEXT_ALIGN_CENTER)
				draw.SimpleText(ply:Ping(),"HomigradFont",w - 200,h / 4,color_white,TEXT_ALIGN_CENTER)

			end

			if ply ~= LocalPlayer() then
				local button = vgui.Create("DButton",playerPanel)
				button:SetSize(16,16)
				button:SetText("")
				local h = playerPanel:GetTall() / 2 - 16 / 2
				button:SetPos(playerPanel:GetWide() - playerPanel:GetTall() / 2 - 16 / 2,h)

				function button:Paint(w,h)
					surface.SetMaterial(ply:IsMuted() and mutedicon or unmutedicon)
					surface.SetDrawColor(255,255,255,255)
					surface.DrawTexturedRect(0,0,w,h)
					draw.SimpleText("E","HomigradFont",w / 2,h / 2,ply:IsMuted() and red or green,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end

				function button:DoClick()
					ply:SetMuted(not ply:IsMuted())
				end

			end

			ypos = ypos + playerPanel:GetTall() + 1
		end
	else
		gui.EnableScreenClicker(false)

		if IsValid(HomigradScoreboard) then
			HomigradScoreboard:Close()
			if IsValid(HomigradScoreboard.playerMenu) then
				HomigradScoreboard.playerMenu:Remove()
			end
		end
	end
end

hook.Add("ScoreboardShow","HomigradOpenScoreboard",function()
	ToggleScoreboard(true)

	return false
end)

hook.Add("ScoreboardHide","HomigradHideScoreboard",function()
	ToggleScoreboard(false)
end)