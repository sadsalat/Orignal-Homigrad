local util_JSONToTable = util.JSONToTable
local util_TableToJSON = util.TableToJSON

local file_Read = file.Read
local file_Write = file.Write

file.CreateDir("homigrad")
file.CreateDir("homigrad/sdata")

function SData_Get(name)
    return file_Read("homigrad/sdata/" .. name .. ".txt","DATA") or ""
end

function SData_Set(name,value)
    return file_Write("homigrad/sdata/" .. name .. ".txt",value or "")
end


