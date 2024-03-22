local a = 0
local b = 0
hook.Add(
    "RenderScreenspaceEffects",
    "grayscr",
    function()
        if not LocalPlayer():Alive() then return end
        a = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1)
        b = math.Clamp(LocalPlayer():GetNWInt("pain") / 250, 0, 1)
        DrawColorModify(
            {
                ["$pp_colour_brightness"] = 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = a,
            }
        )
    end
)