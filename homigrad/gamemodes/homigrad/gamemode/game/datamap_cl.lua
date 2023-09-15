SpawnPointsList = SpawnPointsList or {}

net.Receive("points",function()
	SpawnPointsList = net.ReadTable()

	--local func = TableRound().SpawnPointsListChange
	--if func then func(SpawnPointsList) end
end)

local hg_drawspawn = CreateClientConVar("hg_drawspawn","0",false,false)

hook.Add("HUDPaint","DrawSpawns",function()
	if not hg_drawspawn:GetBool() then return end

	local lply_pos = LocalPlayer():GetPos()

	for name,info in pairs(SpawnPointsList) do
		for i,point in pairs(info[3]) do
			local pos = (TypeID(point) == TYPE_TABLE and point[1] or point)
			if pos:Distance(lply_pos) > 1000 then continue end

			pos = pos:ToScreen()
			if not pos.visible then continue end

			draw.SimpleText(info[1],"DefaultFixedDropShadow",pos.x,pos.y,info[2],TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
end)

local red,blue = Color(255,0,0),Color(0,0,255)
local ebalgmod = Color(0,0,0)
hook.Add("PostDrawTranslucentRenderables","DrawSpawns",function()
	if not hg_drawspawn:GetBool() then return end

	render.SetColorMaterial()

	for name,info in pairs(SpawnPointsList) do
		local color = info[2]
		ebalgmod.r = color.r
		ebalgmod.g = color.g
		ebalgmod.b = color.b
		ebalgmod.a = 25

		for i,point in pairs(info[3]) do
			point = ReadPoint(point)

			local dis = point[3] or 6
			render.DrawWireframeSphere(point[1],dis,16,16,ebalgmod)
		end
	end
end)

concommand.Add("hg_spawninfo",function()
	for name,info in pairs(SpawnPointsList) do
		print(name .. ":")
		PrintTable(info)
	end
end)

