SBTM.IconTable = {
    [SBTM_RED] = "icon16/flag_red.png",
    [SBTM_BLU] = "icon16/flag_blue.png",
    [SBTM_GRN] = "icon16/flag_green.png",
    [SBTM_YEL] = "icon16/flag_yellow.png",
    [TEAM_UNASSIGNED] = "icon16/help.png",
    [TEAM_SPECTATOR] = "icon16/eye.png"
}

SBTM.IconMaterialTable = {
    [SBTM_RED] = Material("icon16/flag_red.png"),
    [SBTM_BLU] = Material("icon16/flag_blue.png"),
    [SBTM_GRN] = Material("icon16/flag_green.png"),
    [SBTM_YEL] = Material("icon16/flag_yellow.png"),
    [TEAM_UNASSIGNED] = Material("icon16/help.png"),
    [TEAM_SPECTATOR] = Material("icon16/eye.png")
}


properties.Add("sbtm_setteam", {
    MenuLabel = "#sbtm.properties.set_team",
    Order = 100,
    MenuIcon = "icon16/group_edit.png",
    Filter = function(self, ent, ply)
        return IsValid(ent) and IsValid(ply) and ent:IsPlayer()
                and ent:Alive() and ply:IsAdmin()
    end,
    MenuOpen = function(self, opt, ent, tr)
        local submenu = opt:AddSubMenu()
        for t, p in SortedPairs(SBTM.IconTable) do
            if ent:Team() == t then continue end
            local newOption = submenu:AddOption(team.GetName(t), function()
                self:SetTeam(ent, t)
            end)
            newOption:SetIcon(p)
        end
    end,
    Action = function() end,
    SetTeam = function(self, ent, id)
        self:MsgStart()
            net.WriteEntity(ent)
            net.WriteUInt(id, 12)
        self:MsgEnd()
    end,
    Receive = function(self, len, ply)
        local ent = net.ReadEntity()
        local id = net.ReadUInt(12)
        if not self:Filter(ent, ply) then return end
        ent:SetTeam(id)
        SBTM:SetPlayerColor(ent, id)
        SBTM:Hint(ent, "#sbtm.hint.team_set_force", 0, {team.GetName(id)})
        SBTM:Hint(ply, "#sbtm.hint.team_set_admin", 0, {ent:GetName(), team.GetName(id)})
    end,
})

properties.Add("sbtm_npcteam", {
    MenuLabel = "#sbtm.properties.set_team",
    Order = 100,
    MenuIcon = "icon16/group_edit.png",
    Filter = function(self, ent, ply)
        return GetConVar("sbtm_teamnpcs"):GetBool() and IsValid(ent) and IsValid(ply)
                and ent:IsNPC() and ply:IsAdmin()
    end,
    MenuOpen = function(self, opt, ent, tr)
        local submenu = opt:AddSubMenu()
        local curteam = SBTM.NPCTeams[ent:GetClass()]
        for t, p in SortedPairs(SBTM.IconTable) do
            if curteam == t or (t == TEAM_UNASSIGNED and curteam == nil) then continue end
            local newOption = submenu:AddOption(team.GetName(t), function()
                self:SetTeam(ent, t)
            end)
            newOption:SetIcon(p)
        end
    end,
    Action = function() end,
    SetTeam = function(self, ent, id)
        self:MsgStart()
            net.WriteEntity(ent)
            net.WriteUInt(id, 12)
        self:MsgEnd()
    end,
    Receive = function(self, len, ply)
        local ent = net.ReadEntity()
        local id = net.ReadUInt(12)
        if not self:Filter(ent, ply) then return end
        SBTM:SetNPCTeam(ent:GetClass(), id)
        if id == TEAM_UNASSIGNED then
            SBTM:Hint(ply, "#sbtm.hint.npc_unset", 0, {ent:GetClass()})
        else
            SBTM:Hint(ply, "#sbtm.hint.npc_set", 0, {ent:GetClass(), team.GetName(id)})
        end
    end,
})

properties.Add("sbtm_ent_setteam", {
    MenuLabel = "#sbtm.properties.set_team",
    Order = 100,
    MenuIcon = "icon16/group_edit.png",
    Filter = function(self, ent, ply)
        return IsValid(ent) and IsValid(ply) and ent.SBTM_TeamEntity == true and ply:IsAdmin()
    end,
    MenuOpen = function(self, opt, ent, tr)
        local submenu = opt:AddSubMenu()
        for t, p in SortedPairs(SBTM.IconTable) do
            if ent:GetTeam() == t then continue end
            local newOption = submenu:AddOption(team.GetName(t), function()
                self:SetTeam(ent, t)
            end)
            newOption:SetIcon(p)
        end
    end,
    Action = function() end,
    SetTeam = function(self, ent, id)
        self:MsgStart()
            net.WriteEntity(ent)
            net.WriteUInt(id, 12)
        self:MsgEnd()
    end,
    Receive = function(self, len, ply)
        local ent = net.ReadEntity()
        local id = net.ReadUInt(12)
        if not self:Filter(ent, ply) then return end
        ent:SetTeam(id)
        if ent.OnSetTeam then ent:OnSetTeam(id, ply) end
    end,
})

properties.Add("sbtm_ent_remove", {
    MenuLabel = "#sbtm.properties.remove_spawns",
    Order = 150,
    MenuIcon = "icon16/delete.png",
    Filter = function(self, ent, ply)
        return IsValid(ent) and IsValid(ply) and ent.SBTM_TeamEntity == true and ply:IsAdmin()
    end,
    MenuOpen = function(self, opt, ent, tr)
        local submenu = opt:AddSubMenu()
        local newOption = submenu:AddOption(language.GetPhrase("sbtm.properties.remove_spawns.this"), function()
            self:Call(ent, 0)
        end)
        newOption:SetIcon("icon16/user_delete.png")
        newOption = submenu:AddOption(language.GetPhrase("sbtm.properties.remove_spawns.all"), function()
            self:Call(ent, 1)
        end)
        newOption:SetIcon("icon16/group_delete.png")

    end,
    Action = function() end,
    Call = function(self, ent, mode)
        self:MsgStart()
            net.WriteEntity(ent)
            net.WriteUInt(mode, 1)
        self:MsgEnd()
    end,
    Receive = function(self, len, ply)
        local ent = net.ReadEntity()
        local mode = net.ReadUInt(1)
        local t = ent:GetTeam()
        if not self:Filter(ent, ply) then return end
        local c = ent:GetClass()
        for _, e in pairs(ents.FindByClass(c)) do
            if mode == 1 or e:GetTeam() == t then e:Remove() end
        end
    end,
})