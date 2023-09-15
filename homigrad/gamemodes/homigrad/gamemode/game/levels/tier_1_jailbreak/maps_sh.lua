hook.Add("PostCleanupMap","gm_fork",function()
    if game.GetMap() ~= "ba_jail_electric_vip_v2" then return end

	timer.Simple(1,function()
		for i,ent in pairs(ents.GetAll()) do
			if ent:GetModel() == "models/props/cs_office/ot_can1" then ent:Remove() end
		end
	end)
end)