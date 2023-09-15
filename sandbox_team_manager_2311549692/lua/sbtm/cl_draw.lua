--[[
local diamond = Material("sbtm/diamond.png", "smooth")
local skull = Material("sbtm/skull.png", "smooth")
local distmaxsqr = 4096 ^ 2
local mouserangesqr = 2048 ^ 2

hook.Add("HUDPaint", "SBTM_Teammates", function()
    local cvar = GetConVar("cl_sbtm_teamoutline"):GetInt()
    local ply = LocalPlayer()

    if not GetConVar("cl_drawhud"):GetBool()
            or ply:Team() == TEAM_UNASSIGNED
            or cvar == 0
            or (cvar == 2 and (not SBMG or SBMG:GameHasTag(SBMG_TAG_FORCE_FRIENDLY_FIRE) or not SBMG:GetActiveGame()))
            or not GetConVar("cl_sbtm_teamoutline_mark"):GetBool() then
        return
    end

    local ally_positions = {}
    cam.Start3D()
    for _, p in pairs(player.GetAll()) do
        if p ~= ply and (p:Team() == ply:Team() or ply:Team() == TEAM_SPECTATOR) then
            table.insert(ally_positions, {p, (p:GetPos() + Vector(0, 0, 80)):ToScreen()})
        end
    end
    cam.End3D()

    for k, v in pairs(ally_positions) do
        local ply_dist = EyePos():DistToSqr(v[1]:GetPos() + Vector(0, 0, 80))
        local s = math.Clamp(1 - ply_dist / distmaxsqr, 0.5, 1) * 32
        local x, y = v[2].x, v[2].y

        local clr_s = SBTM:TeamColor(v[1], SBTM_TCLR_SOFT)

        local mouse_dist = math.sqrt(math.abs(ScrW() * 0.5 - x) ^ 2 + math.abs(ScrH() * 0.5 - y) ^ 2)
        local mouse_range = math.Clamp(1 - ply_dist / mouserangesqr, 0.1, 1) * 256 * (ScrH() / 720)
        if mouse_dist < mouse_range then
            --GAMEMODE:ShadowText(v[1]:GetName(), "CGHUD_24_Unscaled", x, y - s / 2, CLR_W, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
            draw.SimpleText(v[1]:GetName(), "Futura_24", x + 1, y - s / 2 + 1, Color(0, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(v[1]:GetName(), "Futura_24", x, y - s / 2, clr_s, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end

        surface.SetDrawColor(clr_s.r, clr_s.g, clr_s.b, 150)
        surface.SetMaterial(v[1]:Alive() and diamond or skull)
        surface.DrawTexturedRect(x - s * 0.5, y - s * 0.5, s, s)
    end
end)]]--