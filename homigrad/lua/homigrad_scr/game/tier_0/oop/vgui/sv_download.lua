--

local function add(path)
    local files,dirs = file.Find("addons/homigrad/materials/" .. path .. "*","GAME")

    for i,file in pairs(files) do
        if string.sub(file,#file - 2,#file) == "png" then
            resource.AddSingleFile("materials/" .. path .. file)
        end
    end

    for i,dir in pairs(dirs) do
        add(path .. dir .. "/")
    end
end

add("")