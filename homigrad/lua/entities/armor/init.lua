AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()

	self.Entity:SetModel("models/combine_vests/bluevest.mdl")
	self.Entity:SetMaterial("models/mat_jack_hmcd_armor")
	self.Entity:SetColor(Color(70,120,60))
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self:SetModelScale(self:GetModelScale()*1,0)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(50)
		phys:Wake()
		phys:EnableMotion(true)
	end
	
end

function ENT:UpdateArmor(taker)
local ply
if IsValid(taker:GetNWEntity("Ragdoll")) then ply = taker:GetNWEntity("Ragdoll") else ply = taker end
if self.taken and !ply.ChestArmor==self then return end
self.taken = true
local pos = ply:GetBonePosition(ply:LookupBone('ValveBiped.Bip01_Spine2'))
local matrix = ply:GetBoneMatrix(ply:LookupBone('ValveBiped.Bip01_Spine2'))
local ang = ply:GetBoneMatrix(ply:LookupBone('ValveBiped.Bip01_Spine2')):GetAngles()
local vec = Vector(5,-5,3)
self:SetMoveType( MOVETYPE_NONE )
vec:Rotate(ang)
self:SetPos(pos+vec)
ang:RotateAroundAxis(ang:Up(),-90)
ang:RotateAroundAxis(ang:Right(),90)
self:SetAngles(ang)
self:FollowBone(ply,ply:LookupBone('ValveBiped.Bip01_Spine2'))
--self:SetParent(ply)
taker.ChestArmor = self
taker:SetNWEntity("Armor",taker.ChestArmor)
self.Carrier = taker
end

function ENT:Use(taker)
self:UpdateArmor(taker)
end

hook.Add("PhysgunPickup","NoPickingArmor",function(ply,ent)
if ent:GetClass()=="armor" and ent.taken then return false end
end)