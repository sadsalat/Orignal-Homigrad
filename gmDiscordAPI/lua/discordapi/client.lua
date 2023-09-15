for k,file in ipairs(file.Find("discordapi/structures/*.lua", "LUA"))
do
    gproclib.include("discordapi/structures/" .. file)
end
for k,file in ipairs(file.Find("discordapi/constructors/*.lua", "LUA"))
do
    gproclib.include("discordapi/constructors/" .. file)
end

local max_table_size = 9007199254740991 -- 2^53-1
local function queue()
    local metatable = {}

    metatable.push = function(self, value)
        if value == nil then return end
        if self.count >= max_table_size then error("queue overflow") end

        self.last = (self.last + 1) % max_table_size
        self.count = self.count + 1
        self[self.last] = value
    end

    metatable.pop = function(self)
        if self.count == 0 then return end

        self.first = (self.first + 1) % max_table_size
        self.count = self.count - 1

        local out = self[self.first]
        self[self.first] = nil

        return out
    end

    return setmetatable({
        first = 0,
        last = 0,
        count = 0,
    }, {__index = metatable})
end

local pairs = pairs
local ipairs = ipairs
local JSONToTable = util.JSONToTable
local _TableToJSON = util.TableToJSON
local _r = function(int) return int end
local function TableToJSON(table = !ret "[]")
    return _TableToJSON(table)
end

function discordlib.msgToMultipart(msg)
    local file = msg.file
    msg.file = nil

    local postdata = "--boundary\nContent-Disposition: form-data; name=\"payload_json\"\nContent-Type: application/json\n\n" .. TableToJSON(msg) .. "\n"
    if file
    then
        postdata.= "--boundary\nContent-Disposition: form-data; name=\"file\"; filename=\"${file[1]}\"\nContent-Type: ${file[3]}\n\n" .. file[2] .. "\n"
    end

    postdata.="--boundary--"
    return postdata
end

function discordlib.intermsgToMultipart(msg)
    local file
	if msg.data
	then
		file = msg.data.file
		msg.data.file = nil
	end

    local postdata = "--boundary\nContent-Disposition: form-data; name=\"payload_json\"\nContent-Type: application/json\n\n" .. TableToJSON(msg) .. "\n"
    if file
    then
        postdata.= "--boundary\nContent-Disposition: form-data; name=\"file\"; filename=\"${file[1]}\"\nContent-Type: ${file[3]}\n\n" .. file[2] .. "\n"
    end

    postdata.="--boundary--"
    return postdata
end

local function emojid(emoji)
    local str = string.match(emoji, "<?a?(:.*:[0-9]*)>?")
    if str == nil
    then
        local str = ""
        for i = 1, #emoji
        do
            str = str .. string.format("%%%x", emoji:byte(i, i))
        end
        emoji = str
    else
        emoji = str or emoji
    end
    return emoji
end

local handleEvent = discordlib.handleEvent
function discordlib.client(token = !err)
    local client = {}

    client.ws = GWSockets.createWebSocket("wss://gateway.discord.gg/?v=9&encoding=json")

    client.cache = {users = {}, guilds = {}, roles = {}, private_channels = {}, channels = {}}
    client.user = {presence = discordlib.presence()}
    client.events = {}

    client.sequence = 1
    client.sessionID = nil
    client.uid = util.CRC(token)
    client.autoreconnect = true

    function client.on(eventname, id, fn)
        client.events[eventname] = client.events[eventname] or {}
        client.events[eventname][id] = fn
    end

    function client.emitEvent(eventname, ...)
        if not client.events[eventname] then return end

        for k, DISCORDLIB_EVENT_FN in pairs(client.events[eventname]) do
            DISCORDLIB_EVENT_FN(...)
        end
    end

    function client.login()
        if client and client.ws:isConnected() then return end
        client.disconect()
        client.ws:open()
    end

    function client.destroy()
        client.autoreconnect = false
        client.disconect()
    end

    function client.disconect()
        if client.uid
        then
            timer.Remove("discord" .. client.uid .. "heartbeat")
            hook.Remove("Think", "discord" .. client.uid .. "ratelimiter")
        end
        if client and client.ws:isConnected() then
            client.ws:clearQueue()
            client.ws:closeNow()
        end
    end

    function client.ws:onDisconnected()
        client.emitEvent("close")

        if client.autoreconnect
        then
            client.login()
        end
    end

    function client.ws:onError(errMessage)
        client.emitEvent("error", errMessage)
        error(errMessage)
    end

    function client.ws:onMessage(json)
        local payload = JSONToTable(json)

        if payload.s
        then
            client.sequence = payload.s
        end

        if payload.op == 0
        then
            handleEvent(client, payload)
        elseif payload.op == 10
        then
            -- Identifying
            if client.sessionID == nil then
                client.ws:write([[{"op":2,"d":{"token":"${token}","presence":]] .. string.Replace([[{"op":3}]] , "\"null\"", "null") .. [[,"properties":{"$os":"${jit.os}","$browser":"gmod-dapi","$device":"gmod-dapi"}}}]])
            else
                client.ws:write([[{"op":6,"d":{"token":"${token}","session_id":"${client.sessionID}","seq":${client.sequence}}}]])
            end

            timer.Create("discord" .. client.uid .. "heartbeat", payload.d.heartbeat_interval / 1000, 0, function()
                if client.ws:isConnected() then return end
                if client.ACKReceived == false then
                    client.reconnect()
                end

                client.ACKReceived = false
                client.ws:write([[{"op":1,"d":]] .. client.sequence .. [[}]])
            end)

            hook.Add("Think", "discord" .. client.uid .. "ratelimiter", function()
                for k,ratelimiter in pairs(client.ratelimiter) do
                    local requests = ratelimiter.requests

                    if ratelimiter.reset < CurTime() then
                        ratelimiter.remaining = ratelimiter.limit
                        ratelimiter.reset = CurTime() + 999999999999
                    end

                    if ratelimiter.remaining == 0 then return end

                    for i = 1, math.min(ratelimiter.remaining, requests.count) do
                        CHTTP(requests:pop())
                        ratelimiter.remaining = ratelimiter.remaining - 1
                    end

                end
            end)
        elseif payload.op == 9 then
            -- Invalid Session
            client.disconect()

            -- session may be resumable
            if payload.d == true
            then
                return timer.Simple(2, client.disconect)
            end

            client.sessionID = nil
            return client.disconect()
        elseif payload.op == 11
        then
            client.ACKReceived = true
        end
    end

    client.ratelimiter = {
    }

    function client.setPresence(presence = !err)
        if presence.game and presence.game.type
        then
            client.ws:write(string.Replace([[{"op":3,"d":]] .. TableToJSON(presence):gsub("\"type\":" .. presence.game.type .. ".0", "\"type\":" .. presence.game.type) .. [[}]] , "\"null\"", "null"))
        else
            client.ws:write(string.Replace([[{"op":3,"d":]] .. TableToJSON(presence) .. [[}]] , "\"null\"", "null"))
        end
        client.user.presence = presence
    end

    local ratelimiter = client.ratelimiter
    local buckets = {}
    local temp = {}

    client.__buckets = buckets
    client.__temp = temp

    function client.HTTPRequest(route, endpoint, method, postdata, callback, rate_limiter_id, multipart)
        local request = {
            method = method,
            url = "https://discordapp.com/api/v9/" .. endpoint,
            headers = {
                ["Authorization"] = "Bot " .. token,
                ["Content-Type"] = multipart and "multipart/form-data; boundary=\"boundary\"" or "application/json",
            },
            type = multipart and "multipart/form-data; boundary=\"boundary\"" or "application/json",
            body = multipart and postdata or TableToJSON(postdata),
            success = function(code, json, headers)
                local CRC = util.CRC(route)
                local bucket =  headers["x-ratelimit-bucket"] or CRC

                if buckets[route] == nil
                then
                    ratelimiter[bucket] = temp[route]
                    temp[route] = nil
                end
                buckets[route] = bucket

                local ratelimiter = ratelimiter[bucket]

                -- Some routes doesn't have the ratelimiter
                if bucket == CRC
                then
                    ratelimiter.limit = 1000
                    ratelimiter.limit = 1000
                    ratelimiter.reset = 0.1
                else
                    if ratelimiter.limit == 0
                    then
                        ratelimiter.limit = tonumber(headers["x-ratelimit-limit"])
                        ratelimiter.remaining = tonumber(headers["x-ratelimit-remaining"])
                    end
                    ratelimiter.reset = CurTime() + tonumber(headers["x-ratelimit-reset-after"])
                end

                if callback then callback(code, JSONToTable(json), headers) end
            end,
            failed = error
        }
        local ratelimiter = ratelimiter[buckets[route]]

        if ratelimiter
        then
            ratelimiter.requests:push(request)
        else
            local tempRatelimiter = temp[route]
            if tempRatelimiter == nil
            then
                tempRatelimiter =
                {
                    limit = 0,
                    remaining = 0,
                    reset = CurTime() + 999999999999,
                    requests = queue()
                }

                temp[route] = tempRatelimiter

                return CHTTP(request)
            end
            tempRatelimiter.requests:push(request)
        end
    end

    function client.sendMessage(channelID, msg, callback)
        if isstring(msg) then msg = {content = tostring(msg)} end

        client.HTTPRequest("channels/{channelID}/messages","channels/${channelID}/messages", "POST", discordlib.msgToMultipart(msg), callback and function(code,data,headers)
            local error = code != 200

            if !error
            then
                local channel = client.cache.channels[data.channel_id]
                data.guild_id = channel and channel.guild_id
                data = discordlib.structures.message(client, data)
            end

            callback(error, data, headers)
        end, 1, true)
    end

    function client.createReaction(channelID = !err, messageID = !err, emoji = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}/reactions/{emoji}/@me", "/channels/${channelID}/messages/${messageID}/reactions/${emoji}/@me", "PUT", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.deleteOwnReaction(channelID = !err, messageID = !err, emoji = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}/reactions/{emoji}/@me", "/channels/${channelID}/messages/${messageID}/reactions/${emoji}/@me", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.deleteUserReaction(channelID = !err, messageID = !err, emoji = !err, userID = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}/reactions/{emoji}/{userID}", "/channels/${channelID}/messages/${messageID}/reactions/${emoji}/${userID}", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.deleteAllReactions(channelID = !err, messageID = !err, callback)
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}/reactions", "/channels/${channelID}/messages/${messageID}/reactions", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, false)
    end

    function client.deleteAllReactionsForEmoji(channelID = !err, messageID = !err, emoji = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}/reactions/{emoji}", "/channels/${channelID}/messages/${messageID}/reactions/${emoji}", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.sendMessageDM(userID, msg, callback)
        if client.cache.private_channels[userID] != nil
        then
            return client.cache.private_channels[userID].send(msg,callback)
        end

        client.HTTPRequest("/users/@me/channels", "/users/@me/channels","POST", {recipient_id = userID}, function(code, data, headers)
            local error = code != 200
            if not error
            then
                data = discordlib.structures.channel(client, data)
                client.cache.private_channels[userID] = data
                data.send(msg, callback)
                return
            end
            if callback then callback(error, data, headers) end
        end)
    end

    function client.editMessage(channelID, messageID, msg, callback)
        if istable(msg) then msg.embeds = nil else msg = {content = tostring(msg)} end
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}", "/channels/${channelID}/messages/${messageID}", "PATCH", msg, callback and function(code,data,headers)
            local error = code != 200

            if !error
            then
                local channel = client.cache.channels[data.channel_id]
                data.guild_id = channel and channel.guild_id
                data = discordlib.structures.message(client, data)
            end

            callback(error, data, headers)
        end, 1)
    end

    function client.deleteMessage(channelID, messageID, callback)
        client.HTTPRequest("/channels/{channelID}/messages/{messageID}", "/channels/${channelID}/messages/${messageID}", "DELETE", {}, callback and function(code,data,headers)
            local error = code != 204

            callback(error, {}, headers)
        end, 1)
    end

    function client.createWebhook(channelID, name, avatar, callback)
        client.HTTPRequest("channels/{channelID}/webhooks", "channels/${channelID}/webhooks", "POST", {
            name = name,
            avatar = avatar
        }, callback and function(code, data, headers)
            local error = code != 200

            if not error
            then
                data = discordlib.structures.webhook(client, data)
            end

            callback(error, data, headers)
        end, false)
    end

    function client.getChannelWebhooks(channelID, callback)
        client.HTTPRequest("channels/{channelID}/webhooks", "channels/${channelID}/webhooks", "GET", {}, callback and function(code, data, headers)
            local error = code != 200

            if not error then
                for k, v in ipairs(data) do
                    data[k] = discordlib.structures.webhook(client, v)
                end
            end

            callback(error, data, headers)
        end, false)
    end

    function client.deleteWebhook(webhookID, callback)
        client.HTTPRequest("webhooks/{webhookID}", "webhooks/${webhookID}", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, false)
    end

    function client.executeWebhook(webhookID, webhookToken, table, callback)
        client.HTTPRequest("webhooks/{webhookID}/{webhookToken}", "webhooks/${webhookID}/${webhookToken}", "POST", discordlib.msgToMultipart(table), callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, 3, true)
    end

    function client.modifyChannel(channelID, table, callback)
        client.HTTPRequest("/channels/{channelID}", "/channels/${channelID}", "PATCH", table, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, 2)
    end

    function client.triggerTypingIndicator(channelID, callback)
        client.HTTPRequest("/channels/{channel.id}/typing", "/channels/${channelID}/typing", "POST", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, 2)
    end

    function client.getGuildInvites(guildID, callback)
        client.HTTPRequest("/guilds/{guildID}/invites", "/guilds/${guildID}/invites", "GET", {}, callback and function(code, data, headers)
            local error = code != 200
            if !error
            then
                for k,v in ipairs(data)
                do
                    data.k = discordlib.structures.invite(client, v)
                end
            end
            callback(error, data, headers)
        end, 2)
    end

    function client.createChannelInvite(channelID, data, callback)
        client.HTTPRequest("/channels/{channelID}/invites", "/channels/${channelID}/invites", "POST", data, callback and function(code, data, headers)
            local error = code != 200
            if !error
            then
                data = discordlib.structures.invite(client, data)
            end
            callback(error, data, headers)
        end, 2)
    end

    function client.getChannelInvites(channelID, callback)
        client.HTTPRequest("/channels/{channelID}/invites", "/channels/${channelID}/invites", "GET", {}, callback and function(code, data, headers)
            local error = code != 200
            if !error
            then
                for k,v in ipairs(data)
                do
                    data.k = discordlib.structures.invite(client, v)
                end
            end
            callback(error, data, headers)
        end, 2)
    end

    function client.deleteInvite(inviteCode, callback)
        client.HTTPRequest("/invites/{inviteCode}", "/invites/${inviteCode}", "DELETE", {}, callback and function(code, data, headers)
            local error = code != 200
            if !error
            then
                data = discordlib.structures.invite(client, data)
            end
            callback(error, data, headers)
        end, 2)
    end

    function client.modifyGuildChannel(guildID, table, callback)
        client.HTTPRequest("/guilds/{guildID}/channels", "/guilds/${guildID}/channels", "PATCH", table, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, 2)
    end

    function client.modifyGuildMember(guildID, memberID, table, callback)
        client.HTTPRequest("/guilds/{guildID}/members/{memberID}", "/guilds/${guildID}/members/${memberID}", "PATCH", table, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, 4)
    end

    function client.modifyGuildNick(guildID,nick,callback)
        return client.HTTPRequest("/guilds/{guildID}/members/@me/nick", "/guilds/${guildID}/members/@me/nick", "PATCH", {nick = name}, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, 5)
    end

    function client.kickMember(guildID, memberID, callback)
        client.HTTPRequest("/guilds/{guildID}/members/{memberID}", "/guilds/${guildID}/members/${memberID}", "DELETE", nil, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, 5)
    end

    function client.banMember(guildID, memberID, reason, deleteMessageDays, callback)
        client.HTTPRequest("/guilds/{guildID}/bans/{memberID}", "/guilds/${guildID}/bans/${memberID}", "PUT", {reason = reason, delete_message_days = deleteMessageDays}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.unbanMember(guildID, memberID, callback)
        client.HTTPRequest("/guilds/{guildID}/bans/{memberID}", "/guilds/${guildID}/bans/${memberID}", "DELETE", nil, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.getGuildBans(guildID, callback)
        client.HTTPRequest("/guilds/{guildID}/bans", "/guilds/${guildID}/bans", "GET", nil, callback and function(code, data, headers)
            local error = code != 200
            if !error
            then
                for k,v in ipairs(data)
                do
                    data[k].user = discordlib.structures.user(client, v.user)
                end
            end
            callback(error, data, headers)
        end, false)
    end


    function client.getGuildCommands(guildID, callback)
        client.HTTPRequest("/applications/{client.user.id}/guilds/{guildID}/commands", "/applications/${client.user.id}/guilds/${guildID}/commands", "GET", {}, callback and function(code, data, headers)
            callback(code ~= 200, data, headers)
        end, false)
    end

    function client.createGuildCommand(command, guildID, callback)
        client.HTTPRequest("/applications/{client.user.id}/guilds/{guildID}/commands", "/applications/${client.user.id}/guilds/${guildID}/commands", "POST", command, callback and function(code, data, headers)
            callback(code ~= 200, data, headers)
        end, 6)
    end

    function client.editGuildCommand(command, guildID, commandID, callback)
        client.HTTPRequest("/applications/{client.user.id}/guilds/{guildID}/commands/{commandID}", "/applications/${client.user.id}/guilds/${guildID}/commands/${commandID}", "PATCH", command, callback and function(code, data, headers)
            local error = code ~= 200

            if not error then
                data.guild_id = guildID
            end

            callback(error, data, headers)
        end, 7)
    end

    function client.deleteGuildCommand(guildID, commandID, callback)
        client.HTTPRequest("/applications/{client.user.id}/guilds/{guildID}/commands/{commandID}", "/applications/${client.user.id}/guilds/${guildID}/commands/${commandID}", "DELETE", {}, callback and function(code, data, headers)
            callback(code ~= 204, data, headers)
        end, false)
    end

    return client
end