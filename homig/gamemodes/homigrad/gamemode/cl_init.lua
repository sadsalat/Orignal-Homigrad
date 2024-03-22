include("shared.lua")
surface.CreateFont(
	"MyFont",
	{
		font = "Arial",
		size = 30,
		weight = 500
	}
)

surface.CreateFont(
	"PlajkaFont",
	{
		font = "Arial",
		size = 35,
		weight = 600
	}
)

surface.CreateFont(
	"BODYCAMFONT",
	{
		font = "Arial",
		size = 42,
		italic = true,
		weight = 1500
	}
)

local TIMER_PANEL = {
	Init = function(self)
		self.Body = self:Add("Panel")
		self.Body:Dock(TOP)
		self.Body:SetHeight(40)
		function self.Body:Paint(w, h)
			surface.SetDrawColor(150, 255, 150)
			draw.RoundedBox(16, -20, 0, w / 2, h, Color(75, 75, 75, 15))
		end

		self.Timer = self.Body:Add("DLabel")
		self.Timer:SetFont("MyFont")
		self.Timer:SetTextColor(Color(255, 255, 255, 255))
		self.Timer:Dock(LEFT)
		self.Timer:SetContentAlignment(5)
	end,
	PerformLayout = function(self)
		self:SetSize(200, 100)
		self:SetPos(0, 0)
	end,
	Think = function(self, w, h)
		net.Receive(
			"round_timer",
			function(len, pl)
				time = net.ReadInt(10)
			end
		)

		if time == nil then
			self.Timer:SetText(5)
		else
			self.Timer:SetText(time)
		end
	end
}

TIMER_PANEL = vgui.RegisterTable(TIMER_PANEL, "EditablePanel")
RoundActive = false
net.Receive(
	"round_active",
	function(len)
		RoundActive = net.ReadBool()
	end
)

hook.Add(
	"HUDPaint",
	"HUDIdent",
	function()
		if not IsValid(TimerPanel) then
			TimerPanel = vgui.CreateFromTable(TIMER_PANEL)
		end

		if IsValid(TimerPanel) then
			TimerPanel:Show()
		end
	end
)

local mat = Material("pp/texturize/plain.png")
local blurMat2, Dynamic2 = Material("pp/blurscreen"), 0
local function BlurScreen(den, alp)
	local layers, density, alpha = 1, den, alph
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blurMat2)
	local FrameRate, Num, Dark = 1 / FrameTime(), 3, 150
	for i = 1, Num do
		blurMat2:SetFloat("$blur", (i / layers) * density * Dynamic2)
		blurMat2:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	Dynamic2 = math.Clamp(Dynamic2 + (1 / FrameRate) * 7, 0, 1)
end

hook.Add(
	"HUDPaint",
	"HUDPaint_DrawABox",
	function()
		local lply = LocalPlayer()
		if not lply:Alive() then
			local specPly = lply:GetNWEntity("SpecPly")
			if not specPly:IsValid() then return end
			local Text = "GoPro #" .. 1259 + specPly:EntIndex() * 72
			draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905 + 2, ScrH() * 0.035 + 2, Color(0, 0, 0), TEXT_ALIGN_CENTER)
			draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905, ScrH() * 0.035, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			draw.RoundedBox(0, ScrW() * 0.85, ScrH() * 0.085, 50, 28, Color(0, 173, 255))
			draw.RoundedBox(0, ScrW() * 0.85 + 58, ScrH() * 0.085, 50, 28, Color(0, 173, 255))
			draw.RoundedBox(0, ScrW() * 0.85 + 58 * 2, ScrH() * 0.085, 50, 28, Color(0, 70, 103))
			draw.RoundedBox(0, ScrW() * 0.85 + 58 * 3, ScrH() * 0.085, 50, 28, color_white)
			Text = specPly:Nick()
			draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905 + 2, ScrH() * 0.11 + 2, Color(0, 0, 0), TEXT_ALIGN_CENTER)
			draw.DrawText(Text, "BODYCAMFONT", ScrW() * 0.905, ScrH() * 0.11, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			DrawBloom(0.6, 1, 9, 9, 1, 1.2, 0.8, 0.8, 1.2)
			--DrawTexturize(1,mat)
			DrawSharpen(1, 1.2)
			BlurScreen(0.3, 55)
			--LocalPlayer():SetDSP(55, true)
			DrawMotionBlur(0.2, 0.3, 0.001)
		end
	end
)

local Names = {
	[0] = "Террорист",
	[1] = "Контр-Террорист"
}

-- Контр срайк :steamhappy:
local TimeStart
local TimeEnd
local function DrawPlajka()
	local lply = LocalPlayer()
	local TimeRemaining = TimeEnd - CurTime()
	local Alpha = math.Clamp(math.abs(TimeRemaining / 0.5), 0, 1)
	draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255 * Alpha))
	draw.DrawText("Твоя команда - " .. (Names[lply:Team()] or ""), "PlajkaFont", ScrW() * 0.5, ScrH() * 0.75, Color(255, 255, 255, 255 * Alpha), TEXT_ALIGN_CENTER)
	local TimeFormat = string.FormattedTime(TimeRemaining, "%02i:%02i:%02i")
	draw.DrawText("Высадка через - " .. TimeFormat or "", "PlajkaFont", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255 * TimeRemaining / 4, 255 * TimeRemaining / 4, 255 * Alpha), TEXT_ALIGN_CENTER)
	draw.DrawText("Counter-Strike", "PlajkaFont", ScrW() * 0.5, ScrH() * 0.25, Color(194, 151, 66, 255 * Alpha), TEXT_ALIGN_CENTER)
	if CurTime() >= TimeEnd then
		hook.Remove("HUDPaint", "Plajka")
	end
end

net.Receive(
	"round_started",
	function()
		hook.Add("HUDPaint", "Plajka", DrawPlajka)
		TimeStart = CurTime()
		TimeEnd = TimeStart + 8
		surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
		system.FlashWindow()
		timer.Simple(
			8,
			function()
				hook.Remove("HUDPaint", "Plajka")
			end
		)
	end
)