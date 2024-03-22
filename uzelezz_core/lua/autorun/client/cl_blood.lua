hook.Add(
	"RenderScreenspaceEffects",
	"ToyssssnssssEffect",
	function()
		local bloodlevel = LocalPlayer():GetNWInt("Blood", 5000)
		local painlevel = LocalPlayer():GetNWInt("pain", 5000)
		local fraction = math.Clamp(1 - ((bloodlevel - 3200) / ((5000 - 1400) - 2000)), 0, 1)
		DrawToyTown(fraction * 8, ScrH() * fraction * 1.5)
		if fraction > 0.93 then
			DrawMotionBlur(0.2, 0.9, 0.03)
			local fraction1 = math.Clamp(1 - (painlevel / 250), 0.25, 1)
			local tab = {
				["$pp_colour_contrast"] = fraction1
			}

			DrawColorModify(tab)
		end
	end
)

net.Receive(
	"ragplayercolor",
	function()
		local ent = net.ReadEntity()
		local col = net.ReadVector()
		if IsValid(ent) and isvector(col) then
			function ent:GetPlayerColor()
				return col
			end
		end
	end
)

surface.CreateFont("thehomigeadfont", {
    font = "Exo 2 Medium",
    extended = true,
    size = ScreenScale(25),
    antialias = true,
    weight = 500,
	blursize = 0
})
surface.CreateFont("bluredfont", {
    font = "Exo 2 Medium",
    extended = true,
    size = ScreenScale(25),
    antialias = true,
    weight = 500,
	blursize = 2
})

surface.CreateFont("smalledfont", {
    font = "Exo 2 Medium",
    extended = true,
    size = ScreenScale(7),
    antialias = true,
    weight = 500,
	blursize = 0
})

surface.CreateFont("buttofont", {
    font = "Exo 2 Medium",
    extended = true,
    size = ScreenScale(10),
    antialias = true,
    weight = 500,
	blursize = 0
})

local function Spalchscreen()

	local faded_black = Color(0, 0, 0, 255) -- The color black but with 200 Alpha
	local whitecolor = Color(255,255,255,0)
	local opentime = CurTime() + 5
	local closetime = CurTime()
	local DFrame = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
	DFrame:SetPos(0, 0) -- Set the position to 100x by 100y. 
	DFrame:SetSize(ScrW(), ScrH()) -- Set the size to 300x by 200y.
	DFrame:ShowCloseButton( false )
	DFrame:SetTitle("") -- Set the title in the top left to "Derma Frame".
	DFrame:SetDraggable(false) -- Makes it so you can't drag it.
	DFrame:MakePopup() -- Makes it so you can move your mouse on it.

-- Paint function w, h = how wide and tall it is.
	DFrame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, faded_black)
	    if DFrame.GoClose then
	    	faded_black.a = math.Clamp(655*( ( (closetime) - CurTime() )/2),0,255)
	    	whitecolor.a = math.Clamp(655*( ( (closetime) - CurTime() )/2),0,255)
	    	if whitecolor.a <= 0 then
	    		self:Close()
	    	end
	    else
		    whitecolor.a = math.Clamp(655*(1 - ( (opentime) - CurTime() )/4),0,255)
		end

		draw.SimpleText("Orignal Homigrad", "bluredfont", w/2, h/3 + 2, whitecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText("Orignal Homigrad", "thehomigeadfont", w/2, h/3, whitecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		whitecolor.a = whitecolor.a/6
		draw.SimpleText("by sadsalat and uzelezz", "smalledfont", w/2, h/2.4, whitecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	end

	local DermaButton = vgui.Create( "DButton", DFrame )
	DermaButton:SetPos( ScrW()/2-150, ScrH()/1.8-25 )
	DermaButton:SetSize( 300, 50 )
	DermaButton:SetText("")
	DermaButton.DoClick = function()
		if DFrame.GoClose then return end
		surface.PlaySound( "ui/buttonclickrelease.wav" )
		closetime = CurTime() + 1
		DFrame.GoClose = true
	end
	local play = false
	local color = Color(55,55,55,0)
	DermaButton.Paint = function(self, w, h)
		draw.RoundedBox(0,0,0,w,h,color)
		if self.Hovered then
			if not self.play then
				surface.PlaySound( "ui/buttonrollover.wav" )
				self.play = true
			end
		else
			self.play = false
		end

		if DFrame.GoClose then
			color.a = math.Clamp(655*( ( (closetime) - CurTime() )/2),0,255)
		else
			color.a = math.Clamp(655*(1 - ( (opentime) - CurTime() )/4),0,255)
		end

		surface.SetDrawColor( 255, 255, 255, color.a )
		surface.DrawOutlinedRect( 0, 0, w, h, 2 )

		whitecolor.a = whitecolor.a*6

		draw.SimpleText("Play", "buttofont", w/2, h/2, whitecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
	end

	local DermaButton = vgui.Create( "DButton", DFrame )
	DermaButton:SetPos( ScrW()/2-150, ScrH()/1.6-25 )
	DermaButton:SetSize( 300, 50 )
	DermaButton:SetText("")
	DermaButton.DoClick = function()
		surface.PlaySound( "ui/buttonclickrelease.wav" )
		RunConsoleCommand("disconnect")
	end

	DermaButton.Paint = function(self, w, h)
		draw.RoundedBox(0,0,0,w,h,color)

		if self.Hovered then
			if not self.play then
				surface.PlaySound( "ui/buttonrollover.wav" )
				self.play = true
			end
		else
			self.play = false
		end

		if DFrame.GoClose then
			color.a = math.Clamp(655*( ( (closetime) - CurTime() )/2),0,255)
		else
			color.a = math.Clamp(655*(1 - ( (opentime) - CurTime() )/4),0,255)
		end

		surface.SetDrawColor( 255, 255, 255, color.a )
		surface.DrawOutlinedRect( 0, 0, w, h, 2 )

		draw.SimpleText("Quit", "buttofont", w/2, h/2, whitecolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
	end

end

concommand.Add( "hg_startscreen", function( ply, cmd, args )
    Spalchscreen()
end )
menuopened = menuopened or false
gameevent.Listen( "OnRequestFullUpdate" )
hook.Add( "OnRequestFullUpdate", "OnRequestFullUpdate_example", function( data )
	if not menuopened then
		Spalchscreen()
		menuopened = true
	end
end )