table.insert(LevelList,"schoolshoot")
schoolshoot = {}
schoolshoot.Name = "Active Shooter"

schoolshoot.red = {"Кибер-спортсмены",Color(255,55,55),
    weapons = {"weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller"},
    main_weapon = {"weapon_m3super","weapon_remington870","weapon_xm1014"},
    secondary_weapon = {"weapon_p220","weapon_deagle","weapon_glock"},
    models = tdm.models
}

schoolshoot.green = {"Школьники",Color(55,255,55),
    weapons = {"weapon_hands"},
    models = tdm.models
}

schoolshoot.blue = {"Спецназовцы",Color(55,55,255),
    weapons = {"weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_hg_f1","weapon_handcuffs","weapon_taser","weapon_hg_flashbang"},
    main_weapon = {"weapon_mk18","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_galilsar","weapon_m249","weapon_mp5","weapon_mp40"},
    secondary_weapon = {"weapon_beretta","weapon_fiveseven","weapon_hk_usp"},
    models = tdm.models
}

schoolshoot.teamEncoder = {
    [1] = "red",
    [2] = "green",
    [3] = "blue"
}

function schoolshoot.StartRound(data)
	team.SetColor(1,schoolshoot.red[2])
	team.SetColor(2,schoolshoot.green[2])
	team.SetColor(3,schoolshoot.blue[2])

	game.CleanUpMap(false)

    if CLIENT then
		roundTimeLoot = data.roundTimeLoot

		return
	end

    return schoolshoot.StartRoundSV()
end

schoolshoot.SupportCenter = true
