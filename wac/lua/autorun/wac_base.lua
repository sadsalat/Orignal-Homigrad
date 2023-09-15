
include("wac/base.lua")

if SERVER then

	AddCSLuaFile("autorun/wac_base.lua")

	local folderList = {}
	folderList = file.Find("wac/".."*.lua", "LUA")
	table.sort(folderList)
	for _, f in pairs(folderList) do
		AddCSLuaFile("wac/" .. f)
	end

else

	-- menu/settings stuff
	wac.hook("PopulateToolMenu", "wac_menu_populate", function()
		for tab, t1 in pairs(wac.menuPanels) do
			for category, t2 in pairs(t1) do
				for name, hook in pairs(t2) do
					spawnmenu.AddToolMenuOption(tab, category, name, name, "", "", function(panel)
						panel:Clear()
						hook.panel = panel
						for _, func in pairs(hook.funcs) do
							func(panel, {})
						end
					end, {})
				end
			end
		end
	end)
	
	local lastThink=0
	wac.hook("Think", "wac_menupanel_update", function()
		local crt=CurTime()
		if lastThink+0.1 < crt then
			for nameTab, tab in pairs(wac.menuPanels) do
				for nameCategory, category in pairs(tab) do
					for namePanel, panel in pairs(category) do
					
						if panel.panel then
							for name, old in pairs(panel.triggers) do
								if GetConVar(name) then
									local new = GetConVar(name):GetString()
									if old != new then
										panel.triggers[name] = new
										panel.panel:Clear()
										for _, func in pairs(panel.funcs) do
											func(panel.panel, panel.triggers)
										end
									end
								end
							end
						end
						
					end
				end
			end
			lastThink = crt
		end
	end)
		
	
	-- calcview hooks
	local view = {}
	local lastCalcView = 0
	wac.calcView = function(player, pos, ang, fov)
		if not wac.hooksOverride["CalcView"] then return end
		if lastCalcView == CurTime() then return end
		player.wac = player.wac or {}
		lastCalcView = CurTime()
		view.origin = pos
		view.angles = ang
		view.fov = fov
		view.vm_angles = nil
		view.vm_origin = nil
		local send = false
		for name, hook in pairs(wac.hooksOverride["CalcView"]) do
			local t = hook.f(player, view.origin, view.angles, view.fov)
			if t then
				view.origin = t.origin or view.origin
				view.angles = t.angles or view.angles
				view.fov = t.fov or view.fov
				view.vm_angles = t.vm_angles or view.vm_angles
				view.vm_origin=t.vm_origin or view.vm_origin
				send = true
			end
		end
		player.wac.lastView = table.Copy(view)
		if send then return view end
	end
	wac.hooks["wac_cl_calcview"] = {f = wac.calcView, g = "CalcView"}

end

concommand.Add("wac_reloadhooks" .. (CLIENT and "_cl" or ""), function(player, command, args)
	for name, t in pairs(wac.hooks) do
		if !t.g or !name or !t.f then error("failed to reload hook " .. tostring(t.g) .. ' ' .. tostring(name) .. ' ' .. tostring(t.f)) end
		hook.Add(t.g, name, t.f)
	end
end)


if CLIENT then

	local madness = CreateClientConVar("wac_steal_hooks", "0")

	if madness:GetBool() then

		wac.hookRemoveOld = wac.hookRemoveOld or hook.Remove

		hook.Remove = function(event, identifier)
			wac.hookRemoveOld(event, identifier)
			if wac.stolenHooks[event] and wac.stolenHooks[event][identifier] then
				print("WAC is cleaning up hook " .. event .. " " .. tostring(identifier))
				wac.stolenHooks[event][identifier] = nil
			end
		end
		
		hook.Add("Think", "wac_stealhooks", function()
			for gmname, hooks in pairs(hook.GetTable()) do
				if WAC_STEAL_HOOKS[gmname] then
					for name, cb in pairs(hooks) do
						if not wac.hooks[name] and (not wac.hooksOverride[gmname] or not wac.hooksOverride[gmname][name]) then
							print("WAC is stealing hook "..gmname.." "..tostring(name))
							wac.stolenHooks[gmname] = wac.stolenHooks[gmname] or {}
							wac.stolenHooks[gmname][name] = cb
							wac.hookRemoveOld(gmname, name)
						end
					end
				end
			end
		end)

		hook.Add("CalcView", "wac_calcview", function(pl, pos, ang, fov)
			local r = wac.calcView(pl, pos, ang, fov)
			if r then
				return r
			end
			if wac.stolenHooks["CalcView"] then
				for n, f in pairs(wac.stolenHooks["CalcView"]) do
					r = f(pl, pos, ang, fov)
					if r then
						return r
					end
				end
			end
		end)
		wac.hooks["wac_calcview"] = true

		hook.Add("CreateMove", "wac_createmove", function(move)
			local result = nil
			if wac.hooksOverride["CreateMove"] then
				for _, hook in pairs(wac.hooksOverride["CreateMove"]) do
					local r = hook.f(move)
					if r then
						result = r
					end
				end
			end
			if wac.stolenHooks["CreateMove"] then
				for _, f in pairs(wac.stolenHooks["CreateMove"]) do
					local r = f(move)
					if r then
						return r
					end
				end
			end
			return result
		end)
		wac.hooks["wac_createmove"] = true

	else

		hook.Add("CalcView", "wac_calcview", function(pl, pos, ang, fov)
			return wac.calcView(pl, pos, ang, fov)
		end)
		wac.hooks["wac_calcview"] = true

		hook.Add("CreateMove", "wac_createmove", function(move)
			local result = nil
			if wac.hooksOverride["CreateMove"] then
				for _, hook in pairs(wac.hooksOverride["CreateMove"]) do
					local r = hook.f(move)
					if r then
						result = r
					end
				end
			end
			return result
		end)
		wac.hooks["wac_createmove"] = true

	end

end
