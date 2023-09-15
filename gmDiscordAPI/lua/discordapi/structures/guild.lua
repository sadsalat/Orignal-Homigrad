function discordlib.structures.guild(client, guild)
    local channels = {}
    local roles = {}
    for k,role in ipairs(guild.roles)
    do
        roles[role.id] = discordlib.structures.role(client, role)
    end
    guild.roles = roles

    for k,channel in ipairs(guild.channels)
    do
        channels[channel.id] = discordlib.structures.channel(client, channel, guild)
    end
    guild.channels = channels

    local members = {}
    for k,member in ipairs(guild.members)
    do
        members[member.user.id] =  discordlib.structures.member(client, member, guild)
    end
    guild.members = members

    local emojis = {}
    for k,emoji in ipairs(guild.emojis)
    do
        emojis[emoji.id] = discordlib.structures.emoji(client, emoji)
    end
    guild.emojis = emojis

    function guild.unban(userID = !err, callback)
        client.unbanMember(guild.id, userID, callback)
    end

    function guild.getBans(callback)
        client.getGuildBans(guild.id,callback)
    end

    function guild.getCommands(callback)
        client.getGuildCommands(guild.id, callback)
    end

    function guild.addCommand(command = !err, callback)
        client.createGuildCommand(command, guild.id, callback)
    end    

    function guild.addUserCommand(name = !err, callback)
        client.createGuildCommand({name = name, type = 2}, guild.id, callback)
    end

    function guild.addMessageCommand(name = !err, callback)
        client.createGuildCommand({name = name, type = 3}, guild.id, callback)
    end

    function guild.editCommand(command = !err, commandID = !err, callback)
        client.editGuildCommand(command, guild.id, commandID, callback)
    end
    
    function guild.deleteCommand(commandID = !err, callback)
        client.deleteGuildCommand(guild.id, commandID, callback)
    end

    function guild.getInvites(callback)
        client.getGuildInvites(guild.id, callback)
    end

    function guild.createInvite(channelID = !err, max_age, max_uses, temporary, unique, callback)
        client.createChannelInvite(channelID, {max_age = max_age, max_uses = max_uses, temporary = temporary, unique = unique}, callback)
    end

    function guild.swapChannels(channelID = !err, channelID2 = !err, callback)
        local channels = guild.channels
        local pos1 = channels[channelID].position or 0
        local pos2 = channels[channelID2].position or 0
        if pos1 == pos2
        then
            return client.modifyGuildChannel(guild.id, {{id = channelID, position = 0},{id = channelID2, position = 1}}, callback)
        end

        client.modifyGuildChannel(guild.id, {{id = channelID, position = (pos1 > pos2) and 0 or 1},{id = channelID2, position = (pos1 > pos2) and 1 or 0}}, callback)
    end
    
    return guild
end