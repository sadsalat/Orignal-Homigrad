AddCSLuaFile()

GM = GM or {}

local function AddFile(File, dir)
    local fileSide = string.lower(string.Left(File, 3))
    
    if SERVER and fileSide == "sv_" then
        include(dir..File)
    elseif fileSide == "sh_" then
        if SERVER then 
            AddCSLuaFile(dir..File)
        end
        include(dir..File)
    elseif fileSide == "cl_" then
        if SERVER then
            AddCSLuaFile(dir..File)
        else
            include(dir..File)
        end
    else
        if SERVER then 
            AddCSLuaFile(dir..File)
        end
        include(dir..File)
    end
end

local function IncludeDir(dir)
    dir = dir .. "/"
    local files, directories = file.Find(dir.."*", "LUA")

    if files then
        for k, v in ipairs(files) do
            if string.EndsWith(v, ".lua") then
                AddFile(v, dir)
            end
        end
    end

    if directories then
        for k, v in ipairs(directories) do
            IncludeDir(dir..v)
        end
    end
end

function GM.Run()
    local time = SysTime()
    print("Loading gamemode HG.")

    GM.loaded = false

    IncludeDir("homigrad/gamemode/core")

    GM.loaded = true

    print("Gamemode HG started, "..tostring(math.Round(SysTime() - time,5)).." seconds needed")
end

GM.Run()