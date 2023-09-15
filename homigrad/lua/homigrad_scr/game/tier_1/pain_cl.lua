local grtodown = Material( "vgui/gradient-u" )
local grtoup = Material( "vgui/gradient-d" )
local grtoright = Material( "vgui/gradient-l" )
local grtoleft = Material( "vgui/gradient-r" )

pain,painlosing,impulse = 0,0,0

net.Receive("info_pain",function()
    pain = net.ReadFloat()
    painlosing = net.ReadFloat()
end)

local ScrW,ScrH = ScrW,ScrH
local math_Clamp = math.Clamp
local k = 0
local k4 = 0
local time = 0

hook.Add("HUDPaint","PainEffect",function()
    if not LocalPlayer():Alive() then return end
    
    local w,h = ScrW(),ScrH()
    k = Lerp(0.1,k,math_Clamp(pain / 250,0,15))
--[[
    surface.SetMaterial(grtodown)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawTexturedRect(0,0,w,h * k)

    surface.SetMaterial(grtoup)
    surface.SetDrawColor(0, 0, 0, 255 )
    surface.DrawTexturedRect(0,h - h * k,w,h * k + 1)

    surface.SetMaterial(grtoright)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawTexturedRect(0,0,w * k,h)

    surface.SetMaterial(grtoleft)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawTexturedRect(w - w * k,0,w * k + 1,h)
--]]
    
    local k2 = painlosing >= 5 and (painlosing / 5 - 1) or 0
   
    DrawMotionBlur(0.2,k2 * 0.9,k2 * 0.06)

    surface.SetMaterial(grtodown)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawTexturedRect(0,h * k - h,w,h * 2)

    surface.SetMaterial(grtoup)
    surface.SetDrawColor(0, 0, 0, 255 )
    surface.DrawTexturedRect(0,h - h * k,w,h)

    surface.SetMaterial(grtoright)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawTexturedRect(-w + w * k,0,w,h)

    surface.SetMaterial(grtoleft)
    surface.SetDrawColor(0,0,0,255)
    surface.DrawTexturedRect(w - w * k,0,w,h)

    DrawMotionBlur(0.2,k * 0.7,k * 0.03)
end)

local addmat_r = Material("CA/add_r")
local addmat_g = Material("CA/add_g")
local addmat_b = Material("CA/add_b")
local vgbm = Material("vgui/black")

local function DrawCA(rx, gx, bx, ry, gy, by)
    render.UpdateScreenEffectTexture()
    addmat_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
    addmat_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
    addmat_b:SetTexture("$basetexture", render.GetScreenEffectTexture())
    render.SetMaterial(vgbm)
    render.DrawScreenQuad()
    render.SetMaterial(addmat_r)
    render.DrawScreenQuadEx(-rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry)
    render.SetMaterial(addmat_g)
    render.DrawScreenQuadEx(-gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy)
    render.SetMaterial(addmat_b)
    render.DrawScreenQuadEx(-bx / 2, -by / 2, ScrW() + bx, ScrH() + by)
end

net.Receive("info_impulse",function()
    impulse = net.ReadFloat() * 50
end)

local k3 = 0
hook.Add("RenderScreenspaceEffects","renderimpulse",function()

    k3 = math.Clamp(Lerp(0.01,k3,impulse),0,50)

    if LocalPlayer():Alive() then
        DrawCA(4 * k3, 2 * k3, 0, 2 * k3, 1 * k3, 0)
    end
    --[[if LocalPlayer():Name() == "useless" then
        local offset = 40
        DrawCA(4 * offset, 2 * offset, 0, 2 * offset, 1 * offset, 0)
    end--]]
end)
