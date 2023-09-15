
local PANEL = {}

function PANEL:Init()
    self.mapPool = {}
    self.nominations = {}

    self.matBlur = Material( 'pp/blurscreen' )

    self:SetPos( 0, 0 )
    self:SetSize( ScrW(), ScrH() )

    self:Hooks()
    RunConsoleCommand( 'solidmapvote_request_mappool' )
    RunConsoleCommand( 'solidmapvote_request_nominations' )

    self.menu = vgui.Create( 'SolidMapVoteNominationMenu', self )
end

function PANEL:PerformLayout( w, h )
    local wide, tall = w*0.3, h*0.6

    self.menu:SetSize( wide, tall )
    self.menu:SetPos( w*0.5 - wide*0.5, h*0.5 - tall*0.5 )
end

function PANEL:Hooks()
    hook.Add( 'SolidMapVote.UpdateNominations', 'SolidMapVote.NominationsMenu', function( nominations )
        self.nominations = nominations
        self.menu:SetNominations( self.nominations )
    end )

    hook.Add( 'SolidMapVote.UpdateMapPool', 'SolidMapVote.NominationsMapPool', function( mapPool )
        self.mapPool = mapPool
        self.menu:SetMapPool( self.mapPool )
    end )
end

function PANEL:OnRemove()
    hook.Remove( 'SolidMapVote.UpdateNominations', 'SolidMapVote.NominationsMenu' )
    hook.Remove( 'SolidMapVote.UpdateMapPool', 'SolidMapVote.NominationsMapPool' )
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( self.matBlur )

    for i = 1, 3 do
        self.matBlur:SetFloat( '$blur', i )
        self.matBlur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( 0, 0, w, h )
    end
end

vgui.Register( 'SolidMapVoteNomination', PANEL )
