local math_Clamp = math.Clamp

hook.Add("Player Think","homigrad-hungry",function(ply,time)
	if not ply:Alive() or ply:HasGodMode() then return end

	if (ply.hungryNext or time) > time then return end
	ply.hungryNext = time + 1

	ply.hungryregen = math_Clamp((ply.hungryregen or 0) - 0.03,-0.01,50)
	ply.hungry = math_Clamp((ply.hungry or 0) + ply.hungryregen,0,100)

	if ply.hungry < 5 then
		ply:SetHealth(ply:Health() - 1)
		if ply:Health() <= 0 then
			ply.KillReason = "hungry"
			ply:Kill()
			return
		end
	end

	if ply.hungry < 80 then
		if ply.hungry < 40 and ply.hungryMessage ~= 1 then
			ply.hungryMessage = 1

			ply:ChatPrint("Ты голоден")
		end

		if ply.hungry > 40 and ply.hungry < 65 and ply.hungryMessage ~= 2 then
			ply.hungryMessage = 2

			ply:ChatPrint("Ты проголодался")
		end
	end

	ply:SetHealth(not ply.heartstop and (math.min(ply:Health() + math.max(math.ceil(ply.hungryregen),1),150)) or ply:Health())
end)

local furrypedik = {
	--["STEAM_0:1:508504180"] = true,
	--["STEAM_0:0:419643141"] = true,
	--["STEAM_0:1:130152051"] = true
}

local sounds = {
	"wowozela/samples/meow.wav",
	"wowozela/samples/woof.wav",
	"bullshitfuck/cute-uwu.mp3",
	"bullshitfuck/owo_oj0bqgj.mp3",
	"bullshitfuck/uwudaddy.mp3"
}

local function uwo(ply)
	furry = ply
	furry:EmitSound( table.Random(sounds), 75, 100, 5, CHAN_WEAPON )
	timer.Create("furry"..furry:EntIndex(),math.random(2,15),1,function()
		if furrypedik[furry:SteamID()] and furry:Alive() then
			uwo(furry)
		else
			timer.Destroy("furry"..furry:EntIndex())
		end
	end)
end

local FurryModels = {
	"models/player/smoky/Smoky.mdl",
	"models/player/smoky/Smokycl.mdl",
	"models/LeymiRBA/Gyokami/Gyokami.mdl",
	"models/eradium/protogens/cody.mdl"
}

hook.Add("PlayerSpawn","homigrad-hungry",function(ply)
	if PLYSPAWN_OVERRIDE then return end
	if furrypedik[ply:SteamID()] then
		--print("huy")
		uwo(ply)
		timer.Simple(1,function()
			ply:SetModel(table.Random(FurryModels))
		end)
	end
	ply.hungry = 89
	ply.hungryregen = 0
	ply.hungryNext = 0
	ply.hungryMessage = nil
end)

concommand.Add("hg_hungryinfo",function(ply)
	if not ply:IsAdmin() then return end

	ply:ChatPrint("hungry: " .. ply.hungry)
	ply:ChatPrint("hungryregen: " .. ply.hungryregen)
end)

COMMANDS.uwu = {function(ply,args)
	if !args[1] then
		uwo(ply)
		return
	end

	if args[1] == "*" then
		for k, v in pairs(player.GetAll()) do
			uwo(v)
			v:SetModel(table.Random(FurryModels))
		end
	end

	if player.GetBySteamID( args[1] ) then
		uwo(player.GetBySteamID( args[1] ))
		player.GetBySteamID( args[1] ):SetModel(table.Random(FurryModels))
	end
end}
