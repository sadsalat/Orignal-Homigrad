PickTable = {}
PickLerp = {}
--[[hook.Add( "HUDWeaponPickedUp", "WeaponPickedUp", function( weapon )
	table.insert( PickTable, weapon:GetPrintName() )
	--PrintTable(PickTable)
	timer.Simple(5,function()
		table.remove(PickTable,1)
		table.remove(PickLerp,1)
	end)
end )

hook.Add( "HUDItemPickedUp", "ItemPickedUp", function( itemName )
	table.insert( PickTable, "#" .. itemName )
	--PrintTable(PickTable)
	timer.Simple(5,function()
		table.remove(PickTable,1)
		table.remove(PickLerp,1)
	end)
end )

hook.Add( "HUDAmmoPickedUp", "AmmoPickedUp", function( ammo, ammout )
	table.insert( PickTable, ammo.." - "..ammout )
	--PrintTable(PickTable)
	timer.Simple(5,function()
		table.remove(PickTable,1)
		table.remove(PickLerp,1)
	end)
end )

function GAMEMODE:HUDDrawPickupHistory()
	for i = 1, table.Count( PickTable ) do
		if PickTable[i] then
			PickLerp[i] = Lerp(5*FrameTime(),PickLerp[i] or 0,(i-1)*20)
			draw.DrawText( "+ "..PickTable[i], "HomigradFontBig", ScrW()-5, ScrH()/3+PickLerp[i], color_white, TEXT_ALIGN_RIGHT )
		end
	end
end]]--

local Vector = Vector
local vecZero,angZero = Vector(0,0,0),Angle(0,0,0)

local RifleOffset = Vector(-8,-4,-2)
local RifleAng = Angle(0,0,-20)

local PistolOffset = Vector(8,-9,-8)
local PistolAng = Angle(-80,0,0)

local Offset,Ang = Vector(0,0,0),Angle(0,0,0)

local function remove(wep,ent) ent:Remove() end

local GetAll = player.GetAll
local LocalPlayer = LocalPlayer
local GetViewEntity = GetViewEntity

local hg_vbw_draw = CreateClientConVar("hg_vbw_draw","1",true,false)
local hg_vbw_dis = CreateClientConVar("hg_vbw_dis","2000",true,false)

local femaleMdl = {}

for i = 1,6 do femaleMdl["models/player/group01/female_0" .. i .. ".mdl"] = true end
for i = 1,6 do femaleMdl["models/player/group03/female_0" .. i .. ".mdl"] = true end

--[[for count = 0,LocalPlayer():GetBoneCount() - 1 do
    print(LocalPlayer():GetBoneName(count))
end]]--

net.Receive("ebal_chellele",function(len)
    net.ReadEntity().curweapon = net.ReadString()
end)

local CurTime = CurTime
local wtf
hook.Add("PostDrawOpaqueRenderables","draw_weapons",function()--почему-то два раза вызывается, и это даже с RenderScene не связано..
    if not hg_vbw_draw:GetBool() then return end

    render.SetColorMaterial()

    local lply = LocalPlayer()
    local firstPerson = DRAWMODEL
    local gameVBWHide = TableRound().VBWHide

    local worldModel = VBWModel
    if not IsValid(worldModel) then
        worldModel = ClientsideModel("models/hunter/plates/plate.mdl",RENDER_GROUP_OPAQUE_ENTITY)
        worldModel:SetNoDraw(true)
        VBWModel = worldModel
    end

    local cameraPos = EyePos()
    local dis = hg_vbw_dis:GetInt()
    local tbl = GetAll()
    for i = 1,#tbl do
        
        local ply = tbl[i]
        if not ply:Alive() or lply == ply and not firstPerson then continue end
        local list = ply:GetWeapons()
        if #list == 0 then continue end
        
        local activeWep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass()

        local ent = ply:GetNWBool("fake") and ply:GetNWEntity("Ragdoll")
        activeWep = IsValid(ent) and ply.curweapon or activeWep
        ent = IsValid(ent) and ent or ply

        if cameraPos:Distance(ent:GetPos()) > dis then continue end

        local matrix = ent:LookupBone("ValveBiped.Bip01_Spine2")
        matrix = matrix and ent:GetBoneMatrix(matrix)
        if not matrix then continue end
        local spinePos,spineAng = matrix:GetTranslation(),matrix:GetAngles()

        matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Pelvis"))
        local pelvisPos,pelvisAng = matrix:GetTranslation(),matrix:GetAngles()
        
        if gameVBWHide then list = gameVBWHide(ply,list) or list end

        local mdl = ply:GetModel()
        --local isFamale = femaleMdl[mdl]

        local sUp,sRight,sForward = spineAng:Up(),spineAng:Right(),spineAng:Forward()
        local pUp,pRight,pForward = pelvisAng:Up(),pelvisAng:Right(),pelvisAng:Forward()

        for i,wep in pairs(list) do
            local active = activeWep ~= wep:GetClass() and wep.vbw

            wep.vbwActive = active
            if not active then continue end

            local localPos,localAng,pistol

            local func = wep.vbwFunc

            local clone

            if func then
                localPos,localAng,pistol = func(wep,ply,mdl)

                Offset:Set(pelvisPos)
                Ang:Set(pelvisAng)

                clone = Vector(localPos[1],localPos[2],localPos[3])
                clone:Rotate(Ang)

                Ang:RotateAroundAxis(pUp,localAng[1])
                Ang:RotateAroundAxis(pRight,localAng[2])
                Ang:RotateAroundAxis(pForward,localAng[3])
            else
                pistol = not wep.vbwRifle and (wep.vbwPistol or not wep.TwoHands)

                if pistol then
                    --[[if isFamale then
                        localPos = wep.vbwPosF or wep.vbwPos or PistolOffsetF
                        localAng = wep.vbwAngF or wep.vbwAng or PistolAngF
                    else]]--
                        localPos = wep.vbwPos or PistolOffset
                        localAng = wep.vbwAng or PistolAng
                    --end

                    Offset:Set(pelvisPos)
                    Ang:Set(pelvisAng)

                    clone = Vector(localPos[1],localPos[2],localPos[3])
                    clone:Rotate(Ang)

                    Ang:RotateAroundAxis(pUp,localAng[1])
                    Ang:RotateAroundAxis(pRight,localAng[2])
                    Ang:RotateAroundAxis(pForward,localAng[3])
                else
                    --[[if isFamale then
                        localPos = wep.vbwPosF or wep.vbwPos or RifleOffsetF
                        localAng = wep.vbwAngF or wep.vbwAng or RifleAngF
                    else]]--
                        localPos = wep.vbwPos or RifleOffset
                        localAng = wep.vbwAng or RifleAng
                    --end

                    Offset:Set(spinePos)
                    Ang:Set(spineAng)

                    clone = Vector(localPos[1],localPos[2],localPos[3])
                    clone:Rotate(Ang)

                    Ang:RotateAroundAxis(sUp,localAng[1])
                    Ang:RotateAroundAxis(sRight,localAng[2])
                    Ang:RotateAroundAxis(sForward,localAng[3])
                end
            end

            Offset:Add(clone)
           
            worldModel:SetModel(wep.WorldModel)--"models/hunter/plates/plate05.mdl"
            worldModel:SetModelScale(wep.vbwModelScale or 1)
            worldModel:SetPos(Offset)
            worldModel:SetAngles(Ang)
            worldModel:DrawModel()
        end
    end
end)

--

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)
local cameraPos,cameraAng
local angRotate = Angle(0,0,0)
local _cameraPos = Vector(20,20,10)
local _cameraAng = Angle(10,0,0)

local cam_Start3D = cam.Start3D
local render_SuppressEngineLighting = render.SuppressEngineLighting

local render_SetLightingOrigin = render.SetLightingOrigin
local render_ResetModelLighting = render.ResetModelLighting
local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend

local render_SetModelLighting = render.SetModelLighting

local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend
local render_SuppressEngineLighting = render.SuppressEngineLighting

local cam_IgnoreZ = cam.IgnoreZ

local cam_End3D = cam.End3D

local ClientsideModel = ClientsideModel
local RealTime = RealTime

WeaponByModel = {}
WeaponByModel.weapon_physgun = {
    WorldModel = "models/weapons/w_physics.mdl",
    PrintName = "Physgun"
}

local function PrintWeaponInfo(self,x,y,alpha)
	if self.DrawWeaponInfoBox == false then return end

	if self.InfoMarkup == nil then
		local str
		local title_color = "<color=230,230,230,255>"
		local text_color = "<color=150,150,150,255>"

		str = "<font=HudSelectionText>"
		if self.Author != "" then str = str .. title_color .. "Автор:</color>\t"..text_color..self.Author.."</color>\n" end
		--if ( self.Contact != "" ) then str = str .. title_color .. "Contact:</color>\t"..text_color..self.Contact.."</color>\n\n" end
		--if ( self.Purpose != "" ) then str = str .. title_color .. "Purpose:</color>\n"..text_color..self.Purpose.."</color>\n\n" end
		if self.Instructions != "" then str = str .. title_color .. "Инструкция:</color>\t"..text_color..self.Instructions.."</color>\n" end
		str = str .. "</font>"

		self.InfoMarkup = markup.Parse(str,250)
	end

	--surface.DrawTexturedRect(x,y - 64 - 5,128,64)
	draw.RoundedBox(0,x,y,260,self.InfoMarkup:GetHeight() + 2,Color(60,60,60,alpha))

	self.InfoMarkup:Draw(x + 5,y,nil,nil,alpha)
end

DrawWeaponSelectionEX = function(self,x,y,wide,tall,alpha)
    local cameraPos = self.dwsPos or _cameraPos
    local mdl = self.WorldModel

    if mdl then
        local DrawModel = G_DrawModel

        local lply = LocalPlayer()

        if not IsValid(DrawModel) then
            G_DrawModel = ClientsideModel(mdl,RENDER_GROUP_OPAQUE_ENTITY)
            DrawModel = G_DrawModel
            DrawModel:SetNoDraw(true)
        else
            DrawModel:SetModel(mdl)

            cam_Start3D(cameraPos,(-cameraPos):Angle() - (self.cameraAng or _cameraAng),45,x,y,wide,tall)
                --cam_IgnoreZ(true)
                render_SuppressEngineLighting(true)

                render_SetLightingOrigin(vecZero)
                render_ResetModelLighting(50 / 255,50 / 255,50 / 255)
                render_SetColorModulation(1,1,1)
                render_SetBlend(255)

                render_SetModelLighting(4,1,1,1)

                angRotate:Set(angZero)
                angRotate[2] = RealTime() * 30 % 360
                angRotate:Add(self.dwsItemAng or angZero)

                local dir = Vector(0,0,0)
                dir:Set(self.dwsItemPos or vecZero)
                dir:Rotate(angRotate)

                DrawModel:SetRenderAngles(angRotate)
                DrawModel:SetRenderOrigin(dir)
                DrawModel:DrawModel()

                render_SetColorModulation(1,1,1)
                render_SetBlend(1)
                render_SuppressEngineLighting(false)
                --cam_IgnoreZ(false)
            cam_End3D()
        end
    end

	if self.PrintWeaponInfo then PrintWeaponInfo(self,x + wide,y + tall,alpha) end
end

local white = Color(255,255,255)
DrawWeaponSelection = function(self,x,y,w,h,alpha) DrawWeaponSelectionEX(self,x,y,w,h + 35,alpha) end
OverridePaintIcon = function(self,x,y,w,h,obj) DrawWeaponSelectionEX(obj,x + 5,y + 5,w - 10,h - 30) end