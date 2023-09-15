
local PANEL = {}

surface.CreateFont( 'SolidMapVote.MapName', { font = 'Roboto', size = ScreenScale( 6 ), weight = 1000 } )
surface.CreateFont( 'SolidMapVote.MapPercent', { font = 'Roboto', size = ScreenScale( 15 ), weight = 1000 } )
surface.CreateFont( 'SolidMapVote.PlayCount', { font = 'Roboto', size = ScreenScale( 4 ), weight = 1 } )
surface.CreateFont( 'SolidMapVote.NominationText', { font = 'Roboto', size = ScreenScale( 5 ), weight = 100 } )

function PANEL:Init()
    self:SetText( '' )

    self.borderSize = 2
    self.coverOpac = 200

    self.zoomAmount = 15
    self.zoomed = false

    self.originalPos = { x = 0, y = 0 }
    self.zoomPos = { x = 0, y = 0 }
    self.originalSize = { w = 0, h = 0 }
    self.zoomSize = { w = 0, h = 0 }

    self.votes = 0
    self.map = nil
    self.mapData = {}
    self.nominator = nil
    self.myVote = false
    self.disabled = false
    self.winner = false
    self.playCount = 0

    self.oldPercentage = 0

    LocalPlayer().nextVoteTime = RealTime()
    self.gradientMat = Material( 'vgui/gradient_up' )
    RunConsoleCommand( 'solidmapvote_request_nominations' )

    self.imageContainer = vgui.Create( 'SolidMapVoteImage', self )
    self.playerGrid = vgui.Create( 'SolidMapVotePlayerGrid', self )
end

function PANEL:OnRemove()
    hook.Remove( 'SolidMapVote.UpdateVotes', 'SolidMapVote.UpdateVotes.' .. self.map )
    hook.Remove( 'SolidMapVote.WinningMaps', 'SolidMapVote.WinningMaps.' .. self.map )
    hook.Remove( 'SolidMapVote.MapPlayCounts', 'SolidMapVote.PlayCounts.' .. self.map )
    hook.Remove( 'SolidMapVote.UpdateNominations', 'SolidMapVote.Nominations.' .. self.map )
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
    self.myVote = votes[ mySteamId64 ] and votes[ mySteamId64 ] == self.mapData.filename

    for steamId64, vote in pairs( votes ) do
        if vote == self.mapData.filename then
            local ply = player.GetBySteamID64( steamId64 )
            local power = IsValid( ply ) and SolidMapVote[ 'Config' ][ 'Vote Power' ]( ply ) or 1

            self.votes = self.votes + power
        end
    end
end

function PANEL:UpdateGrid( votes )
    local players = self.playerGrid:GetPlayers()

    for steamId64, vote in pairs( votes ) do
        if vote == self.mapData.filename and not table.HasValue( players, steamId64 ) then
            self.playerGrid:AddPlayer( steamId64 )
        elseif vote != self.mapData.filename and table.HasValue( players, steamId64 ) then
            self.playerGrid:RemovePlayer( steamId64 )
        end
    end
end

function PANEL:GetPercentage()
    local maxVoteCount = 0

    for _, ply in pairs( player.GetAll() ) do
        local power = IsValid( ply ) and SolidMapVote[ 'Config' ][ 'Vote Power' ]( ply ) or 1
        maxVoteCount = maxVoteCount + power
    end

    return math.Round( 100 * (self.votes / maxVoteCount) )
end

function PANEL:SetMap( map )
    self.map = map
    self.mapData = SolidMapVote.GetMapConfigInfo( map )

    self.imageContainer:SetImageURL( self.mapData.image )
    self.imageContainer:SetImageSize( self.mapData.width, self.mapData.height )

    hook.Add( 'SolidMapVote.UpdateVotes', 'SolidMapVote.UpdateVotes.' .. map, function( votes )
        self:UpdateVotes( votes )
        self:UpdateGrid( votes )
    end )

    hook.Add( 'SolidMapVote.MapPlayCounts', 'SolidMapVote.PlayCounts.' .. map, function( playCounts )
        self.playCount = playCounts[ self.map ] or 0
    end )

    hook.Add( 'SolidMapVote.WinningMaps', 'SolidMapVote.WinningMaps.' .. map, function( winningMaps, realWinner, fixedWinner )
        local isWinner = self.map == realWinner or self.map == fixedWinner

        self:Zoom( not isWinner )
        self.winner = isWinner
        self.disabled = true
    end )

    hook.Add( 'SolidMapVote.UpdateNominations', 'SolidMapVote.Nominations.' .. map, function( nominations )
        if table.HasValue( nominations, self.map ) then
            self.nominator = table.KeyFromValue( nominations, self.map )
            steamworks.RequestPlayerInfo( self.nominator )
        end
    end )
end

function PANEL:PerformLayout( w, h )
    self.imageContainer:SetSize( w-self.borderSize, h-self.borderSize )
    self.imageContainer:SetPos( self.borderSize*0.5, self.borderSize*0.5 )

    self.playerGrid:SetWide( w-self.borderSize )
    self.playerGrid:SetXPos( self.borderSize*0.5 )
end

function PANEL:Paint( w, h )
    DisableClipping( true )
        draw.RoundedBox( 0, -3, -3, w+6, h+6, Color( 0, 0, 0, 15 ) )
        draw.RoundedBox( 0, -2, -2, w+4, h+4, Color( 0, 0, 0, 30 ) )
        draw.RoundedBox( 0, -1, -1, w+2, h+2, Color( 0, 0, 0, 60 ) )
    DisableClipping( false )

    local col = self.winner and Color( 233, 212, 96 ) or (self.myVote and Color( 0, 177, 106 ) or color_white)
    draw.RoundedBox( 0, 0, 0, w, h, col )
end

function PANEL:PaintOver( w, h )
    surface.SetDrawColor( 0, 0, 0, self.coverOpac )
    surface.SetMaterial( self.gradientMat )
    surface.DrawTexturedRect( self.borderSize*0.5, self.borderSize*0.5, w-self.borderSize, h-self.borderSize )

    if not self.map then return end

    local mapName = string.upper( self.mapData.displayname )
    local mapNameWidth, mapNameHeight =
    draw.SimpleTextOutlined( mapName, 'SolidMapVote.MapName', 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
    draw.SimpleTextOutlined( mapName, 'SolidMapVote.MapName', 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )

    local nominatorWidth, nominatorHeight = 0, 0
    if self.nominator and SolidMapVote[ 'Config' ][ 'Allow Nominations' ] then
        local nominator = 'NOMINATED BY ' .. string.upper( steamworks.GetPlayerName( self.nominator ) )

        nominatorWidth, nominatorHeight =
        draw.SimpleTextOutlined( nominator, 'SolidMapVote.NominationText', 5, 5 + mapNameHeight*0.9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
        draw.SimpleTextOutlined( nominator, 'SolidMapVote.NominationText', 5, 5 + mapNameHeight*0.9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )
    end

    local playCountWidth, playCountHeight = 0, 0
    if SolidMapVote[ 'Config' ][ 'Show Map Play Count' ] then
        local playCount = 'PLAYED ' .. string.Comma( self.playCount ) .. ' TIMES'

        playCountWidth, playCountHeight =
        draw.SimpleTextOutlined( playCount, 'SolidMapVote.PlayCount', 5, 5 + mapNameHeight*0.9 + nominatorHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
        draw.SimpleTextOutlined( playCount, 'SolidMapVote.PlayCount', 5, 5 + mapNameHeight*0.9 + nominatorHeight, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )
    end

    local old, new, increment = self.oldPercentage, self:GetPercentage(), 200*FrameTime()
    local current, target = (new > old) and old or new, (new > old) and new or old
    local approach = old == new and 0 or math.Approach( current, target, increment )

    self.oldPercentage = (new > old) and approach or old - approach
    local percentageWidth, percentageHeight =
    draw.SimpleTextOutlined( math.Round( self.oldPercentage ) .. '%', 'SolidMapVote.MapPercent', 5, 5 + mapNameHeight*0.9 + nominatorHeight + playCountHeight*0.8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
    draw.SimpleTextOutlined( math.Round( self.oldPercentage ) .. '%', 'SolidMapVote.MapPercent', 5, 5 + mapNameHeight*0.9 + nominatorHeight + playCountHeight*0.8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )
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

function PANEL:DoClick()
    if self.disabled then return end

    if LocalPlayer().nextVoteTime < RealTime() and not self.myVote then
        surface.PlaySound( 'UI/buttonclick.wav' )
        RunConsoleCommand( 'solidmapvote_vote', self.mapData.filename )
        LocalPlayer().nextVoteTime = RealTime() + 1
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

vgui.Register( 'SolidMapVoteMap', PANEL, 'DButton' )
