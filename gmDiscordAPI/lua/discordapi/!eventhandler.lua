local EVENT_HANDLERS = {}

local function catch(error)
    local level = 3

    local traceback = "" 
    local spaces = "  "
    while true do
        local info = debug.getinfo( level, "Slnf" )
        if info == nil then break end
#ifndef DISCORD_DEBUG
        if info.name == "emitEvent" then break end
#endif
        local depth = level - 3
        if info.what == "C" 
        then
            traceback.= "${spaces}${depth+1}. ${info.name} - [C]:-1 \n"
        else
            if info.name == "DISCORDLIB_EVENT_FN"
            then
                info.name = "eventCallback"
            end
            traceback.= "${spaces}${depth+1}. ${(info.name or "unkown")} - ${info.short_src}:${info.linedefined}\n"
        end
        spaces.=" "
        level++
    end

    local path = error:match("addons/([^/]*)")
    ErrorNoHalt(path and "[${path}] " or "" ,error, "\n", traceback, "\n")
end

function discordlib.handleEvent(client, payload)
#ifdef DISCORD_DEBUG
    print(payload.t)
#endif
    local fn = EVENT_HANDLERS[payload.t]
    if fn
    then
        xpcall(fn,catch,client, payload.d)
    end
end

function EVENT_HANDLERS.READY(client, payload)
    if client.ready then return end
    client.ready = true
    client.user = discordlib.structures.user(client, payload.user)
    client.sessionID = payload.session_id
    client.emitEvent("Ready", payload)
end

////////// GUILD

function EVENT_HANDLERS.GUILD_CREATE(client, payload)
    client.cache.guilds[payload.id] = discordlib.structures.guild(client, payload)
    client.ws:write([[{"op": 8,"d": {"guild_id": "${payload.id}","query": "","limit": 0}}]])
    //client.emitEvent("GuildCreate", client.cache.guilds[payload.id])
end

function EVENT_HANDLERS.GUILD_MEMBERS_CHUNK(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    
    for k,v in ipairs(payload.members)
    do
        guild.members[v.user.id] = discordlib.structures.member(client, v, guild)
    end

    if (payload.chunk_index + 1) == payload.chunk_count
    then
        client.emitEvent("GuildCreate", client.cache.guilds[payload.guild_id])
    end
end

////////// MEMBER

function EVENT_HANDLERS.GUILD_MEMBER_ADD(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    guild.members[payload.user.id] = discordlib.structures.member(client, payload, guild)
    client.emitEvent("GuildMemberAdd",guild, guild.members[payload.user.id])
end

function EVENT_HANDLERS.GUILD_MEMBER_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    local oldMemberData = guild.members[payload.user.id]
    guild.members[payload.user.id] = discordlib.structures.member(client, payload, guild)
    client.emitEvent("GuildMemberUpdate", guild, guild.members[payload.user.id], oldMemberData)
end


function EVENT_HANDLERS.GUILD_MEMBER_REMOVE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    client.emitEvent("GuildMemberRemove", guild, guild.members[payload.user.id])
    guild.members[payload.user.id] = nil
end

////////// CHANNEL

function EVENT_HANDLERS.CHANNEL_CREATE(client, payload)
    -- dm channel
    if payload.type == 1
    then
        client.cache.private_channels[payload.id] = discordlib.structures.channel(client, payload)
        return
    end

    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end

        payload.guild_hashes = nil
        guild.channels[payload.id] = discordlib.structures.channel(client, payload, guild)
        client.emitEvent("ChannelCreate", guild.channels[payload.id])
    end

end

function EVENT_HANDLERS.CHANNEL_UPDATE(client, payload)
    -- dm channel
    if payload.type == 1
    then
        client.cache.private_channels[payload.id] = discordlib.structures.channel(client, payload)
        return
    end

    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end

        payload.guild_hashes = nil
        local oldChannelData = guild.channels[payload.id]
        guild.channels[payload.id] = discordlib.structures.channel(client, payload, guild)
        client.emitEvent("ChannelUpdate", guild.channels[payload.id], oldChannelData)
    end

end

function EVENT_HANDLERS.CHANNEL_DELETE(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        client.emitEvent("ChannelDelete", guild.channels[payload.id])
        guild.channels[payload.id] = nil
    end
end

////////// MESSAGE

function EVENT_HANDLERS.MESSAGE_CREATE(client, payload)
    client.emitEvent("MessageCreate", discordlib.structures.message(client, payload))
end

function EVENT_HANDLERS.MESSAGE_UPDATE(client, payload)
    client.emitEvent("MessageUpdate", discordlib.structures.message(client, payload))
end

function EVENT_HANDLERS.MESSAGE_DELETE(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        payload.guild = guild
        
        payload.channel = client.cache.channels[payload.channel_id]
    else
        payload.channel = client.cache.private_channels[payload.channel_id]
    end

    client.emitEvent("MessageDelete", payload)
end

////////// ROLE

function EVENT_HANDLERS.GUILD_ROLE_CREATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    guild.roles[payload.role.id] = discordlib.structures.role(client, payload.role)
    client.emitEvent("GuildRoleCreate",guild,  guild.roles[payload.role.id])
end

function EVENT_HANDLERS.GUILD_ROLE_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    local oldRoleData = guild.roles[payload.role.id]
    guild.roles[payload.role.id] = discordlib.structures.role(client, payload.role)
    client.emitEvent("GuildRoleUpdate",guild,  guild.roles[payload.role.id], oldRoleData)
end

function EVENT_HANDLERS.GUILD_ROLE_DELETE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    client.emitEvent("GuildRoleDelete",guild, guild.roles[payload.role_id])
    guild.roles[payload.role_id] = nil
end

////////// EMOJI

function EVENT_HANDLERS.GUILD_EMOJIS_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    
    local emojis = {}
    for k,emoji in ipairs(payload.emojis)
    do
        emojis[emoji.id] = discordlib.structures.emoji(client, emoji)
    end

    guild.emojis = emojis

    client.emitEvent("GuildEmojisUpdate", guild)
end

////////// REACTIONS

function EVENT_HANDLERS.MESSAGE_REACTION_ADD(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        client.emitEvent("MessageReactionAdd", payload.emoji, guild.members[payload.member.user.id], {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    else
        client.emitEvent("MessageReactionAdd", payload.emoji, client.cache.users[payload.user_id] or payload.user_id, {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    end
end

function EVENT_HANDLERS.MESSAGE_REACTION_REMOVE(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        client.emitEvent("MessageReactionRemove", payload.emoji, guild.members[payload.user_id], {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    else
        client.emitEvent("MessageReactionRemove", payload.emoji, client.cache.users[payload.user_id] or payload.user_id, {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    end
end


////////// Webhooks

function EVENT_HANDLERS.WEBHOOKS_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    client.emitEvent("WebhooksUpdate", guild, guild.channels[payload.channel_id])
end


////////// Interaction

function EVENT_HANDLERS.INTERACTION_CREATE(client, payload)
    if payload.member
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        payload.guild = guild

        payload.member = guild.members[payload.member.user.id]
        payload.user = payload.member.user
        payload.channel = guild.channels[payload.channel_id]
    end

    payload = discordlib.structures.interaction(client, payload)

    if payload.type == 3
    then
        payload.message = discordlib.structures.message(client, payload.message)
        client.emitEvent("ButtonInteraction", payload)
    elseif payload.type == 2
    then
        payload.data = discordlib.structures.slashcmdinteractiondata(client, payload.data, payload.guild)
        client.emitEvent("SlashCommandInteraction", payload)
    end
end

////////// Voice

function EVENT_HANDLERS.VOICE_STATE_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    payload.guild = guild

    payload.channel = client.cache.channels[payload.channel_id]

    client.emitEvent("VoiceStateUpdate", payload)
end


////////// Invite

function EVENT_HANDLERS.INVITE_CREATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    payload.guild = guild
    payload.channel = client.cache.channels[payload.channel_id]

    payload = discordlib.structures.invite(client, payload)

    client.emitEvent("InviteCreate", payload)
end

function EVENT_HANDLERS.INVITE_DELETE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    payload.guild = guild
    payload.channel = client.cache.channels[payload.channel_id]

    client.emitEvent("InviteDelete", payload)
end
