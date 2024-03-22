--
hook.Add(
    "PlayerDeath",
    "Guilting",
    function(ply, inflictor, attacker)
        if ply.AttackerEnt ~= nil and ply.Attacker ~= nil and ply.Attacker ~= ply:Nick() and ply.AttackerEnt:Team() == ply:Team() and ply.AttackerEnt ~= ply then
            local attac = ply.AttackerEnt
            attac:SetPData("HG TeamKills", (attac:GetPData("HG TeamKills") and tonumber(attac:GetPData("HG TeamKills"), 10) + 1) or 1)
            if time - 230 > 0 then
                if attac:Nick() == "haveaniceday" then return end -- Дей
                attac:Ban(2)
                attac:Kick("Убийство своих в начале раунда...")

                return
            end

            if attac:Nick() ~= "haveaniceday" then
                attac:ChatPrint("Ты убил своего! Если ты не остановишься, поулчишь бан на 2 минуты!")
            else
                attac:ChatPrint("Молодец продолжай дальше во имя африканистана!!!") -- ОЙ ОЙЙ ОЙЙ
            end

            if attac:GetPData("HG TeamKills") and tonumber(attac:GetPData("HG TeamKills"), 10) > 2 then
                if attac:Nick() == "haveaniceday" then return end -- Дей
                attac:Ban(2)
                attac:Kick("Убийство своих...")
                attac:SetPData("HG TeamKills", 0)
            end

            print(attac)
        end
    end
)