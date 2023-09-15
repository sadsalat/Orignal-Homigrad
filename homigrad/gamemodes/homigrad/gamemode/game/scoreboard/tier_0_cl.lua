function SB_PaintButton(self,w,h)
	surface.SetDrawColor(0,0,0,self:IsDown() and 225 or 200)
	surface.DrawRect(0,0,w,h)

	surface.SetDrawColor(255,255,255,16)
	surface.DrawRect(0,0,w,1)
	--surface.DrawRect(0,0,1,h)

	/*surface.SetDrawColor(0,0,0,128)
	surface.DrawRect(0,h - 1,w,1)
	surface.DrawRect(w - 1,0,1,h)*/

	if not self:IsDown() and self:IsHovered() then
		surface.SetDrawColor(255,255,255,5)
		surface.DrawRect(0,0,w,h)
	end

	draw.SimpleText(self.text,"HomigradFont",w / 2,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

function SB_CreateButton(parent)
	local button = vgui.Create("DButton",parent)
	button:SetText("")
	button.Paint = SB_PaintButton
	return button
end