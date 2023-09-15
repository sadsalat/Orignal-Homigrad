
include "wac/keyboard.lua"

local panel={}
local editTime=0

surface.CreateFont("wac_keypanel", {
	font = "Tahoma",
	size = 14
})

function panel:Init()
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	local w,h = self:GetParent():GetWide(),20
	self:SetSize(w,h)
	self.label = vgui.Create("DLabel", self)
	self.label:SetPos(5,0)
	self.label:SetFont("wac_keypanel")
	self.label:SetText("")
	self.label:SetSize(w/2,h)
	self.key = vgui.Create("DLabel",self)
	self.key:SetFont("wac_keypanel")
	self.key:SetPos(w/2,0)
	self.key:SetSize(w/2,h)
	self.key:SetText("")
	self.key.__IsVisible=true
end

function panel:setLabel(t)
	self.label:SetText(t)
end

function panel:setKey(k)
	self.key:SetText(wac.key.name(k))
	self.keyNum=k
	self.oldkey=k
end

local current

function panel:updateKey(k)
	current = nil
	if self.Function then
		self.Function(k,self.keyNum)
	end
	if self.runCommand then
		RunConsoleCommand(self.runCommand, k)
	end
	self.oldkey = self.keyNum
	self.keyNum = k
	--self.key:SetText(WAC.key[k] and WAC.key[k].n or WAC.key[0].n)
	self:SetEdit(false)
end

wac.key.addHook("wac_key_panel", function(key, pressed)
	if pressed and IsValid(current) and current.editing and editTime+0.1<CurTime() then
		current:updateKey(key)
	end
end)

function panel:SetEdit(b)
	if b then
		self.key:SetText("Enter key..")
	else
		self.key:SetText(wac.key.name(self.keyNum))
		current=nil
	end
	self.editing = b
end

function panel:OnMousePressed(mc)
	if current==self and self.editing then return end
	if mc==MOUSE_LEFT then
		editTime=CurTime()
		if current and IsValid(current) then
			current:SetEdit(false)
			current=nil
		else
			current=self
			self:SetEdit(true)
		end
	elseif mc==MOUSE_RIGHT then
		editTime=CurTime()
		if IsValid(current) and current!=self and current.editing then
			current:SetEdit(false)
		end
		self:updateKey(0)
	end
end

local color = {
	key = Color(100, 100, 100, 255),
	background = Color(90, 90, 90, 255),
	editing = Color(150, 150, 150, 255)
}

function panel:Paint()
	local w,h = self:GetSize()
	draw.RoundedBox(1, 0, 0, w, h, color.background)
	draw.RoundedBox(1, w*0.5, 1, w*0.5-2, h-2, color.key)
	if(self.editing) then
		draw.RoundedBox(1, w*0.5, 1, w*0.5-2, h-2, color.editing)
	end
end

function panel:Think()
	if self.runCommand then
		local key = GetConVar(self.runCommand):GetInt()
		if key != self.keyNum then
			self:updateKey(key)
		end
	end
end

wac.hook("SpawnMenuOpen","wac_key_panel_opensm", function()
	if IsValid(current) and current.editing then return false end
end)

wac.hook("Initialize", "wac_key_panel_initgm", function()

	local contextClose=GAMEMODE.OnContextMenuClose
	local contextOpen=GAMEMODE.OnContextMenuOpen
	local menuClose=GAMEMODE.OnSpawnMenuClose
	
	function GAMEMODE:OnContextMenuClose()
		if IsValid(current) and current.editing or !contextClose then return end
		wac.contextMenuOpen=false
		contextClose(self);
	end
	
	function GAMEMODE:OnContextMenuOpen()
		if IsValid(current) and current.editing or !contextOpen then return end
		wac.contextMenuOpen=true
		contextOpen(self)
	end
	
	function GAMEMODE:OnSpawnMenuClose()
		if IsValid(current) and current.editing or !menuClose then return end
		wac.spawnMenuOpen=false
		menuClose(self)
	end
	
	--[[function GAMEMODE:OnSpawnMenuOpen()
		if IsValid(current) and current.editing then return end
		wac.spawnMenuOpen=true
		mopen(self)
	end]]
end)

vgui.Register("wackeyboard::key", panel, "Panel")
