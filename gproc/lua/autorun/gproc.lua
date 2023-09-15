local source, offset, len, errordata, path, file
local gproclib = {}
_G.gproclib = gproclib

local xpcall = xpcall

local function initVars(_source)
    source = _source
    offset = 1
    len = #source
    errordata = {}
end

local function char(_offset)
    if _offset == nil 
    then
        return source:sub(offset,offset)
    end
    _offset = offset + _offset
    return source:sub(_offset,_offset)
end

local function next()
    offset = offset +  1
end

local function seek(_offset)
    offset = offset + _offset
end

local function EOF()
    return offset > len
end

local function match(pattern)
    return source:match(pattern, offset)
end

local function skipWhitespace()
    local match = (match("^[ ]*") or "")
    local len = #match
    seek(len)
    return match
end

local function rewriteChars(pos, str)
    local slen = #str
    source = source:sub(0,pos - slen) .. str .. source:sub(pos+1)
    len = #source
end

local function writeChars(pos, str)
    source = source:sub(0,pos) .. str .. source:sub(pos + 1)
    len = #source
end

local function rewriteCharsWS(offset, wslen)
    local tSource = source
    for i=1,wslen
    do
        tSource = tSource:SetChar(offset - i, tSource:GetChar(offset - i) == "\n" and "\n" or " ")
    end
    source = tSource
    len = #source
end

function gproclib.addFormating(type ,callback)
    _G["gprocfmt" .. type] = callback
end

local function gprocError(err, _offset, charoffset)
    errordata  = {error = err, offset = _offset or offset, charoffset = charoffset or 0}
    error("gprocerror")
end

local parseString

local function parseStringInterpolation(type, s, contest)
    contest = contest .. (type == 0 and s or "]" .. s .. "]") .. " .. "
    local bracketsExcepted = 1
    local format = ""
    local formatOffset = 0
    local captureFormat = false
    local captureArgs = false
    local output = ""
    local args = ""
    while !EOF()
    do
        local c = char()
        if c == "}"
        then
            bracketsExcepted = bracketsExcepted - 1
            if bracketsExcepted == 0
            then
                next()
                break
            end
        end

        if c == "{"
        then
            bracketsExcepted = bracketsExcepted + 1
        end

        local type,s,scontest = parseString(true)
        if scontest
        then
            output = output .. (type == 0 and s or "[" .. s .. "[") ..  scontest .. (type == 0 and s or "]" .. s .. "]")
            continue
        end

        if captureFormat and !captureArgs
        then
            if c == ","
            then
                captureArgs = true
            else
                // "${a:a()} ${a:a''} ${a:a""} ${a:a{}} ${a:a[[]]}"
                if c == "(" or c == "'" or c == "\"" or c == "[" or c == "{"
                then
                    captureFormat = false 
                    format = ""
                else
                    format = format .. c
                end
            end
        end

        if captureArgs
        then
            args = args .. c
        end

        if c == ":"
        then
            captureFormat = true
            formatOffset = offset
        end

        output = output .. c
        next()
    end
    if captureFormat and _G["gprocfmt" .. format] == nil
    then
        gprocError("unkown format type '" .. format .. "'", nil, formatOffset - offset - 2)
    end
    contest = contest .. "(" .. (captureFormat and "gprocfmt" .. format .. "((" .. output:sub(0,#output - #format - #args - 1) .. ")" .. args .. ")" or output) .. ") .. " .. (type == 0 and s or "[" .. s .. "[")
    return contest
end

function parseString(interploatestring)
    local c = char()
    local contest = ""
    local linesCount = 0
    if c == "'" or c == "\""
    then
        next()
        local bscount = 0
        while !EOF()
        do
            if char() == "\\"
            then
                bscount = bscount + 1
            end

            if interploatestring and char() == "$" and char(1) == "{"
            then
                seek(2)
                contest = parseStringInterpolation(0,c,contest)
                continue
            end

            if c == char() and (bscount == 0 or bscount % 2 == 0)
            then
                next()
                break
            end

            if char() != "\\"
            then
                bscount = 0
            end

            contest = contest .. char()
            next()
        end

        return 0,c,contest,linesCount
    end

    if char() == "[" and (char(1) == "[" or char(1) == "=")
    then
        local bscount = 0
        seek(1)
        local sign = (match("=*") or "")
        seek(#sign + 1)

        local pattern = "^%]" .. sign .. "%]"
        while !EOF()
        do
            if char() == "\\"
            then
                bscount = bscount + 1
            else
                bscount = 0
            end

            if char() == "\n"
            then
                linesCount = linesCount + 1
            end

            if interploatestring and char() == "$" and char(1) == "{"
            then
                seek(2)
                contest = parseStringInterpolation(1,sign,contest)
                continue
            end

            if match(pattern)
            then
                break
            end

            contest = contest .. char()

            next()
        end

        seek(2 + #sign)
        
        return 1,sign,contest, linesCount
    end

    return nil,nil,nil,linesCount
end

local function parseFunction()
    seek(8)
    skipWhitespace()
    skipWhitespace()
    local functionname = ""
    while !EOF()
    do
        local c = char()
        if c == "(" then next() break end
        if c == " "
        then

        else
            functionname = functionname .. c
        end
        next()
    end
    functionname = functionname == "" and "anonymous" or functionname
    local captureArgName = true
    local captureDefaultValue = false

    local bracketsExcepted = 0
    local sqrbracketsExcepted = 0
    local endExcepted = 0

    local argName = ""
    local defaultValue = ""
    local argNum = 1
    local code = " "

    local function captureEnd()

        captureArgName = true

        if captureDefaultValue
        then
            if defaultValue:match("%s*!err$")
            then
                code = code .. "if " .. argName .. " == nil then error('bad argument #" .. argNum .." " .. string.format("%q", argName):sub(2,-3) .. " (nil)') end "
            elseif defaultValue:match("%s*!ret")
            then
                code = code .. "if " .. argName .. " == nil then return " .. (defaultValue:match("%s*!ret(.*)") or "") ..  " end "
            else
                code = code .. "if " .. argName .. " == nil then " .. argName .. "=" .. defaultValue .. " end "
            end

        end
        argName = ""
        defaultValue = ""
        captureDefaultValue = false
        argNum = argNum + 1
    end

    while !EOF()
    do
        local c = char()

        if c == "{" then sqrbracketsExcepted = sqrbracketsExcepted + 1 end
        if c == "}" then sqrbracketsExcepted = sqrbracketsExcepted - 1 end
        if c == "("
        then
            bracketsExcepted = bracketsExcepted + 1
        end

        if c == ")"
        then
            if bracketsExcepted == 0 and endExcepted == 0
            then
                if argName != ""
                then
                    captureEnd()
                    writeChars(offset, code)
                end
                break
            end
            bracketsExcepted = bracketsExcepted - 1
        end

        if c == "," and sqrbracketsExcepted == 0 and endExcepted == 0 and bracketsExcepted == 0
        then
            captureEnd()
            next()
            continue
        end

        if captureArgName and c == "="
        then
            rewriteCharsWS(offset + 1, 1)
            captureArgName = false
            captureDefaultValue = true
            next()
            continue
        end

        if captureArgName
        then
            argName = argName .. c
        end

        if captureDefaultValue
        then
            local type,s,contest = parseString()
            if contest
            then
                local str = (type == 0 and s or "[" .. s .. "[") ..  contest .. (type == 0 and s or "]" .. s .. "]")
                defaultValue = defaultValue .. str
                rewriteCharsWS(offset, #str)
                seek(-1)
            else
                if match("^function")
                then
                    endExcepted = endExcepted + 1
                end
        
                if match("^if")
                then
                    endExcepted = endExcepted + 1
                end
        
                if match("^do")
                then
                    endExcepted = endExcepted + 1
                end
        
                if match("^end")
                then
                    endExcepted = endExcepted - 1
                end

                defaultValue = defaultValue .. c
                rewriteCharsWS(offset + 1, 1)
            end
        end


        next()
    end

    return functionname
end

local defines = {}
local definesK = {}
local function setConstant(name,value)
    local len = #name
    local node = defines
    for i = 1, len
    do
        local char = name:sub(i,i)
        local t = node[char] or {}
        if len == i then t.value = value end
        node[char] = t
        node = t
    end
    definesK[name] = value
end

gproclib.setConstant = setConstant
function gproclib.getConstant(name)
    return definesK[name]
end

function gproclib.isDefined(name)

    return definesK[name] != nil
end

function gproclib.defineMacro(name, callback)
    local len = #name
    local node = defines
    for i = 1, len
    do
        local char = name:sub(i,i)
        local t = node[char] or {}
        if len == i then t.callback = callback end
        node[char] = t
        node = t
    end
    definesK[name] = callback
end


local parseDerective

local function parseDefine()
    local name = match("%s*([^%s]*)")
    if name == nil or #name == 0
    then
        gprocError("no name given in #define derective", offset, 0)
    end
    local len = #name
    seek(len + 1)
    rewriteCharsWS(offset, len)

    local value
    if char() == " "
    then
        next()
        value = match("[^\n]*")
        local len = #value
        seek(len)
        rewriteCharsWS(offset, len)
        seek(-1)
    else
        value = ""
    end

    setConstant(name, value)
end

local function parseUnDefine()
    skipWhitespace()
    local name = match("([^%s]*)")
    if name == nil or #name == 0
    then
        gprocError("no name given in #undef derective")
    end
    seek(#name)
    rewriteChars(offset - 1, (" "):rep(#name))
    setConstant(name, nil)
end

local IFNDEF = 0
local IFDEF  = 1
local IF = 2

local function parseIf(type)
    local sOffset = offset
    skipWhitespace()

    local const = match("[^%s]*")

    if const == nil or #const == 0
    then
        if type == IF
        then
            gprocError("no condition given in #" .. (type == IFDEF and "ifdef" or "ifndef") .. " derective", offset)
        else
            gprocError("no name given in #" .. (type == IFDEF and "ifdef" or "ifndef") .. " derective", offset)
        end
    end
    local isValid
    local removeChars = true
    if type == IFNDEF
    then
        isValid = definesK[const] == nil
    elseif type == IFDEF
    then
        isValid = definesK[const] != nil 
    elseif type == IF
    then
        local _source, _offset, _len, _errordata, _path, _file = source, offset, len, errordata, path, file
        const = match("[^\n]*")

        local preprocessedCode = gproclib.parse("return " .. const:gsub("DEFINED[%s]*([^%s]*)", function(const) return tostring(gproclib.isDefined(const)) end), path)

        source, offset, len, errordata, path, file = _source, _offset, _len, _errordata, _path, _file

        local obj = CompileString(preprocessedCode, "", false)

        if isstring(obj)
        then
            gprocError(obj:match(":1:(.*)") or obj, offset + #const + 4)
        end

        local err
        local function catch(_err)
            err = _err
        end
        isValid = select(2,xpcall(obj, catch))

        if err
        then
            gprocError(err:match(":1:(.*)") or err, offset + #const + 4)
        end
    end

    removeChars = !isValid
    local len = #const
    seek(len)
    rewriteCharsWS(offset, len)

    local closed = false
    local sOffset = offset

    while !EOF()
    do
        if char() == "#" and (char(-1) == "\n" or offset == 1)
        then
            next()
            skipWhitespace()
            local derectiveName = match("[^%s]*")
            seek(#derectiveName)
            rewriteCharsWS(offset, #derectiveName + 1)

            if isValid
            then
                if derectiveName != "endif" and derectiveName != "elseif"
                then
                    parseDerective(derectiveName)
                end
            end

            if derectiveName == "endif"
            then
                offset = sOffset
                return
            elseif derectiveName == "elseif"
            then
                if isValid
                then
                    removeChars = true
                else
                    removeChars = false
                end
            end
        end

        if removeChars
        then
            source = source:SetChar(offset, char() == "\n" and "\n" or " ")
        end

        next()
    end

    if EOF() and !closed
    then
        gprocError("'#endif' excepted ",sOffset, 0)
    end
    offset = sOffset
end

function parseDerective(derectiveName)
    if derectiveName == "define"
    then
        parseDefine()
    elseif derectiveName == "undef"
    then
        parseUnDefine()
    elseif derectiveName == "ifdef"
    then
        parseIf(IFDEF)
    elseif derectiveName == "ifndef"
    then    
        parseIf(IFNDEF)
    elseif derectiveName == "if"
    then
        parseIf(IF)
    else
        gprocError("unexcepted derective #" .. derectiveName)
    end
end

local function parsePrefixOpVar()
    local sOffset = offset 
    seek(-1)
    local var = ""
    while offset > 0
    do
        if !char():match("[%w%u ]") or char() == "\n"
        then
            break
        end

        var = char() .. var
        seek(-1)
    end
    offset = sOffset
    return var
end

local function parseMacroArgs(name)
    local endExcepted = 0
    local sqrBracketsExcepted = 0
    local bracketsExcepted = 0
    local args = {}
    local arg = ""
    next()
    local oOffset = offset - #name - 2
    while !EOF()
    do
        local type,s,contest = parseString()
        if contest
        then
            arg = arg .. (type == 0 and s or "[" .. s .. "[") ..  contest .. (type == 0 and s or "]" .. s .. "]")
        end

        if match("^function") then endExcepted = endExcepted + 1 end
        if match("^do") then endExcepted = endExcepted + 1 end
        if match("^if") then endExcepted = endExcepted + 1 end
        if match("^end") then endExcepted = endExcepted - 1 end

        local c = char()
        if c == "(" then bracketsExcepted = bracketsExcepted + 1 end
        if c == ")" 
        then 
            bracketsExcepted = bracketsExcepted - 1 
            if bracketsExcepted == -1
            then
                args[#args + 1] = arg
                arg = ""
                next()
                break
            end
        end        
        if c == "[" then sqrBracketsExcepted = sqrBracketsExcepted + 1 end
        if c == "]" then sqrBracketsExcepted = sqrBracketsExcepted - 1 end

        if c == "," and sqrBracketsExcepted == 0 and bracketsExcepted == 0 and endExcepted == 0
        then
            args[#args + 1] = arg
            arg = ""
            next()
            continue
        end

        arg = arg .. c
        next()
    end

    return args, oOffset
end

local function parseTier0()
    local newSource = ""
    while !EOF()
    do
        local type,s,contest = parseString(true)
        if contest
        then
            newSource = newSource .. (type == 0 and s or "[" .. s .. "[") ..  contest .. (type == 0 and s or "]" .. s .. "]")
        end

        if (char() == "/" and char(1) == "/") or (char() == "-" and char(1) == "-" and !char(-1):match("[%w%u]") and char(2) != "[")
        then
            while !EOF()
            do
                if char() == "\n" then break end
                newSource = newSource .. " "
                next()
            end
        end

        if char() == "/" and char(1) == "*"
        then
            while !EOF()
            do
                if char() == "*" and char(1) == "/" then newSource = newSource .. "  " seek(2) break end
                newSource = newSource .. (char() == "\n" and "\n" or " ")
                next()
            end
        end

        if char() == "-" and char(1) == "-" and char(2) == "["
        then
            seek(3)
            newSource = newSource .. "   "

            for i=1,#(match(".*%]" .. (match("=*") or "") .. "%]") or "")
            do
                newSource = newSource .. (char() == "\n" and "\n" or " ")
                next()
            end
        end

        newSource = newSource .. char()
        next()
    end

    initVars(newSource)
end

local function parseTier1()
    local node = defines
    local clen = 0
    local oNode
    local name = ""
    local lName = ""
    
    while !EOF()
    do
        parseString()

        if char() == "#" and (char(-1) == "\n" or offset == 1)
        then
            next()
            skipWhitespace()
            local derectiveName = match("[^%s]*")
            seek(#derectiveName)
            rewriteChars(offset - 1, (" "):rep(#derectiveName + 1))
            parseDerective(derectiveName)
        end

        local c = char()
        clen = clen + 1
        oNode = node
        node = node[c]
        name = name .. c
        if node == nil
        then
            if oNode and name != lName
            then
                if oNode.value
                then
                    source = source:sub(0,offset - clen).. tostring(oNode.value) .. source:sub(offset)  
                    len = #source
                    seek(-clen)
                elseif oNode.callback
                then
                    local name = name:sub(0,-2)
                    local args, oOffset = parseMacroArgs(name)
                    source = source:sub(0, oOffset) .. (definesK[name](args) or "") .. source:sub(offset)
                    len = #source
                    offset = oOffset
                end
            end
            node = defines
            clen = 0
            lName = name
            name = ""
        end

        if (char() == "+" and char(1) == "+") or (char() == "-" and char(1) == "-")
        then
            local op = char()
            local var = parsePrefixOpVar()
            source = source:SetChar(offset, " ")
            source = source:SetChar(offset + 1, "  ")
            seek(2)
            writeChars(offset, "=" .. var .. op .. "1")
        end

        if char(1) == "="
        then
            local op = char()
            if op == "-" or op == "+" or op == "/" or op == "*" or op == "." or op == "^" or op == "%"
            then
                local var = parsePrefixOpVar()
                source = source:SetChar(offset , "")
                seek(1)
                writeChars(offset - 1, var .. (op == "." and ".." or op))
            end
        end

        next()
    end

    local c = char(-1)
    clen = clen + 1
    oNode = node
    node = node[c]
    name = name .. c

    if node == nil
    then
        if oNode and oNode.value and name != lName
        then
            source = source:sub(0,offset - clen).. tostring(oNode.value) .. source:sub(offset)

            len = #source
            seek(-clen)
        end
        node = defines
        clen = 0
        lName = name
        name = ""
    end


    offset = 1
    len = #source

end

local function parseTier2()
    local defConstantFunctions = {}
    local endExcepted = 0

    while !EOF()
    do
        parseString()

        if match("^__FUNCTION__")
        then
			seek(-1)
			local t = defConstantFunctions[#defConstantFunctions]
            source = source:sub(0,offset) .. "\"" .. (t and t[1] or "main") .. "\"" .. source:sub(offset + 13)
			len = #source
        end

        if match("^function")
        then
            defConstantFunctions[#defConstantFunctions + 1] = {parseFunction(), endExcepted}
            endExcepted = endExcepted + 1
        end

        if match("^if")
        then
            endExcepted = endExcepted + 1
        end

        if match("^do")
        then
            endExcepted = endExcepted + 1
        end

        if match("^end")
        then
            endExcepted = endExcepted - 1
            local t = defConstantFunctions[#defConstantFunctions]
            if t and t[2] == endExcepted
            then
                defConstantFunctions[#defConstantFunctions] = nil
            end
        end
        next()
    end

    offset = 1
end

local function parseTier3()
    local line = 0
    while !EOF()
    do
        local _,_,_,linescount = parseString()
        line = line + linescount
        local char = char()
        
        if match("^__LINE__")
        then
            source = source:sub(0,offset - 1) .. line + 1 .. source:sub(offset + 8)
            len = #source
        end

        if match("^__FILE__")
        then
            source = source:sub(0,offset - 1) .. file .. source:sub(offset + 8)
            seek(#file - 1)
            len = #source
        end

        if char == "\n"
        then
            line = line + 1
        end

        next()
    end

    offset = 1
end

local function onError(err)

    if err:sub(#err - 9) == "gprocerror"
    then
        offset = 0
        local line = 0
        local nLineOffset = 0

        while offset < errordata.offset
        do
            local _,_,_,linescount = parseString()
            line = line + linescount

            if char() == "\n"
            then
                line = line + 1
                nLineOffset = offset
            end
            next()
        end

        errordata.error =  path .. " " .. line .. ":" .. (offset - nLineOffset) + errordata.charoffset .. ": error: " .. errordata.error

        return
    end

    errordata.error = "[gm-gproc] " .. err .. debug.traceback():sub(17)
end

local function parse(_source, _path)
    initVars(_source)
    path = _path
    file = ("%q"):format(_path)

    xpcall(parseTier0,onError)
    if !errordata.error then xpcall(parseTier1,onError) end
    if !errordata.error then xpcall(parseTier2,onError) end
    if !errordata.error then xpcall(parseTier3,onError) end

    if errordata.error
    then
        error(errordata.error, 0)
    end

    return source
end

gproclib.parse = parse

local files = {}
local fRead = _G.file.Read
local fTime = _G.file.Time
local CompileString = CompileString
local dGetInfo = debug.getinfo
local pairs = pairs

local function filewatcher()
    timer.Simple(0.1, filewatcher)
    for k,filedata in pairs(files)
    do        
        local time = fTime(k, "LUA")

        if filedata[1] != time
        then
            filedata[1] = time
            gproclib.include(k)
        end
    end
end
filewatcher()

function gproclib.include(file)
    if file == nil then file = "" end
    local source = fRead(file, "LUA")

    if !source or source == ""
    then
        local info = dGetInfo(2)
        return print("[gproc-include] Couldn't include file '" .. file .. "' (File not found) (" .. info.source .. " (line " .. info.currentline .. "))")
    end
    files[file] = {fTime(file, "LUA"), true}
    source = parse(source, file)

    local fn = CompileString(source, file, true)
    if fn then return fn() end
end