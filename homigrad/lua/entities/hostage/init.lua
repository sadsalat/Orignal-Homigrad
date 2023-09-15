AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local model = {
	"models/Characters/Hostage_01.mdl",
	"models/Characters/Hostage_02.mdl",
	"models/Characters/hostage_03.mdl",
	"models/Characters/hostage_04.mdl"
}

function ENT:Initialize()
	local rag = ents.Create( "prop_ragdoll" )
	rag:SetModel( model[math.random(1,4)] )
	rag:SetPos( self:GetPos() )
	rag.deadbody = true
	rag.hostage = true
	rag:Spawn()
	self:Remove()
end