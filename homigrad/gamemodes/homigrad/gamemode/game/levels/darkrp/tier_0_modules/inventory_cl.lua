function darkrp.OnContextMenuOpen()
    darkrp.Inv_Open()
end

function darkrp.OnContextMenuClose()
    darkrp.Inv_Close()
end

function darkrp.Inv_Close()
    if IsValid(darkrpContextMenu) then darkrpContextMenu:Remove() end
end

net.Receive("darkrp inv",function()
    darkrp.Inv = net.ReadTable()

    if IsValid(darkrpContextMenu) then
        darkrpContextMenu:Update()
    end
end)

local niger = Color(0,0,0,200)
local white = Color(255,255,255,15)

local empty = {}
function darkrp.Inv_Open()
    darkrpContextMenu = vgui.Create("DFrame")
    darkrpContextMenu:SetTitle("Инвентарь")

    function darkrpContextMenu:Update()
        local w = math.min(#darkrp.Inv)
        local h = math.min(math.ceil(#darkrp.Inv / 8),1)

        darkrpContextMenu:SetSize(w * 32,30 + h * 32)
        darkrpContextMenu:Clear()

        for x = 0,w - 1 do
            for y = 0,h - 1 do
                local button = vgui.Create("DButton")
                button:SetPos(w * 32,30 + h * 32)
                button:SetSize(32,32)
                button:SetText("")

                x = x + 1
                y = y + 1

                function button:Paint(w,h)
                    local slot = darkrp.Inv[x + y]

                    draw.RoundedBox(0,0,0,w,h,niger)
                    draw.RoundedBox(0,0,0,w,1,white)
                    draw.RoundedBox(0,0,0,1,h,white)

                    if button:IsHovered() then
                        draw.RoundedBox(0,1,1,w - 2,h - 2,white)
                    end

                    empty.WorldModel = slot[3]
                    local x,y = self:LocalToScreen(0,0)
                    DrawWeaponSelectionEX(empty,x,y,w,h)

                    markup.Parse("<font=HudSelectionText>" .. slot[4] .. "</font>",250):Draw(0,0,w,h,255)--удобнонаверное..........
                end

                function button:DoClick()
                    net.Start("darkrp inv drop")
                    net.WriteInt(x + y,16)
                    net.SendToServer()
                end
            end
        end
    end

    darkrpContextMenu:Update()
    darkrpContextMenu:Center()

    function darkrpContextMenu:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,niger)
    end
end