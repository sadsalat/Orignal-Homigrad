AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Бокс"
ENT.Author = "0oa"
ENT.Spawnable = true
ENT.AdminSpawnable = false

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/Items/ammocrate_ar2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end

    function ENT:Use()
    
    end
else
    local openVgui = function(ent)
        local panel = vgui.Create("DFrame")
        panel:SetSize(300,400)
        panel:Center()
        panel:SetTitle("Бокс")

        
    end

    --if LocalPlayer():UserID() == 234 then openVgui() end

    net.Receive("Box",function()
        openVgui(net.ReadEntity())
    end)
end