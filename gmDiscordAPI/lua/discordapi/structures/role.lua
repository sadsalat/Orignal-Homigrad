function discordlib.structures.role(client, role)
    role.color = discordlib.intToColor(role.color)

    client.cache.roles[role.id] = role
    return role
end