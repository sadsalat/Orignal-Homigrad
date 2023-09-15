table.insert(LevelList,"bahmut")
bahmut = {}
bahmut.Name = "Конфликт Хомиграда"

bahmut.red = {"ЧВК\"ВАГНЕР\"",Color(60,75,60),
	weapons = {"weapon_megamedkit","weapon_binokle","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller","weapon_hg_rgd5","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_ak74u","weapon_akm","weapon_galil","weapon_rpk","weapon_galilsar"},
	secondary_weapon = {"weapon_p220", "weapon_deagle","weapon_glock"},
	models = {"models/knyaje pack/dibil/sso_politepeople.mdl"}
}

local models = {}
for i = 1,9 do table.insert(models,"models/player/rusty/natguard/male_0" .. i .. ".mdl") end

bahmut.blue = {"НАТО",Color(125,125,60),
	weapons = {"weapon_megamedkit","weapon_binokle","weapon_hands","weapon_kabar","bandage","med_band_big","med_band_small","painkiller","weapon_hg_f1","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_mk18","weapon_m4a1","weapon_xm1014","weapon_m249"},
	secondary_weapon = {"weapon_beretta","weapon_fiveseven","weapon_hk_usp"},
	models = models
}

bahmut.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function bahmut.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,bahmut.red[2])
	team.SetColor(2,bahmut.blue[2])

	if CLIENT then

		bahmut.StartRoundCL()
		return
	end

	bahmut.StartRoundSV()
end
bahmut.RoundRandomDefalut = 1
bahmut.SupportCenter = true
