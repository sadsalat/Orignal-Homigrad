surface.CreateFont("atlaschat.slider.text", {font = "DeJaVu Sans", size = 12, weight = 400})

local panel = {}

AccessorFunc(panel, "m_iMin", "Min")
AccessorFunc(panel, "m_iMax", "Max")
AccessorFunc(panel, "m_iRange", "Range")
AccessorFunc(panel, "m_iValue", "Value")
AccessorFunc(panel, "m_iDecimals", "Decimals")
AccessorFunc(panel, "m_fFloatValue", "FloatValue")

local color_line = Color(255, 255, 255, 120)
local color_knob_inner = Color(41 +40, 128 +40, 185 +40)
local color_background = Color(255, 255, 255, 250)

----------------------------------------------------------------------
-- Purpose:
--		Called when the panel is created.
----------------------------------------------------------------------

function panel:Init()
	self:SetMin(2)
	self:SetMax(10)
	self:SetDecimals(0)
	
	local min = self:GetMin()
	
	self.Dragging = true
	self.Knob.Depressed = true
	
	self:SetValue(min)
	self:SetSlideX(self:GetFraction())
	
	self.Dragging = false
	self.Knob.Depressed = false
	self.Knob:SetSize(9, 9)
	
	function self.Knob:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, color_background)
		draw.RoundedBox(4, 1, 1, w -2, h -2, color_knob_inner)
	end
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:SetMinMax(min, max)
	self:SetMin(min)
	self:SetMax(max)
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:SetValue(value)
	value = math.Round(math.Clamp(tonumber(value) or 0, self:GetMin(), self:GetMax()), self.m_iDecimals)
	
	self.m_iValue = value
	
	self:SetFloatValue(value)
	self:OnValueChanged(value)
	self:SetSlideX(self:GetFraction())
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:GetFraction()
	return (self:GetFloatValue() -self:GetMin()) /self:GetRange()
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:GetRange()
	return (self:GetMax() -self:GetMin())
end

----------------------------------------------------------------------	
-- Purpose:
--		
----------------------------------------------------------------------

function panel:TranslateValues(x, y)
	self:SetValue(self:GetMin() +(x *self:GetRange()))
	
	return self:GetFraction(), y
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:OnValueChanged(value)
end

----------------------------------------------------------------------	
-- Purpose:
--		Called whenever the panel should be drawn.
----------------------------------------------------------------------

function panel:Paint(w, h)
	draw.SimpleRect(0, h /2 -1, w, 2, color_line)
end

----------------------------------------------------------------------
-- Purpose:
--		
----------------------------------------------------------------------

function panel:PaintOver(w, h)
	if (self.Hovered or self.Knob.Hovered or self.Knob.Depressed) then
		surface.DisableClipping(true)
			draw.SimpleText(self:GetValue(), "atlaschat.slider.text", self.Knob.x -1 +self.Knob:GetWide() /2 +1, self.Knob.y -8, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(self:GetValue(), "atlaschat.slider.text", self.Knob.x -1 +self.Knob:GetWide() /2, self.Knob.y -9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface.DisableClipping(false)
	end
end

vgui.Register("atlaschat.slider", panel, "DSlider")

-- vk.com/urbanichka