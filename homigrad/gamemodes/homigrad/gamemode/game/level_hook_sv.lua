hook.Add("Player Can Lisen","level",function(output,input,isChat)
	local func = TableRound().PlayerCanLisen
	if not func then return end

	local result,is3D = func(output,input,isChat)
	if result ~= nil then return result,is3D end
end)

hook.Add("Player Start Voice","level",function(ply)
	local func = TableRound().PlayerStartVoice
	if func then func(ply) end
end)

hook.Add("Player End Voice","level",function(ply)
	local func = TableRound().PlayerEndVoice
	if func then func(ply) end
end)

hook.Add("Should Fake Ground","level",function(ply)
	local func = TableRound().ShouldFakeGround
	if func then return func(ply) end
end)

hook.Add("Should Fake Velocity","level",function(ply,speed)
	local func = TableRound().ShouldFakeVelocity
	if func then return func(ply,speed) end
end)

hook.Add("Spectate NPC","level",function(ply,npc)
	local func = TableRound().SpectateNPC
	if func then func(ply,npc) end
end)

hook.Add("OnPhysgunFreeze","level",function(_,_,ent,ply)
	local func = TableRound().OnPhysgunFreeze
	if func then func(ply,ent) end
end)

hook.Add("PhysgunPickup","level",function(ply,ent)
	local func = TableRound().PhysgunPickup
	if func then return func(ply,ent) end
end)

hook.Add("PhysgunDrop","level",function(ply,ent)
	local func = TableRound().PhysgunDrop
	if func then func(ply,ent) end
end)

hook.Add("Should Fake Physgun","level",function(ply,ent)
	local func = TableRound().ShouldFakePhysgun
	if func then return func(ply,ent) end
end)

hook.Add("PlayerDeath","level",function(ply,att,dmgInfo)
	local func = TableRound().PlayerDeath
	if func then return func(ply,att,dmgInfo) end
end)

hook.Add("Think","level",function()
	local func = TableRound().Think
	if func then func() end
end)