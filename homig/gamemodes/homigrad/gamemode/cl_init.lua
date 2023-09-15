include("shared.lua")
surface.CreateFont("MyFont", {
	font = "Arial",
	size = 30,
	weight = 500
} )
local TIMER_PANEL = {
	Init = function(self)
		self.Body = self:Add("Panel")
		self.Body:Dock(TOP)
		self.Body:SetHeight(40)
		function self.Body:Paint(w,h)
			surface.SetDrawColor(150,255,150)
			draw.RoundedBox(16,-20,0,w/2,h,Color(75,75,75,15))
		end
		self.Timer = self.Body:Add("DLabel")
		self.Timer:SetFont("MyFont")
		self.Timer:SetTextColor(Color(255,255,255,255))
		self.Timer:Dock(LEFT)
		self.Timer:SetContentAlignment(5)
		end,
		PerformLayout = function(self)
			self:SetSize(200,100)
			self:SetPos(0,0)
		end,
		Think = function(self,w,h)
			net.Receive("round_timer",function(len,pl)
			time = net.ReadInt(10)
		end)
		if(time==nil)then
			self.Timer:SetText(5)
		else
			self.Timer:SetText(time)
		end
	end
}

TIMER_PANEL = vgui.RegisterTable(TIMER_PANEL,"EditablePanel")

RoundActive = false

net.Receive("round_active",function(len)
	RoundActive=net.ReadBool()
end)

hook.Add("HUDPaint","HUDIdent",function()
	if(!IsValid(TimerPanel))then
		TimerPanel=vgui.CreateFromTable(TIMER_PANEL)
	end
	if(IsValid(TimerPanel))then
		TimerPanel:Show()
	end
end)