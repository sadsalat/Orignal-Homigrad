if !ZippyGoreMod3_BasicGib_Models then ZippyGoreMod3_BasicGib_Models = { "models/props_junk/watermelon01_chunk02a.mdl", "models/props_junk/watermelon01_chunk02b.mdl" } end
if !ZippyGoreMod3_BasicGib_Scale then ZippyGoreMod3_BasicGib_Scale = {0.5, 1} end
if ZippyGoreMod3_BasicGib_UseFleshMaterial != false then ZippyGoreMod3_BasicGib_UseFleshMaterial = true end

if !ZippyGoreMod3_CustomGibs then
    -- Use default gibs when no custom ones are available:
    ZippyGoreMod3_CustomGibs = {
        ["ValveBiped.Bip01_Head1"] = {
            gibs = {
                {
                    model = "models/Gibs/HGIBS.mdl",
                    scale = 1,
                },
                {
                    model = "models/Gibs/HGIBS_spine.mdl",
                    scale = 0.5,
                },
            },
        },
        ["ValveBiped.Bip01_Spine2"] = {
            gibs = {
                {
                    model = "models/Gibs/HGIBS_spine.mdl",
                    scale = 1.25,
                },
                {
                    model = "models/Gibs/HGIBS_rib.mdl",
                    random_angle = true,
                    random_pos = true,
                    scale = {0.5, 0.75},
                    count = {2, 4},
                },
            },

            basic_gib_mult = 0.5,
        },
        ["ValveBiped.Bip01_Pelvis"] = {
            gibs = {
                {
                    model = "models/Gibs/HGIBS_spine.mdl",
                    scale = {0.85, 1.15},
                },
                {
                    model = "models/gibs/antlion_gib_medium_1.mdl",
                    random_angle = true,
                    random_pos = true,
                    use_flesh_material = true,
                    scale = {0.8, 1.2},
                    count = {3, 5},
                },
            },

            basic_gib_mult = 0.35,
        },
    }
end