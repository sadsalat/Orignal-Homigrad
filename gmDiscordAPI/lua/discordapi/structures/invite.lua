
function discordlib.structures.invite(client, invite)
    invite.guild = client.cache.guilds[invite.guild.id]
    invite.channel = invite.guild[invite.channel.id]

    if invite.inviter then invite.inviter = client.cache.users[invite.inviter.id] end

    function invite.delete(callback)
        client.deleteInvite(invite.code, callback)
    end

    return invite
end