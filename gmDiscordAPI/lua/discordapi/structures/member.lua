local band = bit.band


discordlib.perms = {
    CREATE_INSTANT_INVITE = 0x00000001,
    KICK_MEMBERS = 0x00000002,
    BAN_MEMBERS = 0x00000004,
    ADMINISTRATOR = 0x00000008,
    MANAGE_CHANNELS = 0x00000010,
    MANAGE_GUILD = 0x00000020,
    ADD_REACTIONS = 0x00000040,
    VIEW_AUDIT_LOG = 0x00000080,
    PRIORITY_SPEAKER = 0x00000100,
    STREAM = 0x00000200,
    VIEW_CHANNEL = 0x00000400,
    SEND_MESSAGES = 0x00000800,
    SEND_TTS_MESSAGES = 0x00001000,
    MANAGE_MESSAGES = 0x00002000,
    EMBED_LINKS = 0x00004000,
    ATTACH_FILES = 0x00008000,
    READ_MESSAGE_HISTORY = 0x00010000,
    MENTION_EVERYONE = 0x00020000,
    USE_EXTERNAL_EMOJIS = 0x00040000,
    VIEW_GUILD_INSIGHTS = 0x00080000,
    CONNECT = 0x00100000,
    SPEAK = 0x00200000,
    MUTE_MEMBERS = 0x00400000,
    DEAFEN_MEMBERS = 0x00800000,
    MOVE_MEMBERS = 0x01000000,
    USE_VAD = 0x02000000,
    CHANGE_NICKNAME = 0x04000000,
    MANAGE_NICKNAMES = 0x08000000,
    MANAGE_ROLES = 0x10000000,
    MANAGE_WEBHOOKS = 0x20000000,
    MANAGE_EMOJIS = 0x40000000,
    USE_SLASH_COMMANDS = 0x0080000000,
    REQUEST_TO_SPEAK =  0x0100000000,
    MANAGE_THREADS  = 0x0400000000,
    USE_PUBLIC_THREADS = 0x0800000000,
    USE_PRIVATE_THREADS = 0x1000000000
}

local function hasPermission(bits, permission)
    return (band(bits, discordlib.perms.ADMINISTRATOR) == discordlib.perms.ADMINISTRATOR) or (band(bits, permission) == permission)
end

function discordlib.structures.member(client, member, guild)
    member.user = discordlib.structures.user(client, member.user)
    local roles = member.roles
    member.roles = nil

    function member.getColor()
        local color = color_white
        local position = 0
        for k,v in ipairs(roles)
        do
            local role = client.cache.roles[v]

            if role
            then
                if role.position > position and role.color != color_white
                then
                    position = role.position
                    color = role.color
                end
            end
        end
        return color
    end

    function member.getRoles()
        local output = {}
        for k,v in ipairs(roles)
        do
            local role = client.cache.roles[v]
            if role
            then
                output[role.id] = role
            end
        end

        return output
    end

    function member.hasPermission(permission)
        for k, v in ipairs(roles)
        do
            local role = guild.roles[v]
            if not role
            then continue end
            if hasPermission(role.permissions, permission) then return true end
        end
        return false
    end

    function member.send(message = !err, callback)
        client.sendMessageDM(member.user.id, message, callback)
    end
    
    function member.setName(name = !err,callback)
        if member.user.id == client.user.id 
        then
            return client.modifyGuildNick(guild.id,name,callback)
        end
        client.modifyGuildMember(guild.id, member.user.id, {nick = name}, callback)
    end

    function member.mute(mute = !err,callback)
        client.modifyGuildMember(guild.id, member.user.id, {mute = mute}, callback)
    end    
    
    function member.moveToNewVoiceChannel(channelID = !err,callback)
        client.modifyGuildMember(guild.id, member.user.id, {channel_id = channelID}, callback)
    end

    function member.removeAllRoles(callback)
        client.modifyGuildMember(guild.id, member.user.id, {roles = {}}, callback)
    end

    function member.setRoles(roles = !err, callback)
        if !istable(roles) then error("bad argument roleID #1 (table excepted got ${type(roleID)})") end
        client.modifyGuildMember(guild.id, member.user.id, {roles = roles}, callback)
    end

    function member.removeRole(roleID = !err, callback)
        if !isstring(roleID) then error("bad argument roleID #1 (string excepted got ${type(roleID)})") end
        local newRoles = {}
        for k,v in pairs(roles)
        do
            if v != roleID then newRoles[#newRoles + 1] = v end
        end
        client.modifyGuildMember(guild.id, member.user.id, {roles = newRoles}, callback)
    end

    function member.addRole(roleID = !err, callback)
        if !isstring(roleID) then error("bad argument roleID #1 (string excepted got ${type(roleID)})") end
        local newRoles = {}
        for k,v in pairs(roles)
        do
            if v != roleID then newRoles[#newRoles + 1] = v end
        end
        newRoles[#newRoles + 1] = roleID
        client.modifyGuildMember(guild.id, member.user.id, {roles = newRoles}, callback)
    end

    function member.kick(callback)
        client.kickMember(guild.id, member.user.id, callback)
    end

    function member.ban(reason, deleteMessageDays, callback)
        client.banMember(guild.id, member.user.id, reason, DeleteMessageDays, callback)
    end

    client.cache.users[member.user.id] = member.user
    return member
end