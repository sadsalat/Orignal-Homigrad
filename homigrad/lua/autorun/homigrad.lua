hg = hg or {}

include("homigrad_scr/loader.lua")
--if SERVER then include("homigrad_scr/run_serverside.lua") end
include("homigrad_scr/run.lua")

if SERVER then
    resource.AddWorkshop("3004847067")
end
