hook.Add("Player Spawn","level",function(ply)
	local func = TableRound().PlayerSpawn
	if func then func() end
end)

hook.Add("PlayerSwitchWeapon","level",function(ply,old,new)
	local func = TableRound().PlayerSwitchWeapon
	func = func and func(ply,old,new)
	if func ~= nil then return func end
end)

hook.Add("OnContextMenuOpen","level",function()
    if not roundActive then return end

    local func = TableRound().OnContextMenuOpen
    if func then func() end
end)

hook.Add("OnContextMenuClose","level",function()
    local func = TableRound().OnContextMenuClose
    if func then func() end
end)

hook.Add("CanUseSpectateHUD","level",function()
    local func = TableRound().CanUseSpectateHUD
    if func then return func() end
end)

hook.Add("Think","level",function()
	local func = TableRound().Think
	if func then func() end
end)

hook.Add("PlayerStartVoice","level",function(ply)
	if ply:Alive() then return true end
end)
