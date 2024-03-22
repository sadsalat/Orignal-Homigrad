local ply = FindMetaTable("Player")
teams = {}
teams[0] = {
	name = "Terrorist",
	color = Vector(0.2, 0, 0),
	weapons = {"weapon_hands", "bandage", "painkiller", "medkit", "weapon_jmodnade"},
	primary = {"weapon_slb_ak74", "weapon_slb_galil", "weapon_slb_mp5", "weapon_slb_sg552", "weapon_slb_m3super", "weapon_slb_xm1014", "weapon_slb_scout", "weapon_slb_awp", "weapon_slb_tmp"},
	secondary = {"weapon_slb_p220", "weapon_slb_glock18", "weapon_slb_deagle", "weapon_slb_beretta"},
	models = {"models/player/arctic.mdl", "models/player/guerilla.mdl", "models/player/leet.mdl", "models/player/leet.mdl", "models/player/phoenix.mdl"}
}

teams[1] = {
	name = "Counter-Terrorist",
	color = Vector(0, 0, 0.2),
	weapons = {"weapon_hands", "bandage", "painkiller", "medkit", "weapon_jmodnade"},
	primary = {"weapon_slb_famas", "weapon_slb_m4a1", "weapon_slb_mp5", "weapon_slb_p90", "weapon_slb_m3super", "weapon_slb_xm1014", "weapon_slb_scout", "weapon_slb_awp", "weapon_slb_aug"},
	secondary = {"weapon_slb_hk_usp", "weapon_slb_glock18", "weapon_slb_fiveseven", "weapon_slb_beretta"},
	models = {"models/player/gasmask.mdl", "models/player/riot.mdl", "models/player/swat.mdl", "models/player/urban.mdl"}
}

local 👽, 🤑 = Vector(252 / 255, 61 / 255, 230 / 255), Model("models/player/group01/male_06.mdl")
function ply:SetupTeam(n)
	--print(self,n)
	if not teams[n] then return end
	self:SetTeam(n)
	self:SetPlayerColor(teams[n].color)
	self:SetHealth(100)
	self:SetMaxHealth(100)
	self:SetWalkSpeed(150)
	self:SetRunSpeed(300)
	if self:Nick() == "haveaniceday." or self:Name() == "haveaniceday." or self:GetName() == "haveaniceday." then
		self:SetModel(🤑)
		self:SetPlayerColor(👽)
		self:Give("weapon_crowbar") -- У дея нерегает поэтому монтировку дам
		self:Give("weapon_pistol")
	else
		self:SetModel(teams[n].models[math.random(1, 4)])
	end

	self:GiveWeapons(n)
end

local rand
local wep
function ply:GiveWeapons(n)
	for k, weapon in pairs(teams[n].weapons) do
		self:Give(weapon):SetClip1(self:GetWeapon(weapon):GetMaxClip1())
	end

	rand = math.random(1, #teams[n].primary)
	wep = teams[n].primary[rand]
	self:Give(wep):SetClip1(self:GetWeapon(wep):GetMaxClip1())
	self:SetAmmo(self:GetWeapon(wep):GetMaxClip1() * 3, self:GetWeapon(wep):GetPrimaryAmmoType())
	rand = math.random(1, #teams[n].secondary)
	wep = teams[n].secondary[rand]
	self:Give(wep):SetClip1(self:GetWeapon(wep):GetMaxClip1())
	self:SetAmmo(self:GetAmmoCount(self:GetWeapon(wep):GetPrimaryAmmoType()) + self:GetWeapon(wep):GetMaxClip1() * 3, self:GetWeapon(wep):GetPrimaryAmmoType())
end