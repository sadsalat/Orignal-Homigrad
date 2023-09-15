function discordlib.structures.user(client, user)

    function user.avatarURL(size, ext)
        if user.avatar
        then
            return "https://cdn.discordapp.com/avatars/" .. user.id .. "/" .. user.avatar .. (ext and "." .. ext or "") .. (size and "?size=" .. 2 ^ math.floor(math.log(size, 2)) or "")

        end
        return "https://cdn.discordapp.com/embed/avatars/" .. (user.discriminator % 5) .. ".png"
    end

    function user.send(message = !err, callback)
        client.sendMessageDM(user.id, message, callback)
    end

    return user
end