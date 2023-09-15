-- VERY IMPORTANT NOTE: You must rename your file to something else, or else it might get overwritten!
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- BASIC GIBS --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- The "basic" gibs are gibs that can spawn from any ragdoll bone:

-- Here is an example that turns the gibs into giant bathtubs:
-- (VERY IMPORTANT: REMOVE THE "local" WHEN YOU USE THESE IN YOUR FILE!!)
local ZippyGoreMod3_BasicGib_Models = { "models/props_c17/FurnitureBathtub001a.mdl" } -- Put as many models as you like.
local ZippyGoreMod3_BasicGib_Scale = {2, 2} -- Minimum and maximum model scale for the basic gibs. Both values have to be included.
local ZippyGoreMod3_BasicGib_UseFleshMaterial = false -- Apply a flesh material to the models, set to false if you want the models to have their default materials.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- BONE SPECIFIC GIBS --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Here you can change what gibs should spawn from specific bones

-- [*name of bone that should have these gibs, for example "ValveBiped.Bip01_Head1"*] = {
--     gibs = {
--         {
--             model = *gib model name*,
--             scale = {*minimum model scale*, *maximum model scale*},
--             random_angle = *true = spawn with random angle, otherwise it will have the same angle as the bone*,
--             random_pos = *true = spawn at a random position around the bone, otherwise it will spawn on the bone*,
--             count = {*minimum amount of this gib*, *maximum amount of this gib*},
--             use_flesh_material = *true = spawn with a flesh material*,
--             is_ragdoll = *true <-- if gib is a ragdoll*,
--         },
--     },

--     basic_gib_mult = *multiply the amount of "basic" gibs spawned when this bone is gibbed*.
-- },

-- Your table of gibs should look something like this:
-- (VERY IMPORTANT: REMOVE THE "local" IN YOUR FILE!!)
local ZippyGoreMod3_CustomGibs = {
    ["ValveBiped.Bip01_Head1"] = {
        -- The head spawns a skull and a small spine piece:
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
        -- Chest spawns ribs and a spine peice:
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
        -- The gut spawns something that kind of resembles intestines, and also another spine peice:
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