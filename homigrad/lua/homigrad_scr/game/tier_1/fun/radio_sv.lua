COMMANDS.radio = {function(ply,args)
	local radio = ents.Create("prop_physics")
	radio:SetModel("models/props/cs_office/radio.mdl")
	radio:SetPos(ply:GetEyeTrace().HitPos + Vector(0,0,10))
	radio:Spawn()
	radio:SetUseType(3)
	radio.radio = true
	radio.destructible = tobool(args[1]) or false
	radio.station = {"",false}
	radio.PlayersUsing = {}
end}

hook.Add("EntityTakeDamage","radio_nodmg",function(radio,dmginfo)
	if radio.radio and not radio.destructible then
		local att = dmginfo:GetAttacker()
		if IsValid(att) and att:IsPlayer() and not att:IsAdmin() and math.random(1,13) == 13 then att:Kick("13 не счастливое число.") end

		dmginfo:ScaleDamage(0)
	end
end)

util.AddNetworkString("radio_use")
util.AddNetworkString("play_snd")
util.AddNetworkString("radio_set")

local function send(ply,radio)
	if ply then
		net.Start("radio_use")
		net.WriteEntity(radio)
		net.WriteString(radio.station[1] or "")
		net.WriteBool(radio.station[2] or false)
		net.Send(ply)
	else
		for ply in pairs(radio.PlayersUsing) do
			if not IsValid(ply) or not ply:Alive() or not IsValid(radio) then
				radio.PlayersUsing[ply] = nil
				send(ply,false)
				continue
			end

			send(ply,radio)
		end
	end
end

hook.Add("PlayerUse","radio_use",function(ply,radio)
	if radio.radio and not radio.PlayersUsing[ply] then
		send(ply,radio)
		radio.PlayersUsing[ply] = true
		return false
	end
end)

net.Receive("radio_use",function(len,ply)
	local radio = net.ReadEntity()

	radio.PlayersUsing[ply] = nil
end)

net.Receive("radio_set",function(len,ply)
	local radio = net.ReadEntity()
	local link = net.ReadString()
	local play = net.ReadBool()

	radio.station = {link,play}

	if link~=nil and play~=nil then
		PlayRadio(radio,radio.station)
	end
end)

function PlayRadio(radio,station)
	for i, ply in pairs(player.GetAll()) do
		net.Start("play_snd")
		net.WriteString(station[1])
		net.WriteBool(station[2])
		net.WriteEntity(radio)
		net.Send(ply)
	end
end