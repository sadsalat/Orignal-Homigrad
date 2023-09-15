if gproclib == nil then return error("DiscordAPI: Missing dependencies https://github.com/devonium/gproc") end
local function require(module, link)
    local succ, err = pcall(_G.require, module)
    if succ then return end

    if (file.Find("bin/*" .. module .. "*", "LUA"))[1]
    then
        error("DiscordAPI: Missing dependencies " .. link .. "\n| You are probably missing some dependencies to run this module", 4)
    else
        error("DiscordAPI: Missing dependencies " .. link, 4)
    end
end

require("chttp", "https://github.com/timschumi/gmod-chttp")
require("gwsockets", "https://github.com/FredyH/GWSockets")

discordlib = {structures = {}}
gproclib.setConstant("DISCORD_DEBUG", file.Exists("dsdebug.txt", "DATA") or nil)

for k,file in ipairs(file.Find("discordapi/*.lua", "LUA"))
do
    gproclib.include("discordapi/" .. file)
end







