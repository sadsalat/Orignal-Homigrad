
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("entities/base_wire_entity.lua")


util.AddNetworkString("wac.seatSwitcher.switch")


function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/consolebox01a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.seats = {}
end

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos+tr.HitNormal*10)
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply	
	return ent
end


function ENT:updateSeats()
	local passengers = {}
	for i = 1, 9 do
		if IsValid(self.seats[i]) and IsValid(self.seats[i]:GetPassenger(0)) then
			table.insert(passengers, self.seats[i]:GetPassenger(0))
		end
	end
	net.Start("wac.seatSwitcher.switch")
	net.WriteEntity(self)
	net.WriteInt(#self.seats, 8)
	for _, e in pairs(self.seats) do
		net.WriteEntity(e)
	end
	net.Send(passengers)
end


function ENT:addVehicle(e)
	if table.HasValue(self.seats, e) then return end
	table.insert(self.seats, e)
	e.wac_seatswitcher = self.Entity
	self:updateSeats()
end


function ENT:removeVehicle(i)
	self.seats[i].wac_seatswitcher = nil
	table.remove(self.seats, i)
	self:updateSeats()
end


function ENT:Use(p)
	if IsValid(p) and p:IsPlayer() then
		for _, v in pairs(self.seats) do
			if not IsValid(v:GetPassenger(0)) and not p:InVehicle() then
				p:EnterVehicle(v)
				break
			end
		end
	end
end


function ENT:switchSeat(p, int)
	if not self.seats[int] or self.seats[int]:GetPassenger(0):IsValid() then return end
	local oldang = p:GetAimVector():Angle()
	oldang.y = oldang.y+90
	p:ExitVehicle()
	if VCMod1 then
		p.VC_CanEnterTime = CurTime()
	end
	p:EnterVehicle(self.seats[int])
	--p:SnapEyeAngles(self.seats[int]:GetAngles())
	self:updateSeats()
end


concommand.Add("wac_setseat", function(p,c,a)
	if not p:InVehicle() then return end
	local veh = p:GetVehicle()
	if veh.wac_seatswitcher then
		veh.wac_seatswitcher:switchSeat(p, tonumber(a[1]))
	end
end)


function ENT:Think()
	for k,v in pairs(self.seats) do
		if not IsValid(v) or not v.wac_seatswitcher then
			self:removeVehicle(k)
		end
	end
end


function ENT:BuildDupeInfo()
	local info=WireLib.BuildDupeInfo(self.Entity) or {}
	info.v={}
	for k,v in pairs(self.seats) do
		info.v[k]=v:EntIndex()
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	WireLib.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	if (info.v) then
		self.seats={}
		for k,v in pairs(info.v) do
			local e=GetEntByID(v)
			if not e or e ~= GetEntByID(v) then
				e=ents.GetByIndex(v)
			end
			if not table.HasValue(self.seats,e) then
				self:addVehicle(e)
			end
		end
	end
end
