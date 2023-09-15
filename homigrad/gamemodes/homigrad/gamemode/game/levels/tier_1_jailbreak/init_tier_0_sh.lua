table.insert(LevelList,"jailbreak")
jailbreak = {}
jailbreak.Name = "Jailbreak"

jailbreak.ranksList = {
    {"Рядовой",Color(125,125,255),{"Light-Helmet"}},
    {"Сержант",Color(75,75,255),{"Light-Helmet","Light-Vest"}},
    {"Старшина",Color(25,25,25,255),{"Riot-Helmet","Light-Vest"}},
    {"Прапорщик",Color(25,25,125),{"Medium-Helmet","Medium-Light-Vest"}}
}

jailbreak.rankGeneral = {"Генерал РФ",Color(55,0,200),{"Ultra-Heavy-Helmet","Medium-Light-Vest"}}

function jailbreak.GetRank(ply)
    local rankID = ply:GetNWInt("JailBreakRank",0)
    local rank = jailbreak.ranksList[rankID]

    if not rank and ply:IsAdmin() then return jailbreak.rankGeneral,true end

    return rank,rankID
end

jailbreak.red = {"Зеки",Color(255,55,55),
    weapons = {
        "weapon_hands",
    },

    models = tdm.models
}

jailbreak.blue = {"Мусора",Color(55,55,255),
    weapons = {
        "weapon_radio",
        "weapon_per4ik",
        "weapon_binokle",
        "weapon_hands",
        "weapon_kabar",
        "bandage",
        "medkit",
        "painkiller",
        "weapon_jmodnade",
        "weapon_handcuffs",
        "weapon_taser",
        "weapon_jmodflash",
        "weapon_megamedkit"
    },
    main_weapon = {
        "weapon_mk18",
        "weapon_m4a1",
        "weapon_m3super",
        "weapon_mp7",
        "weapon_xm1014",
        "weapon_fal",
        "weapon_galilsar",
        "weapon_m249",
        "weapon_mp5",
        "weapon_mp40"
    },
    secondary_weapon = {
        "weapon_beretta",
        "weapon_fiveseven",
        "weapon_hk_usp"
    },
    models = tdm.models
}

jailbreak.teamEncoder = {
    [1] = "red",
    [2] = "blue"
}

function jailbreak.GetMaxBlue()
    return math.max(math.floor(#team.GetPlayers(1) / 4),1)
end

function jailbreak.StartRound()
    team.SetColor(1,jailbreak.red[2])
    team.SetColor(2,jailbreak.blue[2])

    game.CleanUpMap(false)

    if CLIENT then return end

    jailbreak.StartRoundSV()
end

function jailbreak.help(ply)
    ply:ChatPrint("!jailbreak_ranks - существующие ранги")
    ply:ChatPrint("!jailbreak_add - имя ранг, имя не должно содержать пробелов (находит по частям)")
    ply:ChatPrint("Имея ранг, обычный игрок сможет зайти за охраников, вы можете друг друга уволнять или повышать. но не сможете повысть кого-то выше себя.")
    ply:ChatPrint("Возьми рацию, зажми лкм и тебя будут слышать все, если в чат пишешь держа в руке рацию то эффект тот же.")
    ply:ChatPrint("На колёсико мышки можно ставить метку или открывать дври.")
    ply:ChatPrint("Что-бы открыть или закрыть двери нажми лкм или пкм")
    ply:ChatPrint("Гилт работает в сторону зеков, если тебя убъёт человек рангом выше (кт), ему не дадут гилт.")
end

function jailbreak.CanUseSpawnMenu(ply)
    if ply:Team() == 2 and ply:Alive() then
        local rank,rankID = jailbreak.GetRank(ply)

        return rankID == true or rankID >= 4
    end
end