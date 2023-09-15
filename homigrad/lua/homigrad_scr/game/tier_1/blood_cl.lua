blood = 5000
adrenaline = 0

net.Receive("info_blood",function()
	blood = net.ReadFloat()
end)

net.Receive("info_adrenaline",function()
	adrenaline = net.ReadFloat()
end)

local math_Clamp = math.Clamp
local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 0,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local ScrH = ScrH

hook.Add("RenderScreenspaceEffects","ToyssssnssssEffect",function()
	if not LocalPlayer():Alive() then return end

	local fraction = math_Clamp(1 - ((blood - 3200) / ((5000 - 1400) - 2000)),0,1)
	DrawToyTown(fraction * 8,ScrH() * fraction * 1.5)

	DrawSharpen(5,adrenaline / 5)
	if fraction <= 0.7 then return end

	DrawMotionBlur(0.2,0.9,0.03)
	--tab["$pp_colour_contrast"] = math_Clamp(adrenaline,0.25,1)
	--DrawColorModify(tab)
end)

--[[concommand.Add("hg_organisminfo",function(ply)
	if not ply:IsAdmin() then return end

	print("blood : " .. blood)
	print("pain : " .. pain)
	print("painlosing : " .. painlosing)
	print("adrenaline : " .. adrenaline)
end)--]]

net.Receive("organism_info",function(len)
	local organs = net.ReadTable()
	local stringinfo = net.ReadString()

	PrintTable(organs)
	print(stringinfo)
end)

hook.Add("ScalePlayerDamage","no_effects",function(ent,dmginfo)
	return true
end)