
local ply = FindMetaTable("Player")

teams = {}

teams[0] = {
	name = "Red",
	color = Vector(1.0,0,0),
	weapons = { "weapon_hands", "p220", "ak74", "bandage", "painkiller", "medkit", "weapon_jmodnade" },
	models = { "models/player/arctic.mdl","models/player/guerilla.mdl","models/player/leet.mdl","models/player/leet.mdl","models/player/phoenix.mdl" }
	}
	
teams[1] = {
	name = "Blue",
	color = Vector(0,0,1.0),
	weapons = { "weapon_hands", "beretta", "m4a1", "bandage", "painkiller", "medkit", "weapon_jmodnade" },
	models = { "models/player/gasmask.mdl","models/player/riot.mdl","models/player/swat.mdl","models/player/urban.mdl" }
	}

function ply:SetupTeam(n)
	--print(self,n)
	if (not teams[n]) then return end
	self:SetTeam(n)
	self:SetPlayerColor(teams[n].color)
	self:SetHealth(200)
	self:SetMaxHealth(100)
	self:SetWalkSpeed(150)
	self:SetRunSpeed(300)
	self:SetModel(teams[n].models[math.random(1,4)])
	self:GiveWeapons(n)
end

function ply:GiveWeapons(n)
	for k, weapon in pairs(teams[n].weapons) do
		self:Give(weapon):SetClip1(self:GetWeapon(weapon):GetMaxClip1())
		self:SetAmmo(90,self:GetWeapon(weapon):GetPrimaryAmmoType())
	end
end
