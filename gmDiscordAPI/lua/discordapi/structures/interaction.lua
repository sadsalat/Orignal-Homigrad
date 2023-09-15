discordlib.response = {
    Pong                             = 1,
    ChannelMessageWithSource         = 4,
    DeferredChannelMessageWithSource = 5,
    DeferredUpdateMessage            = 6,
    UpdateMessage                    = 7,
}

function discordlib.structures.interaction(client, interaction)

    function interaction.response(type = !err, msg, callback)
        local postData = {}
		if isstring(msg) then msg = {content = tostring(msg)} end
		postData.data = msg 
		postData.type = type
		client.HTTPRequest("interactions/{interaction.id}/{interaction.token}/callback", "interactions/${interaction.id}/${interaction.token}/callback", "POST", discordlib.intermsgToMultipart(postData), callback and function(code, data, headers)
            callback(code ~= 204, data, headers)
        end, nil, true)
    end

    function interaction.editResponse(msg = !err, callback)
		if isstring(msg) then msg = {content = tostring(msg)} end
        client.HTTPRequest("webhooks/{client.user.id}/{interaction.token}/messages/@original","webhooks/${client.user.id}/${interaction.token}/messages/@original", "PATCH", discordlib.msgToMultipart(msg), callback and function(code, data, headers)
            callback(code ~= 200, data, headers)
        end, nil, true)
    end

    function interaction.deleteResponse()
        client.HTTPRequest("webhooks/{client.user.id}/{interaction.token}/messages/@original", "webhooks/" .. client.user.id .. "/" .. interaction.token .. "/messages/@original", "DELETE", {}, callback and function(code, data, headers)
            callback(code ~= 204, data, headers)
        end)
    end

    return interaction
end
