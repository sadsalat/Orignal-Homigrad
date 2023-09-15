net.Receive("darkrp rules",function()
    darkrp.rules = net.ReadString()
end)

darkrp.pages[3] = {"Законы",function(panel)
    local role = darkrp.GetRole(LocalPlayer())

    local textEntry = vgui.Create("DTextEntry",panel)
    textEntry:SetMultiline(true)
    textEntry:Dock(FILL)
    textEntry:SetEditable(role.canChangeRule)

    function textEntry:OnEnter(value)
        net.Start("darkrp rules")
        net.WriteString(value)
        net.SendToServer()
    end
end}