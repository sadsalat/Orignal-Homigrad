function discordlib.structures.message(client, message)
    local _message = message
    function message.reply(message = !err, callback)
        message.message_reference = {message_id = _message.id}
        _message.channel.send(message, callback)
    end

    function message.edit(message = !err, callback)
        client.editMessage(_message.channel.id, _message.id, message, callback)
    end

    function message.delete(callback)
        client.deleteMessage(message.channel.id, message.id, callback)
    end    
    
    function message.react(emoji = !err, callback)
        client.createReaction(message.channel.id, message.id, emoji, callback)
    end

    function message.deleteOwnReaction(emoji = !err, callback)
        client.deleteOwnReaction(message.channel.id, message.id, emoji, callback)
    end
    
    function message.deleteUserReaction(emoji = !err, userID = !err, callback)
        client.deleteUserReaction(message.channel.id, message.id, emoji,userID, callback)
    end    
    
    function message.deleteAllReactions(callback)
        client.deleteAllReactions(message.channel.id, message.id, callback)
    end    
    
    function message.deleteAllReactionsForEmoji(emoji = !err,callback)
        client.deleteAllReactionsForEmoji(message.channel.id, message.id, emoji, callback)
    end
    
    if message.author then message.author = discordlib.structures.user(client, message.author) end

    if message.guild_id
    then
        local guild = client.cache.guilds[message.guild_id]
        message.channel = guild.channels[message.channel_id]
        message.guild = guild
    
        if message.author then message.member = guild.members[message.author.id] end
    else
        message.channel = client.cache.private_channels[message.channel_id]
    end


    if message.referenced_message
    then
        message.referenced_message.guild_id = message.message_reference.guild_id
        message.referenced_message.channel_id = message.message_reference.channel_id
        message.referenced_message = discordlib.structures.message(client, message.referenced_message)
    end

    return message
end
