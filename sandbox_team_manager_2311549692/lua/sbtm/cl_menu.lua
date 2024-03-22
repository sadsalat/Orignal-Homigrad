local info = {}
local lists = {}

surface.CreateFont("Futura_13", {
    font = "Futura-Bold",
    size = 13,
})

surface.CreateFont("Futura_18", {
    font = "Futura-Bold",
    size = 18,
})

surface.CreateFont("Futura_24", {
    font = "Futura-Bold",
    size = 24,
})

local function populate(button, li, id)
    if button then
        button:SetText(language.GetPhrase("sbtm.join"))
        button:SetVisible(GetConVar("sbtm_selfset"):GetBool())
        button.DoClick = function(self)
            if GetConVar("sbtm_selfset"):GetBool() then
                net.Start("SBTM_Request")
                    net.WriteUInt(id, 12)
                net.SendToServer()
                timer.Simple(0.1, function()
                    for i, v in pairs(lists) do
                        populate(nil, v, i)
                    end
                end)
            end
        end
    end
    li:Clear()
    info[id] = {}
    for _, ply in pairs(team.GetPlayers(id)) do
        local line = li:AddLine(ply:GetName())
        info[id][line] = ply
    end
    for class, t in pairs(SBTM.NPCTeams) do
        if t == id then li:AddLine(class) end
    end
    if LocalPlayer():IsAdmin() then
        li.OnRowRightClick = function(self, lineID, line)
            local dmenu = DermaMenu()
            dmenu:SetPos(input.GetCursorPos())
            for t, p in SortedPairs(SBTM.IconTable) do
                if t == id then continue end
                local newOption = dmenu:AddOption(team.GetName(t), function()
                    local rows = self:GetSelected()
                    local targets = {}
                    for _, v in pairs(rows) do
                        table.insert(targets, info[id][v] or v:GetColumnText(1))
                    end
                    net.Start("SBTM_Admin")
                        net.WriteUInt(0, 2)
                        net.WriteUInt(t, 12)
                        net.WriteTable(targets)
                    net.SendToServer()
                    -- Invalidate existing lists so it's updated
                    timer.Simple(0.25, function()
                        for i, v in pairs(lists) do
                            populate(nil, v, i)
                        end
                    end)
                end)
                newOption:SetIcon(p)
            end
            dmenu:Open()
        end
    end
end

local function repopulate()
    timer.Simple(0.25, function()
        for i, v in pairs(lists) do
            populate(nil, v, i)
        end
    end)
end

list.Set( "DesktopWindows", "SBTM", {
    title = "SBTM",
    icon = "icon64/sbtm.png",
    width		= 640,
    height		= 480,
    onewindow	= true,
    init		= function( icon, window )
        window:SetTitle( "#sbtm.title" )
        window:SetSize( math.min( ScrW() - 16, window:GetWide() ), math.min( ScrH() - 16, window:GetTall() ) )
        window:SetMinWidth( window:GetWide() )
        window:SetMinHeight( window:GetTall() )
        window:Center()

        info = {}

        local left = vgui.Create("DPanel", window)
        left:SetSize(window:GetWide() * 0.3, window:GetTall())
        left:Dock(LEFT)
        function left:Paint() end

        local left_top = vgui.Create("DPanel", left)
        left_top:SetSize(left:GetWide(), left:GetTall() * 0.6)
        left_top:Dock(TOP)
        left_top:DockMargin(2, 2, 2, 2)

        local label_unassigned = vgui.Create("DLabel", left_top)
        label_unassigned:SetSize(left_top:GetWide() * 0.5, window:GetTall() * 0.05)
        label_unassigned:SetText(team.GetName(TEAM_UNASSIGNED))
        label_unassigned:Dock(TOP)
        label_unassigned:SetFont("Futura_24")
        label_unassigned:SetTextColor(Color(0, 0, 0))
        label_unassigned:DockMargin(4, 4, 4, 4)

        local btn_unassigned = vgui.Create("DButton", left_top)
        btn_unassigned:SetSize(left_top:GetWide() * 0.3, window:GetTall() * 0.06)
        btn_unassigned:SetPos(left_top:GetWide() * 0.7 - 8, 4)
        btn_unassigned:SetFont("Futura_13")

        local left_bottom = vgui.Create("DPanel", left)
        left_bottom:Dock(FILL)
        left_bottom:DockMargin(2, 2, 2, 2)

        local label_spectator = vgui.Create("DLabel", left_bottom)
        label_spectator:SetSize(left_bottom:GetWide() * 0.5, window:GetTall() * 0.05)
        label_spectator:SetText(team.GetName(TEAM_SPECTATOR))
        label_spectator:Dock(TOP)
        label_spectator:SetFont("Futura_18")
        label_spectator:SetTextColor(Color(0, 0, 0))
        label_spectator:DockMargin(4, 2, 4, 2)

        local btn_spectator = vgui.Create("DButton", left_bottom)
        btn_spectator:SetSize(left_top:GetWide() * 0.3, window:GetTall() * 0.05)
        btn_spectator:SetPos(left_top:GetWide() * 0.7 - 8, 4)
        btn_spectator:SetFont("Futura_13")

        local list_spectator = vgui.Create("DListView", left_bottom)
        list_spectator:Dock(FILL)
        list_spectator:DockMargin(4, 4, 4, 4)
        list_spectator:AddColumn(language.GetPhrase("sbtm.titlename"))
        lists[TEAM_SPECTATOR] = list_spectator
        populate(btn_spectator, list_spectator, TEAM_SPECTATOR)

        local bottom = vgui.Create("DPanel", left_top)
        bottom:SetSize(left_top:GetWide(), window:GetTall() * 0.08)
        bottom:Dock(BOTTOM)

        local btn_shuffle = vgui.Create("DButton", bottom)
        btn_shuffle:SetSize(left:GetWide() * 0.5 - 4, window:GetTall() * 0.08)
        btn_shuffle:Dock(LEFT)
        btn_shuffle:DockMargin(2, 2, 2, 2)
        btn_shuffle:SetText(language.GetPhrase("sbtm.shuffle"))
        btn_shuffle.DoClick = function(self)
            RunConsoleCommand("sbtm_shuffle")
            repopulate()
        end
        btn_shuffle:SetDisabled(not LocalPlayer():IsAdmin())
        btn_shuffle:SetFont("Futura_13")

        local btn_assign = vgui.Create("DButton", bottom)
        btn_assign:SetSize(left:GetWide() * 0.5 - 4, window:GetTall() * 0.08)
        btn_assign:Dock(RIGHT)
        btn_assign:DockMargin(2, 2, 2, 2)
        if team.NumPlayers(TEAM_UNASSIGNED) == 0 then
            btn_assign:SetText(language.GetPhrase("sbtm.unassignall"))
            btn_assign.DoClick = function(self)
                RunConsoleCommand("sbtm_unassignall")
                repopulate()
            end
        else
            btn_assign:SetText(language.GetPhrase("sbtm.autoassign"))
            btn_assign.DoClick = function(self)
                RunConsoleCommand("sbtm_autoassign")
                repopulate()
            end
        end
        btn_assign:SetDisabled(not LocalPlayer():IsAdmin())
        btn_assign:SetFont("Futura_13")

        local list_unassigned = vgui.Create("DListView", left_top)
        list_unassigned:Dock(FILL)
        list_unassigned:DockMargin(4, 4, 4, 4)
        list_unassigned:AddColumn(language.GetPhrase("sbtm.titlename"))
        lists[TEAM_UNASSIGNED] = list_unassigned
        populate(btn_unassigned, list_unassigned, TEAM_UNASSIGNED)

        local layout = vgui.Create("DIconLayout", window)
        layout:Dock(FILL)
        layout:DockMargin(4, 4, 4, 4)
        layout:SetSpaceX(4)
        layout:SetSpaceY(4)

        for id = SBTM_RED, SBTM_YEL do
            local panel = layout:Add("DPanel")
            panel:SetSize(window:GetWide() * 0.35 - 16, window:GetTall() * 0.5 - 20)
            local bgclr = team.GetColor(id)
            bgclr.a = 50
            panel.Paint = function(pnl, w, h)
                draw.RoundedBox(1, 0, 0, w, h, bgclr)
                draw.SimpleTextOutlined(team.GetName(id), "Futura_24", 4, 4, team.GetColor(id), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
            end

            local btn = vgui.Create("DButton", panel)
            btn:SetSize(panel:GetWide() * 0.3, panel:GetTall() * 0.1)
            btn:SetPos(panel:GetWide() * 0.7 - 4, 4)
            btn:DockMargin(2, 2, 2, 2)
            btn:SetFont("Futura_13")

            local li = vgui.Create("DListView", panel)
            li:Dock(FILL)
            li:DockMargin(4, 32, 4, 4)
            li:AddColumn(language.GetPhrase("sbtm.titlename"))
            lists[id] = li

            populate(btn, li, id)
        end
    end
})

local function valid_lang(str)
    return language.GetPhrase(str) ~= str
end

local options = {}
local function populate_options(layout, t)
    for k, v in pairs(options) do
        if IsValid(v) and IsValid(v:GetParent()) then
            v:GetParent():Remove()
        end
    end
    options = {}

    -- Attempt to find last saved option set
    local last_options = SBTM.TeamConfig[t] or {}
    local fallback = SBTM.TeamConfig[0] or {}
    --[[]
    if file.Exists("sbtm_teamconfig.txt", "DATA") then
        last_options = util.JSONToTable(file.Read("sbtm_teamconfig.txt", "DATA"))
    end
    ]]

    for k, v in SortedPairsByMemberValue(SBTM.TeamProperties, "so") do
        local parent = vgui.Create("DPanel", layout)
        parent:SetSize(layout:GetWide(), 24)
        if k.ao then
            parent:SetTooltip(language.GetPhrase("sbtm.team.adminoverride"))
        elseif valid_lang("sbtm.team." .. k .. ".desc") then
            parent:SetTooltip(language.GetPhrase("sbtm.team." .. k .. ".desc"))
        end
        parent.Paint = function(pnl, w, h)
            draw.SimpleText(language.GetPhrase("sbtm.team." .. k), "Futura_13", 4, h / 2, Color(0, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local reset = vgui.Create("DImageButton", parent)
        if v.type == "i" then
            options[k] = vgui.Create("DNumberWang", parent)
            options[k]:SetPos(layout:GetWide() - 16 - 64 - 8, (24 - 15) / 2)
            options[k]:SetFraction(0)
            options[k]:SetMinMax(v.min, v.max)
            options[k]:SetValue(last_options[k] or fallback[k] or v.default)
            options[k].OnValueChanged = function(pnl, val)
                net.Start("SBTM_TeamPropertySet")
                    net.WriteUInt(t, 16)
                    net.WriteString(k)
                    net.WriteUInt(val, 32)
                net.SendToServer()
                reset:SetDisabled(false)
            end
        elseif v.type == "b" then
            options[k] = vgui.Create("DCheckBox", parent)
            options[k]:SetPos(layout:GetWide() - 16 - 15 - 8, (24 - 15) / 2)
            local checked = v.default
            if last_options[k] ~= nil then
                checked = last_options[k]
            elseif fallback[k] ~= nil then
                checked = fallback[k]
            end
            options[k]:SetChecked(checked)
            options[k].OnChange = function(pnl, val)
                net.Start("SBTM_TeamPropertySet")
                    net.WriteUInt(t, 16)
                    net.WriteString(k)
                    net.WriteBool(val)
                net.SendToServer()
                reset:SetDisabled(false)
            end
        elseif v.type == "f" then
            options[k] = vgui.Create("DNumSlider", parent)
            options[k]:Dock(FILL)
            options[k]:SetDecimals(v.decimals or 2)
            options[k]:SetMinMax(v.min or 0, v.max or 1)
            options[k]:SetValue(last_options[k] or fallback[k] or v.default)
            options[k].OnValueChanged = function(pnl, val)
                net.Start("SBTM_TeamPropertySet")
                    net.WriteUInt(t, 16)
                    net.WriteString(k)
                    net.WriteFloat(val)
                net.SendToServer()
                reset:SetDisabled(false)
            end
        end
        reset:SetPos(layout:GetWide() - 18, (24 - 15) / 2)
        reset:SetSize(16, 16)
        reset:SetImage("icon16/arrow_rotate_clockwise.png")
        reset:SetDisabled((SBTM.TeamConfig[t] or {})[k] == nil)
        reset.DoClick = function(self)
            net.Start("SBTM_TeamPropertyReset")
                net.WriteUInt(t, 16)
                net.WriteString(k)
            net.SendToServer()
            if v.type == "i" or v.type == "f" then
                options[k]:SetValue(v.default)
            elseif v.type == "b" then
                options[k]:SetChecked(v.default)
            end
            self:SetDisabled(true)
        end
    end
end

SBTM.TeamConfigPanel = nil
local function config_window(p)
    if SBTM.TeamConfigPanel then SBTM.TeamConfigPanel:Remove() end

    if p then
        SBTM.TeamConfigPanel = p
    else
        SBTM.TeamConfigPanel = vgui.Create("DFrame", g_ContextMenu)
        SBTM.TeamConfigPanel:SetSize(300, 480)
        SBTM.TeamConfigPanel:Center()
        SBTM.TeamConfigPanel:MakePopup()
    end
    local window = SBTM.TeamConfigPanel

    window:SetTitle( "#sbtm.team.config" )
    window:SetSize( math.min( ScrW() - 16, window:GetWide() ), math.min( ScrH() - 16, window:GetTall() ) )
    window:SetMinWidth( window:GetWide() )
    window:SetMinHeight( window:GetTall() )
    window:Center()

    local title = vgui.Create("DPanel", window)
    title:Dock(TOP)
    title:SetTall(24)

    local dropdown = vgui.Create("DComboBox", title)
    dropdown:SetWidth(96)
    dropdown:Dock(RIGHT)
    dropdown:SetSortItems(false)
    dropdown:AddChoice("#sbtm.team.allplayers", 0, true, "icon16/box.png")
    dropdown:AddChoice(team.GetName(TEAM_UNASSIGNED), TEAM_UNASSIGNED, false, "icon16/help.png")
    for k = SBTM_RED, SBTM_YEL do
        dropdown:AddChoice(team.GetName(k), k, false, SBTM.IconTable[k])
    end

    title.Paint = function(pnl, w, h)
        local _, s = dropdown:GetSelected()
        local c = (s == TEAM_UNASSIGNED or s == 0) and color_white or team.GetColor(s)
        draw.SimpleTextOutlined("Team Properties", "Futura_24", 4, 0, c, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    end

    local panel = vgui.Create("DPanel", window)
    panel:Dock(FILL)
    panel:DockMargin(4, 4, 4, 4)
    panel:InvalidateParent(true)

    local optionlayout = vgui.Create("DIconLayout", panel)
    optionlayout:Dock(FILL)
    optionlayout:InvalidateParent(true)
    --optionlayout:DockMargin(0, 0, 0, 0)
    optionlayout:SetLayoutDir(LEFT)
    SBTM.TeamConfigPanel.layout = optionlayout
    populate_options(optionlayout, 0)

    --[[]
    title.Paint = function(pnl, w, h)
        local _, data = dropdown:GetSelected()
        local str = (data == 0 and "#sbtm.team.allplayers") or team.GetName(data)
        local clr = (data == 0 and color_white) or team.GetColor(data)
        draw.SimpleTextOutlined(str, "Futura_24", 4, 4, clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    end
    ]]
    function dropdown:OnSelect(i, txt, t)
        title:SetText(txt)
        window.team = t
        populate_options(optionlayout, t)
    end
    window.team = 0
end
hook.Add("SBTM_UpdateConfigMenu", "SBTM", function()
    if SBTM.TeamConfigPanel then
        populate_options(SBTM.TeamConfigPanel.layout, SBTM.TeamConfigPanel.team)
    end
end)

list.Set( "DesktopWindows", "SBTM_Config", {
    title = "Team Config",
    icon = "icon64/sbtm_config.png",
    width		= 300,
    height		= 480,
    onewindow	= true,
    init		= function( icon, window )
        config_window(window)
    end
})

hook.Add("HUDDrawScoreBoard", "SBTM", function()
    if not g_Scoreboard or not g_Scoreboard:IsVisible() then return end
    --[[]
    for k, v in pairs(g_Scoreboard.Scores:GetChildren()) do
        print(k, v:GetText())
    end
    ]]
    local plyrs = player.GetAll()
    local y = 100
    for id, pl in pairs( plyrs ) do
        if SBTM:IsTeamed(pl) then
            local icon = SBTM.IconMaterialTable[pl:Team()]
            if icon then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScrW() / 2 - 350 - 16, 100 + y + 10, 16, 16)
            end
        end
        y = y + 32 + 8
    end
end)