
include("shared.lua")

ENT.thirdPerson = {
	distance = 800
}

function ENT:DrawWeaponSelection() end

local function DrawLine(v1,v2)
	surface.DrawLine(v1.y,v1.z,v2.y,v2.z)
end

local mHorizon0=Material("WeltEnSTurm/WAC/Helicopter/hud_line_0")
local HudCol=Color(70,199,50,150)
local Black=Color(0,0,0,200)

local mat = {
	Material("WeltEnSTurm/WAC/Helicopter/hud_line_0"),
	Material("WeltEnSTurm/WAC/Helicopter/hud_line_high"),
	Material("WeltEnSTurm/WAC/Helicopter/hud_line_low"),
}

local function getspaces(n)
	if n<10 then
		n="      "..n
	elseif n<100 then
		n="    "..n
	elseif n<1000 then
		n="  "..n
	end
	return n
end


function ENT:DrawPilotHud()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetRight(), 90)
	ang:RotateAroundAxis(self:GetForward(), 90)
	
	local uptm = self.SmoothVal
	local upm = self.SmoothUp
	local spos = self.Seats[1].pos

	cam.Start3D2D(self:LocalToWorld(Vector(30,3.75,37.75)+spos), ang,0.015)
		surface.SetDrawColor(HudCol)
		surface.DrawRect(234, 247, 10, 4)
		surface.DrawRect(254, 247, 10, 4)
		surface.DrawRect(247, 234, 4, 10)
		surface.DrawRect(247, 254, 4, 10)
		
		local a=self:GetAngles()
		a.y=0
		local up=a:Up()
		up.x=0
		up=up:GetNormal()
		
		local size=180
		local dist=10
		local step=12
		for p=-180,180,step do
			if a.p+p>-size/dist and a.p+p<size/dist then
				if p==0 then
					surface.SetMaterial(mat[1])
				elseif p>0 then
					surface.SetMaterial(mat[2])
				else
					surface.SetMaterial(mat[3])
				end
				surface.DrawTexturedRectRotated(250+up.y*(a.p+p)*dist,250-up.z*(a.p+p)*dist,300,300,a.r)
			end
		end
		
		surface.SetTextColor(HudCol)
		surface.SetFont("wac_heli_small")
		
		surface.SetTextPos(30, 410) 
		surface.DrawText("SPD  "..math.floor(self:GetVelocity():Length()*0.1) .."kn")
		surface.SetTextPos(30, 445)
		local tr=util.QuickTrace(pos+self:GetUp()*10,Vector(0,0,-999999),self.Entity)
		surface.DrawText("ALT  "..math.ceil((pos.z-tr.HitPos.z)*0.01905).."m")
		
		if self:GetNWInt("seat_1_actwep") == 1 and self.weapons["S-8"] then
			surface.SetTextPos(330,445)
			surface.DrawText("S-8"..getspaces(self.weapons["S-8"]:GetAmmo()))
		end
	cam.End3D2D()
end

