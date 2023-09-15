oop = oop or {}--sasi
--эт лиш регистрация классов

oop.listClass = oop.listClass or {}
local listClass = oop.listClass

function oop.Inherit(class)
    local oldBase = class.oldBase
    if oldBase then
        class.oldBase = nil

        for i,base in pairs(oldBase) do
            base = listClass[base]
            base.baseChildrens[class.ClassName] = nil--shut the fuck up!
        end
    end

    local content = class[1]
    local base = class.base
    if not base then return end

    local copyContent = util.tableCopy(content)

    for i,base in pairs(base) do
        base = listClass[base]
        base.baseChildrens[class.ClassName] = class

        util.tableLink(content,base[1])
    end

    util.tableLink(content,copyContent)
end--veru simple.. maybe,я на таком чиле это делаю🤙

function oop.InheritChildren(base)
    local contentBase = base[1]

    for className,class in pairs(base.baseChildrens) do
        oop.Get(className)
    end
end

function oop.RegEx(className,base)
    if type(base) ~= "table" then base = {base} end--hihihah

    local class = listClass[className]
    if not class then
        class = {
            {}, --content
            {}, --non inherit content
            {},  --files includd
            baseChildrens = {}
        }

        class.ClassName = className
        listClass[className] = class
    end

    class.oldBase = class.base
    class.base = base

    local content = class[1]
    for k in pairs(content) do content[k] = nil end

    local nonInheritContent = class[2]
    for k in pairs(nonInheritContent) do nonInheritContent[k] = nil end

    content.ClassName = className

    oop.Inherit(class)

    return class
end

--

function oop.InsertFile(class,isFolder)
    local pathInsert = hg.GetPath(2)
    local listFiles = class[3]

    if isFolder then pathInsert = string.GetPathFromFilename(pathInsert) end

    for i,path in pairs(listFiles) do
        if path == pathInsert then return end
    end

    listFiles[#listFiles + 1] = pathInsert
end

oop.override = {}
local override = oop.override

function oop.Include(class,isFirst)
    local className = class.ClassName
    for i,path in pairs(class[3]) do
        if string.sub(path,#path - 3,#path) == ".lua" then
            include(path)
        else
            hg.includeDir(path)
        end

        if isFirst then return end
    end

    local func = class[1].Construct
    if func then func(class) end

    oop.InheritChildren(class)

    override[className] = nil
end

function oop.GetClassName(className)
    if not className then
        return string.gsub(string.GetFileFromFilename(hg.GetPath(2)),".lua","")
    else
        return className
    end
end

--

function oop.Reg(className,base,isFolder)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass end

    local class = oop.RegEx(className,base)
    oop.InsertFile(class,isFolder)
    override[className] = class
    oop.Include(class)
end

function oop.RegConnect(className,isFolder)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass end

    local class = listClass[className]
    oop.InsertFile(class,isFolder)
    oop.Include(class,true)
end

function oop.Get(className)
    className = oop.GetClassName(className)
    local overrideClass = override[className]
    if overrideClass then return overrideClass[1],overrideClass end

    oop.Include(listClass[className],true)
end

ents.listClass = listClass--HAHA
ents.RegEx = oop.RegEx
ents.Reg = oop.Reg
ents.RegConnect = oop.RegConnect
ents.Get = oop.Get