local ZERO_WIDTH_CHAR = "​"

function discordlib.messageEmbed(embed = {title = ZERO_WIDTH_CHAR, fields = {},files = {},thumbnail = {}})
    function embed.setTitle(title)
        embed.title = tostring(title)

        return embed
    end

    function embed.setDescription(description)
        embed.description = tostring(description)

        return embed
    end

    function embed.setURL(url)
        embed.url = url

        return embed
    end

    function embed.setTimestamp(time)
        embed.timestamp = discordlib.timestamp(time)

        return embed
    end

    function embed.setColor(color)
        embed.color = discordlib.colorToInt(color)

        return embed
    end

    function embed.addField(name, value, inline)
        embed.fields[#embed.fields + 1] = {
            name = tostring(name or ZERO_WIDTH_CHAR),
            value = tostring(value or ZERO_WIDTH_CHAR),
            inline = inline or false
        }

        return embed
    end

    function embed.setThumbnail(url)
        embed.thumbnail = {
            url = url
        }

        return embed
    end

    function embed.setImage(url)
        embed.image = {
            url = url
        }

        return embed
    end

    function embed.setAuthor(name, url, icon_url)
        embed.author = {
            name = tostring(name),
            url = url,
            icon_url = icon_url
        }

        return embed
    end

    function embed.setFooter(text, icon_url)
        embed.footer = {
            text = tostring(text),
            icon_url = icon_url
        }

        return embed
    end

    //embed.type = "embed"
    return embed
end