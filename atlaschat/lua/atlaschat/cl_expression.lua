atlaschat.expression = {}

local stored = {}
local object = {}
object.__index = object

----------------------------------------------------------------------
-- Purpose:
--		Creates a new expression.
----------------------------------------------------------------------

function atlaschat.expression.New(text, unique)
	local expression = {}
	
	expression.text = text
	expression.unique = unique
	
	setmetatable(expression, object)
	
	table.insert(stored, expression)

	return expression
end

----------------------------------------------------------------------
-- Purpose:
--		Returns all the stored expressions.
----------------------------------------------------------------------

function atlaschat.expression.GetStored()
	return stored
end

----------------------------------------------------------------------
-- Purpose:
--		Returns an expression based on expression.
----------------------------------------------------------------------

function atlaschat.expression.GetByExpression(expression)
	for i = 1, #stored do
		local object = stored[i]
		
		if (object.text == expression) then
			return object
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		Returns an expression based on unique.
----------------------------------------------------------------------

function atlaschat.expression.GetByUnique(unique)
	for i = 1, #stored do
		local expression = stored[i]
		
		if (expression.unique == unique) then
			return expression
		end
	end
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function object:GetPlayer()
	return self.player
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function object:GetExpression()
	return self.text
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function object:GetUnique()
	return self.unique
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function object:GetCleanName()
	return self.cleanName and self.cleanName or self.text
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

local function ExtractColor(color)
	if (!color or color == "") then
		return color_white
	else
		if (string.sub(color, 0, 2) == "c=") then
			local info = string.Explode(",", string.sub(color, 3))

			if (info) then
				local r, g, b = tonumber(info[1]) or 0, tonumber(info[2]) or 0, tonumber(info[3]) or 0
				
				return Color(r, g, b)
			end
		else
			return color_white
		end
	end
end

---------------------------------------------------------
-- Emoticons.
---------------------------------------------------------

local emoticons = {}

emoticons[":)"] = "icon16/emoticon_smile.png"
emoticons[":D"] = "icon16/emoticon_happy.png"
emoticons[":O"] = "icon16/emoticon_surprised.png"
emoticons[":p"] = "icon16/emoticon_tongue.png"
emoticons[":P"] = "icon16/emoticon_tongue.png"
emoticons[":("] = "icon16/emoticon_unhappy.png"
emoticons["garry"] = {"atlaschat/emoticons/garry.png", 64, 64}
emoticons["gaben"] = {"atlaschat/emoticons/gaben.png", 64, 64}
emoticons["228"] = {"atlaschat/emoticons/228.png", 64, 64}
emoticons["almaz"] = {"atlaschat/emoticons/almaz.png", 64, 64}

emoticons[":smile:"] = "icon16/emoticon_smile.png"
emoticons[":online:"] = "icon16/status_online.png"
emoticons[":tongue:"] = "icon16/emoticon_tongue.png"
emoticons[":offline:"] = "icon16/status_offline.png"
emoticons[":unhappy:"] = "icon16/emoticon_unhappy.png"
emoticons[":suprised:"] = "icon16/emoticon_surprised.png"
emoticons[":exclamation:"] = "icon16/exclamation.png"
emoticons[":information:"] = "icon16/information.png"

for match, data in pairs(emoticons) do
	local expression = atlaschat.expression.New(match, match)

	expression.image = true
	expression.noPattern = true
	expression.cleanName = match
	
	function expression:Execute(base)
		local type = type(data)
		local image = base:Add("DImage")
		
		if (type == "table") then
			image:SetImage(data[1])
			image:SetSize(data[2], data[3])
		else
			image:SetImage(data)
			image:SetSize(16, 16)
		end

		image:SetToolTip(self.text)
		image:SetMouseInputEnabled(true)
		
		image.toolTip = self.text
		
		function image:OnCopiedText()
			return self.toolTip
		end
		
		return image
	end
	
	function expression:GetExample(base)
		return self.text, self:Execute(base)
	end
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<noparse>(.-)</noparse>", "noparse")

expression.cleanName = "<noparse> </noparse>"

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("<red>This would be a red text</red>")
	label:SetSkin("atlaschat")
	label:SizeToContents()
	
	return "<noparse><red>This would be a red text</red></noparse>", label
end

---------------------------------------------------------
-- URL.
---------------------------------------------------------

local color_url = Color(1, 192, 253)

local expression = atlaschat.expression.New("<url>(.-)</url>", "url")

expression.cleanName = "<url> </url>"

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_url)
	label:SizeToContents()
	
	label.url = text
	label.cursor = true
	
	function label:PaintOver(w, h)
		surface.SetDrawColor(color_url)
		surface.DrawLine(0, h -1, w, h -1)
	end
	
	function label:OnCursorEntered()
		self:SetCursor("hand")
	end
	
	function label:OnCursorExited()
		self:SetCursor("arrow")
	end
	
	function label:OnMousePressed(code)
		if (code == MOUSE_LEFT) then
			self.wasPressed = CurTime()
		end
	end
	
	function label:OnMouseReleased()
		if (self.wasPressed and CurTime() -self.wasPressed <= 0.16) then
			gui.OpenURL(self.url)
		end
		
		self.wasPressed = nil
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("http://www.youtube.com")
	label:SetColor(color_url)
	label:SizeToContents()
	
	label.cursor = true
	
	function label:PaintOver(w, h)
		surface.SetDrawColor(self.visited and color_url_visited_line or color_url)
		surface.DrawLine(0, h -1, w, h -1)
	end
	
	function label:OnCursorEntered()
		self:SetCursor("hand")
	end
	
	function label:OnCursorExited()
		self:SetCursor("arrow")
	end
	
	function label:OnMousePressed(code)
		if (code == MOUSE_LEFT) then
			self.wasPressed = CurTime()
		end
	end
	
	function label:OnMouseReleased()
		if (self.wasPressed and CurTime() -self.wasPressed <= 0.16) then
			gui.OpenURL(self:GetText())
			
			self:SetColor(color_url_visited)
			
			self.visited = true
		end
		
		self.wasPressed = nil
	end
	
	return "<url>http://www.youtube.com</url>", label
end

---------------------------------------------------------
-- Text color. <c=r,g,b> Text </c>
---------------------------------------------------------

local expression = atlaschat.expression.New("<c=(%d+,%d+,%d+)>(.-)</c>", "color")

expression.cleanName = "<c> </c>"

function expression:Execute(base, color, text)
	local color = string.Explode(",", color)
	color = Color(color[1], color[2], color[3])

	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a red colored text")
	label:SetColor(color_red)
	label:SizeToContents()
	
	return "<c=255,0,0>This is a red colored text</c>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<avatar>", "avatar")

expression.noPattern = true

function expression:Execute(base)
	local player = self:GetPlayer()
	local size = atlaschat.smallAvatar:GetBool() and 24 or 32

	local avatar = vgui.Create("AvatarImage")
	avatar:SetParent(base)
	avatar:SetSize(size, size)
	avatar:SetPlayer(player, size)
	
	function avatar:OnCopiedText()
		return "<avatar>"
	end
	
	return avatar
end

function expression:GetExample(base)
	local size = atlaschat.smallAvatar:GetBool() and 24 or 32
	
	local avatar = base:Add("AvatarImage")
	avatar:SetSize(size, size)
	avatar:SetPlayer(LocalPlayer(), size)
	
	return "<avatar>", avatar
end

local expression = atlaschat.expression.New("<avatar=(STEAM_[0-5]:[01]:%d+)>", "avatar_steamid")

expression.cleanName = "<avatar=STEAMID>"

function expression:Execute(base, steamID)
	if (steamID) then
		local size = atlaschat.smallAvatar:GetBool() and 24 or 32
		local communityID = util.SteamIDTo64(steamID)
		
		local avatar = vgui.Create("AvatarImage")
		avatar:SetParent(base)
		avatar:SetSize(size, size)
		avatar:SetSteamID(communityID, size)
		
		avatar.steamID = steamID

		function avatar:OnCopiedText()
			return "<avatar=" .. self.steamID .. ">"
		end
		
		return avatar
	end
end

function expression:GetExample(base)
	local size = atlaschat.smallAvatar:GetBool() and 24 or 32
	
	local avatar = base:Add("AvatarImage")
	avatar:SetSize(size, size)
	avatar:SetPlayer(LocalPlayer(), size)
	
	return "<avatar=" .. LocalPlayer():SteamID() .. ">", avatar
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<font=(.-)>(.-)</font>", "font")

expression.cleanName = "<font> </font>"

function expression:Execute(base, font, text)
	local ok = pcall(draw.SimpleText, text, font, 0, 0, color_transparent, 1, 1)
	local font = font
	
	if (!ok) then
		local eugh = font
		
		timer.Simple(0.05, function() chat.AddText(":exclamation: The font \"" .. eugh .. "\" is invalid!") end)
		
		font = atlaschat.font:GetString()
	end
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetFont(font)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a different font")
	label:SetSkin("atlaschat")
	label:SetFont("DermaDefaultBold")
	label:SizeToContents()
	
	return "<font=DermaDefaultBold>This is a different font</font>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("OverRustle", "overrustle")

expression.noPattern = true

function expression:Execute(base)
	local image = base:Add("DImage")
	image:SetImage("atlaschat/emoticons/overrustle.png")
	image:SetSize(32, 32)
	image:SetToolTip("OverRustle")
	image:SetMouseInputEnabled(true)
	
	function image:Paint(w, h)
		if (vgui.GetHoveredPanel() == self) then
			local x = math.sin(CurTime() *80) *3
			local y = math.cos(CurTime() *60) *1.5
			
			self:PaintAt(x, y, self:GetWide(), self:GetTall())
		else
			self:PaintAt(0, 0, self:GetWide(), self:GetTall())
		end
	end
	
	function image:OnCopiedText()
		return "OverRustle"
	end
	
	return image
end

function expression:GetExample(base)
	return "OverRustle", self:Execute(base)
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<lg>(.-)</lg>", "limegreen")

expression.cleanName = "<lg> </lg>"

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_limegreen)
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a limegreen text")
	label:SetColor(color_limegreen)
	label:SizeToContents()

	return "<lg>This is a limegreen text</lg>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<spoiler>(.-)</spoiler>", "spoiler")

expression.cleanName = "<spoiler> </spoiler>"

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	label:SetMouseInputEnabled(true)
	
	function label:PaintOver(w, h)
		if (!self.clicked) then
			draw.SimpleRect(0, 0, w, h, color_black)
		end
	end
	
	function label:OnMousePressed()
		self.clicked = true
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a spoiler text")
	label:SetSkin("atlaschat")
	label:SizeToContents()
	label:SetMouseInputEnabled(true)
	
	function label:PaintOver(w, h)
		if (!self.clicked) then
			draw.SimpleRect(0, 0, w, h, color_black)
		end
	end
	
	function label:OnMousePressed()
		self.clicked = true
	end

	return "<spoiler>This is a spoiler text</spoiler>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<hsv>(.-)</hsv>", "hsv")

expression.cleanName = "<hsv> </hsv>"

function expression:Execute(base, text)
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	label.color = color_white
	
	function label:Think()
		local hue = math.abs(math.sin(CurTime() *0.9) *335)

		self.color = HSVToColor(hue, 1, 1)
		
		self:SetFGColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end
	
	function label:ApplySchemeSettings()
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a hsv text")
	label:SetColor(color_white)
	label:SizeToContents()

	label.color = color_white
	
	function label:Think()
		local hue = math.abs(math.sin(CurTime() *0.9) *335)

		self.color = HSVToColor(hue, 1, 1)
		
		self:SetFGColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end
	
	function label:ApplySchemeSettings()
	end

	return "<hsv>This is a hsv text</hsv>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<flash%s*(c?=?%d-,-%d-,-%d-)>(.-)</flash>", "flash")

expression.cleanName = "<flash> </flash>"

function expression:Execute(base, color, text)
	color = ExtractColor(color)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color)
	label:SizeToContents()
	
	local hue, saturation = ColorToHSV(color)
	
	label.hue = hue
	label.color = saturation
	label.saturation = saturation
	
	function label:Think()
		local value = math.abs(math.sin(CurTime() *0.9) *1)

		self.color = HSVToColor(self.hue, self.saturation, value)
		
		self:SetFGColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end
	
	function label:ApplySchemeSettings()
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a red flashing text")
	label:SetColor(color_white)
	label:SizeToContents()

	local hue, saturation = ColorToHSV(color_red)
	
	label.hue = hue
	label.color = saturation
	label.saturation = saturation
	
	function label:Think()
		local value = math.abs(math.sin(CurTime() *0.9) *1)

		self.color = HSVToColor(self.hue, self.saturation, value)
		
		self:SetFGColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end
	
	function label:ApplySchemeSettings()
	end

	return "<flash c=255,0,0>This is a red flashing text</flash>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<vscan%s*(c?=?%d-,-%d-,-%d-)>(.-)</vscan>", "vscan")

expression.cleanName = "<vscan> </vscan>"

function expression:Execute(base, color, text)
	color = ExtractColor(color)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()

	label.scanColor = color
	
	function label:PaintOver(w, h)
		local y = -h +(h *2) *((CurTime() %1) ^2)

		draw.SimpleRect(0, y, w, h, self.scanColor)
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a vertical scan")
	label:SetSkin("atlaschat")
	label:SizeToContents()

	label.scanColor = color_red
	
	function label:PaintOver(w, h)
		local y = -h +(h *2) *((CurTime() *0.8 %1) ^2)

		draw.SimpleRect(0, y, w, h, self.scanColor)
	end

	return "<vscan c=255,0,0>This is a vertical scan</vscan>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<hscan%s*(c?=?%d-,-%d-,-%d-)>(.-)</hscan>", "hscan")

expression.cleanName = "<hscan> </hscan>"

function expression:Execute(base, color, text)
	color = ExtractColor(color)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color_white)
	label:SizeToContents()
	
	label.scanX = -4
	label.scanColor = color
	
	function label:PaintOver(w, h)
		local width = math.max(1, w *0.2)
		local x = (CurTime() %1) ^2 *(w +width) -width
		
		draw.SimpleRect(x, 0, width, h, self.scanColor)
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a horizontal scan")
	label:SetSkin("atlaschat")
	label:SizeToContents()

	label.scanColor = color_red
	
	function label:PaintOver(w, h)
		local width = math.max(1, w *0.2)
		local start = (CurTime() %1) ^2 *(w +width) -width
	
		draw.SimpleRect(start, 0, width, h, self.scanColor)
	end

	return "<hscan c=255,0,0>This is a horizontal scan</hscan>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<reverse>(.-)</reverse>", "reverse")

expression.cleanName = "<reverse> </reverse>"

function expression:Execute(base, text)
	local text = string.utf8reverse(text)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetSkin("atlaschat")
	label:SizeToContents()
	
	return label
end

function expression:GetExample(base)
	local text = string.utf8reverse("This is a reversed text")
	
	local label = base:Add("DLabel")
	label:SetText(text)
	label:SetSkin("atlaschat")
	label:SizeToContents()

	return "<reverse>This is a reversed text</reverse>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<cflash%s*(c?=?%d-,-%d-,-%d-)%s*(c?=?%d-,-%d-,-%d-)>(.-)</cflash>", "cflash")

expression.cleanName = "<cflash> </cflash>"

function expression:Execute(base, color, color2, text)
	color = ExtractColor(color)
	color2 = ExtractColor(color2)
	
	local label = atlaschat.GenericLabel()
	label:SetParent(base)
	label:SetText(text)
	label:SetColor(color)
	label:SizeToContents()
	
	label.color = color
	label.first = Color(color.r, color.g, color.b)
	label.second = Color(color2.r, color2.g, color2.b)
	label.reach = label.first
	
	function label:Think()
		if (self.color == self.first) then
			self.reach = self.second
		elseif (self.color == self.second) then
			self.reach = self.first
		end
		
		self.color.r = math.Approach(self.color.r, self.reach.r, 1.5)
		self.color.g = math.Approach(self.color.g, self.reach.g, 1.5)
		self.color.b = math.Approach(self.color.b, self.reach.b, 1.5)
		
		self:SetFGColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end
	
	function label:ApplySchemeSettings()
	end
	
	return label
end

function expression:GetExample(base)
	local label = base:Add("DLabel")
	label:SetText("This is a colored flash")
	label:SetSkin("atlaschat")
	label:SizeToContents()

	label.color = Color(255, 0, 255)

	label.first = Color(255, 0, 255)
	label.second = Color(0, 255, 0)
	label.reach = label.first
	
	function label:Think()
		if (self.color == self.first) then
			self.reach = self.second
		elseif (self.color == self.second) then
			self.reach = self.first
		end
		
		self.color.r = math.Approach(self.color.r, self.reach.r, 1.5)
		self.color.g = math.Approach(self.color.g, self.reach.g, 1.5)
		self.color.b = math.Approach(self.color.b, self.reach.b, 1.5)
		
		self:SetFGColor(self.color.r, self.color.g, self.color.b, self.color.a)
	end
	
	function label:ApplySchemeSettings()
	end
	
	return "<cflash c=255,0,255 c=0,255,0> This is a colored flash </cflash>", label
end

---------------------------------------------------------
--
---------------------------------------------------------

local expression = atlaschat.expression.New("<icon%s?(%d+),-(%d+)>(.-)</icon>", "icon")

expression.cleanName = "<icon> </icon>"

function expression:Execute(base, width, height, icon)
	local image = base:Add("DImage")
	local icon = icon or ""
	local width = tonumber(width) or 64
	local height = tonumber(height) or 64
	
	width = math.Clamp(width, 0, 64)
	height = math.Clamp(height, 0, 64)

	image:SetImage(icon)
	image:SetSize(width, height)
	image:SetToolTip(icon)
	image:SetMouseInputEnabled(true)
	
	image.toolTip = icon
	
	function image:OnCopiedText()
		return self.toolTip
	end
	
	return image
end

function expression:GetExample(base)
	return "<icon 64,64>icon16/user.png</icon>", self:Execute(base, 64, 64, "icon16/user.png")
end

---------------------------------------------------------
--
---------------------------------------------------------

local base64 = {}

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- decoding
function base64.decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local EMOTICONS = [[0|0E|1|100|100oj|100percent|12gauge|1337|1g|1heart|1questberserk|1questdizzy|1questdoomed|1questfury|1questinterogation|1questlove|1questmute|1questsad|1queststun|1stplace|1up|2|2014bass|2014lead|2014pick|2014reel|2014rhythm|228|2Dqbert|2cupz|2spooky|2sword|3|300|3079crazy|3079demon|3079meh|3079o_o|3079pig|3079private|3079smile|3089boss|3089bot1|3089bot2|3089bot3|3089ghost|3089pretty|3089tank|3arc|3heads|3zee|4|404|404sight|47|4everd|4eyes|4thwall|4wheel|4windsrune|500years500|500yearsant|500yearsearthlike|500yearsship|500yearsspaceant|50sturret|5Star|5in1btr|5in1mc|5in1tl|5in1vs|5in1wp1|5in1wp2|6|60sCan|60sFirstAid|60sMask|60sRadio|60sWater|6180|8|80|8BitHug|8BitMMO|8BitMage|8BitMageGB|8BitThief|8BitThiefGB|8BitWarrior|8BitWarriorGB|8O|8bitheart|8bomb|99|99s|9mm|9mmPistol|A|AAF|ABS|AChainsaw|ADAface|AIM|AKingIsBorn|ALTIS|AOECannon|AOEHouse|AOEKnight|AOESheep|AOEShield|AR|ARID|ARIDMask|ARTIFACTMASTER|ATAR|ATCH|ATDE|ATDO|ATEM|ATMA|ATOX|ATTA|ATWT|AXShark|A_Pneuma|AbAI|Abblack|Abgoldstar|Absilverstar|Abwhite|Access|AdaRE4|Adelpha|Administrator|AdmiralAmerica|AdmiralEurope|Adolf|Adrenaline|Adventurer|AeroBomb|AeroKey|AeroMeat|AeroRedOrb|AetherRay|AffinityHarmony|AffinityPurity|AffinitySupremacy|Ageha|Aiden|AirTarget|Airbus380|AkiStar|AkihabaraGGN|AkiraGGN|Akuma|AlarmBot|Alchemy|Aldmeri|Alessa|Alexis|AlienExecutioner|AlienHand|AlienInvasion|AlienPlatypus|AlienSoldier|AlienSpaceship|AlienTarget|Alienky|Alienstalker|Alive|AllOut|Alma|Amane|AmericanReclamationCorporation|AmmoLeech|Ammokit|Amulet|AndreHappy|AndreTough|Android|AngerGhost|Angered|AngryBot|AngryPick|AngryRobot|AngryRoehm|AngrySword|AngryVampire|AngryViking|Angry_boxer|Angryfly|Animal_Instincts|Ankh|AnthonyCarboni|AntiHero|Antipho|Aorta|Arakune|Arberrang|Archery|ArcwoodRanger|AresHelm|ArgosHelm|ArgosIcon|ArgosSeed|ArmadilloSuit|ArmdZombie|ArmorEmoticon|ArmorGNZ|Armored|ArrowHead|ArtificialMind|Artuo|Asa|Asaga|AsakusaGGN|AshleyRE4|Asleep|Assassin|Assault1|AssuredTraveler|Aste_Daniel|Aste_Esto|Aste_Fio|Aste_Grato|Aste_Roy|Astro|Astronaut|Asumi|Ataa|Atomics|Attacker|Attention_Sign|Attract|Aunt|Auraco|Ava|Avengers|Awaken|AwesomeBorn|AxGun|AxMissile|AxScoutShip|AxeNSword|Axel|Aztec|B1|B2Bomber|B3|BASIC|BBFdead|BBFdemon|BBFflame|BBFmonster|BBFsword|BBHammer|BEARTRAP|BG2Icon|BG2Leader|BMarrow|BMgauntlent|BMhorn|BMshield|BMswords|BRBrute|BRForeman|BRPendant|BRRayne|BTeam|BUDflower|BUDlove|BURNDAYRAZ|BabyBorn|BabyMonster|BadBeans|BadBunny|Badaboom|BalkanCross|BallzofLeather|Bandito|Bandy|BangS|BansheeODannan|BarbedWireBat|Barbwire|Barnacle|Barofsoap|Barthon|BasicAttack|BasicCog|Bastardo|Batman_Emoticon|Batsignal_Emoticon|BattleLorePoisoned|Battlerage|BayonetShovel|BeachDwarf|Beard|Bearded|Beat|Beatrice|Beaver|BeefSteak|BeerJar|BeltedRounds|Bengt|Benito|BevelStudios|BiT|BiTGlitch|BiTNES|BiTPixel|BigBear|BigBite|BigBomb|BigBullet|BigZee|BillyHatcher|Binoculars|BiohazardSymbol|Birdie|Birds|BlackGiantMonsterharmful|BlackHat|BlackMagic|Black_Mask_Emoticon|Black_Stone|Blackgate_Emoticon|Blackhorne|Blacktail|BlakesArmor|Blaze|Bleaty|BleedH|BlehRob|BloodEye|BloodKnife|BloodRayne|BloodRayne2|BloodWraith|BloodyKey|Bloody_Stone|BlueFlamingo|BlueGoop|BlueMagic|BlueMitten|BlueTalisman|Blue_Stone|Blueseashield|Blur|Boarlion|Bobblehead|Boeing737_600|Boeing737_700|BombBird|BombBot|Bomber|BoomBoom|BoonBoon|Boooom|BorealisEarth|BorealisGalaxy|BorealisIcePlanet|BorealisPurplePlanet|BorealisStar|BoredToDeath|Born|BossSkull|Bottle_of_SP|BottomQuark|Boxing_glove|Braddock|Breach|Brew|Broken|Brom|Brontodon|BronzeOrb|BrownHarmfulMonster|Brunt|Bucco|BuffaloofLies|BufferBot|Building|Bullet_|Bunny|Burn|BurningHot|Burnstar|BurstRadiation|Butcher|Butsu|Buttons|Buzzer|C4|CALLER|CC1Ant|CC1Ball|CC1BlueTank|CC1FireBall|CC1Hover|CC1Spider|CC1Teeth|CC2Bribe|CC2FireBoots|CC2Melinda|CC2Suction|CC2SwiftBoots|CC2Wellies|CDCash|CDFGoliath|CDtrophy|CELLULAR|CGV|CIAEvidence|CLONE|CMRPlayer|COMPAS|COWS|CROSS1|CROSS2|CRZY|CSAArtillery|CSACavalry|CSAGeneral|CSAInfantry|CSASkirmishers|CSAT|CStud|CStudios|Cactus|Camcorder|Camera|Cammy|CanYouDigIt|Candelabra|CapitalDome|CaptainZ|Card|Careful|Caretaker|Carl|Carley|CashFace|Cashbag|CatBunch|CatNip|CatacombSkull|Catwoman_Emoticon|Catz|Cavalry|Celea|CeliaAngry|CeliaSmile|Cert|ChainLinks|Champion_belt|ChaosEye|CharacterFace|Cheap|Chen_Yu_Contempt|Chen_Yu_Nifty|ChequredFlag|ChessSlice|ChibiAyaka|ChibiChiho|ChibiRise|ChibiRitsuko|ChibiRuriko|Chigara|ChigaraRocket|Chip|ChipEvil|ChipJoy|ChipNorm|ChipSad|ChipStern|ChipWink|ChompyChompy|Chonchon|ChunLi|Circuits|Circuits|Citadel|Cjoe|Clementine|CleoMoon|ClericCheering|Clie|Cliff|Clot|Clothes|Clubs_Gem|CoalitionFlag|CoffeeBreak|Coffee_GGC|Cogs|Coin_Thief|Coldsnap|Collectable|ColonialScienceDivision|Colt1911|CommandoUnit|Commenter|CommonWealth|Compy|ConcreteDonkey|Cone|ConfusedBot|Conquer|Conquerer|Contraband|ContractorRush|Convair|Corinthian|CornBomb|Corpus|CortoMaltese|Cosmo|Cougar|Cousin|Cousinar|Cowboys|Cowl_Emoticon|CrateKeeper|Crawler|Credit|Credits|Cricket_Ball|Cricket_Bat|Cricket_Duck|Cricket_Helmet|Cricket_Stumps|CrossedBlades|CrosshairAim|CrowdControl|CrownGod|Crowned|Cupajoes|CuriousSion|Currency|CurvedClip|Custodiss|CuteBearDoll|CuteBot|CyberVision|Cyberboost|Cyberspace|Cyclobot|D|DAngry1|DAngry2|DB01Enlightened|DB01Illumined|DB01Survivor|DCool|DEUflag|DE_Grin|DE_Happy|DE_Monada|DE_MyEyes|DE_Tasty|DHcargo|DISARM|DIdle|DJSkully|DLskull|DNA|DNA_strand|DNAstrand|DOOR|DOuch|DRage|DSAArbach|DSABarbarianSword|DSABattleaxe|DSAClub|DSADagger|DSAHelberd|DSAHuntingKnife|DSAMorningStar|DSAPike|DSARapier|DSARavensbeak|DSASaber|DSASlavedeath|DSATwoHanded|DSATwoLilies|DSMcop|DSMpig|DSMskull|DYNO|DYVN|DZ|DaVinci|Daggerfall|Daisy|Dakka|Dandelion|Danger1|Dania|Daqan|DarkKnight|DarkOphelia|Darkfire|Dave|Dawn|DawnShadow|DeadFranz|DeadMeat|DeadSoldier|Dead_Dwayne|DeadlyZombie|DealersEye|DeathKnight|DeathMask|DeathSmile|Deathsplit|Deaux|DecoDigital|Deer|Defend|DelphiCoin|DemonLady|Dentia|DesertDragon|DesertWitch|Designless|DeterminedRobot|Detonation|Devi|DeviledEgg|Devils|Devourer|DiagStringLeft|DiagStringRight|Diamond_Gem|Die|Digger|Dignity|Dinsdale|Diplomat|DiscardedGun|Discord|Disease|DiseaseSmile|DisembodiedHead|Dizzeler|Djoe|DnexTalon|Dog|DogOfWar|Dogen|Domesticon|Dominate|Donutbats|DoomBolt|Doomsday|Dosh|Dossenus|Doug|Doviculus|DownQuark|Downvoter|Dr_Darling|Dracila|Drago|Dragon_Eye|Dragon_Key|Dredge|Droner|DrumStick|Dual|Dubrovnik|Duck|DuckPlz|Dumahim|DuncanFree|DuncanTrapped|Durno|DustySkull|DwarfWarrior|Dwayne|Dwayne_Dancing|Dweed|Dynamic|DzHelmet|DzMask|DzNade|DzRiot|E|EARTH_YASHIRO|EE|ENFORCE|EXPLODARAMA|EXcompas|EXparking|EXwrench|E_Pneuma|Eagle_Eye|Eaglet|EarthMage|Earthbound|Earthlings|Ebonheart|Eco|EcstaticRoehm|Eddie|Edison|Eduardo|Ego|EgoGhost|Ejoe|Eko_Emoticon|ElderSign|ElfHero|EliteSword|ElvenCourt|ElvenRanger|Ember|Emoticon_01|Emoticon_02|Emoticon_03|Emoticon_04|Emoticon_05|Emperium|Emph|EnergyMax|Engine|Engines|Enoch|Enola1|Enola2|Enola3|Enola4|Enola5|Enola6|Enola7|Enshadowed|Entropy|EpochAngry|EpochDead|EpochEyeroll|EpochHappy|Epochsad|Ere|Eredin|Eri_Emoticon|Evade|Evasion|EvilPhoenix|EvilSad|EvilZombie|Excalibur|ExcitedElica|Excitedfly|Excrement_Item|Exploder|ExplodingAlien|Explorer|ExtraLifePickup|EyeLess|Eye_tv|EyelessGhost|EyeofProvidence|F1cog|F1flag|F1fuel|F1globe|F1gold|F1graph|F1headphones|F1helmet|F1ribbon|F1time|F1trophy|F1tyre|F1wheel|F1wreath|FATE|FBALL1|FBALL2|FBALL3|FF|FFIVluca|FFXIII2bomb|FFXIII2cactuar|FFXIII2chocobo|FFXIII2mirochu|FFXIII2mog|FFXIIIflag|FFXIIIlightning|FFXIIImog|FFXIIIserah|FFXIIIvanille|FIA|FLAMENSTEIN|FLAME_CHRIS|FLUX|FRAK|FRAflag|FRBG|FRCLERIC|FRDR|FRGG|FRLOL|FRTMI|FSPGREN|FSPMG|FSPROCK|FSPSG|FSPSNP|Falcon|Fancygraph|Faris|Farm|FarmerShovel|FastFood|FatBird|FatMan|FateBow|FateCrab|FateFox|FateHelmet|FateScorpion|FateScroll|FateScythe|FateSnake|FateTower|FateTree|FavouriteEmployee|Fenix1|Fenix2|Fermi|Fermibarrier|Fermipoint|Fermistatic|Fermitoken|Ferril|FiRST|FighterJet|Fighterz|FinalFate|Finger|Finger2|FingerPin|FireFist|FireFlame|FirePin|FireStrike|FireballDirectDamageSpell|Firebomb|Fireworks|FirstPlayer|First_Kill|FishmanTails|FistGNZ|Fistpump|FlamePriestess|Flame_Shot_Weapon_Item|Flame_Sign|Flames|Flapper|FlashFreeze|Flashback|Fleet|FleetAdmiral|Fleur_de_Lys|FloatPin|Flow|FlowerBomb|FlyNight|Flyinggreen|ForestDragon|FrankferttheOdd|Frann|FreeFire|FreedomFallBomb|FreedomofLife|FreezeDamageOverTimeSpell|Frieza|Froglet|FrostWizard|Frozen_Rose|FullHeart|FullPower|Furies|Furrowed|Fury|Fuzzy|G4M3|GATduke|GATgat|GAThell|GATimp|GATimplogo|GATsatan|GATuriel|GBAdmiral01|GBBiT|GBCap01|GBCap02|GBRflag|GC|GDAuto|GDCreep|GDDemon|GDDemonIcon|GDEasy|GDHard|GDHarder|GDIcon|GDInsane|GDNormal|GERMANREICH|GG|GIGA|GTR|GTeam|Gale|Gambling|GanadoRE4|Gargoyle_Gem|Gartley|GasAttack|GasCan|GatlingShip|Gauntlet_Chest|Gauntlet_Coin|Gauntlet_Gold|Gauntlet_Ham|Gems|Geralt|GermanCap01|GhostTeam|Giant|GiantDying|Gib|Gil|GinzaGGN|Givemeyourmoney|GkolAcolyte|GlasgowSmile|GlassesRoehm|Glider|GlorkConcerned|GlorkContent|GlorkEnnui|GlorkExcited|GlorkLookOut|GlorkOuch|GlorkScared|GlorkUnhappy|Glove|GnashboneFury|GoBoom|GoalieMask|GodApple|Gohan|Goku|GoldBall|GoldCross|GoldEmblem|GoldHorseShoe|GoldMedal|GoldOrb|GoldPocketWatch|GoldSkull|GoldYelaxotKey|GoldenMouth|GoldenPoo|GoldenRider|Goldshroom|GooBall|Gopher|Gorum|Gover|Granny|GrantNora|Graven|GreenBug|GreenCube|GreenDragon|GreenMagic|GreenMitten|GreenNote|Green_Stone|Greenalien|GrenadeKey|Grenade_GGC|Grenadier|GreyBriefcase|GreyShield|Griff|GrimReaperGoldenSkull|Grimm|GrimmReaper|Grimp|GrimpII|GrimpIII|Grineer|Groth|Grrr|GrumpyChompy|GrumpyLavie|Grundy_Emoticon|Gumiho|GunofEdo|HATCHED_CHRYSALIS|HAZEBlaster|HEALTHFUL|HESSTILLGOOD|HOLD|HOSTAGE|HPpotion|HS_Asteroid|HS_Walker|HVY|HalfHeart|Halo|Hamburg|Hand_Garrett|Hand_Shake|Hands|HangingController|Hank|HanzosShadow|HappyBot|HappyChompy|HappyCompass|HappyDemon|HappyElica|HappyFragger|HappyMask|HappyRob|HappyVampire|Happyfly|HardAss|HarmfulYellowMonster|Harry|Haruka_Emoticon|Harvestor|HatchedEgg|Hayashi_Twinkle|Hcrawler|HeadExplode|Healing|HealthIcon|HealthKey|Healthptn|Healthy|HeartPickup|Heart_Gem|Heartful|Heat|HeavyHammer|Heavy_Machine_Gun_Weapon_Item|Heavy_Super_Attack|Hekatombaion|HektorBattery|HektorFlashlight|HektorGhast|HektorPredator|HektorSniper|HellHeels|HelmetAlien|Helmeted|Hercules|Hero|HeroesFist|HesistantRobot|HexRoC|HighAggro|Hiko|Hilary|Hilda_Emoticon|Hilko|HipaziaTheone|Histoire|HiveSlug|HoTang|HockeyPuck|HockeyReferee|HockeyStick|HoldOnSight|Holey|HolyBall|HolyLead|Holy_Cross|HomePlanet|HomeStar|Homemadebomb|Homewrecker|Honest|Honored|Hookshot|Hooray|Hope|HopeSmile|Hoplon|Horse|Horzine|HotHead|Hotdog|HoyMadar|Hub|HulaGirl|HumanHero|HumanInsignia|HumanKnight|HumanoidBot|Hun|Hunky|Hunters|HydraBeast|Hynx|I|IAMSOLAME|ICBM|ID_Card|IFBat|IFBurger|IFCake|IFCheese|IFCherry|IFFrank|IFHeart|IFHotDog|IFKnight|IFRaspberry|IGNIZ|IHaveAProof|II|IRON_LIZARD|IRoc|IS2|IVVBeast|IX|IceSword|Icecreamer|Icon4|Id|Ignis|Ijoe|Ikaruga|IkebukuroGGN|IllKeepAnEyeOnYou|IllumEvidence|Imagine|Immobilized|Imperial|Infantry|InfectedObserver|Infection|Injured|InjusticeCatwoman|InjusticeCyborg|InjusticeFlash|InjusticeGreenArrow|InjusticeJoker|InjusticeTheRegime|InkRibbon|InstaGib|Interplanetary|Investigate_ESO|InvincibilityPotion|Invincible|InvisibleFace|IronBall|IronHeart|IronShield|IronSkull|Ironguard|Isb|Isis|ItalianCap01|ItsBoshyTime|Ivan|J1M|JAPAN|JackFace|JackLumber|JackRE4|JacksAxe|Jackson|JapanCap01|JapanFlag|JefLeppard|JetGunner|Jim|JinK|JoggerTraveler|Johnny2|JonRivera|Juju_fury|Juju_sad|Juju_smile|Juju_suprised|Juju_ungry|Juliet_Emoticon|JumaliEmoticon|Jump|Jump_Rope|JumperTraveler|Junkie|JustGo|JustGreatRob|JustLance|K|KICK|KOh|KRIZALID|KSad|KScared|KSmiley|KTBG|KTGG|KTLG|KTTG|KTZG|Kafra|Kagari|Kami|Kanae_Emoticon|Kaori|Kasainami|KaullFirelance|Kayto|KeepOnSmiling|Keeper|Ken|Kenny|Keys|Khappy|Kharn|KholatBoot|KholatCarabiner|KholatCompass|KholatFlashlight|KholatPickax|KidMorgane|Kidman|Killmaster|KingZyron|Kingdom|Kingston|KioskBot|KissAss|Kitsune|Kitty|KneelingBow|Knightly|Knossosgold|Koin|Kotori|Kovac|Krillin|KronHappy|KronMad|KronOhNoes|KronSly|KronWut|Krugas|Kurumi_Emoticon|LA04|LAKSPUR|LASER_BEAM|LCTOO_DualGuns|LCTOO_LaraCroft|LCTOO_Revolver|LCTOO_Staff|LCTOO_staffofosiris|LClock|LDODbook|LDODedna|LDODedna2|LDODgold|LDODheart|LEL|LHead|LIFERING|LIS_Arrow|LIS_PolaPhoto|LIS_PostCard|LIS_brush|LIS_butterfly|LIS_flower|LIS_pixel_heart|LIS_poker_face|LIS_star|LLTFrog|LLTGoggles|LLTOwl|LLTRowRun|LLTRun|LLTScarf|LOG|LQuote|LRepair|LString|LTTR|LVictory|LaRoche|Lacerator|LadyScissors|Lancer|Landed|LaserBeam|LaserShip|LastStar|Laura|LazarustheLizard|LazerBird|Lee|Leecher|Legionnaires|Lenin|LeonRE4|LetMeFixThatForYa|LetsSing|Letter|Library|Lich|Lick|LifeLeech|Light|Light1|Light2|Light3|Light4|Light5|LightBlueCube|LightRedCube|Lightning|Liich|Lili|Lilith|Lilly|Lillywizard|Limb|Lips|LiselotCute|LiselotQuirky|LiselotSad|Litchi|Litho|LittleDizzy|Livelikeitwasyourlastday|LoadEmoticon|LoaderCoveringFace|Logo|London|LongBlah|Longship|Lord_Fist|Lord_Rune|Lord_Shield|Lore_ESO|Lotus|LotusFlower|LoveHearts|LoveLife|LoyaltyGhost|Luana|LuauLarry|Lucifer|LuckyFaust|Luminos|Lump|Luna_Emoticon|Lunar|LunarStrength|Lur|M2H|MA02|MA06_1|MA06_2|MA11|MD4|META|MHLK|MONTA_RAKA|MONTA_SHAUT_RASKE|MSM|MSparta|MT|M_Pneuma|MachoMan|Mad|Maddyson|Madness|Madness_Medal|Madness_Star|Magnum_GGC|MajorNinja|MakotoGGN|MalvaEmoticon|ManaOrb|MandaTheDragon|ManufacturingBot|Map_Arrow|Maray|MarinaSeminova|MarkSkid|Marmalade|Marsh|Marsmole|Mashiba|Masquerade|Masqueraded|MassiveHam|MasterGhost|MataHari|Mature|Maul|MaxDamage|McKillin|Meat|MechSkull|MecinniEmoticon|MedHypo|MedPill|MediKit|Mediator|Medics|Melinda|MercyGhost|Merrilee|MilitaryBomber|Milla|Mimic|MindControl|MindEye|Mine|MineField|Mines|MinionAlien|MinionPig|MissIon|MissileLocked|Moga|Molag|Mole|Molotov|Moneybag_GGC|Monface|Moo|MoonRaker|Morale|MorningStar|Morry|MotoRider|Mouthless|MrFoster|MrOwl|MrPigeon|MrSkull|MrTree|Mstar|Multi|Multipass|MusicBox|Mustachebrows|Mysterious_emblem|N|NATO|NATO2|NA_Castle|NA_Flag|NA_Head|NA_Military_Leaders_Fan|NA_Officer|NA_Soldier|NA_Soul|NC|NETHER|NOTES|NOX|NZA2_Eagle|NZA2_IronCross|NZA2_Pentagram|NZA2_TombStone|NZA2_Zed|N_Pneuma|NannyBrown|Nanu|NaziUfoLeft|NaziUfoRight|Neapolitan|Neko|Neko|NekoKiss|NekoMoto|NekoSkate|Nell|Nepgear|Nervousfly|NeverGiveUp|NewZombie|NiGHTS|Nicez|NightWatchman|NinjaHappy|NinjaLove|NinjaSad|NinjaShuriken|NinjaSmoke|NinjaText|NitroBC|NletterNKOA|No1|NoHeartsForYou|NoPants|NoVision|Noah|Noel|Nor|Norse|Northmen|Nosgoth|Nurse|Nussoft|Nutcracker|Nyanbear|O|OGCrosshair|OGMech|OGOA|ORAN|ORIGINAL|OTTTD_Boom|OTTTD_Rockon|OTTTD_Shark|OTTTD_Skullcracker|OTTTD_TalkHand|OXYTANK|Oblivion_Flower|ObserverSad|Obtainium|Oda|Odin|OfficerDoughneaux|OhMyGold|OhNo|OhNoBlue|Ohdeer|Okami|OldGiant|OldHagWitch|OldOne|OmaniHelm|OmaniIcon|OmaniSeed|Omega|OnFire|OnThePhone|Oneeye|OnigiriFace|OnlyADrill|Opener|Ophelia|OptionA|OptionB|OptionC|OrangeNVAPin|OrangeSurprise|OrangeVCPin|OrbGetMage|OrbGetThief|OrbGetWarrior|Orb_Gem|OrbitalLaser|OrcHero|OrcSlayer|Original_Assassin|OrkHead|OscillatingShip|Oscura1|Oscura2|Oscura3|Oscura4|Oscura5|Outland_Dark|Outland_Light|Outland_Spider|Owl|Owls|Ozgur|P|PADDLE|PISORF|PNUTbomb|POBX|POW_PANTS|PRCL|PROMOTE|PS2|PSchain|PSdivine|PSfire|PSheart|PSice|PSpotion|PSring|PStreasure|P_Pneuma|PacificSkiesAce|PacificSkiesCaptain|PacificSkiesFighter|PacificSkiesMissionLeader|PacificSkiesSquadLeader|Page|Pain|PainH|Pal|PandoraGroovesnore|Panic|Panzer|Pappas|Paralysis|Paran|ParticleShip|Parvus|PawnshopBot|Pax|Penguin|Pentagram|Peril_ESO|Perseverance|PersonRune|Peter|Pew|PhantasmalEye|PhotonShip|Physics|Piccolo|PickupRocket|PickupUzi|Pidgeon|Pig|Pigeon|Pills|PineappleGrenade|PinkContent|PinkCube|PinkMitten|Pirate_Skull|Pitter1|Pitter10|Pitter2|Pitter3|Pitter4|Pitter5|Pitter6|Pitter7|Pitter8|Pitter9|Pixel|PixelBlob|PixelBunny|PixelDeath|PixelFruit|PixelHardcore|PixelHeart|PixelMegaHardcore|PixelProfessor|PixelRobot|PixelSupercore|PixelTeeth|PixelartAmanita|Pixelartflame|Pizza|Plaidshield|PlanetYelaxot|Plans|PlantBot|PlasmaClip|PlasmaMod|PlasticExplosive|Poison|Polystralia|Pooop|Poring|Pork_Bun|Porridge|PortalRune|Pot|Potatoman|PowerMag|Power_Crack|Power_Phantom|Praxis|President|President_Eagle|Pressured|Princerupert|PristineTeddy|ProfMaple|Pulse|Pulse|PulseRifle|Punchicken|Punching|PunishedAlien|PurpleRider|Purple_Stone|Q|QBirdy|QFatty|QLeggy|QNecky|QThirsty|Quanton|QuantonsMinion|QueenBee|Queenie|Queens|Quilly|Quinten|R|RA_KUNS_SHAUT|RA_MONKESRATA|RA_RANTOSKE|RGP2|RGP2confuse|RGP2dead|RGP2love|RGP2sweat|RGnightmare|ROCKET_LAUNCHER|RPGMage|RPGTree|RPGTycoon|RR|RTFB|RTeam|RUGAL|RUSflag|Ra|Rachel|RadarIcon|RadioCallIn|Ragerider|Ragna|Raider|RainbowUnicorn|Ralph|Rambois|RandomSkull|RareSmile|Rasheed|Rasta|RavenForm|Ravenous|RayneHead|RaynePendant|Raz|RbLivia|RbLog|RbMenu|RbPower|RbWait|ReclusiveCowboy|RedArmordZombie|RedBaron|RedBird|RedChainsaw|RedGoblin|RedMagic|RedMitten|RedNVAPin|RedStar|RedTalisman|RedVCPin|Redalien|Redbmbr|Redshuriken|Reflex|Regen|Remember|Repair1|Repeatski|Repel|Replenish|Research|ReviveIcon|Rex|Ribbon|Rin|Ring|Rings|Rival|RoadSplatter|RobotRosie|Robots|Robster|Rock|RockCrystal|RockSasha|RockSkull|RockVinyl|RockZoe|RocketGNZ|RocketKnife|Rockout|Rockstar|RockwellYoungXJ9|Roedeer|RogueChallenge|RogueChicken|RogueIncoming|RogueMimic|RogueMoneybags|RollingPin|Roman|RomanShield|RookieEmoticon|Roth|RottenEgg|RottenMeat|Rottendonut|RoundShield|RoverEdison|Roy|RoyalDragon|Royalty|RubChick|Rubber_Duck|RubricEvidence|RunnerTraveler|Rusty|Ruvik|RyoHazuki|RyseBlood|RyseCoin|RyseHelmet|Ryu|SA06|SA07_1|SA07_2|SA08|SA10|SBHorse|SBchicken|SBmm|SBpanda|SBpenguin|SDOGlutton|SDOProjector|SDOPulsor|SDORainbow|SDOShooter|SD_HakuMen|SD_Hazama|SD_Lambda|SD_Makoto|SD_Mu|SD_Nu|SD_Platinum|SD_Relius|SD_Tsubaki|SD_Valkenhayn|SFCow|SFMoon|SFPig|SFSteve|SFThomas|SFvictory|SHIPWHL|SIDEARM|SJW|SMHead|SPRING|SRCBL|SRank|SS|SSWbadmood|SSWhappy|SSWspeachless|SSWsurprise|SSWwink|STARFSH|STNT|SUNNY|SV00|Saboteur|Sachiko|Sacked|Sacred_Book|SadBot|SadChompy|SadDog|SadRoehm|SadSkyhammer|SaddenedRobot|Sadfly|Saevar|SafeForWork|Safe_House|SafetyFirst|Saki_Emoticon|Salem|SaltyHam|Salvation|SammyTheBrother|Sanddragon|Sandsymbol|SandyOhh|SandySmiling|Sapper|Sasha|Sashawizard|Sass|Satelite|Savior|Saxon|ScalesMonster|Scanner|ScaredChompy|ScaredRobot|Science|Scientist|Scissors|Scream|Scroll|ScytheofDeath|SeamusHappy|SeamusHurt|Sebastian|Segment_Attack|SentenceSplitter|Sentiment|Serif|SeriousDog|SeriousSparks|SettingsSpanner|ShadowWarrior|Shadowstalker|Shallow|SharSeth|SharkTooth|Shattered|Sheep|Shiau_Yu_Darkness|Shiau_yu_Sad|ShibuyaGGN|Shielded|Shields|Shieldy|Shingoh|ShinjukuGGN|Shinra|Shinse|ShinyHeart|Ship1|Ship2|Ship3|ShipAlien|Shipyard|Shiv|ShmobBomb|Shmobs|Shoot|ShortSword|ShotGun_Weapon_Item|Shouted|Showdown|ShurikenStar|ShutTFU|Shy|SidMeiersAcePatrolAce|SidMeiersAcePatrolCaptain|SidMeiersAcePatrolFighter|SidMeiersAcePatrolMissionLeader|SidMeiersAcePatrolSquadLeader|Siege|Silence|SilverOrb|SilverSword|SisterRam|SisterRom|Skate|Skeezick|SkeleSkull|Skeleton|SkeletonHead|SkeletonWolf|Skelleton|Skillz|SkullCarma|SkullPin|Skullo|Skulltat|SkullyBones|Skunk|SleepingDuck|SleepyBot|SleepySion|Slinki|Sloomba|SlyNinja|SmartAss|Smash|SmileyRoehm|Smilin|SmilingGirl|SmokingChair|Smoosh|SmugBushwhacker|SmugRob|Snakey|Sneaky|SneakyBait|SneakyChest|SneakyRuby|SneakySlime|Sniper|SniperBullet|Sniper_Binoculars|Snorkel|SnowCrab|Snowman|SnuggleTruck|Snuke|Sob|SoccertronBall|SocialPolicy|Sock|Sola|SolarSun|SoldierBee|SonCarrot|Song|Sophia|Sorata|SorcererFrog|Sorcery|SoulDagger|SoulMate|SoulToken|SoulWell|Soulscreamer|Sound|SoundsCreepy|SpaceRocket|Spacebucks|Spaceman|Spades_Gem|Spanner|Sparring_Partner|Special_Lilith_Emoticon|Spectra|SpectraII|SpeedEmoticon|SpeedPin|SpeedRunner|Speed_Bag|Spidey|Spidy|Spirit|SpiritFeather|SpitterAlien|Splat|Sprint|Squirrels|Stab|StabbySword|Stalker|Starcrossshield|StarvationSmile|StarwhalBlue|StarwhalGreen|StarwhalIcon|StarwhalPink|StarwhalYellow|Station|Steady_Aim|StealLife|Stealth|StellarMine|Stick|Stick_TNT|StopWatch|StrandedMap|StrengthGNZ|StrikeDamage|StrikeVector|StrykerRetsu|StrykerZero|StuffBox|StunJacks|Submachinegun|SunIsLife|SunShip|SunriderBird|SuperCollectable|SuperSkimoWorld|SuperSonic|SurpriseDog|Surrender|SurveyorTraveler|Survivalist|SwagBag|Swallow|Swarm|SweatDrops|SweezyBoglin|SweezyCaticus|SweezyClown|SweezyGoldBag|SweezyGunner|SweezyPapers|SweezySlime|Swimmer|Switcher|Switcher|SwordSkull|SwordsofEdo|SystemConfirmation|T|TB|TBbubble|TEDDY_BEAR|TFammo|TFdollar|TFgold|TFgrenade|TFhand|TFhappy|TFhealth|TFskull|TFvhs|TFyousonofa|THEBITTRIP|THE_WIND_MASTER|THUNDER_SHERMIE|THeart|TKchest|TKorc|TKskull|TNTBox|TOanchor|TOcreditcard|TOdice|TOfuel|TOletter|TOmagnifier|TOspeed|TOsteeringwheel|TOwarning|TOwrench|TP|TP_Exit|TP_Grey|TP_Jupiter|TP_Key|TP_KeyMaster|TPmage|TProgue|TPwarrior|TR|TRAK|TR_Crosshair|TR_E|TR_I|TR_M|TR_T|TWDog|TWGoldBorg|TWLpyramid|TWSoldier|TWTedHead|TWThug|TWTurtle|Tager|TalProAssassin|TalProDruid|TalProMonk|TalProPriest|TalProProphetess|TalProToad|TalProTroll|TalProWarrior|TalismanCrown|TalismanDwarf|TalismanElf|TalismanGhoul|TalismanMinstrel|TalismanSorceress|TalismanThief|TalismanWizard|TalkToTheHead|Talmage5008|TalonLeader|Tammy|Tamvaasa|TankYouMate|Taokaka|TargetAcquired|TargetDummy|Teddy_Drink|Teddy_Exit|Teddy_Laugh|Teddy_Photo|Teddy_Prize|Teddy_Walk|Teddy_closed|Teddy_paintBrush|Teddy_pencil|Teddy_take|Teddy_talk|Teddy_up|TelePin|TeleportationFairy|Television|TempuraFace|Tentacle|Terminator|Terra|Terramus|Terror_ESO|Tesla|Tesla_GGC|ThatSmellsFishy|TheBat|TheBear|TheBee|TheBlues|TheBureauAlien|TheBureauEagle|TheConceptOfEli|TheCrease|TheCrusader|TheD|TheDevil|TheEagle|TheFall|TheFish|TheFlower|TheGrimReaper|TheHand|TheHolyHandGrenade|TheHydra|TheJetPack|TheKeys|TheKingsHead|TheKnocker|TheLadybug|TheMajor|TheMercenary|TheRooster|TheShark|TheSkunk|TheTommySpecial|TheTurtle|TheVillager|TheWitch|TheWorm|The_Clans_Sakura|The_Program|Thor|ThorHammer|Tie|Timeglass|Timid|Tina|Tiny|Tired|Toad_Item|ToasterRepair|Tom|Tombstone|Tone|Tonic|Tools|ToolsOfDestruction|TopQuark|Top_Secret|Tophat|Torpeagle|Tortise|TotemRune|ToughEnough|Toxic_Geralt|Toxo|Traction|Transparent|TreasureC|TreyAngry|TreySurprised|TriRune|Triad|TriangleAttract|TriangleRepel|TrinityEye|Trinket|TripleSword|Trophies|TrophyCup|Trunkss|Trust|TryAgain|Tsubaki|TtMrabbit|TuffLaughing|TuffSurprised|TunaCan|TunaSandwich|Turkey|Tybalt|Type2|UK|US|USArtillery|USCap01|USCap02|USCavalry|USGeneral|USInfantry|USSR|USSkirmishers|USstar|UT2004adrenaline|UT2004flak|UT2004health|UT2004shield|UT2004udamage|U_Pneuma|UglyBaby|Ultimate|Ulukai|UmbrellaLogo|Uncle_Joe|UncommonSmile|UndeadBow|Undefeated|UnhappyMask|UnhatchedEgg|Uni|Unic|UnionJackFlag|UniversalLove|Upgrade|Upvoter|Uranium|Uthuk|Utsuro|VC_ENGINEER|VC_LANCER|VC_SCOUT|VC_SHOCK|VC_SNIPER|VC_TANK|VS1|VString|VacBot|Vagrant|Vale|Vammpyre|VampireInsignia|VampireKiller|VampireTongue|VarrSmile|Vegeta|VeggieWater|VeneticaGoldCoin|VeneticaHammer|VeneticaMoonblade|VeneticaRaven|VeneticaSkull|VenexianaStevenson|Veritas|VictoryPoint|Vitalism|Viviane|Vivianne|Void|VolgarrChalice|VolgarrCoin|VolgarrCrown|VolgarrNecklace|VolgarrWalrus|VoxBomb|WEYTWUT|WFBlackwood|WFEngineer|WFMedic|WFRifleman|WFSniper|WGoldCoins|WHEAT|WHouse|WONAFYT|WRULAT|WShield|WWBackpack|WWBoom|WWCrowbar|WWFAK|WWGasmask|WWMissile|WWPK|Wah|Walkman|Wand|WarSmile|Warface|WarmFuzzy|Warning|Warrioress|Watch_Thief|WaterBeetle|WaterBottle|WaterSpider|Weapon|WelderSpark|Well_Done_steak|WereWanda|WetRider|WheelOfAges|WheelchairKey|WhiteHarmfulMonster|WhiteHorse|WhiteMagic|WhiteSword|WhoahRob|WildShade|Wild_ESO|Windmill|Wing|WingSuit|WingedChest|WinkingRoehm|Winston|Wisp|WooDoo|WoodAxe|Woodbot|WordsForEvil|WorkGNZ|Workers|Wormhole|WosonBoson|Wre|Wreath|Wriggler|X|XBones|XMen|XX|XenoA|XenoE|XenoP|XenoT|Xenonight|Xie_Smile|Xinghua|Xiphos|Y|YTeam|YelaxotCat|YelaxotCow|YelaxotDog|YelaxotFish|YelaxotFrog|YellowCube|YellowMitten|Yellow_Stone|Yoru|Yuan_de_Sinister|Yuan_de_angry|Yui_Emoticon|Z|ZAT_Correct|ZAT_Pentagram|ZAT_Relic|ZAT_Safe_Room|ZAT_Skull|ZAT_Zombie_Heart|ZK1|ZX|Zayten|Zebra|ZenRider|Zeus|ZigZag|Zoeds|ZomNom|Zombeer|ZombieBrain|ZombieFace|ZombieHeart|ZombieKey|ZombieScream|Zombiezz|Zommbie|Zoroaster|ZosonBoson|_banana_|a2|a5m|a_suite_of_parisienne_apprentice|aa|aa_goblin|aa_rogue|aa_rogueface|aa_skeleton|aagunner|abc|abobo|abomb|abominable|abomination|abs_birdfly|abs_birdsit|abs_happy|abs_surprised|abs_zzz|abstraction|abumm2|abuskull|abyssalthrone|acbutterfly|accat|accepted|acduck|acheronshield|acid|acleap|acorn_pickup|actime|ada|adam|adamantine|adambane|administration|adol|adoma|adoroo|advent|advz_orc|advz_skelly|ae_amandamite|ae_gem_planet|ae_metal_planet|ae_normal_planet|ae_organic_planet|ae_ship_engines|ae_technology_planet|aemaster|aeoncivilian|aeondrone|aeonhauler|aeonsapper|aeonscience|aeos|aeroplane|aether|aethercoin|aethernet|aetherup|afraidkobold|after|agathacross|agathalion|agent|agis|agwkey|aha|ahcoachman|ahdetective|ahh|ahmed|ahomeplanet|ai|ai_boost|ai_flare|ai_fuel|ai_gyro|ai_repair|ai_wormhole|aid|ailish|aimedshot|aiming|aiprogress|air_rune|airbane|airforce|airmech|airmine|airplane|airstrike|airwolf|akaeye|akalogo|akalord|akanegoro|akaneheart|akanepow|akaneshoot|akaoni|akemi|akio|akop|alahanbow|alahanshield|alarm|alas|albedobball|albedobeer|albedoeye|albedofisherman|albedoscientist|albedosnail|albedothumbsup|alchbottle|ale|alert|alessandro|alexandre|alfiebanks|algeiranpassport|alicemushroom|alicia|alien|alien2|alienadviser|alienegg|alienhive|alienlogo|alienmouth|alienskull|alient|alientoy|alizard|alkat|alliance|allied|alliedbridge|alliedstar|allweather|alpen|alphahero|alphastriker|altar|altefoor|alter|alteration|alterbat|alterdog|alterdoor|alterguy|alterpup|alterram|altersoul|alvin|alwayschicken|alyx|amadeus|amadeus2|amarr|amazedcyto|amazedhitomi|ambition|ambrosia|ame|amethyst|amethystdust|ami|ammo|ammobelt|ammocrate|ammofist|ammunition|ammut|amnesia|amoon|ampersand|ampoule|amu|amyWhat|ana|anarky|anchor|ancientcoin|ancientmask|ancientspell|and|andend|andmyaxe|andy|angel|angelic|angelrobbe|angravi|angry|angryCP|angryEye|angryEyes|angry_cell|angry_creep|angry_sign|angrybox|angrycrank|angrycubelet|angrydante|angryduck|angrydwarf|angryeets|angryfaic|angryfairy|angrygomo|angryjack|angryjeff|angrykit|angrykol|angryleon|angrymud|angrymummy|angrynerd|angryofficer|angryoleg|angryowl|angrypirate|angryreddragon|angryshank|angryskull|angrytiger|angrytitan|angryvillager|angryworm|angryworm|angryz|anhel|anhk|animalbones|anisoptera|annakey|annamask|annihilation|annihilator|annoyedking|anonbishop|ant|anthony|antigravi|antipiracy|antiquark|anvil|anxiousterry|aofarmor|aofbeer|aofblade|aofbless|aofbook|aofbow|aofdef|aofdemon|aoffire|aofhero|aofice|aofmed|aofpotion|aofring|aofshield|aofsummon|aofsword|aofwing|aoichan|apafrog|apencil|aphid|apollo|apothekineticist|apple|applesauce|apprentice|apprenticehead|approve|approved|apteka|aptkey|aquaman|arachnid|arachnidleviathan|arachnoid|arachtoid|aran|araven|araym|arc|archer|archerflea|archerrat|arcsd|arcticfox|ares|aresex|arethielves|areusureaboutthat|argh|argus|arise|aritanasheart|ark|arkane|arkback|arkbag|arkburguer|arkdog|arkfall|arkgears|arkham|arkhamsymbol|arkseed|arksphereon|armageddon|armor|armorbreaker|armorer|armour|armpump|arms|armwave|army|arr|arrest|arrey|arrow|arrowdown|arrowleft|arrowright|arrows|arrowup|arson|arther|arthur|artifact|artificialintelligence|artifire|as|as_elisa|as_evan|as_jackie|as_natasha|as_russell|as_tori|as_troy|ascboss|asciiterror|asgdead|asghero|asgray|asgrose|asgxp|ashraze|asonewestand|aspect|assassination|assault|assist|asskicker|ast|asterisk|asteroid|astron|athena|athenadsc|atk|atlas|atom|atomic|atsgandalf|atsheap|atsmusicbox|atspendant|atsteddy|attack|atten|attention|audioreel|august|auriel|aurora|autumn_leaf|av|avdrone|avegg|avgn|avgnmad|avoid|avoidfreeze|avoidghost|avoidmap|avoidshield|avoidstar|avoidtime|avsnail|avsyringe|awakesheep|award|awarddsc|awesome|awetobot|awkward|ax|axe|axe_dyl|axekiller|axesword|axis|axisfountain|azon_jewel|azra|azriel|azuki|azumi|azurite|b|b2b|baa|babelfish|baboom|baby|babyboy|babygirl|backpack|backpack_large|bacon|bad|badWulf|badass|badbarrett|badbear|badcat|baddie|baddy|badge|badger|badgercoin|badgership|badguy|badninja|badplant|badrats|bag|bagFace|bagelhead|baghat|bagofgold|bagofmoney|bahamut|bait|bakal|baker|balaz|bald|baldwin|ball|ball8|ballista|ballistic|ballnchain|balloon|balloonicon|balloonicorn|balloons|balon|baloon|bam|bamboos|banana|bananahammock|bananas|bandageC|bandages1|bandit|bane|bang|bang2|banner|banshee|barbarian|barberscrest|barbpole|bardbacon|baron|baronsoldier|barrel|barreloffun|barrier|barry|base|baseball|baseball16|baseballdiamond|baseballdiamond16|baseballglove|baseballglove16|basedisco|bash|basicturret|basketball|bass|bat|bat16|batarang|batbrick|baterry|bathtub|batlogo|batman|baton|batsilo|batsymbol|batteringram|battery|battleaxe|battlefield_earth|battlefleet|battleship|bawk|bbabsmily|bball|bbamsmily|bbat|bbbb|bbomb|bbtcat|bbtduckshark|bbtgem|bbtraccoon|bbutcher|bcandy|bccat|bcfrank|bchild|bcjosie|bcloak1|bcube|bdjoey|bdoug|bdrosa|be_bad|be_crazy|be_crosshair|be_good|be_medium|beachball|beacon|beam|beamer|beamhit|beancharacter|bear|bear_sigil|bearmm4|bears|beartoise|beary|beast|beatbuddy|beatingheart|beatmeat|beatnote|beatpaddle|beatricemad|beconfused|bed|bee|beehat|beeper|beer|beercan|beermug|beers|beetle|beginners|behappy|behemot|behemoth|behind|beholder|beignet|belephant|bell|belleball|bellebelle|belledad|belleluc|bellemacfae|belletour|bellkiller|belt|ben|benchandler|benny|benoitmm1|benoitmm2|beralien|beret|bernice|berry|berserk|berserker|besad|bestfriend|beta|betalord|beth|bethlehem|betsy|beverysad|bewilder|bf109|bfacid|bfbomb|bfcannonball|bfcluster|bff|bflower|bfmagma|bfmagnet|bfmask|bfstone|bfwood|bgs_angry|bgs_chimera|bgs_hurt|bgs_joking|bgs_sad|bgs_serious|bh|biff|biffyghost|bigGrin|big_lock|big_sunflower|bigbang|bigbee|bigboom|bigboss|bigbrute|bigchest|bigemerald|bighead|bigheart|bigkiss|bigpig|bigpink|bigred|bigship|bigsmile|bigstuff|bigsword|bigtop|bigups|bik|bikini3s|bill|billy|billybot|billylee|bino|bio|biohazard|biohazardsign|biolojoe|bird|bird1|birder|bishop|bisondelta|bisous|bit_zombie|bite|biteme|biter|bitly|bittrip|bittripcore|bittripvoid|bkey|blablabla|black|blackbeardchest|blackcoffee|blackdress|blackduck|blackhair|blackhole|blacklotus|blackmask|blacksheep|blackspot|blacksuit|blacktile|blade|bladeship|blam|blanc|blanky|blarg|blaser|blast|blcengineer|blcharbinger|blcnomad|blcpsychopomp|blcravener|blcseeker|blcstalker|blcthorn|bldemon|bleach|bleak_spirit|blech|bleedingheart|bleedingheart1|bless|blessed|blgirl|blight|blimp|blind|bling|blingbling|blingwrench|blissful_creep|blitz|blob|blobfromspace|block|blockade|blocked|blockhead|blockmongler|blockshield|blocky|blondiemm5|blood|blood_sign|bloodangel|bloodhan|bloodhand|bloodheart|bloodlife|bloodman|bloodsplat|bloodsplatter|bloodstain|bloody|bloodyfinger|bloodygoldpiece|bloodymary|blooming|bloop|blotworx|blowfish|blowup|bloxbot|blr|blrno|blrosa|blryes|blue|blueFlowerNKOA|blue_gem|blue_jewel|blue_spikes|blue_spirit|blueberry|bluebird|bluebox|bluebtn|bluebutterfly|bluecrystal|bluecube|bluecubot|bluediamond|blueduck|bluefox|bluegel|bluegem|bluelaser|bluelightorb|bluemana|bluepad|bluepage|bluepill|bluepix|blueplanet|bluepolyball|blueporc|bluepot|blueprint|bluepunch|bluerose|blueshield|blueslimebeast|bluesnakebird|blueteam|bluetri|bluewizard|bluezombie|blugem|blunderbuss|blush|blushterry|blute|bmbr|bmp1|bms|bms_crowbar|bms_headcrab|bndage|boar|boat|bob|bobeyes|bobfortress|bobslime|body|bodybuilder|boe|bogfrog|bok|bokbok|bokdenmm4|boldg|boldly|bolo|bolt|boltgun|bomack|bomb|bomb2|bomb_boom|bomba|bombard|bombbox|bombclaw|bomberrat|bombfuse|bombie|bombproof|bombs|bone|boned|bonehead|boneleton|bones|bonesdsc|bonesmm1|bonesmm2|bonesmm3|boney|bonfire|bonus|boo|boobunnyplague|book|books|boombaby|boomboomboom|boombot|boombox|boomcrate|boomer|boomerang|booom|boot|boots|booze|borderlands2|bored|borntokill|boron|boryo|boss|bossflame|bossred|bot|botchanger|bottle|bounce|bouncer|bouquet|bout|bow|bowandarrow|bowfinvalkyrie|bowtie|bowyerhead|box|box1|box2|boxball|boxing|boxwagon|boxy|boycry|boyking|bpcharge|bpcharge|bpecow|bpegrave|bpehay|bpemartian|bpenguin|bpeninjalog|bpescape|bpfist|bpflash|bpflash|bpgreen|bpheal|bpheal|bphealt|bphere|bphero|bpkey|bpquest|bpred|bpregeneration|bpskull|bpswim|bpswim|bpvitality|bpvitality|br_bubblegum|br_confused|br_cool|br_cry|br_love|br_mad|br_sad|br_shock|br_smile|bracelets|bradface|bradtackle|brain|brainjar|brainwave|brand|brarrow|brave|bravedoll|bravery|bread|breadstick|break|breakbone|breakdown|breakhip|breakrib|breaks|breakskull|breakspine|breeder|brentconfused|brfire|brflash|briarwood|brick|brickdevil|brickfawkes|brickman|brickmonster|brickskull|brickzilla|bridget|brig|brightidea|brightsmile|brigid|brknife|bro|broadaxe|brochubbs|brofist|brokeball|brokeneye|brokenheart|brokenshield|bronco|bronzemedal|bronzer|brownbear2|brownegg|brownmana|brshield|brucelee|brush_icon|brutaldeluxe|brute|brutus|bryda|bryhild|bsa|bsbullet|bschar|bsduke|bsearth|bsgrenade|bsgun|bsod|bsressources|bsskull|bsterritory|bsthunder|bsvbadge|bsxbadge|bsym|bteddy|btiki|btr60|bubble|bubbledot|bubbles|bucket|buckler|bucks|buckshot|bucky|bud|buddhist|buddhistsymbol|buddy|buddy_boulder|buffoon|bufforpington|bug|buggy|bujoey|buki|bulauren|bull|bullet|bulletproof|bullets|bullseye|bully|bullypower|bumper|bun|bundleofjoy|bundleoftulips|bunker|bunnyguitar|bunnyon|buoy|burden|burger|burgertime|burgerz|burgzone|buried|burke|burned|burnedsaw|burnov|burns|burnthemall|burntworld|burst|bus|bush|bushfire|butterfly|butterflyfish|butterflymm1|button|buzz|buzzsaw|bw|bwcookie|bye|byjove|byplane|byte|byteme|bytetrail|c|c3dlegs|c4charge|c98|cabinet|cacti|cadet|cadventure|cage|cageclosed|cagefly|calc|caldari|caligula|calltoarms|calm|calm_creep|calmqueen|cambot|camel|camelface|camp|camper|campfire|campfireonfield|canadian|cancel|cancer_dyl|candidLemonTea|candles|candy|candybar|candycane|candycorn|candyman|cane|cannon|cannonball|cannontower|canopyflower|cap|capitalist|capsule|capsuling|capturedsystem|car|carbon|carbonjames|carbuncle|card2|cardback|cardfate|cardsoldier|cargo|carkeys|carkill|carol|carrier|carrot|carrotman|carrying|carson|cartax|cartooncow|cartridge|casette|casey|cashcow|cashguy|cashsplash|casinochip|cast|caster_happy|caster_mad|caster_sad|caster_shock|caster_wink|cat|catapult|catapultic|catapultry|catblood|catenvelope|caterpillar|catkin|catlateraldamage|catmace|catmug|catnap|catpaw|catpesticide|catpuzzle|cats|cauldron|cavalryussr|cavebrute|caveguard|caveman|cavemonster|cavespider|caw|cb|cball|cbandit|cbhunter|cbox|cbturret|cc3dblinky|cc3dbluegolem|cc3dbouncer|cc3dnibbles|cc3domni|cc3dscreamer|cc3dsnappy|cc3dwhoop|cc3dyellowgolem|ccane|ccbandit|ccgold|cchearts|ccknight|ccmine|ccoin|ccrbolt|ccrcoin|ccrgoldkey|ccskull|ccwarrior|cdoug|cedar|celestia|celestialteapot|cell|centralunit|ceo|ceodore|cerberus|cfacepalm|cgpout|cgrazz|ch|chain|chains|chainsaw|chair|chairman|chalice|chalk|challenge|challengeicon|challenger|challengespears|champ|champbelt|chaos|chaosaxe|chaossymbol|chaostool|charge|chargepack|charger|charlie|charm|charming|charmofclouds|charmoffire|charmofsnow|charmofwater|charmspell|charnel|chartreuse|chase|chasseur|chat|chatterbox|check|checkeredflag|checklist|checkmark|checkmate|checkpoint|cheeeese|cheeky|cheepy|cheer|cheerful|cheers|cheese|cheeseburger|cheesechunk|cheeseslice|cheez|cheezy|chef|cheffie|chefknife|chemical|cheritzCherry|cherries|cherry|cherrydonut|cherrypie|cheshire|chess|chessking|chessknight|chessqueen|chest|chester|chestkey|chesto|chewer|chick|chicken|chickenleg|chickenwings|childghost|childhood|chilipepperknight|chillies|chimera|china|chinatsu|chinesedragon|chipofftheblock|chippy|chiquita|chirp|choccoin|choco|chocobo|chocochip|chocola|chocolate|chocolatestone|choke|chokeychicken|choppa|chopyouup|chris|christian|christian2|christine|chromed|chrysotile|chubb|chunk|ci3chicken|ci3chickeneaster|ci3chickenxmas|ci3easterbunny|ci3splat|ci4burger|ci4chicken|ci4droid|ci4egg|ci4feather|ci4football|ci4invader|ci4key|ci4leg|ci4roast|ci5bubble|ci5corn|ci5earth|ci5hensolo|ci5icbm|ci5minigun|ci5popcorn|ci5safebox|ci5spaceship|ci5trophy|cid|cidtay|cigar|cigarette|cigarettes|cindersskull|cinnamon|circle|circuspeanut|citranium|citric|city|civil_clothes|civilwarsoldier|ckchest|ckcrate|ckeye|ckjack|cktnt|ckwormbody|ckwormbutt|ckwormhead|clap|claptrap|clargun|clarity|classicfiredrake|classicreaper|claugh|claw|claygear|clean|cleapipe|cleaver|clef|clementineelf|clements|cleric|click|clickbutton|clip|clock|clockstopper|clocktime|clocktower|clockwork|clonecc|cloon|clorm|closedeyes|closetgamer|cloud|clouddragon|clover|cloveralexia|clown|clownfish|clownghost|clownhair|clownmouth|clownraider|clscoutos2u|clubmarq|clubshield|cluck|clue|clueless|clunk|cluster_grenade|cmd|cmdr|co2|coach|coach2|coalspark|cobalt|cobrastan|cocktail|cocochan|coconut|coddog|codeeye|codezoe|codknife|codskull|coffecup|coffee|coffeebreaktime|coffeecup|coffeeguy|coffeethermos|cog|cogwheel|cogwheel2|coin|coindlc|coinface|coinpurse|coinstack|coinz|coldone|coldwarwarrior|collectible|collection|colon|colonist|colonize|colony|colonylove|colorbars|colorlessfaerie|colorwheel|colossus|colt|column|combat|combine|combokill|comeatmebro|comeon|comet|comic|comica|comicc|comick|comicr|comicw|commander|commandericon|commandervideo|commandgirlvideo|commanding|commandmajor|commando|commandobot|commie|compa|companion|complanet|computer|con_bishop|con_eye|con_knight|con_peace|con_rook|con_shield|conductor|coneanimal|confedflag|confident|confuse|confused|confusionmm4|conquistador|construktor|consuela|content|controller|conveyorblock|convoybolts|convoybuggy|convoyfuel|convoymines|convoyshell|conwayfacepalm|conwayheadscratch|conwaypunch|conwayshrug|coo|coocoo|cook|cookie|cookie1|cooking|cool|coolbaddie|coolchicken|coolchickenshoot|coolcubelet|cooldown|coolfu|coolgomo|coolgrin|coolmonkey|coolness|coolrocket|coolrom|coolsam|coolsmile|coolstuff|coolthulhu|cooltoilet|coolunicorn|coop|cootcoot|copaxe|copbomb|copfreeze|copgun|copsaw|copter|copterHat|corblimeyguvnor|core|corerainbow|coretext|corgan|corinthianhelmet|corn|corncan|cornet|cornstalk|cornucopia|coronet|corpangry|corporate|corporatebranding|correctamundo|corrin|corruptedworld|corsairs|cortex|corvette|coryool3s|cosmoglitch|cosmogun|cosmonaut|cosmorobot|cospolitagirl|cottagekey|councilguard|countess|counting|cover|cow|cowboyhat|cowcredits|cowpig|cowskull|crab|crabchef|crabclaw|crablet|crackedball|cracker|craftgoblin|crafting|crane|cranewagon|cranium|crash|crashedlander|crashtest|crate|crawl|crayon|crazy|crazyleon|creature|credz|creedy|creep|creepy|creepy_girl|creepybug|creepysheep|crimewatch|criminal|crimson|crimsonheart|crimzonbullet|crimzonstar|crispin|cristal|critical|critter|critterbig|croc|crocodilesmile|croix|cross|crossb|crossbones|crossbow|crossh|crosshair|crosshairbush|crossx|crow|crowbar|crowmance|crown|crowndown|crownofpower|crownofthedamned|crowntrap|crownz|crowsh|crt|crucifix|cruncher|crunchy|crunchychick|crusader|crusher|cry|crybaby|cryfox|cryingacan|cryingcubelet|cryingmarcus|cryingrika|crykit|cryst|crystal|crystaldeposit|crystalized|crystals|crystalsrule|crystaltrophy|crystl|cryx|cs2atk|cs2death|cs2def|cs2mag|cs2sleep|cs2spd|cs_axe|cs_crown|cs_knight|cs_sword|cs_viking|csdmad|csdmeh|csdsick|csdsmile|csgoa|csgoanarchist|csgob|csgocross|csgoct|csgoglobe|csgogun|csgohelmet|csgoskull|csgostar|csgox|cskel|csnz|cteddy|cthulhu|cthulhuship|cthulhusprite|cu|cube|cubeup|cubot|cucumber|cuddlefish|cult|culterl|cupcake|cupcakeelf|cupidarrow|cure|curious|curiouspanda|curry|curse|cursed|cursedpendant|curtis|cute|cuteghost|cutesheep|cuteteddy|cutter|cw|cwalker|cwat|cxxlbuild|cxxlbulldozer|cxxlhousing|cxxlindustry|cxxltransport|cyan|cyanheart|cyanid|cyberbear|cyberdeck|cybereye|cybergoat|cybersmile|cyborg|cycle|cyclist|cyclops|cygnar|cylinder|cz1|cz2|cz3|czombie|d20|d2antimage|d2axe|d2bloodseeker|d2brewmaster|d2invoker|d2lonedruid|d2naturesprophet|d2puck|d2rubick|d2tidehunter|d4_angry|d4_cry|d4_sleep|d4_smile|d4_strange|d4_wink|d_ghost|d_human|d_key|d_mach_key|d_pill|d_rune|d_skull|d_syringe|d_titan|d_watch|daExecutioner|da_jim|da_skull|dagger|daggerclan|dahonko|dalhousie|dallas|damien|dance|danceshoe|danger|dangerous|dangerousplanet|dani|dante|daperdillo|dappershark|dark|dark_rune|darkcrystal|darkeid|darkfaerie|darkgiant|darkhead|darklazer|darkmummy|darkness|darkpda|darn|darrell|dart|dartfalcon|darwin|dashforth|dashfrown|dashsmile|dashstache|data|database|datadisk|datastream|dauros|david|davy|dawnz|dbite|dbleep|dbmcleric|dbmdrumb|dbmfighter|dbmmage|dbmsoul|dbmthief|dd_bot|dd_catch|dd_denied|dd_disco|dd_dodge|dd_duck|dd_godlike|dd_ninja|dd_squirrel|dd_target|dddgrenade|ddgoblin|dead|deaddino|deadfish|deadgrunt|deadguest|deadhead|deadhead1|deadhead2|deadhead3|deadhead4|deadhead5|deadhead7|deadhuman|deadjeff|deadly0|deadly3|deadlyammo|deadlyd|deadlyrabbit|deadlyshark|deadlyspikes|deadmanshead|deadmen|deadnaut|deadnautdrag|deadnautgear|deadnautghost|deadnautshield|deadrat|deadsheep|deadskull|deadweight|deal|deal_done|dealwithit|death|death2|death_from_above|deathamulet|deathfinger|deathfromabove|deathhelmet|deathkin|deaths|deathsconsort|deathstar|deathstroke|deathtouch|deboost|decaycam|decaycoin|decaypwatch|decaysledge|deck|decomonkey|decorator|deerskull|def|defaultstaff|defender|defense|defiledskull|deflect|dehappinator|dehead|dejavu|dejavuii|dejo|delete|deliciousfruit|delightedRob|delos|delta|delta6|demiburp|demise|demo|demon|demoncrown|demondober|demoneye|demongalvis|demonic|demonimp|demonsheep|demonspact|demonspider|demoticon|denied|deponiacat|depth|derekhales|derp|derpmouse|derpy|desertrat|designer|desktopclock|desperado|dessert|destiny|destroy|destroyer|destruct|destruction|desu|detachlimb|detachneck|detachspine|detail|detective|determined|determinedstarfish|detonate|deuce|deusex|devil|devilgoat|devilish|deviljoker|devillilith|devilskiss|devilsmusicbox|devious|devitsy|devitt|devon|devourerofworlds|dewey|dewgrim|dewstare|dfapple|dfsrank|dg2asteroid|dg2endurance|dg2gun|dg2laser|dg2planet|dgaxe|dgfear|dggun|dghammer|dgjewels|dgjug|dglogo|dgrasp|dgskull|dgsplat|dgwalker|dh_apprentice|dh_assistant|dh_dawn|dh_demon|dh_lucy|dhead|dia|diablo|diadem|diamond|diamonddust|diamondface|diamondroll|diamonds|diamondscroll|diamondstar|diaochan|diaxe|dice|dice1|dice2|dice3|dice4|dice5|dice6|dictaphone|dictionary|didrik|diebutcher|died|diefloater|diehard|diepuller|dieram|diescreamer|diesoldier|diesuicider|dietourist|diggin|diktat|dilo|dinner|dino|dinocoffee|dip|dipaddle|diplomacy|diplomatic|directions|dirtblock|dirtwall|dirtyshard|disapprove|discdrone|disk|dislike|displash|disruptor|dive|divekick|diver|diverghost|divination|divine|divinggoggles|divingmask|diwrench|dizombie|dizzy|dlbrain|dmctheorder|dmitry|doc|docbrown|doctor|dodcp|dodge|dodger|dofkskull|dog_bone|dog_choco|dog_coin|dog_gift|dog_green|dog_heart|dog_husky|dog_poop|dogbone|dogbowl|doge|dogface|doggie|doggy|dogi|dogiwink|dojoflea|dokidoki|doll|doll_sigil|dollars|dollseye|dollsteak|dolphin|dolphinfish|domey|domination|dominik|domino|dompam|dongle|dontgetit|dontmakemeangry|donut|doodle|doodlefall|doodleheart|doodlescared|doom_mark|doomguard|doomsphere|doorchip|dopey|dorothyscarf|dos|doskias|dosprompt|dotecrystal|doubleaxe|doublemaple|doubt|doughnut|dovrac|downarrow|downvote|dp|dpbaldguy|dpbirdiel|dpdragon|dpeagleia|dpfrogo|dpgold|dpguardian|dpguild|dpointgomo|dporacle|dpranger|dpskitter|dpsorcerer|dpturtelio|dq_beholder|dq_demon|dq_ghost|dq_goddess|dq_jellyfish|dq_ogre|dq_princess|draco|draconian|dracul|draculala|dragon2|dragona|dragonbone|dragonboss|dragoneye|dragonfire|dragonhead|dragonhelmet|dragonmm5|dragonmoon|dragonrider|dragonskull|dragonsky|drake|drakeseye|drakonix|drakonjr|draky|drama|drbones|dreadnaught|dreadnought|dreamy|dred|dredan|dredd|dredddice|dreddgun|dreddperp|dreddrobot|dredmorninja|drewblock|drewcolor|drewdream|drewhome|drewteo|dribbling|drifter|drill|drink|drinkme|drive|drivetime|drizzle|droid|drone|drool|drop|dropbot|dropcat|dropcrate|dropford|dropheart|dropmic|droppedcashbag|dropsmirk|droptear|drover|drowen|drownerbrain|druid|drunk|ds_gearmech|ds_glee|ds_goopresso|ds_grumpy|ds_pride|ds_prisoner|ds_rage|ds_smile|ds_sticky|ds_stormer|dsad|dsattack|dsdamage|dsenergy|dsfight|dsham|dshound|dshull|dskull|dsmagic|dsmile|dsparkle|dsrepair|dssmallbird|dstools|dsus|dswilson|dswilsonscared|dualpistols|dubiousscience|dubthee|ducat|duckfeet|ducky|ducttape|dude|duel|duhon|duke|dukkha|dumble|dummy|dungeon|dungeonmaster|dungeonsaxe|dunnomm1|dunnomm2|dunnomm3|duranceleft|duranceright|durkin|dusk12|dustgirl|dustkid|dustman|dustoffpilot|dustoffskull|dustworth|dusty|dwDancingStars|dwJellies|dwYellowStar|dwarf|dwarf_planet|dwarf_star|dwarfbeer|dwarffight|dwarfwork|dwarven|dwarvenshield|dwayneelf|dwgreen|dwred|dwyellow|dyanna|dyell|dyer|dyingplanet|dynamite|dynamite_sign|dynamites|dys_cat|dys_postcard|dys_rita|dys_torch|e5|eagle|eagleeye|eaglehead|ear|earbuds|earth|earth_rune|earthmagic|earthplatypus|earthrune|earthworks|easel|eastconfed|eater|eatyourbrains|ebele|ebonyivory|ecapsule|echelonaim|echelonstar|echo1|echo10|echo11|echo2|echo7|echo8|echo9|echobravo|ecm|eco9|ed|eden_sigil|edf|edge|ediaxe|ediblemushroom|edie|ediexclamationmark|edipistol|edirunner|eeee|eek|eetsonion|efferdan|egg|egg_broken|eggy|egon|egther|eh|eidcamera|eight|eightone|el|elchu|elco|eldarsign|elderdragon|eldhrimnir|eldust|electricity|electrify|electro|element4lborn|element4lghost|element4lheart|element4lquote|element4lworld|elementomega|elementsigma|elenor|elephant|elfood|elfsheild|eli|elindustry|elinfluence|eliseangry|elisedejected|eliselaugh|elisesmile|elisesurprised|elite|eliteork|elixer|elixir|ellen|ellie|ellip|elrath|elscience|emasteroid|embercult|embermage|emblem|emdisruptor|emely|emerald|emerexit|emi|emitter|emlo|emmo|emocompy|emofdr|emojiion|emote_anvil|emote_bag|emote_book|emote_char|emote_lantern|emp|emperor|empewpew|empgren|empire|emplanet|employee|employer|empty|emtransport|emturret|en|enclaveskull|endcube|endera|enderacoffee|endregateeth|enemy|enemyace|enemyfighter|enemyhit|enemyplane|enemyship|energy|energy_freeze|energycapsule|energycube|energydrink|energyqbeh|energyresource|energyrune|energysword|eng|engi|engineer|engineercat|england|eni_axe|eni_compass|eni_preacher|enjoy|enki|enlightened|enlightenedone|enlightenedwarrior|enraged|ent|entity|entrancetothehells|entropy_rune|eoshelmet|eosshield|eossoul|eossword|eostarget|epicblitz|epicdragon|epicpaint|epicremote|epicrobot|epicstickman|epiczombie|epscary|equals|equate|eradicate|eraser_icon|ered|eri|erik|erin|erindsc|ermahgerd|esa|escape|escwings|eshock|essenceofdeath|essenceofwater|essiqueen|esteban|etbeetle|etcapturecapsule|eternity|etgrub|ethan|ethancle|ethereal|etheriumconsortium|etheriumguardians|etheriumintari|etheriumparasites|etheriumraiders|etheriumvectides|ethrap|ethungry|etmantis|etmold|etmoth|eurika|eusalliance|eusearth|eusfirst|eusmineturret|euswarning|eva|evadebullets|evadeextension|evafacepalm|evawhat|eveleaf|everdusk|evil|evil_clony|evil_mask|evilbarber|evilcunning|evildisappointed|evileye|evilhead|evilhero|evilidk|eviljordan|evilkeeble|evilmad|evilpeaking|evilrat|evilskull|evilsword|evilwonkers|evolve|evomars|evooil|evosnowtree|evotree|evoworm|evp|exa|exalted|examine|exar|exas|excellent|excite|excitebox|excitedCP|excitedstarfish|excl|exclaim|exclamation|execution|executioner|exevil|exhaust|exhero|exilium_axe|exilium_bow|exilium_hammer|exilium_shield|exilium_staff|exilium_sword|exit|exittotem|exodus|expandshrink|explode|explodeminion|explodiness|exploooode|explore|explosive|explosiveness|explosivetower|extank|exterminate|exting|extinguisher|extraheart|extralife|extrastrongcoffee|extrk|exucaveira|eye|eyeball|eyeballofdeath|eyebot|eyeofdemon|eyeofhorus|eyeofra|eyeonu|eyepear|eyeroll|eyerollgrim|eyes|eyesee|eyeterror|eyewk|f|f117|f1_bat|f1_crown|f1_egg|f1_shield|f1_skull|f2_angry|f2_goblet|f2_happy|f2_key|f2_sad|f2_shield|f2_skull|f2_suprised|f2_unsure|f2a3buffalo|f4fwildcat|fab100|face|facepalm|facepunch|factory|faddyghost|fadeheart|fadehearts|faerie|faeryant|faerybutterfly|faerycreature|faerydragon|faerymirror|faerytree|faewing|fahi|fail|fairy|faith|falkwreath|fall|fallingman|fallinlove|famicart|fan|fanatics|fancyhat|fangs|faraday|fardy|faretw|farlandhero|farmowl|farportal|farthing|fashion|fasttravel|fastwheel|fat|fateBook|fateChest|fateDog|fateFish|fateHelm|fateWoof|father|faucet|fauna|faust|fawkes|fax|faye|fb|fbat|fbgem|fbgrub|fblook|fbomb|fbpearl|fbsmirk|fbump|fbzap|fbzorm|fbzzz|fdisk|fear|fearclue|fearmonster|fearshield|fearskull|feather|feathergold|featherpen|federation|fedstates|feelings|feena|feena2|female|femalefox|fencey|fenrir|ferret|ferryman|fervent|fervus|fez|ffist|ffs|fhammer|fhappy|fhtagn|fieldradio|fierce|fiery_heart|fierypepper|fifty|fight|fighter|fighting|fightmm1|filiahat|film|fin|finalboss|finch|find|finewine|fingers|fingerscrossed|finn|finnbody|finnhead|fins|finyomu|firbolg|fire|fire_e|fire_rune|firealert|fireapple|firebaby|fireball|fireball2|firebone|fireclub|firedemon|firedragon|firedrake|firefire|firefly|firefruit|firemage|firemagic|firemissile|firepit|firepoint|firerune|firesigil|fireslime|firesteak|firewisp|first_star|firstaid|fish|fishalexia|fishbone|fishbones|fishbowl|fishboy|fishbun|fishee|fisher|fishgun|fishing|fishingcat|fishingrod|fishman|fishpie|fishy|fist|fist2|fistbump|fistbumpleft|fistbumpright|fistshake|five|fix|fixwrench|fizzler|fkace|fkchip|fkcrown|fkdice|fkvip|flag|flag2|flagger|flags|flailknight|flamboyantsuperhero|flame|flameeye|flamen|flamer|flamermachine|flameskull|flametorch|flammable|flare|flash|flashbang|flashlight|flat|flea|fledermaus|fleur|flirtylora|flix|float|floatbubble|floater|floatingshoe|floatingtree|floatskull|flockdog|flockeagle|flocker1|flocker2|flocker3|flocker4|flocker5|flockfrog|flockgoat|flockllama|flockpig|flol_ball|flol_cow|flol_cup|flol_legion|flol_ufo|flol_whirl|floppy|floppydisk|flora|flower|flowerbullet|flowerpuzzleface|flowerseed|fluorine|fluorite|flutterby|fly|flycube|flydaddy|flyer|flyface|flying|flyingkick|flyingminer|flyingshmobs|flyn|fmad|foamhand|foddagger|foil|food|food_bag|football|footprint|forbiddenpower|force|foresee|forget|forgetful|forgician|forklift|forsalehollywood|fortress|fortytwo|foundation|fourLeafClover|fox|foxmonk|foxy|fpalm|fphat|fpidgeon|fprose|fr|frag|fraggrenade|fragile|fragment|fraise|fram|france|francemap|frankie|fraud|freak|frecunning|fredisappointed|freebeer|freedanpixelartsmile|freedanpixelartsurprise|freedom|freesia|freeze|freezing|freidk|freight|freja|fremad|french|frenchcheese|frepeaking|freshbrain|freshmeat|frickinlasers|friedchicken|friend|friendship|fries|frigate|fright_dyl|frightened|frigideer|fro|frog|frogg|froggy|frogzone|frostclaw|frostingcube|frostshield|frosttower|frosty|frown|fruit|frustration|fs|fs15cereal|fs15chicken|fs15cow|fs15milk|fs15tractor|fs2cry|fs2hp|fs2rabbitp|fs2rabbitw|fs2smile|fsad|fsbomb|fscared|fscrazy|fscrown|fsdislike|fsemo|fseye|fsgren|fshappy|fsheart|fsleepy|fsm|fsmeh|fsmg|fsonfire|fspokerface|fsrocket|fsshield|fsshot|fssnipe|fsstar|fszzz|ft2blob|ft2crab|ft2explorer|ft2fish|ft2gem|ft2iera|ft2snow|ft2sword|ftd_dragon|ftd_firelord|ftd_golem|ftd_minotaur|ftd_mummy|ftired|ftlhuman|ftlmantis|ftlrebel|ftlslug|ftlzoltan|ftp|fuel|fuelcan|fueltank|fuff|fujimoto|fullstars|fume|fungus|funny|funnybone|funnyclownbot|funnyfox|furious|fuschia|fusebomb|fusing|fxball|fxboots|fxgloves|fxredcard|fxwhistle|fyeah|g|g_skull|gachapon|gael|gaflag|galactic|galaxy|galena|gallara|gallente|galleon|galley|gallina|galvis|gambler|gambler_b|gambler_g|gambler_r|gameface|gameover|gametron|gandalf|gangerousplanet|gapafrog|gaper|garfunkel|gargoyle|garlic|gas|gas_can|gas_giant|gasbag|gasgiant|gaskull|gasmask|gasmist|gaspipe|gassed|gate|gauntlet|gavin|gaz66|gbadger|gcandy|gcblue|gcbrick|gcdirt|gcgrass|gchardwood|gcicat|gcidog|gcifainted|gcihatchet|gciknife|gcilove|gcipokerface|gcireaper|gcisad|gcishock|gcispectre|gcitongue|gclava|gcleaves|gcloak1|gcred|gctree|gcwindow|gdsm|geagle|gear|gear2|gear_energy|gears|gearup|gecko|geel|geerhead|geisha|geishadragon|geishafan|gekkou|geldoffon|gem|gem_green|gemcomplete|gemfrag|gemgreen|gemini|gemstone|general|generator|genestealer|genkorpmask|gent|gentleman|gentleminer|george|georgia|georgio|geosbutterfly|german|germancross|germanflag|germanhelmet|germany|geron|getalife|getin|getout|gflower|ggbeta|ggecash|ggechamp|ggeclock|ggeftp|ggesnb|gggoo|gghuman|ggmoon|ggslayer|ggxxaceddie|ggxxacky|ggxxacmay|ggxxacmillia|ggxxacsol|gh_icon|gh_m_dash|gh_m_down|gh_m_guts|gh_m_ignition|gh_m_jump|gh_w_dash|gh_w_down|gh_w_hey|gh_w_jump|ghlol|ghostcat|ghostenemy|ghosteye|ghostgirl|ghostlight|ghostpax|ghostracing|ghsmile|giantsword|gift|giftbox|gildrei_alt|gilgamesh|gilma|ginny|giott|giraffe|girl|giselle|giveityourbest|givemeahand|gk|gk1_croc|gk1_dagger|gk1_eye|gk1_skull|gk1_talisman|gl2_guard|gl2_mother|gl2_otter|gl2_queen|gl2_spirit|gl_beast|gl_emblem|gl_kitty|gl_mark|gl_witch|gladys|glassshiv|glassslipper|glenn|glenn2|glenngeh|glennthefrog|gleosmug|glitch|glitchdsc|glob|global|gloomfaerie|gloomy|glory|gloson|glottis|glow|glowbug|glowinganchor|glowingorb|glowstick|glowtree|gman|gmask|gmbomb|gmod|gnarr|gnaw|gng|gnome|gnomehead|gnomoria|go|goalastonished|goalhappy|goalinsecure|goalsad|goalscared|goalsmile|goatlook|goatstanding|goblin|goblincannon|goblinhead|goblinking|godarblos|godchorion|godguantri|godhuman|godmode|godstar|goforgoal|goggles|gogglesBUD|gogo|gohempire|gohlaw|gohrepublic|gokigen|gold|goldBC|gold_bullion|gold_coin|gold_element|gold_loren|goldartifact|goldasteroid|goldbars|goldbullet|goldcardmember|goldcart|goldchunk|goldclick|goldcoin|goldcoins|goldcrossbones|goldcrystal|goldcup|golddata|golddsc|goldduck|golden|golden_brooch|goldenak|goldenarrows|goldenbit|goldencrystal|goldenegg|goldenfaerie|goldengun|goldenkey|goldenmilkminer|goldenpiece|goldenpuzzlepiece|goldenscale|goldenskull|goldenstarfish|goldenturtle|goldhelmet|goldidol|goldkey|goldmask|goldmedalalt|goldpiece|goldpouch|goldr|goldradar|goldring|goldsack|goldshield|goldsmile|goldstack|goldstar|goldtiki|goldwolf|goldyinyang|golem|gollum|gomezterry|gonzossm|goo|goodgame|goodgrip|goodhero|goodie|goodshot|goodsword|gordon|gorge|gorilla|goro|gorrister|gossip|gotwood|government|gpblue|gpgift|gphand|gplocked|gpokka|gpred|gpscrew|gpyellow|gr|gr8|grab|grabby|grabucket|gracash|grace|graclip|gracoin|grafish|graflower|grail|grakey|gralantern|gramagnet|grannie|grapickaxe|grappa|grapple|grasshopper|grasshopperinsect|grave|gravestone|graveyard|gravi|gravieye|gravilogo|gravispike|graviton|gravity|gravity_of_creation|gravon|grawr|gray8|graymatter|grcbucket|grccash|grccoin|grcflower|grcgold|grckey|grclantern|grcmagnet|greatcthulhu|greateye|greatwhite|green|green16|green_gem|green_jewel|green_spirit|greenacid|greenalert|greenapple|greenbook|greenbtn|greencrystal|greencubot|greendaemon|greendiamond|greenexclamation|greengem|greenjersey|greenlantern|greenlaser|greenled|greenlight|greenlightorb|greenmana|greenpad|greenpix|greenplane|greenporc|greenshark|greenslime|greensnakebird|greenstar|greenteam|greentri|greentwist|greenvial|greenwizard|greenwrench|greenzombie|grenade|grenader|grenny|greydress|greysuit|greytile|grid|gridbyte|grim|grimbox|grimind|grimmonster|grimreaper|grimthereaper|grin|grinsam|gripphinmm2|griselda|groggnar|grogue|grom|groove|groucho|groundtroops|growl|grr|grub|grubb|grumgog|grumpy|grumpyfrog|grumpyvienna|grunt|gruumcry|gs_angry|gs_annoyed|gs_bubblegum|gs_catchme|gs_cautious|gs_derp|gs_evil|gs_gaze|gs_happy|gs_joy|gs_lol|gs_owned|gs_sad|gs_shuriken|gs_stomped|gs_unimpressed|gskull|gsold|gt1cd|gt1datassette|gt1disk35|gt1dvd|gt1gamelantern|gtdisk525|gtfo|guacchest|guacegg|guacfist|guacpinata|guactequila|guarana|guard|guardian|guardsword|guh|guheart|guildseal|gulden|gull|gulltoppr|gumdrop|gumo|gun|gunclaw|gunlaws|gunner|gunnyyes|gunsight|gunslinger|gunslugscrate|gunz|gurepair|guristas|gutrophy|guyfawkes|gw|gwbwfire|gwenda|gym|h|ha|hack|hack_the_planet|hackan|hacker|haggis|haht|halberd|halisi|halloween|halloweener|halt|ham|hamalian_armor|hamburger|hamletcrown|hamletexclamation|hamletghost|hamletskull|hamletthermometer|hammer|hammerclan|hammerhead|hammerheadsnark|hammertime|hamster|hand|hand1|hand2hand|handalexia|handcuff|handgun|handprint|handprintleft|handprintright|handshake|handsyghost|handy|hangbanner|hangedmanhappy|hangedmanlaugh|hangedmanpirate|hangedmansmile|hangedmansorrow|hankthehumpback|hanzo|hapaheart|happiness|happy|happyAlice|happyBUD|happyCP|happyTom|happy_creep|happyaka|happyalien|happyball|happyblup|happychappy|happycrank|happycthulhu|happycubelet|happycyclops|happycyto|happyecho|happyeets|happyelf|happyfairy|happyfish|happyflem|happyfruit|happygirl|happygrim|happyhamster|happyhero|happyjasmine|happyjeff|happykoala|happylaika|happylaugh|happyleon|happymeat|happyminer|happymum|happynippy|happyoctober|happypirate|happypug|happyraider|happysaki|happyscruffy|happysnowball|happystarfish|happywagon|happywheel|happyz|harbinz9a|harbourmaster|hardcandy|harderthanhell|hardgrave|hardhat|hardsuit|harefoot|harley|harmony|harpoon|harpy|harvester|harvey|harveyangry|harveyastonished|harveyconfused|harveyhappy|harveysad|harveyskeptic|harveywizard|haste|hat|hat1|hat2|hat228|hatanon|hatchet|hate|hatfbi|hatman|hatpaket|hattime|hatty|haveaseat|havocsuit|hawken|hazard|hcat|head|headbash|headcrab|headless|headphones|headshot|headstone|heal|healingbeacon|healme|healplz|health|health_low|healthcrate|healthpot|healthpotion|healthvial|heart|heart2|heartbreak|heartdecoration|hearter|heartframe|hearticon|heartlove|heartmm1|heartmm2|heartmm3|heartmm4|heartmm5|heartmonitor|heartoful|hearts|heavy|heavybullet|heavycoin|heavydiamond|heavyheart|heavypill|heckabomber|heckyeah|hee|heff|hehe|heimdall|hela|helia|helicopter|helicrash|helimissle|helipad|helitags|helium|hello|helloween|hellsfury|hellslime|helm|helmet|help|helperbot|helpfulalien|helpmeorkillme|hemblem|henchix|henk|herasia3s|herbalism|hermesangry|hermesconfused|hermeshappy|hermessad|hermesskeptic|hermessmile|herofiona|heroicfacepalm|heroine|heropose|heroshock|herosvictory|hex|hexrad|hexy|hey|heyred|heyu|hggrave|hgpotion|hgskull|hgtreasure|hi|hiBUD|highbrow|highcross|highfive|highlvl|highrise|highschoolhat|hiigara|hiigarans|hikari|hindsight|hintlord|hirodash|hirofall|hiroflip|hirojump|hirorun|hirosad|hiroslash|hirothrow|hiss|hitcharide|hittheroad|hivebeetle|hiveladybug|hivespider|hivskull|hiya|hiyoko|hm|hmbomb|hmm|hmmm|hmspaceship|hoblin|hobo|hohartemis|hohathena|hohheracles|hohperseus|hohposeidon|hohzeus|hoji_angry|hoji_fury|hoji_sad|hoji_smile|hoji_surprised|holdline|hole|holloot|hologlobe|holpotion|holscroll|holyshit|home|homers|homeworld|homingbullet|honkhonk|honor|honour|hoofprint|hook|hoop|hoot|hopper|hops1up|hopsbadge|hopsbullet|hopscommander|hopsemblem|hopsgasmask|hopsknife|hopsnightmare|hopsrevolver|hopsvip|horatio|horned|horns|horrifiedcubelet|horror|horsearmor|horseshadow|horseshead|horseshoe|horsey|hostagerescue|hostile|hotdogdad|hotel|hoteye|hotspot|houndeye|hourglass|house|hoverbot|hoxton|hp_aiko|hp_audrey|hp_beli|hp_jessie|hp_kyanna|hp_kyu|hp_lola|hp_nikki|hp_tiffany|hpbox|hpirate|hrdemon|hrflail|hrgrail|hrhedgehog|hrknight|hromeangry|hromeattack|hromecaesar|hromehappy|hromehelmet|hromesurrender|hrseep|hs|hs2|hschool|hsforhardslash|hship|hskull|htangry|htcry|hth|hthappy|htpts|htrcanary|htrlucky|htrpigeon|htrrat|htrsnowball|htserious|htshocked|htsleep|htsmile|htsmug|htt|huey|hug|hugdeity|hugebag|hugebomb|hugin|hugo|huh|huhdonut|huhuh|hum|human|human2|humanheart|humaninvader|humans|humansheild|humantank|humiliation|humskull|hungover|hungry|hunkofcheese|huntdeer|hunter|hunterhat|hunting|huntress|hurray|hurricane|hurt|hvbomber|hwangry|hwhappy|hwinterceptor|hwshield|hwsilly|hwsword|hydra|hydrogen|hype|hyper|hypercube|hyperion|hyperrogue|hyperrogue2|hypersonic|hyphen|hyphencannon|hyphenmine|hyphensaw|hypnofearangry|hypnofearconfused|hypnofeargrumpy|hypnofearsad|hypnofearsmiling|i90sign|iaito|iambagel|iambaguette|iambread|iamcrackerbread|iamdeath|iamrocket|ibb|icaquaman|icare|icarusdoubt|icarushappy|icaruslove|icarusmad|icarussmile|icbatman|ice|icebeam|iceburn|icecream|icecream2|icecreamy|icelance|icemage|iceplant|icesigil|icflash|ichi_block|ichi_bluetri|ichi_collect|ichi_redtri|ichi_teleport|icon|icsuperman|icu|icwonderwoman|icy|icyfaerie|idea|ideamm1|ideamm2|ideamm3|ideamm4|identity|idislike|idle|idol|idragon|ifb|iffy|iggy|ignore|igor|ihatedamanvel|iibubble|iicomputer|iidisrupter|iigun|iiii|ilamentia1|ilamentia2|ilamentia3|ilamentia4|ilamentia5|ilamentia6|ilike|illuminati|ily|imachamp|imler|imout|impaled|impossaction|impressive|imprison|imrich|inc|inch|incognita|income|indestructible|indifferentterry|infbot|infected|infectedparty|infinitoad|infinity|influence|influx|influxsphere|info|ingyang|inhibitor|initiator|injection|inkpixelartinlove|inkpixelartsad|innocentstarfish|inoball|inquisitive|ins|insanegasmask|insanity|insect|insekt|insfist|insomniac|instincthenge|insurgent|int|interact|interceptor|interesting|intermediate|interrogation|intimidate|invasionfleet|inventor|inverted|investigate|invictus|inyourface|ipenergy|ipmaterial|ipot|ira|irc|irclaw|irhalfmoon|irhowl|ironcog|ironcross|ironcrosswings|ironfist|ironpaladin|irrun|irspace|irspace2|irspace3|irwolf|irwolfhead|is3|isaac|isabel|isak|iseeyou|ishani|iskull|island|it|itd_mayor|item|itgbed|itgkey|itgrope|itgsad|itgsmile|its_on|itsbacon|itsfine|itsgrimm|itsmyground|itstime|iwanttobelieve|iworshiphazeezus|ixi|jack|jackbody|jackdeath|jacko|jackofblades|jackpot|jackthelumber|jacomo|jacques|jake|jakes_dance|james|jamesmurphy|jammer|japonempire|japonkingdom|jarate|jarbrain|jarhead|jasminedeathstare|jasper|jaw|jawdropping|jawleft|jawless|jawright|jazzy|jcoin|jcube|jd2angry|jd2cake|jd2chick|jd2happy|jd2shock|jdcircle|jdduck|jdflower|jdhat|jdhex|jdmousetrap|jdstar|jdtea|jealousy|jeep|jeff|jeffknife|jeffrey|jelly|jellybean|jellyf|jerboa|jeremy|jericho|jerry|jester|jesus|jet|jetform|jewel|jeweler|jeweller|jgt|jgthp|jgttnt|jianh|jieunApple|jihaeBroccoli|jimmy|jimmykid|jimmylee|jimsterling|jin|jisooOrangeJuice|jisooPaw|jisooTunacan|jiwooLaptop|jiyeonToy|jknight|jo|jockolaugh|joe|joegould|joeknife|joeyhat|joffirewater|jofgoldenkitty|jofhat|jofjones|jofkitty|john|johnFace|johnnysmile|johnwizard|joke|joker|jollyroger|jollyrogermini|jonan|jondagger|jorge|jorji|jos|joshua|journal|journal3|journalface|journalpage|journey|journeyj|journeyl|journeyy|jove|joy|joyfin|joystick|jp|jrmelchkin|juan|jue|jug|jukebox|jumjum|jumpmm1|jumpmm2|jumpmm3|jumpmm4|junkyarddog|junta|justT|kablammo|kaboom|kabuki|kairo|kairorings|kalis|kalisymbol|kalol|kamikaze|kamina|kana|kane|kap40|kapow|karateka|kardfy|karenpurse|karinchan|katana|katanas|keeble|keebleking|keeblequeen|keep|keg|keim|keiro|kellycar|kentony|kenzflea|kerplode|ketta|kev|keyboardcat|keybot|keytar|kforkick|khador|kharaaeye|ki|ki96|kickthem|kid|kidblink|kidcurious|kiddiamond|kidgeishagirll|kidhappy|kidluckygirl|kidmad|kidouch|kidpassionategirl|kidrose|kidsad|kidscared|kidweak|kill|killcrate|killenemy|killer|killerbee|killme|killskull|killthenpcs|kilver|kimikat|kindofgood|king|kingb|kingcrown|kingfish|kingk|kingknight|kingkoi|kingme|kingsguard|kingsword|kingtrophy|kinky|kira|kiskit|kiss|kitteh|kittehface|kittyboat|kittybrokenheart|kittycaptain|kittyheart|kjartan|knife2|knifebtn|knight|knight30|knightaxe|knightcross|knightmm1|knightshield|knowledgeresource|knp|koala|kogoat|koi|koifish|koikoijapan_aoi|koikoijapan_cho|koikoijapan_kazaguruma|koikoijapan_momiji|koikoijapan_ume|kono|kowka|kr17|krait|kraken2|kraug|krawnix|kreps|krgrenade|krlvlup|krmine|krolm|krsheep|krskull|krstar|krveznan|kship|kthumb|kudos|kungfusam|kurimuzon|kurimuzon2|kuro|kv|kvplanet|kya|kylek|kylekeever|l00t|labman|labrat|lad|lady|ladybird|ladybug|ladykatarina|lagg3|lamp|lampoff|lander|landlord|landsers|lantern|laptop|larry|laser|laser2mirror|laser2wall|laserbattery|lasercat|lasercats|laserdefense|laseremit|lasergun|lasermine|lasermirror|laserpewpew|laserrcv|lasertower|laserturret|lastknight|latch|late|latteru|laughedat|laughingbomb|laughingfairy|launchpad|lauren|lava|laverne|lawnufo|lawyercat|lbfishy|lck|lcrown|leader|leadership|leaf|leaffaerie|leafoffriendship|leaper|leatherhelmet|led|leechclaw|leftarrow|leftroz|legacy|legendary|legendarysword|legion|legionis|legitimacy|lei|leira|lemmaa|lemmae|lemmal|lemmam|lemur|leninmask|lensofsecret|leo|leon|lernie|lernie2|lethosdream|letmespeakfrommyheart|letsgo|lettera|lettere|letterg|letterl|letterp|lev|levelup|leviathan|lewisdenby|lewt|lg|lgodead|lgograil|lgogrin|lgojeff|lgoknight|liam|libertine|libra|librarian|lichdom|lid|lideyes|lie|life|lifelink|lifepotion|lifetree|lifterblock|liftoff|light_rune|lightball|lightbolt|lightbulb|lighter|lighthouse|lightningbug|lightspeed|lightup|like|like_king|likeaboss|likeit|lilac|lilacstare|lilaki|lilbanshee|lilguppy|liliawink|lililil|lily|limomickey|lin|linda|lion|lionhead|lionhelmet|lionsden|lipsandteeth|lis|lisa|listen|listine|littleClaire|little_girl|littlebird|littlebree|littlecrab|littledog|littlefrogs|littleheileen|littlemarie|littlepeople|livingfire|lizard|lizardman|lizardstatue|llama|lloyd|lltqjewel|lltqsword|locked|locknload|lockon|lockpick|locktime|log_helmet|log_key|log_potion|log_skull|log_sword|logiaim|logibomb|logihand|logiimpact|logizap|logs|logwagon|lok|loki|lol|lollipop|lolskull|lonestar|longhaul|look|lookaround|looking_sharp|lookingatyou|looper1|looper2|looper3|looper4|looper5|loot|lootanchor|lootbag|lootcannon|looter|lootjack|lootrum|lootsabres|loottreasure|lootwheel|lord|lordjair|lordobludia|lordofthemind|loren|lorwyn|loss|lostleg|lotsoftrash|louie|love|loveb|loveblup|lovecube|lovedead|lovedude|lovefromsteph|lovehate|loveheart|lovelace|lovelanding|loveletter|lovelovelove|lovely|lovely_planet|lovelypixels|lover|lovesaw|lovespike|lovew|loveyou|lovez|lowang|lowenergy|lowfuel|lowkick|lowrider|loxbless|loxcurse|loxdead|loxsick|loxstun|loxwound|lp33|lp3l|lp3p|lp_baddie|lp_bomb|lp_buddy|lp_guy|lp_samurai|lp_teleport|lrsflink|lrskappa|lrspanzer|lrspeace|lrsvaliente|lrsvelocci|ltangel|ltears|ltegg|ltkitty|ltshaggy|ltt|lubu|luca|luchador|luchamask|luci3s|lucille|lucion|luck|lucky|lucky_clever|luckycat|luckyhand|luckyme|luger|luger9mm|lugh|luis|lumberjack|lumbermancer|lumen|lunacontroller|lunaearth|lunahealthpotion|lunalick|lunamine|lunaperfect|lunapewpew|lunargiant|lunarlander|lunatica|lunchtime|lustbottle|luvgaze|luxcannon|luxhorse|luxjet|luxtank|lvl1pages|lvl2pages|lvl3pages|lvl4pages|lwface|lwfeather|lwflame|lwmiss|lwrage|lwskull|lwsun|lwswords|lycan|lyn|lyneglow|lynehalt|lyneknot|lyneleap|lynevision|lyrie|m|m67grenade|m8|m_planet|maaad|mabiskull|mabitools|mac|macface|machiko|machinepistols|machinery|madTom|madVlad|madball|maddie|maddoctor|madeintropico|madelf|madoctober|madpug|madscruffy|madskull|maeko|maestro|mag|mage|maggot|magic_bottle|magical_question|magicalring|magicalscroll|magiccrystal|magichatmouse|magicicon|magiclamp|magicmaker|magicmushroom|magicone|magicpotion|magicring|magicshards|magicsword|magictablet|magister|magmasite|magnet|magnetize|magnifier|magnifierbush|magnifyingglass|magturtle|maia|maidcafe|maihome|mailedfist|maimm5|makarovpistol|makingapoint|male|malefox|malfireball|mallet|malletbow|malleus|mana|manamana|manap|manapot|manekineko|mango|mangopainting|maninblack|mannequin|manny|manslayer|manticore|mantis|manual|map|maple|maple_leaf|maplechan|mapleleaf|maraudskull|marblecrown|marblefan|marcothecook|marek|marian|marinehelmet|marinemm1|marinemm2|marinemm3|marinemm4|marinemm5|mark|markarth|markeyeglasses|markos|marksman|markterror|marquis|mars|marsdog|marshal|marshuttle|marslander|marsrover|martini|marvin|mary|marysad|masher|mask|masked|maskedghost|maskpunk|masky|masoneagle|masonfist|mast|master|mastermedal|masterwushu|mate|maternitydoll|mathematical|matilda|matrick|mattock|matty|matubo|max|maxfist|maxout|maxpower|maxtophat|maxwell|mayor|mayorshark|mayumi|mbablob|mbachill|mbadrink|mbafood|mbapigout|mbfaoi|mbfiks|mbfkirio|mbfleafa|mbfraika|mbgoblin|mbiker|mbspider|mcamulet|mccalypso|mcdragon|mcdrop|mceye|mcgun|mchand|mcheart|mcidea|mcjardel|mcmouth|mcpixel|mcsusanna|mcvhelmet|md5|mdconfused|mddisgust|mdhappy|mdmad|mdsurprise|me|mead|mean_creep|meanie|meataxe|meatboy|meatboyterry|meatcleaver|meaty|meatytears|mech|mechanic|mechy|mecury|med|medal|medal2|medalartifact|medallion|medic|medicineman|medicon|medieval_flag|medipus|meditate|medkit|medpack|meds|meeple|mega|megabomb|mehearty|mei|mejerry|mel|mel1|melchkin|melee|meleeattack|meloblond|meloblue|melody|melogold|melogreen|melohp|melon|melopink|meltdown|meltdownzed|memory|menace|mend|meow|meowie|meowric|meplane|merc|mercenaries|mercury|merdeka|merlin|merlinemm3|meroz|merry|meso|metabolism|metal|metalbed|metalcog|metalmarble|meteor|meteorite|metro|metrocrime|metromask|metroquestion|metroscared|metrosee|metrotrade|mg_turret|mgc|mglass|miasma|michellejoyce|mickey|microraptor|midair|might|mightygrenade|mightygun|mightyrocket|mikey|militaryStar|milk_can|milkbottle|milkminer|milkwagon|milky|millafp|milliecunning|milliegrin|milliehurray|milliepuzzled|milliethinker|millstone|minasmile|mind_rune|mine2|mineBC|miner|minerham|minerlamp|minernuke|minerpick|minerpickaxe|minersoul|miniboss|miniglottis|mining|minion|minivan|miniwarren|minmatar|minor|mirage|miranda|mirrormoon|mirrorsmile|mis|misa|missdebug|missile|missing|missioncount|misslily|misterx|misterybox|mistfairy|mit|mite|mitra|mixtape|miyabi|miyu|mjk|mjks|mk|mk8|mkanvil|mkb|mkbear|mkcat|mkguano|mkmandrake|mksuitcase|mktomato|mllrM|mllrcrosshair|mllrmask|mllrrad|mllrsniperround|mm|mm_acid|mm_bananas|mm_bug|mm_garlic|mm_worm|mmagnet|mmclover|mmep_e|mmep_m|mmep_p|mmmdonut|mmmm|mmseagull|moab|moaibandit|moaibl|moaifimi|moaigl|moaileader|moaimotg|moavassassin|moavhero|moavhunter|moavmage|moavwarrior|mobile|mobileoctopus|mobstermoose|mobsterspike|mocking_cell|modelt|moebius|mojito|mokuso|molepax|mollusk|molococktail|mom|momiji|mommy|money|moneybags|moneymaker|moneypowerup|moneyresource|monitor|monk|monkeyeye|monob|monocle|monolith|monomakh|monor|monow|monsoon|monster|monsterecho|monsters|monstertruck|monty|monument1|monument2|monument3|monument4|monument5|moon|moon_energy|moonchild|moonchildkiss|moonflower|moonincar|moonshine|moose|mordheimbook|mordheimdagger|mordheimfire|mordheimfist|mordheimskull|mordheimtooth|mordred|moreexclamation|morgan|morgane|mori|morphine|mortar|mortis|morton|mosquito|moth|mothership|motherslime|mothpax|moti|motionsensor|moto|motor|motoro|mount|mountGoat|mouse|mousemagichat|mousesitting|moustacheterry|mouth|move|moveicon|moveit|movieskull|mpgb_ayumi|mpgb_chise|mpgb_elsa|mpgb_resabell|mpgb_sge_airi|mpgb_sge_akane|mpgb_sge_kotomi|mpgb_sge_ouka|mpgb_sge_urara|mpgb_tsubasa|mpotion|mrbigguns|mrbree|mrcat|mrcrab|mrghost|mrlogo|mrpatterson|mrr|mrsbree|mrsnail|mrtotem|ms_alice|ms_dragon|ms_grey|ms_mind|ms_shadow|msfortune|msinclair|mspatterson|mucha|mudhand|mudpop|mudyuggler|mug|muiraquita|mukan|mule|mummy|mummyeye|mummymouse|muney|murkoff|murmillohelmet|murnay|murray|musclecar|mushbloom|mushroomhead|music|musicnote|mustscream|mute|muxin|mvp|mybeer|myfins|mygasmask|mygrenade|myhelmet|myknife|mymeat|mymedkit|myougiLaugh|mypizza|myrobot|mystbook|mystery|mysterygas|mystic|mysticalskull|mystpirate|n8|nagam|nahbee|nahbl|nahclown|nahkitty|nahmilkshake|nailgun|naked|nametag|nanpilothelmet|nansupremegeneral|nao|naptime|naru|narumi|nate|nativewarchief|navalbattle|navvie|navy|nay|necklace|necro|necroed|necroheart|necronomicon|necropotion|necroshovel|needler|needsleep|negative1|negran|neil|neildeal|neilfacepalm|neiljaw|nekkerheart|nelumbo|neogaf|neoncamera|neonhack|neonstims|nepilim|nepnep|nerd|nerdmel|nervous|nestra|nethack|netherlands|neumine|neutral|neutralmorale|neutralrobot|neutrino|neveralonebear|neveraloneowl|new|newguy|newspaper|newsword|newton|newtype|neymar|nftd|nftd_frightening|nftd_frightening2|nftd_scared|nic|nice|nicekitty|nicerat|nico|nicolas|nicolas2|nidhogg|nidhoggoengarde|nidhoggorun|nidhoggs|nidhoggyengarde|nidhoggyrun|nightbutterfly|nightflame|nightmare|nightmareghost|nightsparkle|niko|nimdok|ninja|ninja2|ninjabear|ninjacoin|ninjaface|ninjaflea|ninjahead|ninjalantern|ninjamode|ninjaspear|ninjastar|nippy|nisha|nitrogen|nitroportion|nitrous|niva|nmrih|no|nocrossbones|noelle|nogarihelmet|nogarimanticore|nogaripiranha|nogo|noire|noirgun|noitubird|noituchimp|noitulove|noitusmart|nolabadge|nomad|nomnom|nomouth|nonmovingship|nonplussed_creep|noo|nooo|nopdstr|nope|norhythm|normal|normalpirate|north|northstar|nose|nospeech|nostars|not|not_happy|notchflower|notchgem|notchwing|note|notearth|notebook|notepad|notestar|notime|notsohappychappy|nottherobot|nova|noway|ns2combat|ntfd3_kraken|nuclear|nuclearalert|nuclearmushroom|nucleicacid|nucular|nudge|nugget|nuke|nukebomb|nukeme|nukethem|nukewarhead|number1|numberone|nuna|nuri|nurseghost|nursejulie|nursejulie1|nux|nuxguy|nuxguy2|nuxmonster|nuxship|nuyen|nyam|nynshocked|o_science|oba|obb|obelisk|oberon|obnoxious|obomb|oboot|observer|obtdbain1|obtdbrain2|obtdcraft|obtdfire|obtdgun|obvious|ocam|ocandy|occulthunter|occulthunterII|octodad|oculus|od_01|odoc|odpbox|odpcoin|odpcordy|odpgradeD|odpspikedball|odrown|oface|officer|offside|offspring|offtowork|ogdenarmor|ogdenhelmet|ogdensword|ogre|ogrebomb|ogres|oh|ohagi|oheart|ohemgee|ohh|ohh_yeah|ohhshiny|ohnono|oi|oil|oilbarrel|oilcan|oink|oj|ojcard|ojchicken|ojseagull|old|olddragon|oldfuse|oldgrimind|oldguitarpick|oldhat|oldheart|oldmage|oldman|oldmap|oldmusicbox|oldpaper|oldpipe|oldsammy|oldschool|oldschooltv|oldshoe|oldwiseman|oldworld|omfg|omnitron|omu|one|onegrenade|onering|oneshotonekill|oni|onibat|onihatchet|onikengrenade|onikenmedkit|onikenninja|onikiraashigaru|onikiradragon|onikiramempo|onikiraoni|onikiratile|onimarker|onlooker|onlyleft|ontheball|ontoagoodthing|ooh|oooo|oops|oozling|openbook|opendoor|openwheel|or|oracle|orange_gem|orangecube|orangecubot|orangegel|orangeguy|orangehalf|orangeheart|orangelily|orangesubmarine|orangetri|orangetulip|orb|orbitrocket|orbitsatellite|orblet|orborb|orbsmile|orcangry|orcsad|ord|order|orderfaction|ordhorse|ordnote|oreallee|organicresource|ori|origami|origamibird|orion|orochi|orpheus|ortower|osher|oshield|osira|ostrich|ostricheyes|ostrichfeather|ostrichscary|osword|otan|ouch|ouchheadshot|ouranus|oureking|ouroboros|ourplanet|outcast|outlander|outpost|overheat|overkill|overlord|ow|oweapon|owforce|owhero|owhunter|owlspirit|owsword|oxameter|oxygen|p08|p2000|p23ant|p23bee|p23bug|p23fish|p23tick|p2aperture|p2blue|p2chell|p2cube|p2orange|p2turret|p2wheatley|pa69|paBaby|paGirl|paJim|paTongue|paantidot|pacman|pact|padlock|pagancharm|paint|paintbrush|painter|paintgun|paknifes|pakvass|paladin|palm|palmer|palmtree|pals|pamedikit|panchos|pandafu|pandashocked|pandastunned|pangoat|pantaloons|panzerIV|paper|paperbag|paperclip|papermarble|papermoney|paperplane|par|parachute|parade_of_creation|paranormal|parcelblock|parcelbox|parcelhackman|parcelmagna|parcelporter|parfume|parin|parkan|particledata|parts|partyfist|partygod|partyhard|parun|pashield|password|pasta|patchroutine|patient|patrol|pause|pavelow|paw|paw_print|pawn|paws|pba_button|pba_flasher|pba_flipper|pba_pinball|pba_target|pbbg_itsuki|pbbg_mikoto|pbbg_nagi|pbbg_waka|pbbg_yuzuha|pbcrown|pbdiamond|pbenergy|pbomb|pbstrawberry|pbteacup|pcars|pcarsnetwork|pcarsracer|pcarstrophy|pcemmo|pckevin|pcmayor|pcrace|pcrita|pcry|pda|pdangry|pdcry|pdgasp|pdgrin|pdkiss|pdlove|pdpff|pdsleep|pdsmile|pdw|pdwink|pe2|pe2bomb|pe_fishing|pe_torch|peace|peaceandlove|peaceful|peaceknight|pearl|pearlywhites|peck|peckermon|pecs|pegasis|pen|pen_icon|pen_icon2|pencil_icon|pendergast|penetratingshot|penguinsrock|penguinsymbol|penguintank|penny|pentagon|pentagonagent|pentak|peopledeath|pepito|pepper|pepperoni|perception|percival|percy|perfect|perforated|perp|personality|pestilence|pet|petal|petrifiedear|petrifiedeye|petrifiedtongue|petrock|petrol|pettyhat|pewpew|pewpewpew|pewpewpewpew|pff|pforpunch|pharaohghost|phaseyghost|phoenixclock|phoenixheart|phoenixlocked|phoenixorb|phoenixstar|phone|photo|photon|photosession|physgun|pick|pickaxe|pickel|pickup|pie|piercing_bullet|piermont|pig_in_a_poke|pigeonquestion|pigface|piggie|piggy|piglaugh|pignut|pigrat|pikkard|pikkard2|pill|pillbill|pillbug|pillow|pilot|pilot1|pilot2|pilot3|pilot4|pilot5|pilothelmet|pilotoption|pilwiz|pin|pinecone|pinkFlowerNKOA|pinkbag|pinkbutterfly|pinkdeath|pinkflower|pinkheart|pinkpack|pinkpill|pinkpokka|pinksweety|pinkteam|pinktri|pinktulip|pinkyhamster|pino|pint|pintofbeer|piousboy|pip|pipe|pipebomb|piranha|pirate|pirate_treasure|pirateapple|piratebomb|piratecompass|pirateflag|piratemeat|piratemedallion|piraterum|pirates|piratesign|pirateskull|pirateterry|pistol|pistolblueprint|pitcher|pitcher16|piumm2|pix|pixduckling|pixduckling2|pixegg|pixelalfie|pixeldead|pixeldig|pixellance|pixelzombie|pixlotbleeding|pixlotderp|pixlotno|pixskull|pixus|pizzaslice|pjcoin|pjgem|pjheart|pjkaboom|pjskull|pjzippo|pla|plagueammo|plagueinc|plagueknight|plaguemedkit|plaguemoney|plane|planestriders|planeswalker|planet|planetmars|planetsplode|plank|plant|plasma|plasmacell|plasmaprojectile|plat2ball|plat2balloon|plat2heart|plat2pointer|platcrate|plate|platfinalboss|platformblock|platgunship|platinum|platinumbullet|platinummedal|platlittleship|platrocket|platypus|player|playerwaveform|pleased|plex|plumber|plunderer|plunger|plus|plushie|pmasteroid|pmbullet|pmfoe|pmship|pmshipgreen|pmshiporange|pmshippurple|pmsnitch|poc|pocket_watch|pocketwatch|poco|pod|poilu|pointdefense|poisoncarrots|poisoned|poisonmoose|poisonous|poisonspell|poisontower|poisonvial|pokerchips|polarbear|police|policecar|policecops|policehelmet|policesign|policetape|polishflag|polkadotjersey|polyball|polymorphic|pom|pomghost|ponderinghero|pong|pontius|pontius2|pony|poo|pooangry|pooboo|poocry|poohappy|poop|poopbag|poopscoop|poopy|poorteddy|pope|popme1gi|popular|porkpopper|porky|portal|portalgate|positron|possession|postcardb|postcardf|potemkin|potion|potion_green|potionbottle|potplant|poultry|pow|powderkeg|power|power_main|power_sub|poweraxe|powerbar|powercore|powercrystal|powercube|poweredup|powerfist|powerfulstrike|powerglove|powerhand|powerinverter|poweroff|poweron|powerring|powersupply|powersword|powerup|powerupbarrel|pp7|pp8ball|ppchampion|ppgame|ppgoodshot|ppokka|ppwinner|practicearrows|praiseham|preach|preacher|predatorballan|prelogate|present|presidente|prespills|priest|prime|primed|primeval|prince|princegrin|princess|princessmaya|prism|prisoner|private|prnss|pro|probapple|probarrow|probbow|probtarget|procyon|procyonshield|profgenki|profit|propaneflame|propanetank|propeller|proposal|protangonist|protect|protectorate|prototype|protozoid|proudeagle|prudence|psi|psvinyl|psy|psybomb|psybubble|psybullet|psyker|psypower|psyshield|psystar|ptbag|ptcase|pthat|ptshovel|ptskull|ptwheel|pudding|pug|pugegg|pugs|puke|puku|pull|pulstar|pulstarlife|pumpkin|pumpkinjoe|punch|punisher|puregear|purge|purity|purpldiamond|purple_gem|purple_spirit|purplecubot|purplediamond|purplek|purplelilac|purplemana|purplepatriot|purplesubmarine|purpleteam|push|pusherblock|pushpin|puzzlecube|puzzlekey|puzzlemaxwell|puzzler|pwghost|pwgold|pwhip|pwrup|pwship|pwskull|pwsword|pygmy|pyramid|pyramideye|pyro|python|qbehs|qbertsaucer|qcf|qfo|qlexcellent|qlfrag|qodapple|qodkey|qodpotion|qq|qr|qrcode|qrellena|qrnatas|qrracer|qrsigma|qrvengarra|quad|quark|quarpjet|quartz|queen|quest|questdone|questhere|question|questionmark|quests|quick|quickfix|quid|quill|r3ammo|r3fuel|r3goblet|r3hammer|r3heart|r3medicine|r3skull|r3trap|r3tree|r3zombie|rabbipunch|rabbistone|rabbit|rabbita|rabbite|rabbithole|rabbiti|rabiddog|rabu|raburabu|raceflag|racefuel|racetrophy|racinghelmet|rad|radar|radbot|radiation|radio|radium|rads|radzone|raeynor|raffleticket|raga|rage|rage_dyl|rageattack|rageblup|rager|ragesun|raiderlogo|raidership|rails|railslave|rainbow|rainbowfart|rainbowlove|rainbowportal|rainbowstar|rainbowtintedshell|rainstorm|raisetheflag|ralphhurt|ralphsmile|ram|rambo_arrow|rambo_face|rambo_headshot|rambo_knife|rambo_skull|ramskull|rana|random3s|randomhero|ranged|ranger|ranger_assault|ranger_assist|ranger_lead|ranger_scout|ranger_techie|rank|rank1|rank2|rank3|rank4|rank5|rankstripes|rapidFire|raptor|raptorkiss|rarebutterfly|rarediamond|rarejgt|raresecret|ratatosk|ratcoon|rathbone|rathermit|rationality|raven|raven_enigmatis|rawfood|rawrzombie|rayne|rbat|rbdxcheese|rbdxdiamond|rbdxgent|rbdxheart|rbdxplayer|rbdxscone|rbdxsoldier|rbdxsupersoldier|rbdxtea|rbdxzombie|rbiggrin|rbit|rbomb|rcandy|rcry|rd_crown|rd_dragon|rd_love|rd_power|rd_stump|rdguardian|rdlogo|rdora|rducky|reachout|readyset|readytoragequit|reah|reah2|reahhood|reahwink|realcrafting|realityboy|reallol|really|reaper|rebel|rebellion|recdroid|recharge|recognizer|recon|rectangle|recycle|red|red16|red8|redMask|red_gem|red_jewel|red_spirit|redaim|redalert|redapple|redarmy|redbat|redbed|redbitninja|redbolt|redbox|redbuggy|redbutton|redcard|redcross|redcrossbush|redcrystal|redcube|redcubot|reddark|reddragon|redeye|redeyes|redfist|redflower|redflowers|redgeisha|redgem|redgiant|redgift|redhearts|redhelmet|redhot|redlaser|redleaf|redled|redlight|redlightorb|redmana|redmine|redmonster|redmushroom|rednailgun|redorb|redpage|redplanet|redpoison|redpolyball|redpotion|redqueen|redrose|redseedling|redskull|redslimebeast|redsnail|redsnakebird|redspoiler|redteam|redthief|redtoadstool|redtri|redtulip|redwarp|redwind|redwing|redwink|redwiz|redwizard|redwolf|redwrench|redyokai|reflectblock|refuel|regeneration|reheart|reinforce|relic|relicrune|relicspirit|relief|remedy|remote|remote_controller|remotebomb|rendoh|rennyf1|rennyf2|renoah|reonion|repairWrench|repairdrone|repairhere|repairpad|repelpot|repenny|repill|replay_icon|repoop|republic|res|resanna|resbennett|resbum|rescue|rescuebuoy|rescuerobot|researcher|resed|reshingu|residue|resiseagull|resmile|respawn|resray|rest|restroom|retention|reticle|retreat|retrific|retro|retro_hourglass|retro_questionMark|retro_squirrel|retro_wagon|retrotorch|retroyeti|reusapple|reuschicken|reusgreed|reusocean|reusrock|revenants|revenge|reversi|revive|revng|revolver|revolverbullet|revs2tank|rewardmoney|rexanna|rexford|rexusrook|rf|rfacepalm|rfc|rflogo|rflower|rg|rghost|rhscandle|rhscross|rhsknife|rhsskull|rhsstar|rhstomb|ria|richard|richardcigar|riches|richy|rickweeks|riddle|riddler|ride|ride_away|rifleammo|riflecartridge|rifleman|riflesword|riftdeath|riftearth|riften|riftfire|riftlife|riftwater|right|rightarrow|rikhor|rileyrune|rimanah|ringing|ringring|ringz|riot|rip|rip4real|ripdammo|ripdhealth|ripdskull|ripper|ripperheart|ripslinger|rise|risen2clawmonkey|risen2sanddevil|risen2skull|risen2tricorn|risen2voodoodoll|risenashbeast|risenghul|risengnomo|risenhero|risenheroinquisitor|risky|risky_laugh|rita|ritonaangry|ritonaworried|riverglance|rkbishop|rkking|rkking2|rkknight|rkpawn|rkqueen|rkrook|rkrook2|rl|rmomo|rnt_crow|rnt_ranger|roach_bud|roach_jim|roar|robbe|robbecelebrate|robbehead|robbehuzzah|robbekey|robert|robi|robin|roblush|robocop|robodance|robodownload|roboeye|robohat|robojoe|robomine|robot|robotboss|robotcommand|robotdude|robotguard|robotguy|robotloveskitty|robotman|robotpanda|robotube|robotvsdinosaur|rocket|rocketflight|rocketrat|rockets|rocketsfired|rocketsrocketsrockets|rockfist|rockon|rockt|rofl|roflspirit|roger|rogue|roguefedora|roguegentleman|roguelike|roguemage|roll|rollingbomb|romance|rook|rookie|roomkey|rooms2|rooster|roosterhead|root|ropey|rorschach1|rorschach2|rorschach3|rorschach4|rose|rosealexia|rosebud|rosefaerie|rosepink|rosered|rosy|roti|rotisserie|rotting|rotty|roundabout|roundfin|roundfox|roundhousekick|roundspeaker|route|rover|roverbot|roxy|royalpearl|rp|rpokka|rrazz|rrbjorn|rrclancy|rrcog|rrdaisy|rred|rrkasumi|rrmaverick|rrrecycle|rrvalentina|rsgoldstar|rshocked|rshout|rsk_gazer|rsk_ghost|rsk_ogre|rsk_pumpkin|rsk_sheep|rsk_skeleton|rsk_slime|rsk_stone|rsk_worm|rsk_zombie|rspider|rtfm|rtiki|rubber|rubberchicken|rubberduck|rubberducky|rubbermarble|rubiWink|rubik|ruby|rubyeye|rude|rufushurt|rufusjoking|rufussad|rufusscared|rufusserious|rufussmile|rui|rum|rumble|run|run_jimmy|rune|runecrying|runemaster|runeshock|runner|runrobotrun|ruskin|russianflag|rust|rustycup|rw|rwr|ryanohno|ryansad|ryanwink|rye|ryker|ryouta|s13eye|s13key|s3ancarian|s3khukuri|s3malakhim|s3safiri|s3seraphim|sa|sabaku|saberlizer|sabres|sacky|sacredtea|sad|sad_boulder|sad_creep|sadblup|sadcthulhu|sadcyclops|sadcyto|saddie|sadecho|sadeddy|sadelf|sadfaic|sadgrim|sadhear|sadja|sadleon|sadmum|sadness|sadpanda|sadpug|sadpunge|sadsadcyclops|sadskull|sadterry|sadz|saerlking|safe|safeharbor|safehouse|sage|sages|sagittarius|sail|sailingboat|sailor|saki|sakodama|sakuaki|sakura|sakurachan|sallet|salomemm3|salomm5|salt|saltshaker|salty|saltytears|salute|salvador|sam|samheart|sammich|sammy|sana|sand|sandshark|sandwatch|sandwich|sandwichaday|santa_hat|santahat|sapphire|sarah|sarah2|sarah3s|sarah5|sarah6|sarahbat|sarahblockhead|sarahbomb|sarahfire|sarahhat|sarahice|sarahskull|sardine|saren|sarge|sargec4|saru|satch|satellite|satsi|saturn|saucer|sauriansheild|savanthead|save_stone|savecomputer|savepoint|saviorsjohn|saviorsjonas|saviorsken|saviorsmanning|saviorsmona|sax|saxoncross|saxoncrown|saxondragon|saxonshield|say_what|sayaka|sbangry|sbconfused|sbhappy|sbrnbomber|sbsad|sbwink|sc|sc_gibberish|sc_love|sc_ouch|sc_skull|sc_stop|scampwick|scarabankh|scarecrow|scarecrowface|scaredTom|scared_eyes|scaredeets|scaredkid|scaredone|scaredspirit|scaredtodeath|scarmiglione|scarydoll|scarydude|scarygirl|scavenger|scheelite|scheinmask|scheinring|schooner|scibear|scienceninja|scifi|scifieye|scimitar|scmeyes|scmhappy|scmjoy|scmoof|scmsad|scope|scorepoint|scorne|scorpio|scouthead|screamcone|screamer|screamers|screamqueen|screenHill|screennade|screwdriver|screwdriverhammer|scribble|scribbleheart|scribblequestion|scribblesuprise|scribe|scrooge|scrubber|scthydroplane|scuba|scubatank|scull|scuttlebutt|scy5|scythe|scythes|scytheworm|sdadol|sdbomb|sdchester|sddogi|sdelena|sdfood|sdpipe|sdprod|sdres|sea_monster|seabornef|seagull|seahat|seal|season_bee|season_bottle|season_coin|season_symbol|season_voodoo|secrectorder|secret|secretary|secretingredient|sectoid|security|seed|seele|seg|sein|selena|selfburn|selfcloak|selfmaderocket|selma|selphinehappy|selva|senpai|sense|sensorbomb|sensorstation|sentientcrate|sentientplasma|sentinel|sentry|sentry_gun|sentrybot|seppuku|sera|sergeant|sergeantmajor|serious|seriousdetectivecase|seriouspewpew|serioussam|serpent|serpent_face|serpent_helen|serpent_kitty|serpent_sheriff|serpent_vendor|serum|served|servicemedal|sery|severedhead|sexyjohn|sexyprincess|sey|seymour|sfb|sfhappy|sforslash|sfsad|sfsmile|sfsmug|sfsurprise|sgbullet|sgnuclear|sgsmile|sgsr_captain|sgsr_gambler|sgsr_general|sgsr_pilot|sgsr_plane|sgsurvivor|sh3angry|sh3gearup|sh3knight|sh3shocked|sh_blue|sh_green|sh_purple|sh_red|sh_ship|shaaard|shades|shadeskull|shadow|shadow_sign|shadowcom|shadowgate|shadowgrounds|shadowrogue|shadows|shadowtail|shadyghost|shaka|shamans_mask|shamil|shammer|shangurmagic|shankgun|shanksaw|shankskull|shantae|shantae_elephant|shantae_harpy|shantae_monkey|shantae_relax|shantae_sky|shantae_smile|shantae_wrench|shapechanger|shapeshifter|shar|shard|sharebear|shareblood|shark|sharkfin|sharpe|sharpness|sharpshuriken|shatplan|shay|shcfire|shcflag|shchess|shcscribe|shcshield|shcsword|shdragon|sheephead|sheepie|sheepify|sheeple|shell|shellBC|shells|shellshock|shelterbadger|shelterbird|shelterfox|shelterfrog|shelterwildfire|shen|shenandorah|shenyangj8|sheridan|sheriffsbadge|sherlockhead|sherry|shertul|shflag|shibuya|shield|shield12|shield_up|shieldgen|shieldgenerator|shielding|shieldsup|shieldsword|shieldup|shieldworks|shieldyourass|shifter|shifty|shigure|shinbiMilk|shinto|shiny|ship|shipanchor|shipblueprint|shipcaptain|shipenergy|shipexplode|shipping|shipwheel|shipwreckbow|shipwrecklantern|shipwreckpickaxe|shipwreckshield|shipwrecksword|shiraz|shiva|shivahstar|shkbread|shkcheese|shkgold|shkmeat|shkstone|shlam|shmedallion|shmup|shnotebook|shock_rune|shocked|shockedhero|shocking|shockjockey|shodan|shoe|shoggoth|shoota|shooter|shooterflea|shopkeeper|shoppingcart|shoppingspree|shorg|shot|shotgun|shotgunbreach|shotshell|shotshells|shou|shovel|shovelknight|shpickle|shpistol|shred|shrine|shroom|shrub|shrunken|shshield|shsword|shtoln|shuriken|shuttle|shutyoureyes|shymisa|shynie|si|sian|sickle|sider|siegefleet|siegrune|sights|sigil|sign|signboard|signey|signpost|signsoflife|silber|silhouette|sill|silver|silverartifact|silverbullet|silvercup|silverdollar|silvermedal|silverplates|simon|simplepinkheart|sin|singlebanana|singleton|sinnersandwich|sir|siren|sistertabitha|sit|sixshooter|sixty|skbarrel|skbomb|skel|skeledead|skelejoe|skeletonwarrior|skelly|sketchymushrooms|skhand|skheart|skillcontruction|skilldexterity|skillforce|skillhealth|skilltome|skillwisdom|skknight|skldth|skogul|skorpion|skreech|skstopsign|sksword|sktrafficcone|skuld|skull|skull1|skull2|skull_sign|skullbomb|skullboy|skullcap|skullcat|skullcc|skuller|skulleton|skullgem|skullgib|skullgirl|skullheart|skullicon|skullie|skullmask|skullmate|skulls|skullsign|skullsquad|skulltoss|skullwrath|skullx|skully|skullz|skunklogo|skybornangry|skybornannoyed|skyborngrin|skybornhappy|skybornsad|skycrystal|skyecute|skyelaugh|skyeooh|skyesad|skyesmile|skyguard|skylasergun|skymerc|skypeople|slag|slak|slash|slashsword|slaveling|slayer|sldbaba|sldcat|sldcurly|slddracula|sldfaith|sldit|sldlily|sldlizzy|sldmuggles|sldwriter|sledgehammer|sleek|sleep|sleepingMouse|sleepingcat|sleepingsheep|sleepingspirit|sleepingwizard|sleepmode|sleeptime|sleepy|sleepyCP|sleepyflem|slender|slendy|slick|slim|slime|slothteddy|slotmachine|slow|slug|slugpoo|slugvenus|slugworm|slurper|sm|small_battery|smallbee|smallcreature|smallmedkit|smart|smartmine|smartphone|smartsam|smashy|smaug|smc|smdc|smelltree|smellyvenus|smg|smile|smile_dyl|smilecyto|smilekit|smiley|smileyface|smileymud|smileyvirus|smilingreia|smith|smithy|smkg|smm|smmstone|smoke|smoking|smooch|smrdrifter|smrgravity|smrnitro|smrsuperjump|smrteleporter|sms|smug|smuggrim|snack|snacker|snadobja|snaggletooth|snail|snake|snarky|sncoin|sneak|sneaker|sneakers|sneakingspirit|sneakyRouge|sneakyjester|snipe|sniperbrain|sniperelite|sniperscope|sniperskull|sniping|snooze|snorkulus|snowball|snowbro|snowflake|snowglobe|snowpard|snowtiger|so_angry|soap|soccerball|sofiya|softbear|sohappy|soiLoveLetter|solar|solarixeye|soldier|soldierblack|soldierblue|soldierred|solitude|solvent|somanto|sombrero|sonata|soniamdisappoint|sonic|sorcerer|sosad|soso|sotachaos|sotacombat|sotacrafting|sotamagic|sotavirtue|sotb|sotd|soul_bolas|soul_candle|soul_lamp|soul_lantern|soul_skull|soulduck|souleye|souleye1|soulmonkey|soulmonkey2|soulmonkey3|soulmonkey4|soulmonkey5|soulorb|soulshark|soulwhale|soundbubble|soundheart|soundhomey|soundplus|soundspike|source|southernbelle|sovereign|soviet|sovietsign|sovietunion|sovunicorn|sow_info|sow_move|sow_rotate|sow_star|sow_time|spComet|spExplosion|spMoon|spRocket|spSun|spacebeer|spacebooze|spaceburger|spacedisk|spaceduck|spaceearth|spacefacehappy|spacefish|spaceflight|spacehelmet|spaceinvader|spacemarine|spacemarinecrosshair|spacemarineshield|spacemarineskull|spacemine|spacemonster|spaceplane|spacepony|spaceprobe|spacepunk|spacerunplanet|spacerunship|spacerunskull|spacerunstar|spacerunthruster|spaceship|spacesun|spaceworm|spade|spain|spark|sparkles|sparta|spasm|spatial|spatula|spazdreaming|spazdunno|spazhorror|spaztears|spazterror|spazwinky|speak|special|specialist|specialsnowflake|specs|specterknight|spectraball|speech|speechless|speed_rune|speedball|speedboost|speedcola|speeddemon|speeder|speedup|speedy|spellbook|spellplague|spelunky|sperm|spg2anarchy|spg2bomb|spg2devil|spg2skull|spg2wolf|sphere|spherebot|sphereoff|spherical_scenery_of_creation|spice|spicy|spider|spiderpax|spiffo|spike|spikeball|spikedsword|spikehair|spikes|spikespore|spikey|spiky|spino|spinycrawler|spirallove|spiraltroll|spiritblades|spiritboard|spirits|spiteghost|splash|splashecho|splatter|split|splitskull|splode|spooky|spookymoon|spookyradio|spoon|sporemine|spot|spraycan|spraypaint|springroll|sprintcup|spriter|sproggi|sproggifear|sproggiflame|sproutella|spryfox|spud|spy|spycon|spyglass|spying|spyowl|spyplant|squawk|squid|squidcat|squinky|squire|squirehead|squirrel|squirrel_blue|squirrel_cartridge|squirrel_green|squirrel_orange|squirtheh|squirtmeh|squirtooh|squirtyay|squishyapple|squishybox|squishydynamite|squishyshead|squishysilverkey|sr4|sr4eagle|sr4fleurdelis|sr4paul|sr4sunglasses|srfrag|sriabelle|srpgdiamond|srpgmithril|srpgpalladium|srpgsilverkey|srpgxorb|ss13axe|ss13blood|ss13brain|ss13down|ss13drill|ss13guts|ss13hammer|ss13head|ss13heart|ss13ok|ss23|ss2bunnies|ss2bunny|ss2cat|ss2flag|ss2heart|ss2magic|ss2sparkle|ss2sparkles|sschool|ssh|ssl|sspalien1|sspalien2|sspalien3|sspalien6|ssrvaxe|ssrvsyringe|ssz|stabby|staff|stag|stage|stage1caterpillar|stagrin|stahappy|stain|stainedshard|stainedshard_green|stainedshard_red|stainedshard_yellow|stainremover|stake|stamad|stan|standardistheway|stapants|stapink|star|starattack|starbacon|starconf|starcrest|starcrusher|stare|starecat|starempty|starfighter|starfish|starfull|staring_dorf|starite|starplatinum|starry|stars|starsandstripes|starshipdilane|starshipphaser|starshipplanet|starshiprobot|starshipspacesuit|starstruck|starus|statbot|static|statup|stawtf|staynpixelartangry|staynpixelartneutral|steadfast|steak|steal|stealing|stealthcoil|steamflake|steamtrooper|steamwings|steelchair|steelgolem|steelhelmet|steerme|stef|steggy|stein|stellar|stepback|stepecho|steps|stereodial|stern|stickgrenade|stickman|sticky|stiggyeggghost|stinky|stockcar|stogie|stoic|stone|stoneface|stonehatchet|stonehold|stoneofmagic|stoner|stoneskull|stop|stophand|stopsign|stoptime|stopwatchpcm|stormbow|stoss|stout|stp|stpeterdome|str|strangephial|stranger|straw_hat|strawberries|strawberry|strawberryNKOA|stream|streetthug|strengomo|strength|stress|stressedterry|strife|strike|strikefighter|strikeit|stripedgum|strong|strongarm|strongest|structure|study|stungrenade|stunned|stunnedfairy|stunner|stuntrap|sturmpanzer|styx|styx2|styx3|styxeye|styxknife|styxphial|styxpouch|styxskull|styxtree|subob|subway|suck|sudeki|sugarshack|sugarskull|sui|suiskull|suit|summer_cup|summer_magic|summerghost|summermoon|summerskull|summersun|summerufo|summeryeti|sumoboot|sumocrown|sumotophat|sun|sun_energy|suncola|sundae|sunflower|sunglasses|sunglassesman|sunjump|sunportal|sunracer|sunshinefaerie|sunsigil|sunspeed|suntri|sunwukong|super|super_Attack|supercocktail|superel|superman|supernashwan|superninja|superpax|superpotion|supersadface|supertruck|supplicant|supplies|support|surprise|surprised|surprised_clony|surprisedcow|surprisedleon|surprisemaxwell|surtur|survivor|susanaflower|sushi|sushidad|suspense|suzuka|suzukimm5|sv_angel|sv_blue|sv_default|sv_happy|sv_oops|sv_red|sv_sad|sv_shocked|sv_wink|svarts|svas|sve|svecom|svemedkit|sverat|sverelic|svering|sverocket|svescanner|svesigil|sveskey|sw0rd|sw3datastorage|sw3eavedev|sw3epod|sw3epodred|sw3precartbat|sw3precskull|swapperorb|swatshield|swcoins|swcrown|swdboozer|swdcranky|swddarkrusty|swdlola|swdmecha|swdrusty|swdshiner|swdshinersleep|swdtrilobite|sweat|sweatdrop|sweatingit|sweetandsour|sweetdog|sweets|swhappy|swice|swift|swill|swipe|swipecartlogo|swiperacer|swirlyglasses|switch|swooper|sword|sworder|swords|swrboss|swrdoggie|swrfire|swrrobo|swrwitch|swshield|syll|symammiel|symantbear|symbol|symcaleb|symeye|symflower|symoctodog|symplant|synchronous|synicle|syringe|szone|tableflip|tablet|tabu|tabula|tactician|taifelel|tail|takashi|take|takemewithyou|takio|tal|talandra|talisman|talkingrucksack|tallowmere|talon|taloslol|tam_tam|tanchik|tang|tangfin|tank|tank1|tank_mine|tankard|tanksfornothing|tankussr|tankyou|tanuki|tap|tape|taperecorder|tapewithmusic|tara|target|targeted|targeting|tarn|tarskull|tarus|tass|tastyplanet|taunt|taurus|taxi|tazer|tballed|tbcoffee|tbcommander|tbcowfall|tbfrigate|tbhamster|tbhappy|tbknight|tblao|tblatha|tbpangry|tbpblush|tbpbook|tbpgloomy|tbphappy|tbpizza|tbpsad|tbpsleep|tbptongue|tbpwink|tbpwtf|tbregis|tcheco|tchecoscream|tchecosmile|tcironaxe|tcironhatchet|tclantern|tcrow|tcry|tcstoneaxe|tcstonehatchet|tcturnip|tdaadr|tdaber|tdaglock|tdamedkit|tdasw|tdealwithit|tdlgasmask|tdlsiren|tdlstray|tdlzombie|tdlzombull|teabag|teabagged|teacup|teal|tealeaf|teammate|teamwork|teardrops|tec|tec2artifact|tec3001|tech|technocrat|technozoologicalist|techtyler|techy|ted|teddy|teddy_paddle|teddybear|tedhead|teeth|tegabangu|teiZzz|teladi|telephonyghost|teleport|teleporter|telina|templars|tempra|tenbucks|tentacles|tera_alert|tera_attack|tera_aware|tera_derp|tera_enraged|tera_helm|tera_threat|terminal|terrainwalker|terran|terran_gsb|terranova|terraria|terrestrial|terror|terrorhedron|terrorlaser|terrorphoton|terrorplasma|terrorvacuum|terry|teslacat|teslakid|teslastaff|testchamber|testtube|tetley|tetris|tetrobot|teuthus|tf_arrows|tf_cyan|tf_green|tf_orange|tf_pink|tfmball|tgrin|thankyou|thatrabbit|the|theLeaf|theM|theShipCleaver|theShipCrowbar|theShipFireAxe|theShipGun|theShipWrench|theStone|the_bats|the_cleaner|the_egg|the_mastermind|the_spikes|the_stranger|the_walker|the_worm|thebackisback|thebag|thebarbarian|thebeast|theblueteam|thebomb|thebull|theburden|thebutt|thechairman|thechosen|thecity|thecleric|thecount|thecrucifix|thedragon|theeviltwin|theeye|theeyeball|thefeather|thefiance|thefinger|thefist|thefrog|thegirl|theglitch|thegrenade|theharmony|thehero|thehotdog|theinterceptor|thejackal|thejumper|thekey|thekid|theking|theliberty|themaestro|theman|themare|themark|themelody|themonk|themoon|thenative|theneon|thenomad|thenovelistbook|thenovelistdan|thenovelistfirstdraft|thenovelistlinda|thenovelisttommy|thenovelisttypewriter|theo|theorb|theorder|thepaladin|thepants|thepentagram|thepizza|theprincess|thepurplepatriot|theranger|therival|therogue|theshopkeeper|thesilverorb|thesniper|thestar|theta|thetramp|thetreasurechest|theundead|theuninvited|thewarrior|thewizard|thewolf|thewordofgod|theye|thief|thiefknife|think|thinkcyto|thoughtful|threebladed|threehearts|threestar|thrivaldi|throwingaxe|throwingknife|throwingstar|thug|thumb|thumbalift|thumbs|thumbsdown|thumbspoop|thumbsup|thumbup|thump|thunder|thunderheart|ti_badland|ti_clunk|ti_dust|ti_jitters|ti_knytt|ti_marvin|ti_runner|ti_scb|ti_tim|ti_tiny|tiaskull|tick|tidoberman|tiextinguish|tiffany|tiger|tihusky|tiki|tikitorch|tilasmouth|timalinois|time|time2|timebomb|timedynamite|timefist|timegoddess|timeisonmyside|timeperiod|timepwup|timer|timeup|tinamedal|tinkerbat|tinkersit|tinyBDiamond|tinyBFlex1|tinyBFlex2|tinyBFlex3|tinyBMeat|tinyBQuail|tinycoin|tinydiamond|tinyfeet|tinyferret|tinygoat|tinypig|tinytank|tinythief|tinythumbsup|tipheal|tipitbull|tipman|tipsy|tire|titanattacks|titancrystal|tl2engineer|tlove|tm1_ancestor|tm1_knight|tm1_michael|tm1_official|tm1_vivien|tm1_witch|tm2_doctor|tm2_ent|tm2_eye|tm2_leaf|tm_dragon|tm_orb|tm_tree|tm_wand|tmmbricks|tmmgun|tmmleaves|tmmpattern|tmmwindow|tmsArrow|tmsbook|tmsmoon|tmspole|tmstree|tmyk|tnt|tntflea|tntsticks|toadstool|toal|toast|toaster|toasty|tobias|toby|tof|togcake|together|togheal|toghorror|toglove|togmystery|togrocket|togsad|togsmile|togxp|toilet|tokarevpistol|tokitori|tomahawk|tomato|tomb|tomcat|tomeofmagic|tommygun|tomo|tomsbottle|toneh|tongue|toolkit|toolmantim|tooru|tooth|toothbrush|toothface|toothless|tootz|topduck|tophats|torch|torenexclamation|torensymbol|tornado|tornbanner|torpedo|torpedoes|torque|torqueduck|tosserbomb|totbomb|totbook|totchest|totcordial|totem|totfedora|totleaf|totmoney|totscrew|totskull|toughluck|tourist|towels|tower|tower1|towertnt|town_dweller|town_guard|towngem|tox|toxic|toxicbarrel|toxiccontent|toxictitan|toy|toycube|toyplane|toyrobot|trace|trackgo|trackstop|tractor|trade|trader|tradingcard|tradingcardfoil|trafficcone|train1|train2|train3|trainbowbarf|tram|trample|trance|tranq|trans|transcendentalmeowie|transistor|transpoship|trap|trapper|trash|trashpile|trazz|treasure|treasurebox|treasurechest|treb|treble|trebleclef|tree|treeker_glasses|treeoflife|triangel|triangle|tribe|tricks|trilogo|trinity|trip|triplegreen|triply|trippinflea|triquetra|tristan|triumph|trollclub|trolled|trolley|trolleybus|trollface_boulder|trolling|trolls|trolol|tron|troncycle|trondisc|trooper|trophy|tropicanstar|tropicoflag|troutslap|truck|truckBC|trueheart|truelove|trunk|trunks|trusky|tsalogo|tsc_bloodmoney|tsc_commando|tsc_ivan|tsc_kingofthehill|tsc_revolution|tsfmarine|tshock|tsukinowa|tsunami|tsuzu|ttaka|ttt_flower|ttt_gremlin|ttt_pumpkin|ttt_questionmark|ttt_tools|ttwammo|ttwcargo|ttwcompleting|ttwfire|ttwship|ttwwrench|tumbleweed|tunningblade|turbocharger|turborun|turret|turretboss|turtloghost|tuskeregg|tutu|tv|tvhead|tw|tw2dragon|twammo|twbuh|twelve|twonha|twp|twplus|twshield|twteamblue|twteamrandom|twteamred|twtimer|tycoon|tyderiummedal|tyger|tyler|typeI|typeII|typeIII|uberstrike|ufo|ufosaucer|uggo|uglydog|ultra|ultra_A|ultra_L|ultra_R|ultra_T|ultra_U|ultra_rare|ultratron|umad|umbrella|uncle_mimic|undbastien|undead|undfela|undflames|undies|undmarcus|undtroll|une|unhallowed|unhappyraider|unicorn|union|unionflag|unionjack|unipoop|unity|universe|unknownpotion|unobtanium|unpopular|up|uparrow|upgradechip|uplum|upperW|uproz|upvote|urapirate|urdead|urgle|urrrgggh|ursula|ursus|urth|usarmy|use|usffleetadmiral|usfmarine|usfpilothelmet|usoda|ustank|uturn|uv_lightbulb|uwodove|uwoexit|uwomoon|uwoskull|uwosword|uwotm8|uzi|v|vahlen|vajra|valette|valiantanna|valiantemile|valiantfreddie|valiantkarl|valkyl|valve|vampire|vampirebite|vampstyle|vanilla|vanir|vanity|vasari|vascar|vault|vaultkey|vause|vaygr|vbox|vcdbin|vcdblood|vcdbucket|vcdjanitor|vcdmop|vcdmutant|vcdsign|vcdworker|vectorcoin|vectskull|veggie|vein|vella|venatorhelmet|vendetta|venom|venomclaw|venomousspider|venus|venusianbear|venusianbruiser|venusiancrawler|venusiansoldier|verawizard|vermis|versus|vert|verthandi|verve|veryhappyraider|veryunhappyraider|veteran|vflip|vh|vh2scar|vhbea|vhs|vhscar|vhsylph|vhuhra|viRage|vial|vic|vicious|vicky|victor|victoria|victoriacross|victory|victorypeacesign|vietrun|vietshot1|vietshot2|viking|vikinghelm|vikinghs|vikingshield|viktor|vile|vine|vinyl|violentcrime|violet|violettOK|violettcurious|violettfly|violettgrumpy|violettsneak|viper|viperbeetle|virginmary|virility|virus|visible|visionary|vitality|vlad|vladskull|vladv|vladwolf|vlc|vleft|voidtext|volcanic|volcanichammer|volley|volnov|voodoo|vorbis|vort|voss|vright|vs|vsgilda|vsign|vspancakes|vsreina|vsvladyn|vswyatt|vulbear|vulchicky|vulfishy|vultulips|vulture|vvoid|w|wa_potion|waah|wagon|wakefield|walker|walkerred|walkietalkie|wallofshame|walt|waltgrowl|waltherp38|walthowl|wanderer|wang_common|warband|warhorse|warlock|warlocks_hat|warlord|warlords|warmage|warn|warningred|warningsign|warningyellow|warp|warplate1|warplate2|warppot|warrior|warrior2|warriorhelmet|warsawpact|warskull|warsonyou|warstar|warthog|wasted|wat|wat_creep|watch|watcher|watcherfly|watching|watchingyou|watchman|watchyou|water_rune|watercraft|waterdrop|waterlily|watermagic|waterrune|waterwolf|wave|waveobstacle|waveycyclops|wax|wayfarer|waywand|wazapple|wazpear|wazpotion|wch|wcube|wdbdrink|wdbgun|wdbgunslinger|wdbscratch|wdbsurrender|weakling|weapon_axe|weasel|web|weed|weedy|weedywow|weenwoo|wela|welder|welderblock|wenk|werewolf|werewolfwolf|wfbullet|wfmerc|wftarget|wftogrin|wftogrumpy|wftohappy|wftolaugh|wftosad|wftosurprised|whale|what|whatever|whattahell|whatthenuts|wheel|wheelchair|wheelclock|wheelie|where|whichway|whine|whirlwind|whiskey|whiskeybottle|whisper|whistle|white|white_gam|white_jewel|white_pearl|whitebunny|whitecrate|whitecrow|whitecube|whitedress|whiteeye|whitefire|whitegel|whitegiant|whitehat|whitekitty|whiteknight|whitepix|whiter|whiterabbit|whiterose|whiterun|whitesheep|whiteskull|whitesuit|whitetile|whitetulip|whitewind|whitewing|whitmarsh|whoosh|whqgoblin|whqrat|whqskeleton|whqtroll|whqvampire|whqzombie|whuman|widebrimmedhat|widebrimmedhatII|widow|wiggly|wil|wilbur|william|willowisp|willy|wilogo|winch|windhelm|windmagic|windrune|wine|winebarrel|winebottle|winetime|wingL|wingR|wink|winkfairy|winkkit|winter_fl|wire|wiretangle|wisdom|wiseman|witch|witchdoctor|witches|wiz|wizard|wizardJellyfish|wizardhat|wizardmagic|wizorbhappy|wizorblaugh|wizorbneutral|wizorbsad|wizorbwink|wlf|wmmp|wnkbox|wnkskull|wnoannemarie|wnoblood|wnoflashlight|wnohannah|wnohorror|wnojeanluc|wnokurt|wnosarah|wnotape|wnotree|woah|woarbubble|woarchristina|woarcoulroz|woardiamond|woarfairy|woarhellena|woarmelrose|woarmrpurr|woarrose|wogsniper|wogtarget|wolf|wolf2|wolfenaxe|wolfenblade|wolffur|wolfguy|wolfpaw|wolfram|wolfteeth|wolftrap|wolfwoman|wolfy|wololo|wonderwoman|wonziu|woo|wood|wood_sword|woodcube|woodenaxe|woodencamel|woodle|woodleball|woodlebush|woodleenemy|woodleenemy2|woodleface|woodlefather|woodlehappy|woof|wool|woolfefeather|woolfelightbulb|woolfelion|woolfelogo|woolfescroll|wooly|woot|work|worker|workerbee|workofart|workowl|world|worldschain|worm|worm_dyl|wormeye|wormfood|wormwarp|worriedgrim|worriedjeff|worriedshio|worriedstarfish|wotm8|wow|wozhere|wpt|wrench|wrenchbush|wrencher|wrenchit|wrenna|wrynhappy|wrynscared|wsd_face|wsd_merc|wsd_skull|wsd_spider|wsma_disappoint|wsma_dontcare|wsma_drool|wsma_embarassed|wsma_happy|wsma_sakura|wtf|wtfgomo|wurmi|wut|wvarrow|wvclosed|wvfootsteps|wvtalk|wvturn|wvwait|wvwarning|ww|wwconsulate|wwexchange|wwpirate|wwsojourn|wwsyndicate|wwvaliant|wyv|x3|xbone|xboson|xengatarn|xenon|xenord|xenoufo|xeon|xerxes|xhair|xia|xindo|xioflower|xisa|xmark|xp|xplo|xray|xxx|yah|yak1|yak9|yaki|yang|yaranaika|yasd|yashu|yavannawink|yawn|yawning_creep|yawp|yay|yazdgirl|yazdguy|yazdsmile|yazdswat|yazdwink|yb|yblue|yellowFlowerNKOA|yellow_gem|yellow_jewel|yellowalert|yellowarrow|yellowbeat|yellowcard|yellowcoat|yellowcrate|yellowheart|yellowjelly|yellowjersey|yellowleaf|yellowlight|yellowmana|yellowpix|yellowporc|yellowradium|yellowrubberduck|yellowsamurai|yellowtaxi|yellowtri|yellowtwist|yellowwizard|yendor|yennefer|yeti|ygold|ygreen|yikes|yinandyang|yinyang|yinyangball|yisha|yo|yokai|yolo|yorick|yoricktheskull|yorksmokes|yoshimi|you|youareahammer|youarefree|young|yourFate|ypokka|yred|yuja|yujinSkull|yum|yummy|yunica|yuonknight|yuri|yuriRose|yurispaceship|yuryship|yusha|yushia|yuurei|yuzuki|yveen3s|za|zaerie|zaku|zaku2|zammo|zarp|zaw|zboss|zccrow|zcompass|zcrystal|zcskullbomb|zedrawr|zedtriumph|zeek|zelemir|zenura|zeppelin|zero|zeroface|zerog|zeye|zgblob|zgbunny|zgdemon|zgparty|zgrunt|zgsanta|zhand|zionHarp|zippo|zjeep|zmey|zoccer|zomb|zombhead|zombie|zombiecat|zombiecreep|zombiedogpoo|zombieemo|zombieeye|zombiefart|zombiehead|zombierunner|zombieskull|zombiestare|zombiethumbsup|zombieva|zombieworm|zombiez|zombify|zombuckz|zooanaconda|zooelephant|zoogiraffe|zook|zoopenguin|zoopolarbear|zoorampage|zoorhinoceros|zootiger|zoozebra|zoya|zoya2|zpills|zpsycho|zscroll|zsniper|zssconstruction|zssexplosion|zsslaser|zsspsycho|zsspyro|zsssniper|zssspy|zsstechnician|zssz|zsszod|ztank|ztough|ztrap|ztreasure|zward|zyr|zytron|zz|zzacid|zzcarniplant|zzenergy|zzod|zztime|zztrophy|zzz|zzzz|zzzzz]]

local function MaterialData(mat)
	local ret = Material("../data/" .. mat)

	return ret
end

local UNCACHED=false
local PROCESSING=true

local cache = {}
local inSplitPattern="|"

local theStart = 1
local theSplitStart, theSplitEnd = string.find( EMOTICONS, inSplitPattern, theStart, true )
while theSplitStart do
	cache[string.sub( EMOTICONS, theStart, theSplitStart-1 ) ]=UNCACHED
	theStart = theSplitEnd + 1
	theSplitStart, theSplitEnd = string.find( EMOTICONS, inSplitPattern, theStart, true )
end
cache[string.sub( EMOTICONS, theStart ) ] = UNCACHED

local FOLDER="steam_emoticons_big"
file.CreateDir(FOLDER,'DATA')

function GetSteamEmoticonCache()
	return cache
end

function GetSteamEmoticon(name)
	local c = cache[name]
	if c then
		if c==true then return end
		return c
	else
		if c==nil then return false end
	end
		
	-- Otherwise download dat shit
	cache[name] = PROCESSING
		
	local path = FOLDER..'/'..name..'.png'
	
	local exists=file.Exists(path,'DATA')
	if exists then
	
		local mat = MaterialData(path)

		if not mat or mat:IsError() then
			Msg"[Emoticons] "print("Material found, but is error: ",name,"redownloading")
		else
			cache[name] = mat
		end
		
	end
	
	local url = 'http://steamcommunity-a.akamaihd.net/economy/emoticonhover/'..name
	--local url = 'http://cdn.steamcommunity.com/economy/emoticon/'..name
	local function fail(err)
		Msg"[Emoticons] "print("Http fetch failed for",url,": "..tostring(err))
	end
	
	http.Fetch(url,function(data,len,hdr,code)
		if code~=200 or len<=222 then
			return fail(code)
		end
		
		local start,ending=data:find([[src="data:image/png;base64,]],1,true)
		if not data then return fail"ending" end
		
		local start2,ending2=data:find([["]],ending+64,true)
		if not start2 then return fail"start2" end
		
		data = data:sub(ending+1,start2-1)
		if not data or data=="" then return fail"sub" end
		
		data = base64.decode(data)
		if not data or data=="" then return fail"Base64Decode" end
		
		file.Write(path,data)
		
		local mat = MaterialData(path)

		if not mat or mat:IsError() then
			Msg"[Emoticons] "print("Downloaded material, but is error: ",name)
			return
		end
		
		cache[name] = mat
		
	end,fail)
end

local GetSteamEmoticon=GetSteamEmoticon

local expression = atlaschat.expression.New("<semote>(.-)</semote>", "semote")

expression.cleanName = "<semote> </semote>"

function expression:Execute(base, emote)
	local image = base:Add("Panel")
	image:SetSize(54, 54)
	image:SetToolTip(emote)
	image:SetMouseInputEnabled(true)

	function image:Paint(w, h)
		local material = GetSteamEmoticon(emote)

		if (material) then
			surface.SetMaterial(material)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end
	
	image.toolTip = emote
	
	function image:OnCopiedText()
		return "<semote>" .. self.toolTip .. "</semote>"
	end
	
	return image
end

function expression:GetExample(base)
	return "<semote>1questdizzy</semote>", self:Execute(base, "1questdizzy")
end

-- vk.com/urbanichka