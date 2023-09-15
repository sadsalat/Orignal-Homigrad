local PANEL = ents.Get("v_panel")
if not PANEL then return end

local Panel = FindMetaTable("Panel")

PANEL:Event_Add("Init","Transform",function(self)
	self.xx = 0
	self.yy = 0

	self.w = 0
	self.h = 0
	self.ww = 0
	self.hh = 0

	self.dx = 0
	self.dy = 0

	self.dw = 0
	self.dh = 0

	self.ax = 0
	self.ay = 0

	--

	self.x2 = 0
	self.y2 = 0

	self.w2 = 0
	self.h2 = 0

	self.dx2 = 0
	self.dy2 = 0

	self.dw2 = 0
	self.dh2 = 0

	self.ax2 = 0
	self.ay2 = 0

	self.x = 0
	self.y = 0

	self[1] = 0
	self[2] = 0

	self[3] = 0
	self[4] = 0--content size

	self.wp = 0
	self.hp = 0
end,-1)

local SetParent = Panel.SetParent

function PANEL:SetParent(panel)
	if not IsValid(panel) then return end

	SetParent(self,panel)
	self:Transform()
end

local SetPos = Panel.SetPos
local SetSize = Panel.SetSize

function PANEL:TransformApply()
	local parent = self:GetParent()

	local w,h = parent.w or parent:GetWide(),parent.h or parent:GetTall()

	self.w = self.ww + w * self.dw
	self.h = self.hh + h * self.dh

	self.x = self.xx + w * self.dx - self.w * self.ax--WAAAAAAAAAYYYYYYYYYYYYYYYYYY.......... иди нахуй
	self.y = self.yy + h * self.dy - self.h * self.ay

	SetSize(self,self.w,self.h)

	for i,panel in pairs(self:GetChildren()) do
		if panel.TransformApply then
			panel:TransformApplyAllTags()
			panel:TransformApply()
		end
	end

	local x,y = 0,0

	for i,panel in pairs(self:GetChildren()) do
		local xx,yy = panel.x + panel.w,panel.y + panel.h

		if xx > x then x = xx end
		if yy > y then y = yy end
	end

	self.contentW = x
	self.contentH = y
end---WAAUUUYyy

function PANEL:TransformEmit()
	if self.OverrideTransform then return end
	self.OverrideTransform = true

	self:Event_Call("Transform")

	for i,panel in pairs(self:GetChildren()) do
		panel:TransformEmit()
	end

	self.OverrideTransform = nil
end

local x,y,dX,dY,w,h,dW,dH,aX,aY
local apply
local parent,wp,hp

function PANEL:Transform()
	parent = self:GetParent()
	apply = false

	if not parent.w then
		wp,hp = parent:GetWide(),parent:GetTall()

		if self.wp ~= wp then self.wp = wp apply = 1 end
		if self.hp ~= hp then self.hp = hp apply = 2 end
	end

	x,y,dx,dy,w,h,dw,dh,ax,ay = self.xx,self.yy,self.dx,self.dy,self.ww,self.hh,self.dw,self.dh,self.ax,self.ay

	if self.x2 ~= x then self.x2 = x apply = 3 end
	if self.y2 ~= y then self.y2 = y apply = 4 end
	if self.dx2 ~= dx then self.dx2 = dx apply = 5 end--dX
	if self.dy2 ~= dy then self.dy2 = dy apply = 6 end

	if self.w2 ~= w then self.w2 = w apply = 7 end
	if self.h2 ~= h then self.h2 = h apply = 8 end
	if self.dw2 ~= dw then self.dw2 = dw apply = 9 end
	if self.dh2 ~= dh then self.dh2 = dh apply = 10 end

	if self.ax2 ~= ax then self.ax2 = ax apply = 11 end
	if self.ay2 ~= ay then self.ay2 = ay apply = 12 end

	if apply then
		self:TransformApply()
		self:TransformEmit()
	end
end--ну х3.;c

function PANEL:TransformApplyAllTags()
	self.x2 = self.xx
	self.y2 = self.yy
	self.dx2 = self.dx
	self.dy2 = self.dy
	self.w2 = self.ww
	self.h2 = self.hh
	self.dw2 = self.dw
	self.dh2 = self.dh
	self.ax2 = self.ax
	self.ay2 = self.ay

	local parent = self:GetParent()
	if not parent.w then
		self.wp = parent:GetWide()
		self.hp = parent:GetTall()
	end
end

PANEL:Event_Add("Think","Transform",PANEL.Transform,-1)