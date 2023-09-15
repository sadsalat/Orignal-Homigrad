
include("wac/base.lua")

wac.tag = wac.tag or {
	
	tags = {},

	add = function(name)
		if not table.HasValue(wac.tag.tags, name) then
			table.insert(wac.tag.tags, name)
		end
	end,

	remove = function(name)
		for _, n in pairs(wac.tag.tags) do
			if n == name then
				table.remove(wac.tag.tags, n)
			end
		end
		local svTags = string.Explode(',', GetConVarString("sv_tags") or "")
		for _, tag in pairs(svTags) do
			if tag == name then
				table.remove(svTags, name)
			end
		end
		table.sort(svTags)
		RunConsoleCommands("sv_tags", table.concat(svTags, ','))
	end,

}
