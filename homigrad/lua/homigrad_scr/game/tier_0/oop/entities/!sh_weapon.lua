local SWEP,CLASS = ents.Reg("weapon_base","lib_event")
if not SWEP then return end

util.tableLink(SWEP,weapons.Get("weapon_base"))

CLASS.NonRegisterGMOD = true

SWEP:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class.NonRegisterGMOD then return end

    weapons.Register(content,content.ClassName)
end)