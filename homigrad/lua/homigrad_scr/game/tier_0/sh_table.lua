local copy
copy = function(obj,seen)
	if type(obj) ~= "table" then return obj end
	if seen[obj] then return seen[obj] end

	local res = {}

	seen[obj] = res

	for k,v in pairs(obj) do res[copy(k,seen)] = copy(v,seen) end

	return res
end

function util.tableCopy(obj)
	local seen = {}
	local result = copy(obj,seen)

	return result,seen
end--https://gist.github.com/tylerneylon/81333721109155b2d244
--спать хочу


function util.tableChange(tbl,source)
	for k in pairs(tbl) do tbl[k] = nil end

	for k,v in pairs(source) do
		tbl[k] = v
	end
end

function util.tableMerge(tbl,source)
	local seen = {}

	for k,v in pairs(source) do
		if type(v) == "table" then v = copy(v,seen) end
		if type(k) == "table" then k = copy(k,seen) end

		tbl[k] = v
	end

	return seen
end

local function copy(tbl,source,seen)
	seen[source] = true
	seen[tbl] = true

	for k,v in pairs(source) do
		if type(v) == "table" then
			if seen[v] then tbl[k] = v continue end

			tbl[k] = tbl[k] or {}

			copy(tbl[k],v,seen)
		else
			tbl[k] = v
		end
	end
end

function util.tableLink(tbl,source)--пиздец блядь было бы моя воля яб твою мать к стулу привезал и хуём ей пятки щекотал до смерти
	local seen = {}

	copy(tbl,source,seen)
end

local function copy2(tbl,source,seen)
	seen[source] = true
	seen[tbl] = true

	for k,v in pairs(source) do
		if type(v) == "table" then
			if seen[v] then tbl[k] = v continue end

			tbl[k] = {}
			copy2(tbl[k],v,seen)
		else
			if tbl[k] == nil then
				tbl[k] = v
			end
		end
	end
end

local function copy(tbl,source,seen,change)
	seen[source] = true
	seen[tbl] = true

	for k,v in pairs(source) do
		if type(v) == "table" then
			if seen[v] then
				if tbl[k] == nil then change[k] = true end

				continue
			end

			if tbl[k] == nil then tbl[k] = {} end

			change[k] = {}
			copy(tbl[k],v,seen,change[k])
		else
			if tbl[k] == nil then
				tbl[k] = v
				change[k] = true
			end
		end
	end
end

function util.tableUnLink(tbl,source)
	local seen,change = {},{}

	copy(tbl,source,seen,change)

	return change
end

local function copy(tbl,source)
	for k,v in pairs(source) do
		if type(v) == "table" then
			if not tbl[k] then continue end

			copy(tbl[k],v)
		else
			tbl[k] = nil
		end
	end
end

function util.tableRemove(tbl,source)
	copy(tbl,source,seen)
end

function util.tableMinMax(tbl)
	local min
	local max

	for i,_ in pairs(tbl) do
		if not min then
			min = i
			max = i

			continue
		end

		if min > i then min = i end
		if max < i then max = i end
	end

	return min,max
end

local string_split = string.Split

function util.ConstructInTablePath(tbl,path)
	local splitPath = string_split(path,".")
	local i = 1
	local l = #splitPath
	local v1,v2

	path = tbl

	while true do
		v1 = splitPath[i]

		split = string_split(v1,":")

		if #split > 1 then
			v1 = split[1]
			v2 = path[v1]

			if not v2 then
				v2 = {}

				path[v1] = v2
				path = v2
			end

			return v2,split[2],true--key,value,isSelf??
		else
			if i == l then return path,v1 end

			v2 = path[v1]

			if not v2 then
				v2 = {}

				path[v1] = v2
				path = v2
			else
				path = v2
			end
		end

		i = i + 1
	end
end