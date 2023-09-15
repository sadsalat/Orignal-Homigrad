local ENT,CLASS = ents.Reg("base_entity","lib_event")
if not ENT then return end

util.tableLink(ENT,scripted_ents.Get("base_entity"))

CLASS.NonRegisterGMOD = true

ENT:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class.NonRegisterGMOD then return end

    scripted_ents.Register(content,content.ClassName)
end)