include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/cs_assault/money.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:GetPhysicsObject():Wake()
end

function ENT:Use(ply)
    if ply:KeyDown(IN_WALK) then
        darkrp.AddMoney(ply,self:GetNWInt("Amount",0))

        self:Remove()
    elseif not self:IsPlayerHolding() then
        ply:PickupObject(self)
    end
end
