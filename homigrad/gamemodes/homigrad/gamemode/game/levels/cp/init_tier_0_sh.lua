--CP от слова чайлд порн, очевидно

table.insert(LevelList,"cp")
cp = {}
cp.Name = "Захват точек"
cp.points = {}

cp.WinPoints = cp.WinPoints or {}
cp.WinPoints[1] = cp.WinPoints[1] or 0
cp.WinPoints[2] = cp.WinPoints[2] or 0

local red, blue, gray = Color(255,75,75), Color(75,75,255), Color(200, 200, 200)

cp.red = {"Красные",Color(255,75,75),
    weapons = {"weapon_binokle","weapon_hg_flashbang","weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller"},
    main_weapon = {"weapon_ak74u","weapon_akm","weapon_remington870","weapon_galil","weapon_rpk","weapon_galilsar","weapon_mp40"},
    secondary_weapon = {"weapon_p220","weapon_deagle","weapon_glock"},
    models = tdm.models
}

cp.blue = {"Синие",Color(75,75,255),
    weapons = {"weapon_binokle","weapon_hg_flashbang","weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","weapon_taser"},
    main_weapon = {"weapon_mk18","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_galilsar","weapon_m249","weapon_mp40"},
    secondary_weapon = {"weapon_beretta","weapon_fiveseven","weapon_hk_usp"},
    models = tdm.models
}

cp.teamEncoder = {
    [1] = "red",
    [2] = "blue"
}

cp.RoundRandomDefalut = 1

function cp.StartRound()
	game.CleanUpMap(false)

    cp.points = {}

    cp.LastWave = CurTime()

    cp.WinPoints = {}
    cp.WinPoints[1] = 0
    cp.WinPoints[2] = 0

	team.SetColor(1,red)
	team.SetColor(2,blue)

    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        cp.points[i] = {}
    end

    SetGlobalInt("CP_respawntime", CurTime())

	if CLIENT then return end

    timer.Create("CP_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        cp.PointsThink()
    end)

    cp.StartRoundSV()
end

--тот кто это кодил нужно убить нахуй

cp.SupportCenter = true