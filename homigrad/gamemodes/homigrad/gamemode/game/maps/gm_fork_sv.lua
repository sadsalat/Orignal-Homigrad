local map = game.GetMap()
if map ~= "gm_fork" then return end

hook.Add("PostCleanupMap","gm_fork",function()
	timer.Simple(1,function()
		local ent = Entity(175)
		if not IsValid(ent) then return end

		ent:Remove()
	end)
end)
