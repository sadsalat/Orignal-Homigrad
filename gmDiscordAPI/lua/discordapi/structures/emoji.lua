function discordlib.structures.emoji(client, emoji)
    local str = "<" .. (emoji.animated and "a" or "") .. ":" .. emoji.name .. ":" .. emoji.id .. ">"
    -- maybe __tostring, __concat?
    function emoji.toString()
        return str
    end

    return emoji
end