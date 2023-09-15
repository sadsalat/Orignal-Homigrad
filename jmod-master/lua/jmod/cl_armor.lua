function JMod.CopyArmorTableToPlayer(ply)
	ply.JMod_ArmorTableCopy = table.FullCopy(JMod.ArmorTable)
	local plyMdl = ply:GetModel()

	if JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets and JMod.LuaConfig.ArmorOffsets[plyMdl] then
		table.Merge(ply.JMod_ArmorTableCopy,JMod.LuaConfig.ArmorOffsets[plyMdl])
	end
end

local CurTime = CurTime
local table_GetKeys = table.GetKeys

local ClientsideModel = ClientsideModel
local render_SetColorModulation = render.SetColorModulation
local render_GetColorModulation = render.GetColorModulation

local models_female = {
	["models/player/group01/female_01.mdl"] = true,
	["models/player/group01/female_02.mdl"] = true,
	["models/player/group01/female_03.mdl"] = true,
	["models/player/group01/female_04.mdl"] = true,
	["models/player/group01/female_05.mdl"] = true,
	["models/player/group01/female_06.mdl"] = true,

	["models/player/group03/female_01.mdl"] = true,
	["models/player/group03/female_02.mdl"] = true,
	["models/player/group03/female_03.mdl"] = true,
	["models/player/group03/female_04.mdl"] = true,
	["models/player/group03/female_05.mdl"] = true,
	["models/player/group03/police_fem.mdl"] = true
}

for i = 1,6 do
	models_female["models/monolithservers/mpd/female_0"..i..".mdl"] = true
end

for i = 1,6 do
	models_female["models/monolithservers/mpd/female_0"..i.."_2.mdl"] = true
end

function JMod.ArmorPlayerModelDraw(ply)
	local EZarmor = ply.EZarmor
	if not EZarmor then return end

	local EZarmorModels = ply.EZarmorModels
	if not EZarmorModels then
		EZarmorModels = {}
		ply.EZarmorModels = EZarmorModels
	end

	local Time = CurTime()

	if not ply.JMod_ArmorTableCopy or (ply.NextEZarmorTableCopy or 0) < Time then
		JMod.CopyArmorTableToPlayer(ply)
		ply.NextEZarmorTableCopy = Time + 30
	end

	local JMod_ArmorTableCopy = ply.JMod_ArmorTableCopy

	local plyboneedit = {}

	local isClient = ply == LocalPlayer() and GetViewEntity() == ply

	for id,armorData in pairs(EZarmor.items) do
		local ArmorInfo = JMod_ArmorTableCopy[armorData.name]

		if isClient and (ArmorInfo.slots.mouthnose or ArmorInfo.slots.eyes or ArmorInfo.slots.head) then continue end

		if armorData.tgl and ArmorInfo.tgl then
			ArmorInfo = table.Merge(table.FullCopy(ArmorInfo),ArmorInfo.tgl)

			for k,v in pairs(ArmorInfo.tgl) do
				if type(v) == "table" then
					if #table_GetKeys(v) == 0 then
						ArmorInfo[k] = {}
					end
				end
			end
		end

		if IsValid(EZarmorModels[id]) then
			local Mdl = EZarmorModels[id]
			local MdlName = string.lower(Mdl:GetModel())

			if MdlName == ArmorInfo.mdl and ArmorInfo.bon then
				local Index = ply:LookupBone(ArmorInfo.bon)
				
				local addposY = (models_female[ply:GetModel()] and ArmorInfo.bon == "ValveBiped.Bip01_Spine2") and -3 or 0

				if Index then
					local matrix = ply:GetBoneMatrix(Index)
					if not matrix then continue end--lol
					local Pos,Ang = matrix:GetTranslation(),matrix:GetAngles()

					if Pos and Ang then
						local Right,Forward,Up = Ang:Right(), Ang:Forward(), Ang:Up()
						Pos = Pos + Right * ArmorInfo.pos.x + Forward * (ArmorInfo.pos.y + addposY) + Up * ArmorInfo.pos.z

						Ang:RotateAroundAxis(Right,ArmorInfo.ang.p)
						Ang:RotateAroundAxis(Up,ArmorInfo.ang.y)
						Ang:RotateAroundAxis(Forward,ArmorInfo.ang.r)

						Mdl:SetRenderOrigin(Pos)
						Mdl:SetRenderAngles(Ang)

						local Mat = Matrix()
						Mat:Scale(ArmorInfo.siz)
						Mdl:EnableMatrix("RenderMultiply",Mat)

						local OldR,OldG,OldB = render_GetColorModulation()
						local Colr = armorData.col

						render_SetColorModulation(Colr.r / 255,Colr.g / 255,Colr.b / 255)

						if ArmorInfo.bdg then
							for k, v in pairs(ArmorInfo.bdg) do
								Mdl:SetBodygroup(k,v)
							end
						end

						if ArmorInfo.skin then Mdl:SetSkin(ArmorInfo.skin) end

						Mdl:DrawModel()

						render_SetColorModulation(OldR,OldG,OldB)
					end

					if ArmorInfo.bonsiz then
						ply.EZarmorboneedited = true

						plyboneedit[Index] = ArmorInfo.bonsiz
					end
				end
			else
				EZarmorModels[id]:Remove()
				EZarmorModels[id] = nil
			end
		else
			local Mdl = ClientsideModel(ArmorInfo.mdl)
			Mdl:SetModel(ArmorInfo.mdl) -- Garrry!
			Mdl:SetPos(ply:GetPos())
			Mdl:SetMaterial(ArmorInfo.mat or "")
			Mdl:SetParent(ply)
			Mdl:SetNoDraw(true)

			Mdl.JModCSModel = true -- doesn't seem to be working though
			EZarmorModels[id] = Mdl
		end
	end

	if ply.EZarmorboneedited then
		local edited = false

		for k = 1, ply:GetBoneCount() do
			if ply:GetManipulateBoneScale(k) ~= (plyboneedit[k] or Vector(1, 1, 1)) then
				ply:ManipulateBoneScale(k, plyboneedit[k] or Vector(1, 1, 1))
			end

			if ply:GetManipulateBoneScale(k) ~= Vector(1, 1, 1) then
				edited = true
			end
		end

		if not edited then
			print("not edited")

			ply.EZarmorboneedited = false
		end
	end--lol
end

hook.Add("PostPlayerDraw","JMOD_ArmorPlayerDraw",function(ply)
	JMod.ArmorPlayerModelDraw(ply)
end)

net.Receive("JMod_EZarmorSync", function()
	local ply = net.ReadEntity()

	if ply.EZarmorModels then
		for k, v in pairs(ply.EZarmorModels) do
			v:Remove()
			v = nil
		end
	end

	ply.EZarmor = net.ReadTable()
end)

concommand.Add("jmod_debug_countclientsidemodels", function()
	print("Entity count : ")
	local entite = {}
	local i = 0

	for k, v in pairs(ents.FindByClass("*C_BaseFlex")) do
		if v:GetModel() == nil then continue end

		if entite[v:GetModel()] == nil then
			entite[v:GetModel()] = 0
		end

		entite[v:GetModel()] = entite[v:GetModel()] + 1
		i = i + 1
	end

	print(i)
	print("-")
	print("- CLIENTSIDE STUFF START :")
	print("-")

	for k, v in pairs(entite) do
		print(v .. " : " .. k)
	end

	print("-")
	print("- CLIENTSIDE STUFF END ...")
	print("-")
end, nil, "Poluxtobee's CS model debug")
