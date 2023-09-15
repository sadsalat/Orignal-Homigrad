include("shared.lua")

function SWEP:Cuff(ent)
    local bone = ent:LookupBone("ValveBiped.Bip01_L_Hand")
    local ent1,ent2

    if bone then
        ent1 = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(bone))
        ent2 = ent:GetPhysicsObjectNum(ent:TranslateBoneToPhysBone(ent:LookupBone("ValveBiped.Bip01_R_Hand")))

        ent1:SetPos(ent2:GetPos())
    end

    local cuff = ents.Create("prop_physics")
    local ang = ent:GetPhysicsObjectNum(4):GetAngles()
    ang:RotateAroundAxis(ang:Forward(),90)
    cuff:SetModel("models/freeman/flexcuffs.mdl")
    cuff:SetBodygroup(1,1)
    cuff:SetPos(ent2 and ent2:GetPos() or ent:GetPos())
    cuff:SetAngles(ang)
    cuff:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    cuff:Spawn()

    for i = 1,9 do constraint.Rope(ent,ent,5,7,Vector(0,0,0),Vector(0,0,0),-2,0,0,0,"cable/rope.vmt",false,Color(255,255,255)) end

    constraint.Weld(cuff,ent,0,7,0,true,false)
    constraint.Weld(cuff,ent,0,5,0,true,false)

    self:Remove()
end

local constraint_FindConstraint = constraint.FindConstraint

local ent
function PlayerIsCuffs(ply)
	if not ply:Alive() then return end

	ent = ply:GetNWEntity("Ragdoll")
	if not IsValid(ent) then return end

	return constraint_FindConstraint(ent,"Rope")
end