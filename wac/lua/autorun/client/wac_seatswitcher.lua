
include "wac/base.lua"

surface.CreateFont("wac_seatswitcher_text", {
	font = "Helvetica",
	size = 14
})

local pos = {x = 224, y = 25}
local lastSwitch = 0
local colorBackground = Color(0,0,0,100)
local colorPlayers = Color(255,255,255,200)
local passengers = {}

wac.hook("HUDPaint", "wac_seatswitch_hudpaint", function()
	local screen = {w = ScrW(), h = ScrH()}
	local crt = CurTime()
	local pl = LocalPlayer()
	local seat = pl:GetVehicle()
	local self = seat.wac_seatswitcher
	if !IsValid(self) or !IsValid(seat) then return end
	colorBackground.a = math.Clamp(lastSwitch - CurTime(), 0.1, 0.5)*200
	colorPlayers.a = math.Clamp(lastSwitch - CurTime(), 0.1, 0.5)*400
	draw.RoundedBox(
		2, screen.w-pos.x, screen.h-pos.y+15-#self.seats*17,
		215, #self.seats*17+2, colorBackground
	)
	for k,s in pairs(self.seats) do
		if IsValid(s) and passengers[k] != s:GetPassenger() then
			passengers[k] = s:GetPassenger()
			lastSwitch = CurTime()+1.5
		end
		draw.RoundedBox(
			2, screen.w-pos.x+2, screen.h-pos.y-#self.seats*17+k*17,
			211, 15, colorBackground
		)
		if IsValid(s) and IsValid(s:GetPassenger()) then
			local v = s:GetPassenger()
			local n = (v.Nick and v:Nick() or v:GetName())
			draw.SimpleTextOutlined(
				k..": "..n, "wac_seatswitcher_text", screen.w-pos.x+4,
				screen.h-pos.y+3-#self.seats*17+k*17, colorPlayers,
				TEXT_ALIGN_LEFT, 0, 1, colorBackground
			)
		else
			draw.SimpleTextOutlined(
				k..": Empty", "wac_seatswitcher_text", screen.w-pos.x+4,
				screen.h-pos.y+3-#self.seats*17+k*17, colorPlayers,
				TEXT_ALIGN_LEFT, 0, 1, colorBackground
			)
		end
	end
end)

local lastVehicle = nil
wac.hook("CreateMove", "wac_cl_seatswitch_centerview", function(md)
	local p = LocalPlayer()
	local vehicle = p:GetVehicle()
	if IsValid(vehicle) then
		if vehicle != lastVehicle then
			md:SetViewAngles(Angle(0,90,0))
			lastVehicle = vehicle
		end
	elseif lastVehicle then
		lastVehicle=nil
	end
end)
