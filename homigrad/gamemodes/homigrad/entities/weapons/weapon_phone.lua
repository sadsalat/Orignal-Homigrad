SWEP.Base                   = "medkit"

SWEP.PrintName 				= "Заказчик"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "Закажи все вещи из JMOD!"
SWEP.Category 				= "Разное"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Slot					= 0
SWEP.SlotPos				= 3
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/props/cs_office/phone_p2.mdl"
SWEP.WorldModel				= "models/props/cs_office/phone_p2.mdl"

SWEP.ViewBack = true
SWEP.ForceSlot1 = true

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.dwsPos = Vector(10,10,7)
SWEP.dwsItemPos = Vector(0,3,0)

SWEP.dwmARight = 90
SWEP.dwmForward = 2
SWEP.dwmRight = -1

local STATE_BROKEN,STATE_OFF,STATE_CONNECTING=-1,0,1
function SWEP:SetupDataTables()
    self:NetworkVar("Int",1,"OutpostID")
    self:NetworkVar("Int",2,"State")
end

function SWEP:PrimaryAttack() end

if SERVER then
	function SWEP:Initialize()
		local Path = "/npc/combine_soldier/vo/"
		local Files, Folders = file.Find("sound" .. Path .. "*.wav", "GAME")
		self.Voices = Files

        self.NextRealThink = 0
		self.ConnectionlessThinks = 0
        self:SetState(STATE_OFF)
	end

	function SWEP:Speak(msg, parrot)
		if parrot then
			for _, ply in pairs(player.GetAll()) do
				if ply:Alive() and (ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 or (self:UserIsAuthorized(ply) and ply.EZarmor and ply.EZarmor.effects.teamComms)) then
					net.Start("JMod_EZradio")
					net.WriteBool(true)
					net.WriteBool(true)
					net.WriteString(parrot)
					net.WriteEntity(self)
					net.Send(ply)
				end
			end
		end

		local MsgLength = string.len(msg)

		for i = 1, math.Round(MsgLength / 15) do
			timer.Simple(i * .75, function()
				if IsValid(self) and (self:GetState() > 0) then
					self:EmitSound("/npc/combine_soldier/vo/" .. self.Voices[math.random(1, #self.Voices)], 65, 120)
				end
			end)
		end

		timer.Simple(.5, function()
			if IsValid(self) then
				for _, ply in pairs(player.GetAll()) do
					if ply:Alive() and (ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 or (self:UserIsAuthorized(ply) and ply.EZarmor and ply.EZarmor.effects.teamComms)) then
						net.Start("JMod_EZradio")
						net.WriteBool(true)
						net.WriteBool(false)
						net.WriteString(msg)
						net.WriteEntity(self)
						net.Send(ply)
					end
				end
			end
		end)
	end

	function SWEP:TurnOn(activator)
		local OldOwner = self:GetOwner()
		JMod.SetOwner(self, activator)

		self:SetState(STATE_CONNECTING)
		self:EmitSound("snds_jack_gmod/ezsentry_startup.wav", 65, 100)
		self.ConnectionAttempts = 0
	end

	function SWEP:TurnOff()
		local State = self:GetState()
		if State == STATE_OFF then return end
		self:SetState(STATE_OFF)
		self:EmitSound("snds_jack_gmod/ezsentry_shutdown.wav", 65, 100)
	end

	function SWEP:Connect(ply)
		if not ply then return end
		local Team = 0

		if engine.ActiveGamemode() == "sandbox" and ply:Team() == TEAM_UNASSIGNED then
			Team = ply:AccountID()
		else
			Team = ply:Team()
		end

		JMod.EZradioEstablish(self, tostring(Team)) -- we store team indices as strings because they might be huge (if it's a player's acct id)
		local OutpostID = self:GetOutpostID()
		local Station = JMod.EZ_RADIO_STATIONS[OutpostID]
		self:SetState(Station.state)

		timer.Simple(1, function()
			if IsValid(self) then
				self:Speak("Comm line established with J.I. Radio Outpost " .. OutpostID)
			end
		end)
	end

    function SWEP:Deploy()
        if self:GetState() == STATE_OFF then self:TurnOn() end
    end

    function SWEP:Holster()
        return true
    end

    function SWEP:PrimaryAttack() end

    function SWEP:SecondaryAttack()
		print(self:GetState(),JMod.EZ_STATION_STATE_READY )
        if self:GetState() == JMod.EZ_STATION_STATE_READY then
            net.Start("JMod_EZradio")
            net.WriteBool(false)
            net.WriteEntity(self)
            net.WriteTable(JMod.Config.RadioSpecs.AvailablePackages)
            net.Send(self:GetOwner())
        end
    end

	function SWEP:Think()
        --if true then return end
		local State, Time = self:GetState(), CurTime()

		if self.NextRealThink < Time then
			self.NextRealThink = Time + 4

			if State == STATE_CONNECTING then
				if self:TryFindSky() then
					self:Speak("Broadcast received, establishing comm line...")
					self:Connect(self:GetOwner())
				else
					JMod.Hint(self:GetOwner(), "aid sky")
					self.ConnectionAttempts = self.ConnectionAttempts + 1

					if self.ConnectionAttempts > 5 then
						self:Speak("Can not establish connection to any outpost. Shutting down.")

						timer.Simple(1, function()
							if IsValid(self) then
								self:TurnOff()
							end
						end)
					end
				end
			elseif State > 0 then
				if not self:TryFindSky() then
					self.ConnectionlessThinks = self.ConnectionlessThinks + 1

					if self.ConnectionlessThinks > 5 then
						self:Speak("Connection to outpost lost. Shutting down.")

						timer.Simple(1, function()
							if IsValid(self) then
								self:TurnOff()
							end
						end)
					end
				else
					self.ConnectionlessThinks = 0
				end

			end
		end
		return true
	end

	function SWEP:TryFindSky()
		local SelfPos = self:LocalToWorld(Vector(10, 0, 45))

		for i = 1, 3 do
			local Dir = self:LocalToWorldAngles(Angle(-50 + i * 5, 0, 0)):Forward()

			local HitSky = util.TraceLine({
				start = SelfPos,
				endpos = SelfPos + Dir * 9e9,
				filter = {self,self:GetOwner()},
				mask = MASK_OPAQUE
			}).HitSky

			if HitSky then return true end
		end

		return false
	end

	function SWEP:UserIsAuthorized(ply)
		if not ply then return false end
		if not ply:IsPlayer() then return false end
		if self:GetOwner() and (ply == self:GetOwner()) then return true end
		local Allies = (self:GetOwner() and self:GetOwner().JModFriends) or {}
		if table.HasValue(Allies, ply) then return true end

		if not (engine.ActiveGamemode() == "sandbox" and ply:Team() == TEAM_UNASSIGNED) then
			local OurTeam = nil

			if IsValid(self:GetOwner()) then
				OurTeam = self:GetOwner():Team()
			end

			return (OurTeam and ply:Team() == OurTeam) or false
		end

		return false
	end

	function SWEP:EZreceiveSpeech(ply, txt)
		local State = self:GetState()
		if State < 2 then return end

		if not self:TryFindSky() then
			JMod.Hint(self:GetOwner(), "aid sky")
			self:Speak("Can not establish connection to any outpost. Shutting down.")

			timer.Simple(1, function()
				if IsValid(self) then
					self:TurnOff()
				end
			end)

			return
		end

		if not self:UserIsAuthorized(ply) then return end
		txt = string.lower(txt)
		local NormalReq, BFFreq = string.sub(txt, 1, 14) == "supply radio: ", string.sub(txt, 1, 6) == "heyo: "

		if NormalReq or BFFreq then
			local Name, ParrotPhrase = string.sub(txt, 15), txt

			if BFFreq then
				Name = string.sub(txt, 7)
			end

			if Name == "help" then
				if State == 2 then
					--local Msg,Num='stand near radio\nsay in chat: "status", or "supply radio: [package]"\navailable packages are:\n',1
					local Msg, Num = 'stand near radio and say in chat "supply radio: status", or "supply radio: [package]". available packages are:', 1
					self:Speak(Msg, ParrotPhrase)
					local str = ""

					for name, items in pairs(JMod.Config.RadioSpecs.AvailablePackages) do
						str = str .. name

						if Num > 0 and Num % 10 == 0 then
							local newStr = str

							timer.Simple(Num / 10, function()
								if IsValid(self) then
									self:Speak(newStr)
								end
							end)

							str = ""
						else
							str = str .. ", "
						end

						Num = Num + 1
					end

					timer.Simple(Num / 10, function()
						if IsValid(self) then
							self:Speak(str)
						end
					end)

					JMod.Hint(self:GetOwner(), "aid package")

					return true
				end
			elseif Name == "status" then
				self:Speak(JMod.EZradioStatus(self, self:GetOutpostID(), ply, BFFreq), ParrotPhrase)

				return true
			elseif JMod.Config.RadioSpecs.AvailablePackages[Name] then
				self:Speak(JMod.EZradioRequest(self, self:GetOutpostID(), ply, Name, BFFreq), ParrotPhrase)

				return true
			end
		end

		return false
	end
elseif CLIENT then
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
        if !IsValid(DrawModel) then
            DrawModel = ClientsideModel( self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY );
            DrawModel:SetNoDraw( true );
        else
            DrawModel:SetModel( self.WorldModel )

            local vec = Vector(55,55,55)
            local ang = Vector(-48,-48,-48):Angle()

            cam.Start3D( vec, ang, 20, x, y+35, wide, tall, 5, 4096 )
                cam.IgnoreZ( true )
                render.SuppressEngineLighting( true )

                render.SetLightingOrigin( self:GetPos() )
                render.ResetModelLighting( 50/255, 50/255, 50/255 )
                render.SetColorModulation( 1, 1, 1 )
                render.SetBlend( 255 )

                render.SetModelLighting( 4, 1, 1, 1 )

                DrawModel:SetRenderAngles( Angle( 0, RealTime() * 30 % 360, 0 ) )
                DrawModel:DrawModel()
                DrawModel:SetRenderAngles()

                render.SetColorModulation( 1, 1, 1 )
                render.SetBlend( 1 )
                render.SuppressEngineLighting( false )
                cam.IgnoreZ( false )
            cam.End3D()
        end

        self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
    end

	function SWEP:Initialize()
		local Files,Folders=file.Find("sound/npc/combine_soldier/vo/*.wav","GAME")
		self.Voices=Files
	end

	local GlowSprite, StateMsgs = Material("sprites/mat_jack_basicglow"), {
		[STATE_CONNECTING] = "Connecting...",
		[JMod.EZ_STATION_STATE_READY] = "Ready",
		[JMod.EZ_STATION_STATE_DELIVERING] = "Delivering",
		[JMod.EZ_STATION_STATE_BUSY] = "Busy"
	}

	function SWEP:Draw()
	end
end