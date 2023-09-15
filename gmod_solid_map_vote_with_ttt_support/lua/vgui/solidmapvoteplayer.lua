
local PANEL = {}

surface.CreateFont( 'SolidMapVote.PlayerTag', { font = 'Roboto', size = ScreenScale( 4 ), weight = 1000 } )

function PANEL:Init()
    self.avatar = vgui.Create( 'AvatarImage', self )
    self.avatar:SetCursor( 'hand' )
    self.steamId = ''
    self.showTag = false
    self.player = nil

    self:SetAlpha( 0 )
    self:SetCursor( 'hand' )
end

function PANEL:SetPlayer( steamId64 )
    self.steamId = steamId64
    self.avatar:SetSteamID( steamId64 )
    steamworks.RequestPlayerInfo( steamId64 )

    self.player = player.GetBySteamID64( self.steamId )

    self:Fade( false )
end

function PANEL:GetPlayer()
    return self.steamId
end

function PANEL:Paint( w, h )
    local borderColor = IsValid( self.player ) and SolidMapVote[ 'Config' ][ 'Avatar Border Color' ]( self.player ) or color_white

    DisableClipping( true )
        draw.RoundedBox( 0, -3, -3, w+6, h+6, Color( 0, 0, 0, 15 ) )
        draw.RoundedBox( 0, -2, -2, w+4, h+4, Color( 0, 0, 0, 30 ) )
        draw.RoundedBox( 0, -1, -1, w+2, h+2, Color( 0, 0, 0, 60 ) )
    DisableClipping( false )

    draw.RoundedBox( 0, 0, 0, w, h, borderColor )

    if not self.showTag then return end

    DisableClipping( true )
        local label = string.upper( steamworks.GetPlayerName( self.steamId ) )
        surface.SetFont( 'SolidMapVote.PlayerTag' )

        local textW, textH = surface.GetTextSize( label )
        local boxW, boxH = textW+5, textH+5
        local boxX, boxY = w*0.5 - boxW*0.5, -(textH+5)
        local textX, textY = boxX + boxW*0.5, boxY + boxH*0.5

        draw.RoundedBox( 0, boxX-3, boxY-3, boxW+6, boxH+6, Color( 0, 0, 0, 15 ) )
        draw.RoundedBox( 0, boxX-2, boxY-2, boxW+4, boxH+4, Color( 0, 0, 0, 30 ) )
        draw.RoundedBox( 0, boxX-1, boxY-1, boxW+2, boxH+2, Color( 0, 0, 0, 60 ) )
        draw.RoundedBox( 0, boxX, boxY, boxW, boxH, borderColor )
        draw.SimpleText( label, 'SolidMapVote.PlayerTag', textX, textY, Color( 30, 30, 30 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    DisableClipping( false )
end

function PANEL:PerformLayout( w, h )
    self.avatar:SetSize( w-2, h-2 )
    self.avatar:SetPos( 1, 1 )
end

function PANEL:Fade( out )
    if self.anim then return end

    self.anim = Derma_Anim( 'SolidMapVote-Fade', self, self.FadeAnimation )
    self.anim:Start( 0.3, out )
end

function PANEL:FadeAnimation( anim, delta, out )
    if out then
        self:SetAlpha( Lerp( delta, 255, 0 ) )
    else
        self:SetAlpha( Lerp( delta, 0, 255 ) )
    end

    if anim.Finished then
        self.anim = nil
        if out then self:Remove() end
    end
end

function PANEL:Think()
    if self.anim then self.anim:Run() end

    self.showTag = self:IsHovered() or self:IsChildHovered()
    if self.showTag then self:MoveToFront() end
end

vgui.Register( 'SolidMapVotePlayer', PANEL )
