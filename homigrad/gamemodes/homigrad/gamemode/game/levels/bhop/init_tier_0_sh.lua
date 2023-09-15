table.insert(LevelList,"bhop")
bhop = {}
bhop.Name = "Bhop"
bhop.LoadScreenTime = 5.5
bhop.CantFight = bhop.LoadScreenTime

bhop.RoundRandomDefalut = 1
bhop.NoSelectRandom = true

local red = Color(255,0,0)

function bhop.GetTeamName(ply)
    local teamID = ply:Team()

     if teamID == 1 then return "CS'ер",red end
end

function bhop.StartRound(data)
    team.SetColor(1,red)
    team.SetColor(2,blue)
    team.SetColor(1,green)

    game.CleanUpMap(false)

    if CLIENT then
        roundTimeStart = data[1]
        roundTime = data[2]

        local bhop
        sound.PlayURL("https://cdn.discordapp.com/attachments/1106621848784994356/1136334459122229309/cs_go_-_Bhop_song_75505505.mp3","mono noblock",function(snd)
            bhop = snd

            snd:EnableLooping(true)
            snd:SetVolume(0.5)
        end)

        timer.Simple(4,function()
            sound.PlayURL("https://cdn.discordapp.com/attachments/1106621848784994356/1136296503657369741/piaterka-upal-v-bezdnu_WxV5k5O.mp3","mono",function(snd)
                snd:SetVolume(0.25)

                timer.Simple(1,function()
                    snd:Stop()
                    bhop:SetVolume(0.25)
                end)
            end)
        end)

        return
    end

    return bhop.StartRoundSV()
end

if SERVER then return end

local nigger = Color(0,0,0)
local red = Color(255,0,0)

local kill = 4

local white,red = Color(255,255,255),Color(255,0,0)

local fuck,fuckLerp = 0,0

function bhop.Think()
    /*if LocalPlayer():Alive() then
        local active = roundTimeStart + bhop.LoadScreenTime < CurTime() and LocalPlayer():IsOnGround()

        if active then
            fuck = fuck + 1 * FrameTime()
        else
            fuck = 0
        end

        if fuck >= kill then RunConsoleCommand("kill") end
    else
        fuck = 0
    end

    fuckLerp = LerpFT(0.1,fuckLerp,fuck)*/
end

function bhop.HUDPaint_RoundLeft(white2)
    local anim_pos = math.max(roundTimeStart + bhop.LoadScreenTime - CurTime(),0) / 3
    anim_pos = math.min(anim_pos / 0.25,1)

    if anim_pos > 0 then
        nigger.a = 255 * anim_pos
        draw.RoundedBox(0,0,0,ScrW(),ScrH(),nigger)

        red.a = nigger.a
        draw.DrawText("Bhop","HomigradFontBig",ScrW() / 2,ScrH() / 5,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        draw.DrawText("Убей их всех, они не заслужили большего.", "HomigradFontBig",ScrW() / 2,ScrH() / 1.2,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        draw.DrawText("ALT что-бы увидеть прячущегося.", "HomigradFontBig",ScrW() / 2,ScrH() / 1.2 + 50,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local time = math.Round(roundTimeStart + roundTime - CurTime())
    if time > 0 then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = acurcetime

        draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    if (timeStartAnyDeath or 0) + 15 < CurTime() then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = acurcetime

        draw.SimpleText("can use alt","HomigradFont",ScrW() / 2,ScrH() - 50,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local k = math.min(fuckLerp / kill,1)
    local k2 = 1 - k

    local color = Color(255,255 * k2,255 * k2)
    color.a = 255 * math.min(k / 0.25,1)

    local k3 = math.max(k - 0.25,0) / 0.25
    local x,y = math.random(-12,12) * k3,math.random(-4,4) * k3

    local w = ScrW() / 4 * k
    draw.RoundedBox(0,ScrW() / 2 + y - w / 2,ScrH() - 125,w,5,color)

    draw.SimpleText("JUMP" .. string.rep("!",(CurTime() * math.max(10 * k,1)) % 4),"ChatFont",ScrW() / 2,ScrH() - 100,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

net.Receive("bhop die",function()
    timeStartAnyDeath = CurTime()
end)

function bhop.CanUseSpectateHUD()
    return (timeStartAnyDeath or 0) + 15 < CurTime()
end