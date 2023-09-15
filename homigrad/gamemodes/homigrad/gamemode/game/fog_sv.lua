file.CreateDir("homigrad/fogs/")

local function getName() return "homigrad/fogs/" .. game.GetMap() .. ".txt" end

function ReadFogSetting()
    return util.JSONToTable(file.Read(getName(),"DATA") or "") or {}
end

COMMANDS.fog = {function(ply,args)
    if not args[1] or args[1] == "" then
        file.Delete(getName())

        SetupFogSetting()
    else
        local dis = tonumber(args[1])
        local color

        if args[2] then color = Color(tonumber(args[2]),tonumber(args[3]),tonumber(args[4])) end

        file.Write(getName(),util.TableToJSON({dis,color}))
    end

    SetupFogSetting()
end}

function SetupFogSetting()
    local tbl = ReadFogSetting()

    SetGlobalVar("Fog Dis",tbl[1] or false)

    local color = tbl[2]
    if color then
        SetGlobalVar("Fog Color",Vector(color.r,color.g,color.b))
    else
        SetGlobalVar("Fog Color",false)
    end
end

SetupFogSetting()