function tdm.KCenter(pos,point)
	local dis = 0

	for i,point in pairs(point) do
		--local dis2 = math.min(math.max(pos:Distance(point[1]) / point[3] - 0.95,0) / 0.05,1)
	    --if dis2 < dis then dis = dis2 end
	end

	return dis
end

if SERVER then return end

local grtodown = Material( "vgui/gradient-u" )
local grtoup = Material( "vgui/gradient-d" )
local grtoright = Material( "vgui/gradient-l" )
local grtoleft = Material( "vgui/gradient-r" )

tdm.SupportCenter = true

hook.Add("HUDPaint","bahmut",function()
    local lply = LocalPlayer()
    if true then return end

    if not TableRound().SupportCenter then return end
    if not GetGlobalVar("Center") or not lply:Alive() then return end

    local point = SpawnPointsList.center[3]
    if #point == 0 then return end
    local dis = tdm.KCenter(lply:GetPos(),point)

    local w,h = ScrW(),ScrH()
    local k = 1 - math.cos(CurTime() * 2) / 2
    k = k / 10
    k = k * dis

    surface.SetMaterial(grtodown)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(0,0,w,h * k)

    surface.SetMaterial(grtoup)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(0,h - h * k,w,h * k + 1)

    surface.SetMaterial(grtoright)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(0,0,w * k / 2,h)

    surface.SetMaterial(grtoleft)
    surface.SetDrawColor(128,0,0,64)
    surface.DrawTexturedRect(w - w * k / 2,0,w * k / 2 + 1,h)
end)