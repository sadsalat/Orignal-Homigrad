
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.EngineForce = 50
ENT.Weight = 7000
ENT.MaxEnterDistance = 100

function ENT:SpawnFunction(p, tr)
	if (!tr.Hit) then return end
	local e = ents.Create(ClassName)
	e:SetPos(tr.HitPos)
	e.Owner = p
	e:Spawn()
	e:Activate()
	return e
end
