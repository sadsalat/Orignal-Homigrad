
function discordlib.structures.channel(client, channel, guild)

    function channel.send(message = !err, callback)
        client.sendMessage(channel.id, message, callback)
    end

    function channel.getWebhooks(callback)
        client.getChannelWebhooks(channel.id, callback)
    end    
    
    function channel.createWebhook(name = !err, avatar, callback)
        client.createWebhook(channel.id, name, avatar, callback)
    end    
    
    function channel.deleteWebhook(webhookID = !err, callback)
        client.deleteWebhook(webhookID, callback)
    end

    function channel.setName(name = !err, callback)
        client.modifyChannel(channel.id, {name = name}, callback)
    end

    function channel.setNSFW(nsfw = !err, callback)
        client.modifyChannel(channel.id, {nsfw = nsfw}, callback)
    end

    function channel.setTopic(topic = !err, callback)
        client.modifyChannel(channel.id, {topic = topic}, callback)
    end

    function channel.getInvites(callback)
        client.getChannelInvites(channel.id, callback)
    end

    function channel.triggerTyping(callback)
        client.triggerTypingIndicator(channel.id, callback)
    end

    if guild
    then
        channel.guild_id = guild.id

        client.cache.channels[channel.id] = channel
    end

    return channel
end