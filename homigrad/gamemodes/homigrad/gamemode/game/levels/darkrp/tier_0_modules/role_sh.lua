darkrp.roles = {
    {
        "Гражданин",Color(125,255,125),
        models = {}
    },
    {
        "Полицейский",Color(0,0,255),
        models = {"models/player/police.mdl","models/player/police_fem.mdl"},
        limit = 4,
        cantArest = true,
        
        main_weapon = {"weapon_per4ik","weapon_radio","weapon_p220","weapon_taser","darkrp_stick_arest","darkrp_doom_ram"}
    },
    {
        "Мэр",Color(255,0,0),
        models = {"models/player/breen.mdl"},
        limitC = 1,
        canChangeRule = true,
        cantArest = true
    },
    {
        "Бандин",Color(155,155,155),
        models = {}
    },
    {
        "Вор",Color(25,25,25),
        models = {},
        shop = {
            {"Взломщик","darkrp+unlocker_door",50}
        }
    },
    {
        "Продавец оружия",Color(255,125,0),
        models = {},
        shop = {
            {"P220","weapon_p220",100}
        }
    },
    {
        "Вармацефт",Color(255,155,155),
        models = {},
        shop = {
            {"Аптечка","medkit",35},
            {"Бинт","bandage",5},
            {"Морфий","morphine",25},
            {"Обезбол","painkiller",25},
            {"Адреналин","adrenaline",55}
        }
    }
}

local roles = darkrp.roles

local models = roles[4].models
for i = 1,9 do models[#models + 1] = "models/player/group03/male_0" .. i .. ".mdl" end
for i = 1,6 do models[#models + 1] = "models/player/group03/female_0" .. i .. ".mdl" end

models = roles[1].models
for i = 1,9 do models[#models + 1] = "models/player/group01/male_0" .. i .. ".mdl" end
for i = 1,6 do models[#models + 1] = "models/player/group01/female_0" .. i .. ".mdl" end

local empty = {}

function darkrp.GetRole(ply)
    local roleID = ply:GetNWInt("DarkRPRole")

    return roles[roleID] or empty,roleID
end

if SERVER then return end

function darkrp.ScoreboardSort(sort)
    local list = {}
    local last = {}

    for i,ply in pairs(team.GetPlayers(1)) do
        local roleID = ply:GetNWInt("DarkRPRole")
        if not roleID then last[#last + 1] = ply continue end

        list[roleID] = list[roleID] or {{},{}}

        if ply:Alive() then list[roleID][1][ply] = true else list[roleID][2][ply] = true end
    end

    for roleID,list in pairs(list) do
        for ply in pairs(list[1]) do sort[#sort + 1] = ply end
        for ply in pairs(list[2]) do sort[#sort + 1] = ply end
    end

    for i,ply in pairs(last) do
        sort[#sort + 1] = ply
    end
end

function darkrp.GetTeamName(ply)
    local teamID = ply:Team()

    if teamID == 1 then
        local role = darkrp.GetRole(ply)
        if not role then return "багаюзер" end

        return role[1],role[2]
	end
end