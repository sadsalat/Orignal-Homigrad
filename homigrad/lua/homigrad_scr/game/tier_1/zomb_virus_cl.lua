local virus = 0
local zombieoverlay = Material( "hud/infection" )
local zombueoverlay2 = Material("hud/scp_infection")
local viruslerp,viruslerp2 = 0,0
local plysound = true

net.Receive("info_virus",function()
    virus = net.ReadFloat()
end)

hook.Add("HUDPaint","VirusEffect",function()
    local w,h = ScrW(),ScrH()
    if virus > 5 then
        if virus > 40 and plysound then
            surface.PlaySound("gbombs_5/tvirus_infection/ply_infection.mp3")
            plysound = false
        end
        local pulse = math.sin(CurTime()*2)
        local pulse2 = math.sin(-CurTime()*2)
        if virus > 70 then
            viruslerp2 = Lerp(0.005,viruslerp2,(virus*1.5)+pulse*15)
            surface.SetMaterial(zombueoverlay2)
            surface.SetDrawColor(0,0,0,viruslerp2)
            surface.DrawTexturedRect(-50+pulse*8,-50+pulse*8,w+50+pulse2*8,h+50+pulse2*8)
        end
        viruslerp = Lerp(0.1,viruslerp,(virus*.5)+pulse)
        surface.SetMaterial(zombieoverlay)
        surface.SetDrawColor(0,0,0,viruslerp*2)
        surface.DrawTexturedRect(-150,-150,w+150,h+150)
    else
        viruslerp = 0
        viruslerp2 = 0
        plysound = true
    end
end)
