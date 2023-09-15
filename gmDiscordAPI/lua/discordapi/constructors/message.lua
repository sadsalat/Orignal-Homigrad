

function discordlib.message()
    local message = {allowed_mentions = {}}

    function message.setText(text = !err)
        message.content = text
        return message
    end    
    
    function message.setReferenceTo(messageID = !err, allowMentition = true)
        message.message_reference = {message_id = messageID}
        message.allowed_mentions.replied_user = allowMentition
        return message
    end

    function message.addEmbed(embed = !err)
        message.embeds = message.embeds or {}
        message.embeds[#message.embeds + 1] = embed
        return message
    end

    function message.addComponents(components = !err)
        message.components = message.components or {}
        if #message.components > 5 then error("Exceeded the limit on the number of components(6)") end
        message.components[#message.components + 1] = components
        return message
    end    
    
    function message.setFile(filename = !err, data = !err, contentType = "text/plain")
        message.file = message.file or {}
        message.file = {filename, data, contentType}
        return message
    end    
    
    function message.disallowMentions()
        message.allowed_mentions.parse = {}
        return message
    end

    function message.resetMentionRestriction()
        message.allowed_mentions.parse = nil
        message.allowed_mentions.users = nil
        message.allowed_mentions.roles = nil
    end

    function message.allowRolesMention()
        message.allowed_mentions.parse = message.allowed_mentions.parse or {}
        message.allowed_mentions.parse[#message.allowed_mentions.parse + 1] = "roles"
        return message
    end

    function message.allowUsersMention()
        message.allowed_mentions.parse = message.allowed_mentions.parse or {}
        message.allowed_mentions.parse[#message.allowed_mentions.parse + 1] = "users"
        return message
    end

    function message.allowEveryoneMention()
        message.allowed_mentions.parse = message.allowed_mentions.parse or {}
        message.allowed_mentions.parse[#message.allowed_mentions.parse + 1] = "everyone"
        return message
    end

    function message.allowUserMention(userID = !err)
        message.allowed_mentions.users = message.allowed_mentions.users or {}
        message.allowed_mentions.users[#message.allowed_mentions.users + 1] = userID
        return message
    end

    function message.allowRoleMention(roleID = !err)
        message.allowed_mentions.roles = message.allowed_mentions.roles or {}
        message.allowed_mentions.roles[#message.allowed_mentions.roles + 1] = roleID
        return message
    end

    return message
end