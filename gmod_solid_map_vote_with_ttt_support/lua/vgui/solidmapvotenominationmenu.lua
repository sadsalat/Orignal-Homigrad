
local PANEL = {}

surface.CreateFont( 'SolidMapVote.NominationTitle', { font = 'Roboto', size = ScreenScale( 15 ), weight = 1000 } )
surface.CreateFont( 'SolidMapVote.NominationMapName', { font = 'Roboto', size = ScreenScale( 6 ), weight = 1000 } )
surface.CreateFont( 'SolidMapVote.NominationLoading', { font = 'Roboto', size = ScreenScale( 4 ), weight = 100 } )
surface.CreateFont( 'SolidMapVote.NominationPlayerName', { font = 'Roboto', size = ScreenScale( 4 ), weight = 1 } )
surface.CreateFont( 'SolidMapVote.NominationClose', { font = 'Roboto', size = ScreenScale( 5 ), weight = 1000 } )

function PANEL:Init()
    self.borderSize = 2

    self.mapPool = {}
    self.nominations = {}

    self.scroll = vgui.Create( 'DScrollPanel', self )
    self.scroll.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, color_white )
	end
	self.scroll.VBar.btnUp.Paint = function( s, w, h ) end
	self.scroll.VBar.btnDown.Paint = function( s, w, h ) end
	self.scroll.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 0, 1, 0, w, h, Color( 20, 20, 20 ) )
	end

    self.close = vgui.Create( 'DButton' )
    self.close:SetText( '' )
    self.close.Paint = function( s, w, h )
        DisableClipping( true )
            draw.RoundedBox( 0, -3, -3, w+6, h+6, Color( 0, 0, 0, 15 ) )
            draw.RoundedBox( 0, -2, -2, w+4, h+4, Color( 0, 0, 0, 30 ) )
            draw.RoundedBox( 0, -1, -1, w+2, h+2, Color( 0, 0, 0, 60 ) )
        DisableClipping( false )

        draw.RoundedBox( 0, 0, 0, w, h, Color( 226, 126, 108 ) )
        draw.RoundedBox( 0, 1, 1, w-2, h-2, Color( 236, 100, 75 ) )

        draw.SimpleTextOutlined( 'X', 'SolidMapVote.NominationClose', w*0.5, h*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 15 ) )
        draw.SimpleTextOutlined( 'X', 'SolidMapVote.NominationClose', w*0.5, h*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 30 ) )
    end
    self.close.DoClick = function( s )
        RunConsoleCommand( 'solidmapvote_nomination_menu' )
    end
end

function PANEL:OnRemove()
    if ValidPanel( self.close ) then
        self.close:Remove()
    end
end

function PANEL:PerformLayout( w, h )
    self.scroll:SetPos( self.borderSize*0.5, self.borderSize*0.5 )
    self.scroll:SetSize( w-self.borderSize, h-self.borderSize )

    local topRightX, topRightY = self:LocalToScreen( w, 0 )
    self.close:SetPos( topRightX - 20, topRightY - 35 )
    self.close:SetSize( 20, 20 )

    local lastBtn = nil
    for _, btn in pairs( self.scroll:GetCanvas():GetChildren() ) do
        btn:SetPos( 0, 0 )
        btn:SetSize( self.scroll:GetWide(), self.scroll:GetTall()*0.1 )

        if lastBtn then btn:MoveBelow( lastBtn, 0 ) end
        lastBtn = btn
    end
end

function PANEL:CreateButtons()
    for _, map in pairs( self.mapPool ) do
        local mapData = SolidMapVote.GetMapConfigInfo( map )

        local btn = vgui.Create( 'DButton', self.scroll )
        btn:SetText( '' )
        btn.coverOpac = 200
        btn.Paint = function( s, w, h )
            local adjustedHeight = (mapData.height/mapData.width) * w
            local offset = h*0.5 - adjustedHeight*0.5

            draw.WebImage( mapData.image, 0, offset, w, adjustedHeight, Color( 255, 255, 255 ) )

            draw.RoundedBox( 0, 0, 0, w, h, s.disabled and Color( 236, 100, 75, 150 ) or Color( 0, 0, 0, s.coverOpac ) )

            local displayname = string.upper( mapData.displayname )
            local displaynameWidth, displaynameHeight =
            draw.SimpleTextOutlined( displayname, 'SolidMapVote.NominationMapName', h*0.5, h*0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 15 ) )
            draw.SimpleTextOutlined( displayname, 'SolidMapVote.NominationMapName', h*0.5, h*0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 30 ) )

            s.disabled = table.HasValue( self.nominations, map )
            if s.disabled then
                local playerName = 'MAP ALREADY NOMINATED BY ' .. steamworks.GetPlayerName( table.KeyFromValue( self.nominations, map ) )
                draw.SimpleTextOutlined( playerName, 'SolidMapVote.NominationPlayerName', h*0.5, h*0.5 + displaynameHeight*0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
                draw.SimpleTextOutlined( playerName, 'SolidMapVote.NominationPlayerName', h*0.5, h*0.5 + displaynameHeight*0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )
            end
        end
        btn.DoClick = function( s )
            if s.disabled then return end

            RunConsoleCommand( 'solidmapvote_nominate', map )
            RunConsoleCommand( 'solidmapvote_nomination_menu' )
        end
        btn.Think = function( s )
            if s.disabled then return end

            if s:IsHovered() then
                s.coverOpac = math.max( s.coverOpac-4, 0 )
            else
                s.coverOpac = math.min( s.coverOpac+4, 200 )
            end
        end

        self.scroll:AddItem( btn )
    end

    self:InvalidateLayout( true )
end

function PANEL:SetMapPool( mapPool )
    self.mapPool = mapPool
    self:CreateButtons()
end

function PANEL:SetNominations( nominations )
    self.nominations = nominations

    -- Cache player info
    for steamId64, map in pairs( self.nominations ) do
        steamworks.RequestPlayerInfo( steamId64 )
    end
end

function PANEL:Paint( w, h )
    DisableClipping( true )
        draw.RoundedBox( 0, -3, -3, w+6, h+6, Color( 0, 0, 0, 15 ) )
        draw.RoundedBox( 0, -2, -2, w+4, h+4, Color( 0, 0, 0, 30 ) )
        draw.RoundedBox( 0, -1, -1, w+2, h+2, Color( 0, 0, 0, 60 ) )

        draw.SimpleTextOutlined( 'MAP NOMINATION', 'SolidMapVote.NominationTitle', 0, -10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, Color( 0, 0, 0, 15 ) )
        draw.SimpleTextOutlined( 'MAP NOMINATION', 'SolidMapVote.NominationTitle', 0, -10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color( 0, 0, 0, 30 ) )

        if #self.mapPool < 1 then
            draw.SimpleTextOutlined( 'LOADING...', 'SolidMapVote.NominationLoading', 2, -15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 15 ) )
            draw.SimpleTextOutlined( 'LOADING...', 'SolidMapVote.NominationLoading', 2, -15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color( 0, 0, 0, 30 ) )
        end
    DisableClipping( false )

    draw.RoundedBox( 0, 0, 0, w, h, color_white )
    draw.RoundedBox( 0, self.borderSize*0.5, self.borderSize*0.5, w-self.borderSize, h-self.borderSize, Color( 20, 20, 20 ) )
end


vgui.Register( 'SolidMapVoteNominationMenu', PANEL )
