
local PANEL = {}

AccessorFunc( PANEL, 'n_columns', 'Columns', FORCE_NUMBER )
AccessorFunc( PANEL, 'n_xpos', 'XPos', FORCE_NUMBER )

function PANEL:Init()
    self.players = {}

    self:SetCursor( 'hand' )
    self:SetText( '' )

    self:SetColumns( 5 )
    self:SetXPos( 0 )
end

function PANEL:AddPlayer( steamId64 )
    table.insert( self.players, steamId64 )

    local btn = vgui.Create( 'SolidMapVotePlayer', self )
    btn:SetPlayer( steamId64 )
end

function PANEL:GetPlayers()
    return self.players
end

function PANEL:RemovePlayer( steamId64 )
    table.RemoveByValue( self.players, steamId64 )

    for _, pnl in pairs( self:GetChildren() ) do
        if pnl:GetPlayer() == steamId64 then
            pnl:Fade( true )
        end
    end
end

function PANEL:Paint( w, h )

end

function PANEL:PerformLayout( w, h )
    local currentRow, currentCol, spacing = 0, 0, 5

    local totalCols = self:GetColumns()
    local totalRows = math.ceil( #self:GetChildren() / totalCols )
    local totalHorizontalSpacing = (totalCols+1) * spacing
    local totalVerticalSpacing = (totalRows+1) * spacing

    local avatarSize = (w - totalHorizontalSpacing) / totalCols
    local panelHeight = (avatarSize * totalRows) + totalVerticalSpacing

    local startX, startY = spacing, h - (avatarSize+spacing)

    self:SetSize( w, panelHeight )
    self:SetPos( self:GetXPos(), self:GetParent():GetTall() - panelHeight )

    for _, pnl in pairs( self:GetChildren() ) do
        if currentCol >= totalCols then
            currentCol = 0
            currentRow = currentRow + 1
        end

        local xPos = startX + (currentCol*avatarSize) + (currentCol*spacing)
        local yPos = startY - (currentRow*avatarSize) - (currentRow*spacing)

        pnl:SetSize( avatarSize, avatarSize )
        pnl:SetPos( xPos, yPos )

        currentCol = currentCol + 1
    end
end

function PANEL:DoClick()
    self:GetParent():DoClick()
end

vgui.Register( 'SolidMapVotePlayerGrid', PANEL, 'DButton' )
