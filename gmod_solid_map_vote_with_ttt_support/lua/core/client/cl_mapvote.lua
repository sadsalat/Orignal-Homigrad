
SolidMapVote.isOpen = SolidMapVote.isOpen or false
SolidMapVote.isNominating = SolidMapVote.isNominating or false

function SolidMapVote.open( maps )
    SolidMapVote.isOpen = true
    gui.EnableScreenClicker( SolidMapVote.isOpen )

    SolidMapVote.Menu = vgui.Create( 'SolidMapVote' )
    SolidMapVote.Menu:SetMaps( maps )
end

function SolidMapVote.close()
    if ValidPanel( SolidMapVote.Menu ) then
        SolidMapVote.isOpen = false
        SolidMapVote.Menu:Remove()

        gui.EnableScreenClicker( SolidMapVote.isOpen )
    end
end

function SolidMapVote.GetMapConfigInfo( map )
    for _, mapData in pairs( SolidMapVote[ 'Config' ][ 'Specific Maps' ] ) do
        if map == mapData.filename then
            return mapData
        end
    end

    return {
        filename = map,
        displayname = string.Replace( map, '_', ' ' ),
        image = SolidMapVote[ 'Config' ][ 'Missing Image' ],
        width = SolidMapVote[ 'Config' ][ 'Missing Image Size' ].width,
        height = SolidMapVote[ 'Config' ][ 'Missing Image Size' ].height
    }
end

hook.Add( 'PlayerBindPress', 'SolidMapVote.StopMovement', function( ply, bind )
    if ValidPanel( SolidMapVote.Menu ) and
       SolidMapVote.Menu:IsVisible() and
       bind != 'solidmapvote_test' and
       (bind != 'messagemode' and SolidMapVote[ 'Config' ][ 'Enable Chat' ]) and
       (bind != 'messagemode2' and SolidMapVote[ 'Config' ][ 'Enable Chat' ]) and
       (bind != '+voicerecord' and SolidMapVote[ 'Config' ][ 'Enable Voice' ])
    then
        return true
    end
end )

local matBlur = Material( 'pp/blurscreen' )
hook.Add( 'HUDPaint', 'SolidMapVote.DrawBackgroundBlur', function()
    if SolidMapVote.isOpen then
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( matBlur )

        for i = 1, 3 do
            matBlur:SetFloat( '$blur', i )
            matBlur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end
    end
end )

concommand.Add( 'solidmapvote_nomination_menu', function()
    -- Check for reasons to not open the menu or remove it
    if SolidMapVote.isOpen then return end
    if SolidMapVote.isNominating then
        if ValidPanel( SolidMapVote.Nominate ) then
            SolidMapVote.Nominate:Remove()
            SolidMapVote.isNominating = false
            gui.EnableScreenClicker( SolidMapVote.isNominating )
        end

        return
    end

    SolidMapVote.isNominating = true
    gui.EnableScreenClicker( SolidMapVote.isNominating )
    SolidMapVote.Nominate = vgui.Create( 'SolidMapVoteNomination' )
end )

concommand.Add( 'solidmapvote_close_ui', function()
    SolidMapVote.close()
end )
