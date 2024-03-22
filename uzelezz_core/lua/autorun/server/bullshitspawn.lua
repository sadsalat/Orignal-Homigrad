KOROBKA_HUYNYI = {"models/props_junk/cardboard_box001a.mdl", "models/props_junk/cardboard_box001b.mdl", "models/props_junk/cardboard_box002a.mdl", "models/props_junk/cardboard_box002b.mdl", "models/props_junk/cardboard_box003a.mdl", "models/props_junk/cardboard_box003b.mdl", "models/props_junk/wood_crate001a.mdl", "models/props_junk/wood_crate001a_damaged.mdl", "models/props_junk/wood_crate001a_damagedmax.mdl", "models/props_junk/wood_crate002a.mdl", "models/props_c17/furnituredrawer001a.mdl", "models/props_c17/furnituredrawer003a.mdl", "models/props_c17/furnituredresser001a.mdl", "models/props_c17/woodbarrel001.mdl", "models/props_lab/dogobject_wood_crate001a_damagedmax.mdl", "models/items/item_item_crate.mdl", "models/props/de_inferno/claypot02.mdl", "models/props/de_inferno/claypot01.mdl",}
weaponscommon = {"bandage", "food_fishcan", "food_spongebob_home", "painkiller", "food_lays", "food_monster", "glock18", "p220", "item_ammo_pistol"}
weaponsuncommon = {"ent_jack_gmod_ezarmor_respirator", "medkit", "beretta", "hk_usp", "hk_usps", "item_ammo_357", "item_ammo_smg1"}
weaponsrare = {"ent_jack_gmod_ezarmor_ltorso", "ent_jack_gmod_ezarmor_lhead", "ent_jack_gmod_ezarmor_gasmask", "mp5", "ump", "m3super", "item_ammo_ar2", "item_box_buckshot"}
weaponsveryrare = {"ent_jack_gmod_ezarmor_mltorso", "ent_jack_gmod_ezarmor_mhead", "ar15", "akm", "item_ammo_ar2"}
weaponslegendary = {"ak74", "m4a1", "rpk", "mk18"}
spawnedweapon = {}
local newTbl = {}
for i, mdl in pairs(KOROBKA_HUYNYI) do
	newTbl[mdl] = true
end

local function ShouldSpawnLoot()
	local chance = math.random(100)
	if chance < 3 then
		return true, weaponsrare[math.random(#weaponsrare)]
	elseif chance < 20 then
		return true, weaponsuncommon[math.random(#weaponsuncommon)]
	elseif chance < 60 then
		return true, weaponscommon[math.random(#weaponscommon)]
	else
		return false
	end
end

hook.Add(
	"PropBreak",
	"homigrad",
	function(att, ent)
		if not newTbl[ent:GetModel()] then return end
		local posSpawn = ent:GetPos() + ent:OBBCenter()
		local huy
		local result, spawnEnt = ShouldSpawnLoot()
		if result == false then return end
		print(1)
		if type(spawnEnt) ~= "string" then
			local entName
			if entName then
				huy = ents.Create(entName)
				if not IsValid(huy) then return end
				huy:SetPos(posSpawn)
				huy:Spawn()
				huy.Spawned = true
				print(2)
			end
		else
			huy = ents.Create(spawnEnt)
			if not IsValid(huy) then return end
			huy:SetPos(posSpawn)
			huy:Spawn()
			huy.Spawned = true
			print(3)
		end
	end
)