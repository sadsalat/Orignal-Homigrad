-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
hook.Add("PopulateToolMenu", "PopulateToolMenu_ZippyGoreMod3", function()
    spawnmenu.AddToolMenuOption("Options", "Zippy", "Gore Mod", "Gore Mod", "", "", function(panel)
        if LocalPlayer():IsSuperAdmin() then

            -- Custom checkbox/slider functions --

            local checkboxes = {}
            local sliders = {}

            local function checkbox( lbl, cvar )
                local ctrl = panel:CheckBox(lbl)
                ctrl:SetChecked(GetConVar(cvar):GetBool())
                ctrl.OnChange = function(me) ZippyGoreMod3_ChangeCvar( cvar, me:GetChecked() && 1 or 0 ) end
                checkboxes[cvar] = ctrl
                return ctrl
            end

            local function slider( lbl, cvar, min, max, decimals )
                local ctrl = panel:NumSlider(lbl, nil, min, max, decimals)
                ctrl:SetValue(GetConVar(cvar):GetFloat())
                ctrl.OnValueChanged = function(me) ZippyGoreMod3_ChangeCvar( cvar, me:GetValue() ) end
                sliders[cvar] = ctrl
            end

            -- CHECKBOXES --

            checkbox( "Enable", "zippygore3_enable" )
            panel:Help("Make future ragdolls gibbable.")

            checkbox( "Gib Map Spawned Ragdolls", "zippygore3_gib_any_ragdoll" )
            panel:Help("Disable to only gib ragdolls spawned by NPCs/nextbots/players.")

            local nevergibBox = checkbox( "Ignore Never-Gib-Damage", "zippygore3_disable_never_gib_damage" )
            nevergibBox:SetToolTip("Enabling this will allow the crossbow, or the CW 2.0 shotguns to gib ragdolls for example, normally they can't.")
            panel:Help("Gib even if damage type was DMG_NEVERGIB.")

            local alwaysgibBox = checkbox( "Ignore Always-Gib-Damage", "zippygore3_disable_always_gib_damage" )
            alwaysgibBox:SetToolTip("This will fix CW 2.0 weapons instantly gibbing bones for example, but will make things like the TFA G.I.B ammo unable to instantly gib bones.")
            panel:Help("Don't let damage with the DMG_ALWAYSGIB damage type instantly gib.")

            checkbox( "Gib Dissolving Ragdolls", "zippygore3_gib_dissolving_ragdoll" )
            panel:Help("Should dissolving ragdolls be gibbable?")
            
            checkbox( "Edible Gibs", "zippygore3_gib_edible" )
            panel:Help("Eat gibs and regain health.")

            checkbox( "Bleed Effect", "zippygore3_bleed_effect" )
            panel:Help("Enable bleed effect from gibs and stumps.")

            local developerBox = checkbox( "Show Gibbed Bone Name", "zippygore3_print_gibbed_bone" )
            developerBox:SetToolTip("Show the name of any gibbed bone on the screen, and print it out in the chat. This will help you when you setup custom bone-specific gibs.")
            panel:Help("Only developers should enable this option!\n\n")

            -- SLIDERS --

            panel:ControlHelp("GIB OPTIONS:")

            slider("Gib Limit", "zippygore3_gib_limit", 0, 500, 0)
            panel:Help("How many gibs can exist at once? When the limit is reached, old gibs are removed.")

            slider("Gib Fade Time", "zippygore3_gib_lifetime", -1, 600, 0)
            panel:Help("Fade gibs automatically after this many seconds? -1 = Don't.\n\n")

            panel:ControlHelp("RAGDOLL HEALTH OPTIONS:")

            slider("Bone Health Multiplier", "zippygore3_misc_bones_health_mult", 0, 10, 1)
            panel:Help("Multiply the health values for all bones (except the root bone) by this amount.")

            slider("Root Bone Health Multiplier", "zippygore3_root_bone_health_mult", 0, 10, 1)
            panel:Help("Multiply the health value of the root bone by this amount. If the root bone on a ragdoll is destroyed, the entire ragdoll is gibbed.\n\n")

            panel:ControlHelp("RAGDOLL DAMAGE OPTIONS:")

            slider("Explosion Damage Multiplier", "zippygore3_explosion_damage_mult", 0, 10, 1)
            panel:Help("Multiply damage from explosions by this amount.")

            slider("Physics Damage Multiplier", "zippygore3_phys_damage_mult", 0, 10, 1)
            panel:Help("Multiply damage from physics by this amount.\n\n")

            panel:ControlHelp("EDIBLE GIBS OPTIONS:")

            slider("Gib Give Health Amount", "zippygore3_gib_heath_give", 0, 100, 0)
            panel:Help("How much health should gibs give when eaten?\n")

            -- RESET BUTTON --

            local button = vgui.Create("DButton", panel)
            button:Dock(TOP)
            button:DockMargin(5, 15, 5, 0)
            button:SetText("Reset All Settings")
            button.DoClick = function()
                for k in pairs(ZGM3_CVARS) do
                    if checkboxes[k] then
                        checkboxes[k]:SetChecked( GetConVar(k):GetDefault() )
                        ZippyGoreMod3_ChangeCvar( k, checkboxes[k]:GetChecked() && 1 or 0 )
                    end

                    if sliders[k] then sliders[k]:SetValue( GetConVar(k):GetDefault() ) end
                end
            end
        else
            panel:Help("You do not have permission!")
        end
    end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------