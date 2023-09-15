
include "wac/base.lua"

for _, file in pairs(file.Find("autorun/wac_*.lua", "LUA")) do
	AddCSLuaFile("autorun/"..file)
end
for _, file in pairs(file.Find("wac/*.lua", "LUA")) do
	AddCSLuaFile("wac/"..file)
end
