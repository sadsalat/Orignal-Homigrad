local CLASS = player.RegClass("police")

CLASS.weapons = {"weapon_radio","med_band_big","medkit","painkiller","weapon_handcuffs","weapon_taser","weapon_hg_flashbang","weapon_police_bat"}
CLASS.secondary_weapon = {"weapon_glock"}
CLASS.models = {}

for i = 1,6 do
	CLASS.models[#CLASS.models + 1] = "models/monolithservers/mpd/female_0"..i..".mdl"
end

for i = 1,6 do
	CLASS.models[#CLASS.models + 1] = "models/monolithservers/mpd/female_0"..i.."_2.mdl"
end

for i = 1,6 do
	CLASS.models[#CLASS.models + 1] = "models/monolithservers/mpd/male_0"..i..".mdl"
end

for i = 1,6 do
	CLASS.models[#CLASS.models + 1] = "models/monolithservers/mpd/male_0"..i.."_2.mdl"
end

CLASS.color = Color(75,75,75)

function CLASS:Off()
	if CLIENT then
		CLASS.CloseMenu()

		return
	end

	/*local guilt = (self.contrGuilt or 0)

	if guilt >= 40 then
		self.Guilt = self.Guilt + guilt

		GuiltCheck(ply)
	end*/

	self.isContr = nil
end

local function EmitSound(self,name,level,pitch,volume)
	if self.Sound then self.Sound:Stop() self.Sound = nil end

	timer.Simple(0.25,function()
		if not IsValid(self) then return end

		self.Sound = CreateSound(self,Sound(name))
		self.Sound:ChangePitch(pitch or math.random(95,105),0)
		self.Sound:ChangeVolume(volume or 1,0)
		self.Sound:SetSoundLevel(level or 75)
		self.Sound:Play()
	end)
end

function CLASS:On()
	if CLIENT then return end

	local color = CLASS.color

	self:SetModel(CLASS.models[math.random(#CLASS.models)])
	self:SetPlayerColor(color:ToVector())

	self:Give("weapon_hands")

	for i,weapon in pairs(CLASS.weapons or empty) do self:Give(weapon) end

	tdm.GiveSwep(self,CLASS.secondary_weapon)

	JMod.EZ_Equip_Armor(self,"Light-Vest",color)

	self.isContr = true

	local r = math.random(1,3)
	if r == 1 then
		--EmitSound(self,"radio/moveout.wav")
	elseif r == 2 then
		--EmitSound(self,"radio/com_go.wav")
	elseif r == 3 then
		--EmitSound(self,"radio/go.wav")
	end
end

function CLASS:EndRound(winner)
	if roundActiveName == "homicide" and winner == 2 then
		--EmitSound(self,"radio/ctwin.wav")
	end
end

local function tracerSee(self,endpos,dis)
	local trace = {start = self:EyePos()}
	trace.endpos = endpos
	trace.filter = self
	
	if util.TraceLine(trace).HitPos:Distance(endpos) <= dis then
		return true
	end
end

local function getList(self)
	local list = {}

	for i,ply in RandomPairs(player.GetAll()) do
		if ply == self or not ply.isContr then continue end
		
		local pos = ply:EyePos()
		local deathPos = self:GetPos()

		if pos:Distance(deathPos) > 1000 then continue end

		local trace = {start = pos}
		trace.endpos = deathPos
		trace.filter = ply
		
		if util.TraceLine(trace).HitPos:Distance(deathPos) <= 512 then
			list[#list + 1] = ply
		end
	end

	return list
end

local soundDeaths = {
	"bot/pain10.wav",
	"bot/pain2.wav",
	"bot/pain4.wav",
	"bot/pain5.wav",
	"bot/pain8.wav",
	"bot/pain9.wav"
}

function CLASS:PlayerDeath()
	if not self.Otrub then 
		local name = table.Random(soundDeaths)
		--EmitSound(self,name)
	end

	self:SetPlayerClass()
end

function CLASS:PlayerKill(ply)
	if ply == self then return end

	--EmitSound(self,"bot/hes_down.wav")
end

local function CanMessage(self,name)
	return (self["msg" .. name] or 0) < CurTime()
end

local function Message(self,name,time)
	self["msg" .. name] = CurTime() + time
end

local active,oldValue

function CLASS:HomigradDamage(hitGroup,dmgInfo,rag)
	if self.Otrub then return end

	if (self.delaysoundpain or 0) > CurTime() then
		self.delaysoundpain = CurTime() + math.Rand(0.1,0.25)

		self:EmitSound("nplayer/damage" .. math.random(1,3) .. ".wav")
	end

	if CanMessage(self,"help") then
		if math.random(1,2) == 1 then
			EmitSound(self,"snd_jack_hmcd_cop1.wav")
		else
			EmitSound(self,"snd_jack_hmcd_cop2.wav")
		end
	end

	Message(self,"help",7)
end

function CLASS:GuiltLogic(ply,dmgInfo)
	if ply.isContr then return 20 end
end

local function live(self,hpOld,hpNew)
	return IsValid(self) and self.isContr and not self.Outrub and hpOld == hpNew
end

local function ebal(name,max)
	local r = math.random(1,max)
	return name .. ((r == 1 and "") or r) .. ".wav"
end

function CLASS:EventPoint(name,pos,radius,a1,a2)
	if self.Otrub then return end

	if self:GetMoveType() ~= MOVETYPE_NOCLIP and name == "fragnade pre detonate" and tracerSee(self,pos,52) then
		--EmitSound(self,"bot/noo.wav")

		local hp = self:Health()

		timer.Simple(2,function()
			if not live(self,hp,self:Health()) then return end

			--EmitSound(self,ebal("bot/yesss",2))
		end)
	end

	if name == "hitgroup killed" and a1 ~= self and a1.isContr then
		if a2.LastHitGroup == HITGROUP_HEAD then
			local hp = self:Health()
			timer.Simple(math.Rand(0.75,1.75),function()
				if not live(self,hp,self:Health()) then return end
				--EmitSound(self,ebal("bot/good_shot",2))
			end)
		end
	end
end

function CLASS:Event(name,a1)
	if self.Otrub then return end

	if name == "flashbang" and a1 >= 0.45 then
		local hp = self:Health()

		timer.Simple(math.Rand(0.5,1.25),function()
			if not live(self,hp,self:Health()) then return end

			if math.random(1,2) == 1 then
				--EmitSound(self,"bot/im_blind.wav")
			else
				--EmitSound(self,"bot/my_eyes.wav")
			end
		end)
	end

	if name == "inventory close" then
		if a1.roleT then
			local r = math.random(1,3)
			if r == 1 then EmitSound(self,"bot/aah.wav") elseif r == 2 then EmitSound(self,"bot/aw_hell.wav") else EmitSound(self,"bot/aww_man.wav") end
		else
			if math.random(1,2) == 2 then
				EmitSound(self,"snd_jack_hmcd_cop2.wav")
			else
				EmitSound(self,"snd_jack_hmcd_cop1.wav")
			end
		end
	end
end

local sounds = {
	{"Right",{"bot/alright.wav","bot/alright2.wav","bot/yea_ok.wav"},{1,1}},
	{"No",{"bot/negative.wav","bot/negative2.wav","bot/no.wav","bot/no2.wav"},{1,2}},
	{"Drop","bot/dropped_him.wav",{2,1}},
	{"Killed","bot/killed_him.wav",{2,2}},
	{"Follow","radio/followme.wav",{3,1}},
	{"Position",{"radio/takepoint.wav","radio/position.wav"},{3,2}}
}

if SERVER then
	util.AddNetworkString("homicide contr")

	net.Receive("homicide contr",function(len,ply)
		if not ply.isContr then return end--ban
		local sound = sounds[net.ReadInt(16)][2]

		if type(sound) == "table" then
			EmitSound(ply,sound[math.random(1,#sound)])
		else
			EmitSound(ply,sound)
		end

		--[[for i,ply in pairs(getList(ply)) do
			net.Start("homicide contr")
			net.WriteString(sound)
			net.Send()
		end]]--
	end)

	return
end

function CLASS:TeamName()
	return "Спецназ",CLASS.color
end

local nigger = Color(0,0,0,200)
local white = Color(255,255,255,25)
local white2 = Color(255,255,255)

local interface = {}
local interfacemaxy = 0

for id,snd in pairs(sounds) do
	local pos = snd[3]
	interface[pos[1]] = interface[pos[1]] or {}
	interface[pos[1]][pos[2]] = {id,snd[1]}
	
	interfacemaxy = math.max(interfacemaxy,pos[2])
end

function CLASS:OpenMenu()
	CLASS.CloseMenu()

	CLASS.Frame = vgui.Create("DFrame")
	local frame = CLASS.Frame
	frame:SetTitle("")
	frame:SetSize(#interface * 100,interfacemaxy * 50)
	frame:SetPos(ScrW() / 2 - frame:GetWide() / 2,ScrH() / 2 + frame:GetTall() + 50)
	frame:MakePopup()
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	
	function frame:Paint(w,h)
		Selected = nil
	end

	for x,list in pairs(interface) do
		x = x - 1
		for y,snd in pairs(list) do
			y = y - 1

			local button = vgui.Create("DButton",frame)
			button:SetText("")
			button:SetSize(100,50)
			button:SetPos(100 * x,50 * y)

			function button:Paint(w,h)
				draw.RoundedBox(0,0,0,w,h,nigger)

				if self:IsHovered() then
					Selected = snd[1]

					draw.RoundedBox(0,0,0,w,h,white)
				end

				draw.SimpleText(snd[2],"HomigradFont",w / 2,h / 2,white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end

			function button:DoClick()
				net.Start("homicide contr")
				net.WriteInt(snd[1],16)
				net.SendToServer()
			end
		end
	end
end

function CLASS:CloseMenu()
	if IsValid(CLASS.Frame) then
		CLASS.Frame:Remove()

		if Selected then
			net.Start("homicide contr")
			net.WriteInt(Selected,16)
			net.SendToServer()
		end
	end
end