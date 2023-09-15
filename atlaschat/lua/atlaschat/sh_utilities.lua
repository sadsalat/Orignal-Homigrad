PLAYER_META = FindMetaTable("Player")
ENTITY_META = FindMetaTable("Entity")

concommand.Add("dgetinfo", function(player)
	local a=player:GetEyeTrace().Entity
	
	Msg(tostring(a) .. "\n")
	Msg(tostring(a:GetPos()).."\n")
	Msg(tostring(a:GetAngles()) .. "\n")
	Msg(tostring(a:GetModel()) .. "\n")
end)

util.GetPlayers = player.GetAll

function util.FindPlayerAtlaschat(name, user)
	if (!name) then return nil end

	local output = {}

	for k, v in pairs(util.GetPlayers()) do
		if (string.lower(v:Nick()) == string.lower(name) or string.lower(v:Name()) == string.lower(name)) then
			return v
		end
		
		if (v:SteamID() == name) then
			return v
		end
		
		local found = false
		
		if (string.find(string.lower(name), string.lower(v:Nick()), 0, true) or string.find(string.lower(name), string.lower(v:Name()), 0, true)) then
			table.insert(output, v)
			
			found = true
		end
		
		if (v.SteamName and !found) then
			if (string.find(string.lower(name), string.lower(v:SteamName()), 0, true)) then
				table.insert(output, v)
			end
		end
		
		if (GAMEMODE.GetAmMurderer and !found) then
			if (string.find(string.lower(name), string.lower(v:GetBystanderName()), 0, true)) then
				table.insert(output, v)
			end
		end
	end

	if (#output == 1) then
		return output[1]
	elseif (#output > 1) then
		if (IsValid(user)) then
			user:ChatPrint("Found more than one player with that name.")
		else
			if (SERVER) then
				Msg("Found more than one player with that name.\n")
			end
		end
	else
		if (IsValid(user)) then
			user:ChatPrint("Can't find any player with that name.")
		else
			if (SERVER) then
				Msg("Can't find any player with that name.\n")
			end
		end
	end
end

function util.FormatNumber(number)
	if (number >= 1e14) then
		return tostring(number)
	end

	number = tostring(number)

    local dp = string.find(number, "%.") or #number +1
	
	for i = dp -4, 1, -3 do
		number = string.sub(number, 1, i) .. "," .. string.sub(number, i +1)
	end
	
    return number
end

function string.Capitalize(text)
	return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end

if (SERVER) then
	function util.PrintAll(text)
		for k, v in pairs(player.GetAll()) do
			v:ChatPrint(text)
		end
	end
	
	function util.PrintConsoleAdmins(text)
		local players = player.GetAll()
		
		for k, player in pairs(players) do
			if (player:IsAdmin()) then
				player:PrintMessage(HUD_PRINTCONSOLE, text)
			end
		end
	end
elseif (CLIENT) then
	-- Thanks capsadmin <3.
	function surface.DrawLineEx(x1, y1, x2, y2, w)
		local dx, dy = x1 -x2, y1 -y2
		local rotation = math.deg(math.atan2(dx, dy))
		local distance = math.Distance(x1, y1, x2, y2)
		
		x1 = x1 -dx *0.5
		y1 = y1 -dy *0.5
		
		surface.DrawTexturedRectRotated(x1, y1, w, distance, rotation)
	end

	function util.InstallHandHover(panel)
		panel:SetMouseInputEnabled(true)
		
		function panel:OnCursorEntered()
			self:SetCursor("hand")
		end
		
		function panel:OnCursorExited()
			self:SetCursor("arrow")
		end
	end
	
	function util.PaintShadow(x, y, w, h, passes, depth)
		passes = passes or 4
		depth = depth or 0.2
		
		for i = 1, passes do
			local color = Color(0, 0, 0, (255 /i) *depth)
			
			surface.SetDrawColor(color)
			
			-- Top shadow.
			surface.DrawRect(x, y +(-1 +i), w, 1)
			
			-- Left shadow.
			surface.DrawRect(x +(-1 +i), y, 1, h)
			
			-- Bottom shadow.
			surface.DrawRect(x, y +(h -i), w, 1)
			
			-- Right shadow.
			surface.DrawRect(x +(w -i), y, 1, h)
		end
	end

	function draw.SimpleRect(x, y, w, h, col)
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, w, h)
	end
	
	function draw.SimpleOutlined(x, y, w, h, col)
		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(x, y, w, h)
	end
	
	function draw.DoubleOutlined(x, y, w, h, col)
		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(x, y, w, h)
		surface.DrawOutlinedRect(x +1, y +1, w -2, h -2)
	end
	
	function draw.Material(x, y, w, h, color, material)
		surface.SetDrawColor(color)
		surface.SetMaterial(material)
		surface.DrawTexturedRect(x, y, w, h)
	end
	
	function draw.MaterialRotated(x, y, w, h, color, material, rotated)
		surface.SetDrawColor(color)
		surface.SetMaterial(material)
		surface.DrawTexturedRectRotated(x, y, w, h, rotated)
	end
	
	function draw.Texture(x, y, w, h, color, texture)
		surface.SetDrawColor(color)
		surface.SetTexture(texture)
		surface.DrawTexturedRect(x, y, w, h)
	end
	
	function draw.TextureRotated(x, y, w, h, color, texture, rotated)
		surface.SetDrawColor(color)
		surface.SetTexture(texture)
		surface.DrawTexturedRectRotated(x, y, w, h, rotated)
	end
	
	function draw.SimpleTextOutline(text, font, x, y, col, colOutline, xAlign, yAlign, outline)
		draw.SimpleText(text, font, x +(outline or 1), y +(outline or 1), colOutline, xAlign, yAlign)
		draw.SimpleText(text, font, x, y, col, xAlign, yAlign)
	end

	function util.GetTextSize(font, text)
		surface.SetFont(font)
		
		local w, h = surface.GetTextSize(text)
		
		return w, h
	end
	
	-- A ghetto way to replace the scrollbar.
	function util.ReplaceScrollbarAtlas(panel)	
		panel.VBar:SetWide(4)
		panel.VBar:Dock(NODOCK)
		panel.VBar.btnUp:Remove()
		panel.VBar.btnDown:Remove()
		
		function panel.VBar:Paint(w, h) end
		
		function panel.VBar.btnGrip:Paint(w, h)
			local parent = self:GetParent():GetParent()
			local x, y = parent:ScreenToLocal(gui.MousePos())
			local w2, h2 = parent:GetSize()
			
			if (x >= w2 -8 and x <= w2 +8 and y >= 0 and y <= h2) then
				if (self.Depressed) then
					draw.RoundedBox(2, 0, 0, w, h, color_white)
				elseif (self.Hovered) then
					draw.RoundedBox(2, 0, 0, w, h, Color(191, 192, 193, 255))
				else
					draw.RoundedBox(2, 0, 0, w, h, Color(221, 222, 223, 255))
				end
			end
		end
		
		function panel.VBar:OnCursorMoved(x, y)
			if (!self.Enabled) then return end
			if (!self.Dragging) then return end
		
			local x = 0
			local y = gui.MouseY()
			local x, y = self:ScreenToLocal(x, y)
			
			y = y -self.HoldPos
			
			local TrackSize = self:GetTall() -self:GetWide() *2 -self.btnGrip:GetTall()
			
			y = y /TrackSize
			
			self:SetScroll(y *self.CanvasSize)	
		end
		
		function panel.VBar:PerformLayout()
			local Scroll = self:GetScroll() /self.CanvasSize
			local BarSize = math.max(self:BarScale() *self:GetTall(), 0)
			local Track = self:GetTall() -BarSize
			
			Track = Track +1
			Scroll = Scroll *Track
			
			self.btnGrip:SetPos(0, Scroll)
			self.btnGrip:SetSize(self:GetWide(), BarSize)
		end
		
		function panel:PerformLayout()
			local width, height = self:GetSize()
		
			self:Rebuild()
		
			self.VBar:SetUp(height, self.pnlCanvas:GetTall())
			self.VBar:SetPos(width -6, 2)
			self.VBar:SetTall(height -4)
			
			if (self.VBar.Enabled) then
				self.pnlCanvas:SetWide(width)
				self.pnlCanvas:SetPos(0, self.VBar:GetOffset())
			else
				self.pnlCanvas:SetWide(width)
				self.pnlCanvas:SetPos(0, 0)
			
				self.VBar:SetScroll(self.pnlCanvas:GetTall())
			end
		
			self:Rebuild()
		end
	end
	
	do	-- Custom ToScreen, ToVector ( For non EyePos based cameras )

		function cam.ToVector( x, y, scrW, scrH, camAng, camFov )
			local d = scrW / ( 2 * math.tan( math.rad( 0.5 * camFov ) ) ) 
			
			local vForward	= camAng:Forward()
			local vRight	= camAng:Right()
			local vUp		= camAng:Up()
			
			return ( d * vForward + ( x - scrW/2 ) * vRight + ( scrH/2 - y ) * vUp ):GetNormalized()	
		end
	
		function cam.ToScreen( camPos, camAng, camFov, scrW, scrH, vec )
			local vDir = camPos - vec
			
			local fdp = camAng:Forward():Dot( vDir )
		
			if ( fdp == 0 ) then
				return 0, 0, false, false
			end
			
			local d = scrW / ( 2 * math.tan( math.rad( 0.5 * camFov ) ) ) 
			local vProj = ( d / fdp ) * vDir
			
			local x = 0.5 * scrW + camAng:Right():Dot( vProj )
			local y = 0.5 * scrH - camAng:Up():Dot( vProj )
			
			return x, y, ( 0 < x && x < scrW && 0 < y && y < scrH ) && fdp < 0, fdp > 0
		end
		
	end
end

--[[	vON 1.3.4

	Copyright 2012-2014 Alexandru-Mihai Maftei
					aka Vercas

	GitHub Repository:
		https://github.com/vercas/vON

	You may use this for any purpose as long as:
	-	You don't remove this copyright notice.
	-	You don't claim this to be your own.
	-	You properly credit the author (Vercas) if you publish your work based on (and/or using) this.

	If you modify the code for any purpose, the above obligations still apply.
	If you make any interesting modifications, try forking the GitHub repository instead.

	Instead of copying this code over for sharing, rather use the link:
		https://github.com/vercas/vON/blob/master/von.lua

	The author may not be held responsible for any damage or losses directly or indirectly caused by
	the use of vON.

	If you disagree with the above, don't use the code.

-----------------------------------------------------------------------------------------------------------------------------
	
	Thanks to the following people for their contribution:
		-	Divran						Suggested improvements for making the code quicker.
										Suggested an excellent new way of deserializing strings.
										Lead me to finding an extreme flaw in string parsing.
		-	pennerlord					Provided some performance tests to help me improve the code.
		-	Chessnut					Reported bug with handling of nil values when deserializing array components.

		-	People who contributed on the GitHub repository by reporting bugs, posting fixes, etc.

-----------------------------------------------------------------------------------------------------------------------------
	
	The vanilla types supported in this release of vON are:
		-	table
		-	number
		-	boolean
		-	string
		-	nil

	The Garry's Mod-specific types supported in this release are:
		-	Vector
		-	Angle
		+	Entities:
			-	Entity
			-	Vehicle
			-	Weapon
			-	NPC
			-	Player
			-	NextBot

	These are the types one would normally serialize.

-----------------------------------------------------------------------------------------------------------------------------
	
	New in this version:
		-	Fixed addition of extra entity types. I messed up really badly.
--]]



local _deserialize, _serialize, _d_meta, _s_meta, d_findVariable, s_anyVariable
local sub, gsub, find, insert, concat, error, tonumber, tostring, type, next = string.sub, string.gsub, string.find, table.insert, table.concat, error, tonumber, tostring, type, next



--[[    This section contains localized functions which (de)serialize
        variables according to the types found.                          ]]



--	This is kept away from the table for speed.
function d_findVariable(s, i, len, lastType, jobstate)
	local i, c, typeRead, val = i or 1

	--	Keep looping through the string.
	while true do
		--	Stop at the end. Throw an error. This function MUST NOT meet the end!
		if i > len then
			error("vON: Reached end of string, cannot form proper variable.")
		end

		--	Cache the character. Nobody wants to look for the same character ten times.
		c = sub(s, i, i)

		--	If it just read a type definition, then a variable HAS to come after it.
		if typeRead then
			--	Attempt to deserialize a variable of the freshly read type.
			val, i = _deserialize[lastType](s, i, len, false, jobstate)
			--	Return the value read, the index of the last processed character, and the type of the last read variable.
			return val, i, lastType

		--	@ means nil. It should not even appear in the output string of the serializer. Nils are useless to store.
		elseif c == "@" then
			return nil, i, lastType

		--	$ means a table reference will follow - a number basically.
		elseif c == "$" then
			lastType = "table_reference"
			typeRead = true

		--	n means a number will follow. Base 10... :C
		elseif c == "n" then
			lastType = "number"
			typeRead = true

		--	b means boolean flags.
		elseif c == "b" then
			lastType = "boolean"
			typeRead = true

		--	' means the start of a string.
		elseif c == "'" then
			lastType = "string"
			typeRead = true

		--	" means the start of a string prior to version 1.2.0.
		elseif c == "\"" then
			lastType = "oldstring"
			typeRead = true

		--	{ means the start of a table!
		elseif c == "{" then
			lastType = "table"
			typeRead = true


--[[    Garry's Mod types go here    ]]

		--	e means an entity ID will follow.
		elseif c == "e" then
			lastType = "Entity"
			typeRead = true
--[[
		--	c means a vehicle ID will follow.
		elseif c == "c" then
			lastType = "Vehicle"
			typeRead = true

		--	w means a weapon entity ID will follow.
		elseif c == "w" then
			lastType = "Weapon"
			typeRead = true

		--	x means a NPC ID will follow.
		elseif c == "x" then
			lastType = "NPC"
			typeRead = true
--]]
		--	p means a player ID will follow.
		--	Kept for backwards compatibility.
		elseif c == "p" then
			lastType = "Entity"
			typeRead = true

		--	v means a vector will follow. 3 numbers.
		elseif c == "v" then
			lastType = "Vector"
			typeRead = true

		--	a means an Euler angle will follow. 3 numbers.
		elseif c == "a" then
			lastType = "Angle"
			typeRead = true

--[[    Garry's Mod types end here    ]]


		--	If no type has been found, attempt to deserialize the last type read.
		elseif lastType then
			val, i = _deserialize[lastType](s, i, len, false, jobstate)
			return val, i, lastType

		--	This will occur if the very first character in the vON code is wrong.
		else
			error("vON: Malformed data... Can't find a proper type definition. Char#" .. i .. ":" .. c)
		end

		--	Move the pointer one step forward.
		i = i + 1
	end
end

--	This is kept away from the table for speed.
--	Yeah, ton of parameters.
function s_anyVariable(data, lastType, isNumeric, isKey, isLast, jobstate)
	local tp = type(data)

	if jobstate[1] and jobstate[2][data] then
		tp = "table_reference"
	end

	--	Basically, if the type changes.
	if lastType ~= tp then
		--	Remember the new type. Caching the type is useless.
		lastType = tp

		if _serialize[lastType] then
			--	Return the serialized data and the (new) last type.
			--	The second argument, which is true now, means that the data type was just changed.
			return _serialize[lastType](data, true, isNumeric, isKey, isLast, false, jobstate), lastType
		else
			error("vON: No serializer defined for type \"" .. lastType .. "\"!")
		end
	end

	--	Otherwise, simply serialize the data.
	return _serialize[lastType](data, false, isNumeric, isKey, isLast, false, jobstate), lastType
end



--[[    This section contains the tables with the functions necessary
        for decoding basic Lua data types.                               ]]



_deserialize = {
--	Well, tables are very loose...
--	The first table doesn't have to begin and end with { and }.
	["table"] = function(s, i, len, unnecessaryEnd, jobstate)
		local ret, numeric, i, c, lastType, val, ind, expectValue, key = {}, true, i or 1, nil, nil, nil, 1
		--	Locals, locals, locals, locals, locals, locals, locals, locals and locals.

		if sub(s, i, i) == "#" then
			local e = find(s, "#", i + 2, true)

			if e then
				local id = tonumber(sub(s, i + 1, e - 1))

				if id then
					if jobstate[1][id] and not jobstate[2] then
						error("vON: There already is a table of reference #" .. id .. "! Missing an option maybe?")
					end

					jobstate[1][id] = ret

					i = e + 1
				else
					error("vON: Malformed table! Reference ID starting at char #" .. i .. " doesn't contain a number!")
				end
			else
				error("vON: Malformed table! Cannot find end of reference ID start at char #" .. i .. "!")
			end
		end

		--	Keep looping.
		while true do
			--	Until it meets the end.
			if i > len then
				--	Yeah, if the end is unnecessary, it won't spit an error. The main chunk doesn't require an end, for example.
				if unnecessaryEnd then
					return ret, i

				--	Otherwise, the data has to be damaged.
				else
					error("vON: Reached end of string, incomplete table definition.")
				end
			end

			--	Cache the character.
			c = sub(s, i, i)
			--print(i, "table char:", c, tostring(unnecessaryEnd))

			--	If it's the end of a table definition, return.
			if c == "}" then
				return ret, i

			--	If it's the component separator, switch to key:value pairs.
			elseif c == "~" then
				numeric = false

			elseif c == ";" then
				--	Lol, nothing!
				--	Remenant from numbers, for faster parsing.

			--	OK, now, if it's on the numeric component, simply add everything encountered.
			elseif numeric then
				--	Find a variable and it's value
				val, i, lastType = d_findVariable(s, i, len, lastType, jobstate)
				--	Add it to the table.
				ret[ind] = val

				ind = ind + 1

			--	Otherwise, if it's the key:value component...
			else
				--	If a value is expected...
				if expectValue then
					--	Read it.
					val, i, lastType = d_findVariable(s, i, len, lastType, jobstate)
					--	Add it?
					ret[key] = val
					--	Clean up.
					expectValue, key = false, nil

				--	If it's the separator...
				elseif c == ":" then
					--	Expect a value next.
					expectValue = true

				--	But, if there's a key read already...
				elseif key then
					--	Then this is malformed.
					error("vON: Malformed table... Two keys declared successively? Char#" .. i .. ":" .. c)

				--	Otherwise the key will be read.
				else
					--	I love multi-return and multi-assignement.
					key, i, lastType = d_findVariable(s, i, len, lastType, jobstate)
				end
			end

			i = i + 1
		end

		return nil, i
	end,

--	Just a number which points to a table.
	["table_reference"] = function(s, i, len, unnecessaryEnd, jobstate)
		local i, a = i or 1
		--	Locals, locals, locals, locals

		a = find(s, "[;:}~]", i)

		if a then
			local n = tonumber(sub(s, i, a - 1))

			if n then
				return jobstate[1][n] or error("vON: Table reference does not point to a (yet) known table!"), a - 1
			else
				error("vON: Table reference definition does not contain a valid number!")
			end
		end

		--	Using %D breaks identification of negative numbers. :(

		error("vON: Number definition started... Found no end.")
	end,


--	Numbers are weakly defined.
--	The declaration is not very explicit. It'll do it's best to parse the number.
--	Has various endings: \n, }, ~, : and ;, some of which will force the table deserializer to go one char backwards.
	["number"] = function(s, i, len, unnecessaryEnd, jobstate)
		local i, a = i or 1
		--	Locals, locals, locals, locals

		a = find(s, "[;:}~]", i)

		if a then
			return tonumber(sub(s, i, a - 1)) or error("vON: Number definition does not contain a valid number!"), a - 1
		end

		--	Using %D breaks identification of negative numbers. :(

		error("vON: Number definition started... Found no end.")
	end,


--	A boolean is A SINGLE CHARACTER, either 1 for true or 0 for false.
--	Any other attempt at boolean declaration will result in a failure.
	["boolean"] = function(s, i, len, unnecessaryEnd, jobstate)
		local c = sub(s,i,i)
		--	Only one character is needed.

		--	If it's 1, then it's true
		if c == "1" then
			return true, i

		--	If it's 0, then it's false.
		elseif c == "0" then
			return false, i
		end

		--	Any other supposely "boolean" is just a sign of malformed data.
		error("vON: Invalid value on boolean type... Char#" .. i .. ": " .. c)
	end,


--	Strings prior to 1.2.0
	["oldstring"] = function(s, i, len, unnecessaryEnd, jobstate)
		local res, i, a = "", i or 1
		--	Locals, locals, locals, locals

		while true do
			a = find(s, "\"", i, true)

			if a then
				if sub(s, a - 1, a - 1) == "\\" then
					res = res .. sub(s, i, a - 2) .. "\""
					i = a + 1
				else
					return res .. sub(s, i, a - 2), a
				end
			else
				error("vON: Old string definition started... Found no end.")
			end
		end
	end,

--	Strings after 1.2.0
	["string"] = function(s, i, len, unnecessaryEnd, jobstate)
		local res, i, a = "", i or 1
		--	Locals, locals, locals, locals

		while true do
			a = find(s, "\"", i, true)

			if a then
				if sub(s, a - 1, a - 1) == "\\" then
					res = res .. sub(s, i, a - 2) .. "\""
					i = a + 1
				else
					return res .. sub(s, i, a - 1), a
				end
			else
				error("vON: String definition started... Found no end.")
			end
		end
	end,
}



_serialize = {
--	Uh. Nothing to comment.
--	Ton of parameters.
--	Makes stuff faster than simply passing it around in locals.
--	table.concat works better than normal concatenations WITH LARGE-ISH STRINGS ONLY.
	["table"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		--print(string.format("data: %s; mustInitiate: %s; isKey: %s; isLast: %s; nice: %s; indent: %s; first: %s", tostring(data), tostring(mustInitiate), tostring(isKey), tostring(isLast), tostring(nice), tostring(indent), tostring(first)))

		local result, keyvals, len, keyvalsLen, keyvalsProgress, val, lastType, newIndent, indentString = {}, {}, #data, 0, 0
		--	Locals, locals, locals, locals, locals, locals, locals, locals, locals and locals.

		--	First thing to be done is separate the numeric and key:value components of the given table in two tables.
		--	pairs(data) is slower than next, data as far as my tests tell me.
		for k, v in next, data do
			--	Skip the numeric keyz.
			if type(k) ~= "number" or k < 1 or k > len or (k % 1 ~= 0) then	--	k % 1 == 0 is, as proven by personal benchmarks,
				keyvals[#keyvals + 1] = k									--	the quickest way to check if a number is an integer.
			end																--	k % 1 ~= 0 is the fastest way to check if a number
		end																	--	is NOT an integer. > is proven slower.

		keyvalsLen = #keyvals

		--	Main chunk - no initial character.
		if not first then
			result[#result + 1] = "{"
		end

		if jobstate[1] and jobstate[1][data] then
			if jobstate[2][data] then
				error("vON: Table #" .. jobstate[1][data] .. " written twice..?")
			end

			result[#result + 1] = "#"
			result[#result + 1] = jobstate[1][data]
			result[#result + 1] = "#"

			jobstate[2][data] = true
		end

		--	Add numeric values.
		if len > 0 then
			for i = 1, len do
				val, lastType = s_anyVariable(data[i], lastType, true, false, i == len and not first, jobstate)
				result[#result + 1] = val
			end
		end

		--	If there are key:value pairs.
		if keyvalsLen > 0 then
			--	Insert delimiter.
			result[#result + 1] = "~"

			--	Insert key:value pairs.
			for _i = 1, keyvalsLen do
				keyvalsProgress = keyvalsProgress + 1

				val, lastType = s_anyVariable(keyvals[_i], lastType, false, true, false, jobstate)

				result[#result + 1] = val..":"

				val, lastType = s_anyVariable(data[keyvals[_i]], lastType, false, false, keyvalsProgress == keyvalsLen and not first, jobstate)
				
				result[#result + 1] = val
			end
		end

		--	Main chunk needs no ending character.
		if not first then
			result[#result + 1] = "}"
		end

		return concat(result)
	end,

--	Number which points to table.
	["table_reference"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		data = jobstate[1][data]

		--	If a number hasn't been written before, add the type prefix.
		if mustInitiate then
			if isKey or isLast then
				return "$"..data
			else
				return "$"..data..";"
			end
		end

		if isKey or isLast then
			return data
		else
			return data..";"
		end
	end,


--	Normal concatenations is a lot faster with small strings than table.concat
--	Also, not so branched-ish.
	["number"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		--	If a number hasn't been written before, add the type prefix.
		if mustInitiate then
			if isKey or isLast then
				return "n"..data
			else
				return "n"..data..";"
			end
		end

		if isKey or isLast then
			return data
		else
			return data..";"
		end
	end,


--	I hope gsub is fast enough.
	["string"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		if sub(data, #data, #data) == "\\" then	--	Hah, old strings fix this best.
			return "\"" .. gsub(data, "\"", "\\\"") .. "v\""
		end

		return "'" .. gsub(data, "\"", "\\\"") .. "\""
	end,


--	Fastest.
	["boolean"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		--	Prefix if we must.
		if mustInitiate then
			if data then
				return "b1"
			else
				return "b0"
			end
		end

		if data then
			return "1"
		else
			return "0"
		end
	end,


--	Fastest.
	["nil"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
		return "@"
	end,
}



--[[    This section handles additions necessary for Garry's Mod.    ]]



if gmod then	--	Luckily, a specific table named after the game is present in Garry's Mod.
	local Entity = Entity



	local extra_deserialize = {
--	Entities are stored simply by the ID. They're meant to be transfered, not stored anyway.
--	Exactly like a number definition, except it begins with "e".
		["Entity"] = function(s, i, len, unnecessaryEnd, jobstate)
			local i, a = i or 1
			--	Locals, locals, locals, locals

			a = find(s, "[;:}~]", i)

			if a then
				return Entity(tonumber(sub(s, i, a - 1))), a - 1
			end

			error("vON: Entity ID definition started... Found no end.")
		end,


--	A pair of 3 numbers separated by a comma (,).
		["Vector"] = function(s, i, len, unnecessaryEnd, jobstate)
			local i, a, x, y, z = i or 1
			--	Locals, locals, locals, locals

			a = find(s, ",", i)

			if a then
				x = tonumber(sub(s, i, a - 1))
				i = a + 1
			end

			a = find(s, ",", i)

			if a then
				y = tonumber(sub(s, i, a - 1))
				i = a + 1
			end

			a = find(s, "[;:}~]", i)

			if a then
				z = tonumber(sub(s, i, a - 1))
			end

			if x and y and z then
				return Vector(x, y, z), a - 1
			end

			error("vON: Vector definition started... Found no end.")
		end,


--	A pair of 3 numbers separated by a comma (,).
		["Angle"] = function(s, i, len, unnecessaryEnd, jobstate)
			local i, a, p, y, r = i or 1
			--	Locals, locals, locals, locals

			a = find(s, ",", i)

			if a then
				p = tonumber(sub(s, i, a - 1))
				i = a + 1
			end

			a = find(s, ",", i)

			if a then
				y = tonumber(sub(s, i, a - 1))
				i = a + 1
			end

			a = find(s, "[;:}~]", i)

			if a then
				r = tonumber(sub(s, i, a - 1))
			end

			if p and y and r then
				return Angle(p, y, r), a - 1
			end

			error("vON: Angle definition started... Found no end.")
		end,
	}

	local extra_serialize = {
--	Same as numbers, except they start with "e" instead of "n".
		["Entity"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
			data = data:EntIndex()

			if mustInitiate then
				if isKey or isLast then
					return "e"..data
				else
					return "e"..data..";"
				end
			end

			if isKey or isLast then
				return data
			else
				return data..";"
			end
		end,


--	3 numbers separated by a comma.
		["Vector"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
			if mustInitiate then
				if isKey or isLast then
					return "v"..data.x..","..data.y..","..data.z
				else
					return "v"..data.x..","..data.y..","..data.z..";"
				end
			end

			if isKey or isLast then
				return data.x..","..data.y..","..data.z
			else
				return data.x..","..data.y..","..data.z..";"
			end
		end,


--	3 numbers separated by a comma.
		["Angle"] = function(data, mustInitiate, isNumeric, isKey, isLast, first, jobstate)
			if mustInitiate then
				if isKey or isLast then
					return "a"..data.p..","..data.y..","..data.r
				else
					return "a"..data.p..","..data.y..","..data.r..";"
				end
			end

			if isKey or isLast then
				return data.p..","..data.y..","..data.r
			else
				return data.p..","..data.y..","..data.r..";"
			end
		end,
	}

	for k, v in pairs(extra_serialize) do
		_serialize[k] = v
	end

	for k, v in pairs(extra_deserialize) do
		_deserialize[k] = v
	end

	local extraEntityTypes = { "Vehicle", "Weapon", "NPC", "Player", "NextBot" }

	for i = 1, #extraEntityTypes do
		_serialize[extraEntityTypes[i]] = _serialize.Entity
	end
end



--[[    This section exposes the functions of the library.    ]]



local function checkTableForRecursion(tab, checked, assoc)
	local id = checked.ID

	if not checked[tab] and not assoc[tab] then
		assoc[tab] = id
		checked.ID = id + 1
	else
		checked[tab] = true
	end

	for k, v in pairs(tab) do
		if type(k) == "table" and not checked[k] then
			checkTableForRecursion(k, checked, assoc)
		end
		
		if type(v) == "table" and not checked[v] then
			checkTableForRecursion(v, checked, assoc)
		end
	end
end



local _s_table = _serialize.table
local _d_table = _deserialize.table

_d_meta = {
	__call = function(self, str, allowIdRewriting)
		if type(str) == "string" then
			return _d_table(str, nil, #str, true, {{}, allowIdRewriting})
		end

		error("vON: You must deserialize a string, not a "..type(str))
	end
}
_s_meta = {
	__call = function(self, data, checkRecursion)
		if type(data) == "table" then
			if checkRecursion then
				local assoc, checked = {}, {ID = 1}

				checkTableForRecursion(data, checked, assoc)

				return _s_table(data, nil, nil, nil, nil, true, {assoc, {}})
			end

			return _s_table(data, nil, nil, nil, nil, true, {false})
		end

		error("vON: You must serialize a table, not a "..type(data))
	end
}



von = {
	version = "1.3.4",
	versionNumber = 1003004,	--	Reserving 3 digits per version component.

	deserialize = setmetatable(_deserialize,_d_meta),
	serialize = setmetatable(_serialize,_s_meta)
}

-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * string.utf8len(s)
-- * string.utf8sub(s, i, j)
-- * string.utf8reverse(s)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * string.utf8upper(s)
-- * string.utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- ABNF from RFC 3629
-- 
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
-- 

local tostring = tostring

-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
local function utf8charbytes (s, i)
	s = tostring(s)
	
	-- argument defaults
	i = i or 1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = s:byte(i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = s:byte(i + 1)

		if not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = s:byte(i + 1)
		local c3 = s:byte(i + 2)

		if not c2 or not c3 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 224 and (c2 < 160 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 237 and (c2 < 128 or c2 > 159) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = s:byte(i + 1)
		local c3 = s:byte(i + 2)
		local c4 = s:byte(i + 3)

		if not c2 or not c3 or not c4 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 240 and (c2 < 144 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 244 and (c2 < 128 or c2 > 143) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end
		
		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if c4 < 128 or c4 > 191 then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end


-- returns the number of characters in a UTF-8 string
local function utf8len (s)
	s = tostring(s)
	
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8len' (string expected, got ".. type(s).. ")")
	end

	local pos = 1
	local bytes = s:len()
	local len = 0

	while pos <= bytes do
		len = len + 1
		pos = pos + utf8charbytes(s, pos)
	end

	return len
end

-- install in the string library
if not string.utf8len then
	string.utf8len = utf8len
end


-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub (s, i, j)
	s = tostring(s)
	
	-- argument defaults
	j = j or -1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8sub' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8sub' (number expected, got ".. type(i).. ")")
	end
	if type(j) ~= "number" then
		error("bad argument #3 to 'utf8sub' (number expected, got ".. type(j).. ")")
	end

	local pos = 1
	local bytes = s:len()
	local len = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or s:utf8len()
	local startChar = (i >= 0) and i or l + i + 1
	local endChar   = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	-- byte offsets to pass to string.sub
	local startByte, endByte = 1, bytes

	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(s, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end

	return s:sub(startByte, endByte)
end

-- install in the string library
if not string.utf8sub then
	string.utf8sub = utf8sub
end


-- replace UTF-8 characters based on a mapping table
local function utf8replace (s, mapping)
	s = tostring(s)
	
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
	end
	if type(mapping) ~= "table" then
		error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
	end

	local pos = 1
	local bytes = s:len()
	local charbytes
	local newstr = ""

	while pos <= bytes do
		charbytes = utf8charbytes(s, pos)
		local c = s:sub(pos, pos + charbytes - 1)

		newstr = newstr .. (mapping[c] or c)

		pos = pos + charbytes
	end

	return newstr
end


-- identical to string.upper except it knows about unicode simple case conversions
local function utf8upper (s)
	return utf8replace(s, utf8_lc_uc)
end

-- install in the string library
if not string.utf8upper and utf8_lc_uc then
	string.utf8upper = utf8upper
end


-- identical to string.lower except it knows about unicode simple case conversions
local function utf8lower (s)
	return utf8replace(s, utf8_uc_lc)
end

-- install in the string library
if not string.utf8lower and utf8_uc_lc then
	string.utf8lower = utf8lower
end


-- identical to string.reverse except that it supports UTF-8
local function utf8reverse (s)
	s = tostring(s)
	
	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8reverse' (string expected, got ".. type(s).. ")")
	end

	local bytes = s:len()
	local pos = bytes
	local charbytes
	local newstr = ""

	while pos > 0 do
		c = s:byte(pos)
		while c >= 128 and c <= 191 do
			pos = pos - 1
			c = s:byte(pos)
		end

		charbytes = utf8charbytes(s, pos)

		newstr = newstr .. s:sub(pos, pos + charbytes - 1)

		pos = pos - 1
	end

	return newstr
end

-- install in the string library
if not string.utf8reverse then
	string.utf8reverse = utf8reverse
end

color_white 		= Color(255, 255, 255, 255)
color_black 		= Color(0, 0, 0, 255)
color_red 			= Color(255, 0, 0, 255)
color_green			= Color(0, 255, 0, 255)
color_green_darker 	= Color(0, 200, 0, 255)
color_blue 			= Color(0, 0, 255, 255)
color_yellow		= Color(255, 255, 0, 255)
color_purple_light	= Color(106, 90, 205, 255)
color_orange 		= Color(255, 165, 0, 255)
color_brown			= Color(150, 75, 0, 255)
color_limegreen		= Color(51, 251, 51)
color_grey			= Color(128, 128, 128)

-- vk.com/urbanichka