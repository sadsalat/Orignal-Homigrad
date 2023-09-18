local meta = FindMetaTable("Entity")

local GetOwner = meta.GetOwner
local val,tab
function meta:__index(key)
	val = meta[key]-- Search the metatable. We can do this without dipping into C, so we do it first.
	if val ~= nil then return val end

	tab = self:GetTable()-- Search the entity table

	if tab then
		val = tab[key]
		if val ~= nil then return val end
	end

	-- Legacy: sometimes use self:GetOwner() to get the owner.. so lets carry on supporting that stupidness
	-- This needs to be retired, just like self.Entity was.
	if key == "Owner" then return GetOwner(self) end
end

local meta		= FindMetaTable("Weapon")
local entity	= FindMetaTable("Entity")

-- Entity index accessor. This used to be done in engine, but it's done in Lua now because it's faster

local GetTable,GetOwner = entity.GetTable,entity.GetOwner--eblan🖕🖕🖕

local val
function meta:__index(key)
	val = meta[key]
	if val ~= nil then return val end

	val = entity[key]-- Search the entity metatable
	if val ~= nil then return val end

	local tab = GetTable(self)-- Search the entity table
	if tab != nil then
		val = tab[key]

		if val ~= nil then return val end
	end

	-- Legacy: sometimes use self:GetOwner() to get the owner.. so lets carry on supporting that stupidness
	-- This needs to be retired, just like self.Entity was.

	if key == "Owner" then return GetOwner(self) end
end

