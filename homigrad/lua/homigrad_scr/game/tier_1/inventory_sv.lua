util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("ply_take_ammo")

local function send(ply,lootEnt,remove)
	if ply then
		net.Start("inventory")
		net.WriteEntity(not remove and lootEnt or nil)

		net.WriteTable(lootEnt.Info.Weapons)
		net.WriteTable(lootEnt.Info.Ammo)
		net.Send(ply)
	else
		for ply in pairs(lootEnt.UsersInventory) do
			if not IsValid(ply) or not ply:Alive() or remove then lootEnt.UsersInventory[ply] = nil continue end

			send(ply,lootEnt,remove)
		end
	end
end

hook.Add("PlayerSpawn","!!!huyassdd",function(lootEnt)
	if lootEnt.UsersInventory ~= nil then
		for plys,bool in pairs(lootEnt.UsersInventory) do
			lootEnt.UsersInventory[plys] = nil
			send(plys,lootEnt,true)
		end
	end
end)

hook.Add("Player Think","Looting",function(ply)
	local key = ply:KeyDown(IN_USE)

	if not ply.fake and ply:Alive() and ply:KeyDown(IN_ATTACK2) then
		if ply.okeloot ~= key and key then
			local tr = {}
			tr.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
			tr.endpos = tr.start + ply:EyeAngles():Forward() * 64
			tr.filter = ply
			local tracea = util.TraceLine(tr)
			local hitEnt = tracea.Entity

			if not IsValid(hitEnt) then return end
			if IsValid(RagdollOwner(hitEnt)) then hitEnt = RagdollOwner(hitEnt) end
			if IsValid(hitEnt) and hitEnt.IsJModArmor then hitEnt = hitEnt.Owner end
			if not IsValid(hitEnt) then return end
			if hitEnt:IsPlayer() and hitEnt:Alive() and not hitEnt.fake then return end
			if not hitEnt.Info then return end
			
			hitEnt.UsersInventory = hitEnt.UsersInventory or {}
			hitEnt.UsersInventory[ply] = true

			send(ply,hitEnt)
			hitEnt:CallOnRemove("fuckoff",function() send(nil,hitEnt,true) end)
		end
	end

	ply.okeloot = key
end)

local prekol = {
	weapon_physgun = true,
	gmod_tool = true
}

net.Receive("inventory",function(len,ply)
	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end

	lootEnt.UsersInventory[ply] = nil
	player.Event(ply,"inventory close",lootEnt)
end)

net.Receive("ply_take_item",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end

	local wep = net.ReadString()
	--local takeammo = net.ReadBool()

	local lootInfo = lootEnt.Info
	local wepInfo = lootInfo.Weapons[wep]
	
	if not wepInfo then return end

	if prekol[wep] and not ply:IsAdmin() then ply:Kick("xd))00") return end

	if ply:HasWeapon(wep) then
		if lootEnt:IsPlayer() and (lootEnt.curweapon == wep and not lootEnt.Otrub) then return end
		if wepInfo.Clip1!=nil and wepInfo.Clip1 > 0 then
			ply:GiveAmmo(wepInfo.Clip1,wepInfo.AmmoType)
			wepInfo.Clip1 = 0
		else
			ply:ChatPrint("У тебя уже есть это оружие.")
		end
	else
		if lootEnt:IsPlayer() and (lootEnt.curweapon == wep and not lootEnt.Otrub) then return end
		
		ply.slots = ply.slots or {}
		
		local realwep = weapons.Get(wep)
		
		if IsValid(lootEnt.wep) and lootEnt.curweapon == wep then
			DespawnWeapon(lootEnt)
			lootEnt.wep:Remove()
		end

		local actwep = ply:GetActiveWeapon()

		local wep1 = ply:Give(wep)
		if IsValid(wep1) and wep1:IsWeapon() then
			wep1:SetClip1(wepInfo.Clip1 or 0)
		end
		
		ply:SelectWeapon(actwep:GetClass())

		if lootEnt:IsPlayer() then lootEnt:StripWeapon(wep) end
		lootInfo.Weapons[wep] = nil
		table.RemoveByValue(lootInfo.Weapons2,wep)
	end

	send(nil,lootEnt)
end)

net.Receive("ply_take_ammo",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end
	local ammo = net.ReadFloat()
	local lootInfo = lootEnt.Info
	if not lootInfo.Ammo[ammo] then return end

	ply:GiveAmmo(lootInfo.Ammo[ammo],ammo)
	lootInfo.Ammo[ammo] = nil

	send(nil,lootEnt)
end)