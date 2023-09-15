function discordlib.structures.webhook(client, webhook)
    webhook.user = client.cache.users[webhook.user.id]

    function webhook.execute(name,avatarURL, message = !err, callback)
        if isstring(message) then message = {content = tostring(message)} end

        message.username = name
        message.avatar_url = avatarURL
        client.executeWebhook(webhook.id,webhook.token, message, callback)
    end

    return webhook
end