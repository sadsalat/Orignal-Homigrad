

local function emojid(emoji)
    if emoji
    then
        local animated,name,id = string.match(emoji, "<?(a?):(.*):([0-9]*)>?")
        if name != nil
        then
            emoji = {name = name,id = id, animated = animated == "a"}
        else
            emoji = {name = emoji}
        end
    end

    return emoji
end

function discordlib.presence()
    local presence = {status = "online", afk = false, game = "null", since = 0}

    function presence.setStatus(status = !err)
        presence.status = status
        return presence
    end

    function presence.setGame(name = !err)
        presence.game = { name = name, type = 0 }
        return presence
    end

    function presence.setStreaming(details = !err, url)
        presence.game = { name = details, url = url, type = 1 }
        return presence
    end

    function presence.setListening(name = !err)
        presence.game = { name = name, type = 2 }
        return presence
    end

    function presence.setWatching(name = !err)
        presence.game = { name = name, type = 3 }
        return presence
    end    

    function presence.setCompeting(name = !err)
        presence.game = { name = name, type = 5}
        return presence
    end



    return presence
end