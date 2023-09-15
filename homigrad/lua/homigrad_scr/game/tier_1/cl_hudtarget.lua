nodraw_players = nodraw_players or {}

hook.Add("Think","ShouldDrawNoclipe",function()
	local lply = LocalPlayer()

	for i,ply in pairs(player.GetAll()) do
		if ply == lply then continue end

		if ply:GetNWBool("scared") or (ply:Alive() and not ply:InVehicle() and ply:GetMoveType() == MOVETYPE_NOCLIP) then
			ply:SetNoDraw(true)
			for i,wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(true) end
			nodraw_players[ply] = true
		elseif nodraw_players[ply] then
			ply:SetNoDraw(false)
			for i,wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(false) end
			nodraw_players[ply] = nil
		end
	end
end)

hook.Add("DrawPhysgunBeam","gg",function(ply)
	if nodraw_players[ply] then return false end
end)

local red = Color(125,0,0)

local hg_customname = CreateClientConVar("hg_customname","",true)

cvars.AddChangeCallback("hg_customname",function(_,_,value)
    net.Start("custom name")
	net.WriteString(value)
	net.SendToServer()
end)

net.Start("custom name")
net.WriteString(hg_customname:GetString())
net.SendToServer()

hook.Add("HUDPaint","homigrad-huynyui",function()
	local lply = LocalPlayer()

	if not lply:Alive() then return end

	if IsValid(lply:GetActiveWeapon()) and lply:GetActiveWeapon():GetClass() != "weapon_hands" then
		local ply = lply
		local t = {}
		local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
		
		t.start = eye and eye.Pos or ply:EyePos()
		t.endpos = t.start + ply:GetAngles():Forward() * 60
		t.filter = lply
		local Tr = util.TraceLine(t)

		local Size = math.Clamp(1 - ((Tr.HitPos -lply:GetShootPos()):Length() / 60) ^ 2, .1, .3)

		local ent = Tr.Entity

		local col
		if ent:IsPlayer() then
			col = ent:GetPlayerColor():ToColor()
		elseif ent.GetPlayerColor ~= nil then
			col = ent.playerColor:ToColor()
		else
			return
		end

		if nodraw_players[Tr.Entity] then
			if math.random(1,25) == 25 then
				draw.DrawText(string.rep("?",math.random(1,4)) .. "you scared me" .. string.rep("?",math.random(1,4)),"DefaultFixedDropShadow",Tr.HitPos:ToScreen().x + math.random(-125,125),Tr.HitPos:ToScreen().y + math.random(-125,125), red, TEXT_ALIGN_CENTER )

				local head = Tr.Entity:GetBonePosition(Tr.Entity:LookupBone("ValveBiped.Bip01_Head1"))
				head = head:ToScreen()

				draw.DrawText(string.rep("c",math.random(1,12)) .. ":","DefaultFixedDropShadow",head.x + math.random(-25,25),head.y + math.random(-25,25), red, TEXT_ALIGN_CENTER )
			end

			return
		end

		col.a = 255 * Size * 2
		draw.DrawText(ent:GetNWString("Nickname",false) or (ent:IsPlayer() and ent:Name()) or "", "HomigradFontLarge", Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y + 30, col, TEXT_ALIGN_CENTER )
	end
end)