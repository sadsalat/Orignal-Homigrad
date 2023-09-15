
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.IgnoreDamage = true
ENT.UsePhysRotor = true
ENT.Submersible	= false
ENT.CrRotorWash	= true
ENT.RotorWidth	= 200
ENT.EngineForce	= 40
ENT.BrakeMul = 1
ENT.AngBrakeMul	= 0.01
ENT.Weight = 8000


ENT.Wheels = {
	{
		mdl="models/bf2/helicopters/mil mi-28/mi28_w2.mdl",
		pos=Vector(-307,0,4),
		friction=100,
		mass=200,
	},
	{
		mdl="models/bf2/helicopters/mil mi-28/mi28_w1.mdl",
		pos=Vector(46.34,-60.59,5.76),
		friction=100,
		mass=200,
	},
	{
		mdl="models/bf2/helicopters/mil mi-28/mi28_w1.mdl",
		pos=Vector(46.34,60.59,5.76),
		friction=100,
		mass=200,
	},
}

function ENT:SpawnFunction(p, tr)
	if (!tr.Hit) then return end
	local e = ents.Create(ClassName)
	e:SetPos(tr.HitPos + tr.HitNormal*15)
	e.Owner = p
	e:Spawn()
	e:Activate()
	return e
end
