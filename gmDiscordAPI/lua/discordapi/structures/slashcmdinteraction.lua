local function parseInteractionData(client, data, guild)
    for k, v in pairs(data) do
        if istable(v) then
            v = parseInteractionData(client, v, guild)
            continue
        end

        if k ~= "value" then continue end

        local dataType = type(v)
        data.type = dataType
        if dataType ~= "string" then continue end

        local member = client.cache.users[v]
        
        if member then
            data[k] = member
            data.type = "user"
            continue
        end
        if guild == nil then continue end
        
        local channel = guild.channels[v]

        if channel then
            data[k] = channel
            data.type = "channel"
            continue
        end

        local role = guild.roles[v]

        if role then
            data[k] = role
            data.type = "role"
            continue
        end
    end

    return data
end

function discordlib.structures.slashcmdinteractiondata(client, data, guild)
    if data.target_id
    then
        if data.resolved.messages
        then
            local _, message = next(data.resolved.messages)
            message.guild_id = guild.id
            data.message = discordlib.structures.message(client, message)
        elseif data.resolved.members
        then
            data.member = client.cache.guilds[guild.id].members[data.target_id]
        end
        return data
    end
    data = parseInteractionData(client, data, guild)
    
    return data
end