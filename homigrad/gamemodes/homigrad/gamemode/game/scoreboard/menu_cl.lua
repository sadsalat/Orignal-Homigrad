local red,green,white = Color(255,0,0),Color(0,255,0),Color(240,240,240)

CreateClientConVar("hg_3dsky","1",true)

RunConsoleCommand("r_3dsky",GetConVar("hg_3dsky"):GetInt())

local list = {
    {
        "3D Sky box",
        function(self,w,h)
            self.textColor = GetConVar("hg_3dsky"):GetInt() > 0 and green or red
            SB_PaintButton(self,w,h)
        end,
        function()
            RunConsoleCommand("hg_3dsky",GetConVar("hg_3dsky"):GetInt() > 0 and 0 or 1)
        end
    },
    {
        function(x,y,w,h)
            local panel = vgui.Create("Panel",HomigradMenu)
            panel:SetPos(x,y)
            panel:SetSize(w,h)

            function panel:Paint(w,h)
                surface.SetDrawColor(0,0,0,200)
                surface.DrawRect(0,0,w,h)

                draw.SimpleText("Fog Distance","HomigradFont",50,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            local textEntry = vgui.Create("DTextEntry",panel)
            textEntry:SetPos(100,0)
            textEntry:SetSize(panel:GetWide() - textEntry.x,h)
            textEntry:SetValue(dataFogMap[2])

            function textEntry:OnEnter(value)
                value = math.max(math.floor(tonumber(value or 0) or 0),0)--wtf
                RunConsoleCommand("hg_fogset",value)
                textEntry:SetText(tostring(value))
            end

            local panel = vgui.Create("Panel",HomigradMenu)
            panel:SetPos(x,y + 25)
            panel:SetSize(w,h)

            function panel:Paint(w,h)
                surface.SetDrawColor(0,0,0,200)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(255,255,255,16)
                surface.DrawRect(0,0,w,1)

                draw.SimpleText("Fog Color","HomigradFont",50,h / 2,self.textColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end

            local diff = (w - 100) / 3
            local textEntry1,textEntry2,textEntry3
            textEntry1 = vgui.Create("DTextEntry",panel)
            textEntry1:SetPos(100 + diff * 0,0)
            textEntry1:SetSize(diff,h)
            textEntry1:SetValue(dataFogMap[1][1])
            textEntry1:SetPlaceholderText("r")
            function textEntry1:OnEnter(value)
                value = math.max(math.floor(tonumber(value or 0) or 0),0)--wtf
                RunConsoleCommand("hg_fogsetcolor",value,textEntry2:GetValue(),textEntry3:GetValue())
                textEntry:SetText(value)
            end
            textEntry2 = vgui.Create("DTextEntry",panel)
            textEntry2:SetPos(100 + diff * 1,0)
            textEntry2:SetSize(diff,h)
            textEntry2:SetValue(dataFogMap[1][2])
            textEntry2:SetPlaceholderText("g")
            function textEntry2:OnEnter(value)
                value = math.max(math.floor(tonumber(value or 0) or 0),0)--wtf
                RunConsoleCommand("hg_fogsetcolor",textEntry1:GetValue(),value,textEntry3:GetValue())
                textEntry:SetText(value)
            end
            textEntry3 = vgui.Create("DTextEntry",panel)
            textEntry3:SetPos(100 + diff * 2,0)
            textEntry3:SetSize(math.ceil(diff),h)
            textEntry3:SetValue(dataFogMap[1][3])
            textEntry3:SetPlaceholderText("b")
            function textEntry3:OnEnter(value)
                value = math.max(math.floor(tonumber(value or 0) or 0),0)--wtf
                RunConsoleCommand("hg_fogsetcolor",textEntry1:GetValue(),textEntry2:GetValue(),value)
                textEntry3:SetText(value)
            end--ultra criiinggg!111 тема смешариков: погоня

            local panel = vgui.Create("Panel",HomigradMenu)
            panel:SetPos(x,y + 25 * 2)
            panel:SetSize(w,h)

            function panel:Paint(w,h)
                surface.SetDrawColor(0,0,0,200)
                surface.DrawRect(0,0,w,h)

                surface.SetDrawColor(255,255,255,16)
                surface.DrawRect(0,0,w,1)

                draw.SimpleText("для каждой карты сохраняется","HomigradFont",5,h / 2,self.textColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end

            return 25 * 3
        end
    }
}

function OpenHomigradMenu()
    if IsValid(HomigradMenu) then HomigradMenu:Remove() end

    HomigradMenu = vgui.Create("DFrame")
    HomigradMenu:SetTitle("")
    HomigradMenu:SetSize(400,400)
    HomigradMenu:Center()
    --frame:ShowCloseButton(false)
    HomigradMenu:SetDraggable(false)
    HomigradMenu:MakePopup()

    ToggleScoreboard_Override = true
    function HomigradMenu:OnRemove() ToggleScoreboard_Override = nil end

    ScoreboardList[HomigradMenu] = true

    HomigradMenu.Paint = function(self,w,h)
        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText("Homigrad Menu","HomigradFont",10,15,white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

        surface.SetDrawColor(255,255,255,128)
		surface.DrawOutlinedRect(1,1,w - 2,h - 2)
    end

    local y = 25

    for i,manual in pairs(list) do
        i = i - 1

        local x,w,h = 4,HomigradMenu:GetWide() - 8,25

        if type(manual[1]) == "function" then
            y = y + manual[1](x,y,w,h) or 0
        else
            local button = SB_CreateButton(HomigradMenu)
            button:SetSize(w,h)
            button:SetPos(x,y)
            button.text = manual[1]
            button.Paint = manual[2]
            button.DoClick = manual[3]

            y = y + 25 + 5
        end
    end
end
