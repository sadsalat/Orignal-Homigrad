discordlib.optiontype =
{
    SUB_COMMAND = 1,
    SUB_COMMAND_GROUP = 2,
    STRING = 3,
    INTEGER = 4,
    BOOLEAN = 5,
    USER = 6,
    CHANNEL = 7,
    ROLE = 8,
    MENTIONABLE	= 9,
    NUMBER	= 10,
}

function discordlib.slashcmd()
    local slashcmd = {
        description = "​",
        options = {}
    }

    local hasSubcommand = false
    local hasOptions = false

    function slashcmd.setName(name = !err)
        slashcmd.name = name
        return slashcmd
    end

    function slashcmd.setDescription(description = !err)
        slashcmd.description = description

        return slashcmd
    end

    function slashcmd.addOption(option = !err)
        if hasSubcommand then error("You can't use the ${__FUNCTION__} if you already have a subcommand") end
        slashcmd.options[#slashcmd.options + 1] = option
        hasOptions = true
        return slashcmd
    end

    function slashcmd.addSubCommand(command = !err)
        if hasOptions then error("You can't use the ${__FUNCTION__} if you already have a options") end
        command.type = discordlib.optiontype.SUB_COMMAND
        slashcmd.options[#slashcmd.options + 1] = command
        hasSubcommand = true
        return slashcmd
    end

    function slashcmd.addSubGroup(subgroup = !err)
        slashcmd.options[#slashcmd.options + 1] = subgroup
        return slashcmd
    end

    return slashcmd
end

function discordlib.subcommand()
    local subcommand = discordlib.slashcmd()
    subcommand.type = discordlib.optiontype.SUB_COMMAND
    subcommand.addSubCommand = nil
    subcommand.addSubGroup = nil

    return subcommand
end

function discordlib.subgroup()
    local subgroup = discordlib.slashcmd()
    subgroup.type = discordlib.optiontype.SUB_COMMAND_GROUP
    subgroup.addSubGroup = nil
    subgroup.addOption = nil
    subgroup.addCommand = subgroup.addSubCommand
    subgroup.addSubCommand = nil

    return subgroup
end

function discordlib.option()
    local option = {
        description = "​",
        type = discordlib.optiontype.STRING
    }

    function option.setType(type = !err)
        option.type = type
        return option
    end

    function option.setName(name = !err)
        option.name = name
        return option
    end

    function option.setDescription(description = !err)
        option.description = description
        return option
    end

    function option.setRequired(required = !err)
        option.required = required
        return option
    end

    function option.addChoice(name = !err, value = !err)
        option.choices = option.choices or {}

        option.choices[#option.choices + 1] = {
            name = name,
            value = value
        }

        return option
    end

    return option
end