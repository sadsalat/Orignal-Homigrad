
local PANEL = {}

AccessorFunc( PANEL, 's_image', 'Image', FORCE_STRING )
AccessorFunc( PANEL, 's_label', 'Label', FORCE_STRING )

surface.CreateFont( 'SolidMapVote.ButtonText', { font = 'Roboto', size = ScreenScale( 6 ), weight = 1000 } )
surface.CreateFont( 'SolidMapVote.ButtonPercent', { font = 'Roboto', size = ScreenScale( 10 ), weight = 1000 } )

function PANEL:Init()
    self:SetText( '' )
    self:SetImage( '' )

    self.label = ''

    self.zoomAmount = 15
    self.zoomed = false

    self.originalPos = { x = 0, y = 0 }
    self.zoomPos = { x = 0, y = 0 }
    self.originalSize = { w = 0, h = 0 }
    self.zoomSize = { w = 0, h = 0 }

    self.borderSize = 2
    self.coverOpac = 200
    self.votes = 0

    self.myVote = false
    self.winner = false
    self.disabled = false

    self.oldPercentage = 0

    LocalPlayer().nextVoteTime = RealTime()
    self.gradientMat = Material( 'vgui/gradient_up' )
end

function PANEL:OnRemove()
    hook.Remove( 'SolidMapVote.UpdateVotes', 'SolidMapVote.UpdateVotes.' .. self.label )
    hook.Remove( 'SolidMapVote.WinningMaps', 'SolidMapVote.WinningMaps.' .. self.label )
end

function PANEL:SetOriginalSize( w, h )
    self.originalSize = { w = w, h = h }
    self.zoomSize = { w = w+self.zoomAmount, h = h+self.zoomAmount }
end

function PANEL:SetOriginalPos( x, y )
    self.originalPos = { x = x, y = y }
    self.zoomPos = { x = x - self.zoomAmount*0.5, y = y - self.zoomAmount*0.5 }
end

function PANEL:UpdateVotes( votes )
    local mySteamId64 = LocalPlayer():SteamID64()

    self.oldPercentage = self.oldPercentage == self:GetPercentage() and self:GetPercentage() or self.oldPercentage

    self.votes = 0
    self.myVote = votes[ mySteamId64 ] and votes[ mySteamId64 ] == self.label

    for steamId64, vote in pairs( votes ) do
        if vote == self.label then
            local ply = player.GetBySteamID64( steamId64 )
            local power = IsValid( ply ) and SolidMapVote[ 'Config' ][ 'Vote Power' ]( ply ) or 1

            self.votes = self.votes + power
        end
    end
end

function PANEL:SetLabel( label )
    self.label = label

    hook.Add( 'SolidMapVote.UpdateVotes', 'SolidMapVote.UpdateVotes.' .. label, function( votes )
        self:UpdateVotes( votes )
    end )

    hook.Add( 'SolidMapVote.WinningMaps', 'SolidMapVote.WinningMaps.' .. label, function( winningMaps, realWinner, fixedWinner )
        if self.label == realWinner then
            self:Zoom( false )
            self.winner = true
        else
            self:Zoom( true )
        end

        self.disabled = true
    end )
end

function PANEL:GetPercentage()
    local maxVoteCount = 0

    for _, ply in pairs( player.GetAll() ) do
        local power = IsValid( ply ) and SolidMapVote[ 'Config' ][ 'Vote Power' ]( ply ) or 1
        maxVoteCount = maxVoteCount + power
    end

    return math.Round( 100 * (self.votes / maxVoteCount) )
end

function PANEL:Paint( w, h )
    DisableClipping( true )
        draw.RoundedBox( 0, -3, -3, w+6, h+6, Color( 0, 0, 0, 15 ) )
        draw.RoundedBox( 0, -2, -2, w+4, h+4, Color( 0, 0, 0, 30 ) )
        draw.RoundedBox( 0, -1, -1, w+2, h+2, Color( 0, 0, 0, 60 ) )
    DisableClipping( false )

    local col = self.winner and Color( 233, 212, 96 ) or (self.myVote and Color( 0, 177, 106 ) or color_white)
    draw.RoundedBox( 0, 0, 0, w, h, col )
    draw.RoundedBox( 0, self.borderSize*0.5, self.borderSize*0.5, w-self.borderSize, h-self.borderSize, Color( 20, 20, 20 ) )

    local label = string.upper( self.label .. ' map' )
    local labelW, labelH =
    draw.SimpleTextOutlined( label, 'SolidMapVote.ButtonText', 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
    draw.SimpleTextOutlined( label, 'SolidMapVote.ButtonText', 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )

    local imageSize = h*0.5
    draw.WebImage( self:GetImage(), w - (imageSize) - (h*0.5 - imageSize*0.5), h*0.5 - imageSize*0.5, imageSize, imageSize, color_white )


    local old, new, increment = self.oldPercentage, self:GetPercentage(), 200*FrameTime()
    local current, target = (new > old) and old or new, (new > old) and new or old
    local approach = old == new and 0 or math.Approach( current, target, increment )

    self.oldPercentage = (new > old) and approach or old - approach
    draw.SimpleTextOutlined( math.Round( self.oldPercentage ) .. '%', 'SolidMapVote.ButtonPercent', 5, labelH + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
    draw.SimpleTextOutlined( math.Round( self.oldPercentage ) .. '%', 'SolidMapVote.ButtonPercent', 5, labelH + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )
end

function PANEL:PaintOver( w, h )
    surface.SetDrawColor( 0, 0, 0, self.coverOpac )
    surface.SetMaterial( self.gradientMat )
    surface.DrawTexturedRect( self.borderSize*0.5, self.borderSize*0.5, w-self.borderSize, h-self.borderSize )
end

function PANEL:PerformLayout( w, h )

end

function PANEL:DoClick()
    if self.disabled then return end

    if LocalPlayer().nextVoteTime < RealTime() and not self.myVote then
        surface.PlaySound( 'UI/buttonclick.wav' )
        RunConsoleCommand( 'solidmapvote_vote', self.label )
        LocalPlayer().nextVoteTime = RealTime() + 1
    end
end

function PANEL:Zoom( out )
    if self.anim then return end
    if self.zoomed and not out then return end

    self:GetParent():PauseLayout( true )

    local w, h = self:GetSize()
    local x, y = self:GetPos()

    self.anim = Derma_Anim( 'SolidMapVote-Zoom', self, self.ZoomAnimation )
    self.anim:Start( 0.1, { w, h, out, x, y } )
end

function PANEL:ZoomAnimation( anim, delta, data )
    local w, h = data[1], data[2]
    local out = data[3]
    local x, y = data[4], data[5]

    if out then
        local startWidth, startHeight = w, h
        local endWidth, endHeight = self.originalSize.w, self.originalSize.h
        local startX, startY = x, y
        local endX, endY = self.originalPos.x, self.originalPos.y

        local currentWidth = Lerp( delta, startWidth, endWidth )
        local currentHeight = Lerp( delta, startHeight, endHeight )
        local currentX, currentY = Lerp( delta, startX, endX )
        local currentY = Lerp( delta, startY, endY )

        self:SetSize( currentWidth, currentHeight )
        self:SetPos( currentX, currentY )
        self.coverOpac = Lerp( delta, self.coverOpac, 200 )
    else
        local startWidth, startHeight = w, h
        local endWidth, endHeight = self.zoomSize.w, self.zoomSize.h
        local startX, startY = x, y
        local endX, endY = self.zoomPos.x, self.zoomPos.y

        local currentWidth = Lerp( delta, startWidth, endWidth )
        local currentHeight = Lerp( delta, startHeight, endHeight )
        local currentX, currentY = Lerp( delta, startX, endX )
        local currentY = Lerp( delta, startY, endY )

        self:SetSize( currentWidth, currentHeight )
        self:SetPos( currentX, currentY )
        self.coverOpac = Lerp( delta, self.coverOpac, 0 )
    end

    if anim.Finished then
        self.anim = nil
        self.zoomed = true

        if out then
            -- Finshed zooming out, so allow the parent to control button layout
            self:GetParent():PauseLayout( false )
            self.zoomed = false
        else
            -- Finshed zooming in, so save the zoomed size so we can return to un zoomed size
            local x, y = self:GetPos()
            self.zoomSize = { w = self:GetWide(), h = self:GetTall() }
            self.zoomPos = { x = x, y = y }
        end
    end
end

function PANEL:Think()
    if self.anim then
        self.anim:Run()
        self:GetParent():PauseLayout( true )
    end

    if self.disabled then return end

    if self:IsHovered() or self:IsChildHovered() then
        self:Zoom( false )
    elseif not self:IsHovered() and self.zoomed then
        self:Zoom( true )
    end
end

vgui.Register( 'SolidMapVoteButton', PANEL, 'DButton' )
