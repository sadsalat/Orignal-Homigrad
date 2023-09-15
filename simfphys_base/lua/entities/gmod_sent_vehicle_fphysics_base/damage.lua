function ENT:ApplyDamage( damage, type )
	if type == DMG_BLAST then 
		damage = damage
	end
	
	if type == DMG_BULLET then 
		damage = damage / 100
	end
	
	local MaxHealth = self:GetMaxHealth()
	local CurHealth = self:GetCurHealth()
	
	local NewHealth = math.max( math.Round(CurHealth - damage,0) , 0 )
	
	if NewHealth <= (MaxHealth * 0.6) then
		if NewHealth <= (MaxHealth * 0.3) then
			self:SetOnFire( true )
			self:SetOnSmoke( false )
		else
			self:SetOnSmoke( true )
		end
	end
	
	if MaxHealth > 30 and NewHealth <= 31 then
		if self:EngineActive() then
			self:DamagedStall()
		end
	end
	
	if NewHealth <= 0 then
		if (type ~= DMG_CRUSH and type ~= DMG_GENERIC) or damage > MaxHealth then
			
			self:ExplodeVehicle()
			
			return
		end
		
		if self:EngineActive() then
			self:DamagedStall()
		end
		
		self:SetCurHealth( 0 )
		
		return
	end
	
	self:SetCurHealth( NewHealth )
end

function ENT:HurtPlayers( damage )
	if not simfphys.pDamageEnabled then return end
	
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		if self.RemoteDriver ~= Driver then
			Driver:TakeDamage(damage, Entity(0), self )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				Passenger:TakeDamage(damage, Entity(0), self )
			end
		end
	end
end

local ExploSnds = {}
ExploSnds[1]                         =  "explosions/doi_generic_01.wav"
ExploSnds[2]                         =  "explosions/doi_generic_02.wav"
ExploSnds[3]                         =  "explosions/doi_generic_03.wav"
ExploSnds[4]                         =  "explosions/doi_generic_04.wav"

local CloseExploSnds = {}
CloseExploSnds[1]                         =  "explosions/doi_generic_01_close.wav"
CloseExploSnds[2]                         =  "explosions/doi_generic_02_close.wav"
CloseExploSnds[3]                         =  "explosions/doi_generic_03_close.wav"
CloseExploSnds[4]                         =  "explosions/doi_generic_04_close.wav"

local DistExploSnds = {}
DistExploSnds[1]                         =  "explosions/doi_generic_01_dist.wav"
DistExploSnds[2]                         =  "explosions/doi_generic_02_dist.wav"
DistExploSnds[3]                         =  "explosions/doi_generic_03_dist.wav"
DistExploSnds[4]                         =  "explosions/doi_generic_04_dist.wav"

local WaterExploSnds = {}
WaterExploSnds[1]                         =  "explosions/doi_generic_01_water.wav"
WaterExploSnds[2]                         =  "explosions/doi_generic_02_water.wav"
WaterExploSnds[3]                         =  "explosions/doi_generic_03_water.wav"
WaterExploSnds[4]                         =  "explosions/doi_generic_04_water.wav"

local CloseWaterExploSnds = {}
CloseWaterExploSnds[1]                         =  "explosions/doi_generic_02_closewater.wav"
CloseWaterExploSnds[2]                         =  "explosions/doi_generic_02_closewater.wav"
CloseWaterExploSnds[3]                         =  "explosions/doi_generic_03_closewater.wav"
CloseWaterExploSnds[4]                         =  "explosions/doi_generic_04_closewater.wav"

function ENT:ExplodeVehicle()
	if not IsValid( self ) then return end
	if self.destroyed then return end
	
	self.destroyed = true

	local ply = self.EntityOwner
	local skin = self:GetSkin()
	local Col = self:GetColor()
	Col.r = Col.r * 0.8
	Col.g = Col.g * 0.8
	Col.b = Col.b * 0.8

	local trace = util.TraceLine({
		start = self:GetPos() + self:OBBCenter(),
		endpos = self:GetPos() + self:OBBCenter() + self:GetVelocity(),
		filter = self
	})

	local traceGround = util.TraceLine({
		start = self:GetPos() + self:OBBCenter(),
		endpos = self:GetPos() - Vector(0,0,math.abs(self:OBBMins()[3]) + 15),
		filter = self
	})

	if not trace.Hit then trace = traceGround end

	if trace.Hit then
		local angles = trace.HitNormal:Angle()
		local pos = self:GetPos()

		for i = 1,2 do
			local fx = EffectData()
			fx:SetNormal(trace.HitNormal)
			
			local rand = Vector(math.random(-25,25),math.random(-25,25),0)
			
			rand:Rotate(angles + Angle(90,0,0))

			fx:SetOrigin(trace.HitPos + rand * 10)
			fx:SetScale(250)
			fx:SetStart(Vector(0,0,0))
			fx:SetSurfaceProp(trace.SurfaceProps)
			fx:SetDamageType(DMG_VEHICLE)
			util.Effect("chloeimpact_groundcrack",fx,true,true)
		end

		net.Start("gred_net_createparticle")
		
		if self:WaterLevel() >= 1 then
			net.WriteString("ins_water_explosion") -- FIXME : Optimize
			net.WriteVector(pos)
			net.WriteAngle(angles)
			net.WriteBool(false)
		else
			net.WriteString("doi_artillery_explosion") -- FIXME : Optimize
			net.WriteVector(pos)
			net.WriteAngle(angles or angle_zero)
			net.WriteBool(angles and true or false)
		end
		
		net.Broadcast()

		gred.CreateSound(pos,nil,table.Random(CloseExploSnds),table.Random(ExploSnds),table.Random(DistExploSnds)) -- FIXME : Replace self.RSound == 1 with an actual bool
	end

	if self.GibModels then
		local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
		bprop:SetModel( self.GibModels[1] )
		bprop:SetPos( self:GetPos() )
		bprop:SetAngles( self:GetAngles() )
		bprop.MakeSound = true
		bprop:Spawn()
		bprop:Activate()
		bprop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
		bprop:GetPhysicsObject():SetMass( self.Mass * 0.75 )
		bprop.DoNotDuplicate = true
		bprop:SetColor( Col )
		bprop:SetSkin( skin )
		
		self.Gib = bprop
		
		--[[simfphys.SetOwner( ply , bprop )
		
		if IsValid( ply ) then
			undo.Create( "Gib" )
			undo.SetPlayer( ply )
			undo.AddEntity( bprop )
			undo.SetCustomUndoText( "Undone Gib" )
			undo.Finish( "Gib" )
			ply:AddCleanup( "Gibs", bprop )
		end]]--
		

		bprop.Gibs = {}
		for i = 2, table.Count( self.GibModels ) do
			local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
			prop:SetModel( self.GibModels[i] )			
			prop:SetPos( self:GetPos() )
			prop:SetAngles( self:GetAngles() )
			prop:SetOwner( bprop )
			prop:Spawn()
			prop:Activate()
			prop.DoNotDuplicate = true
			--bprop:DeleteOnRemove( prop )
			bprop.Gibs[i-1] = prop
			
			local PhysObj = prop:GetPhysicsObject()
			if IsValid( PhysObj ) then
				PhysObj:SetVelocityInstantaneous( VectorRand() * 500 + self:GetVelocity() + Vector(0,0,math.random(150,250)) )
				PhysObj:AddAngleVelocity( VectorRand() )
			end

			--simfphys.SetOwner( ply , prop )
		end
	else
		local bprop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
		bprop:SetModel( self:GetModel() )			
		bprop:SetPos( self:GetPos() )
		bprop:SetAngles( self:GetAngles() )
		bprop.MakeSound = true
		bprop:Spawn()
		bprop:Activate()
		bprop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(150,250)) ) 
		bprop:GetPhysicsObject():SetMass( self.Mass * 0.75 )
		bprop.DoNotDuplicate = true
		bprop:SetColor( Col )
		bprop:SetSkin( skin )
		for i = 0, self:GetNumBodyGroups() do
			bprop:SetBodygroup(i, self:GetBodygroup(i))
		end

		self.Gib = bprop
		
		--[[simfphys.SetOwner( ply , bprop )
		
		if IsValid( ply ) then
			undo.Create( "Gib" )
			undo.SetPlayer( ply )
			undo.AddEntity( bprop )
			undo.SetCustomUndoText( "Undone Gib" )
			undo.Finish( "Gib" )
			ply:AddCleanup( "Gibs", bprop )
		end]]--
		
		if self.CustomWheels == true and not self.NoWheelGibs then
			bprop.Wheels = {}
			for i = 1, table.Count( self.GhostWheels ) do
				local Wheel = self.GhostWheels[i]
				if IsValid(Wheel) then
					local prop = ents.Create( "gmod_sent_vehicle_fphysics_gib" )
					prop:SetModel( Wheel:GetModel() )			
					prop:SetPos( Wheel:LocalToWorld( Vector(0,0,0) ) )
					prop:SetAngles( Wheel:LocalToWorldAngles( Angle(0,0,0) ) )
					prop:SetOwner( bprop )
					prop:Spawn()
					prop:Activate()
					prop:GetPhysicsObject():SetVelocity( self:GetVelocity() + Vector(math.random(-5,5),math.random(-5,5),math.random(0,25)) )
					prop:GetPhysicsObject():SetMass( 20 )
					prop.DoNotDuplicate = true

					--bprop:DeleteOnRemove( prop )
					bprop.Wheels[i] = prop
					
					--simfphys.SetOwner( ply , prop )
				end
			end
		end
	end

	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		if self.RemoteDriver ~= Driver then
			Driver:TakeDamage( Driver:Health() + Driver:Armor(), self.LastAttacker or Entity(0), self.LastInflictor or Entity(0) )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			if IsValid( Passenger ) then
				Passenger:TakeDamage( Passenger:Health() + Passenger:Armor(), self.LastAttacker or Entity(0), self.LastInflictor or Entity(0) )
			end
		end
	end

	self:Extinguish() 
	
	self:OnDestroyed()
	
	hook.Run( "simfphysOnDestroyed", self, self.Gib )
	
	self:Remove()
end

local dis = 50

function ENT:OnTakeDamage( dmginfo )
	if not self:IsInitialized() then return end
	
	if hook.Run( "simfphysOnTakeDamage", self, dmginfo ) then return end
	
	local Damage = dmginfo:GetDamage() 
	local DamagePos = dmginfo:GetDamagePosition() 
	local Type = dmginfo:GetDamageType()
	local Driver = self:GetDriver()
	
	self.LastAttacker = dmginfo:GetAttacker() 
	self.LastInflictor = dmginfo:GetInflictor()
	
	if simfphys.DamageEnabled then
		net.Start( "simfphys_spritedamage" )
			net.WriteEntity( self )
			net.WriteVector( self:WorldToLocal( DamagePos ) ) 
			net.WriteBool( false ) 
		net.Broadcast()
		
		self:ApplyDamage( Damage, Type )
	end
	
	if self.IsArmored then return end
	
	if IsValid(Driver) then
		local Distance = (DamagePos - Driver:GetPos()):Length() 
		if (Distance < dis) then
			local Damage = (dis - Distance) / 22
			dmginfo:ScaleDamage( Damage )
			Driver:TakeDamageInfo( dmginfo )
			
			local effectdata = EffectData()
				effectdata:SetOrigin( DamagePos )
			util.Effect( "BloodImpact", effectdata, true, true )
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.PassengerSeats ) do
			local Passenger = self.pSeat[i]:GetDriver()
			
			if IsValid(Passenger) then
				local Distance = (DamagePos - Passenger:GetPos()):Length()
				local Damage = (dis - Distance) / 22
				if (Distance < dis) then
					dmginfo:ScaleDamage( Damage )
					Passenger:TakeDamageInfo( dmginfo )
					
					local effectdata = EffectData()
						effectdata:SetOrigin( DamagePos )
					util.Effect( "BloodImpact", effectdata, true, true )
				end
			end
		end
	end
end

local function Spark( pos , normal , snd )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos - normal )
	effectdata:SetNormal( -normal )
	util.Effect( "stunstickimpact", effectdata, true, true )
	
	if snd then
		sound.Play( Sound( snd ), pos, 75)
	end
end

function ENT:PhysicsCollide( data, physobj )

	if hook.Run( "simfphysPhysicsCollide", self, data, physobj ) then return end

	if IsValid( data.HitEntity ) then
		if data.HitEntity:IsNPC() or data.HitEntity:IsNextBot() or data.HitEntity:IsPlayer() then
			Spark( data.HitPos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			return
		end
	end
	
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		
		local pos = data.HitPos
		
		if (data.Speed > 1000) then
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactHard" )
			
			self:HurtPlayers( 5 )
			
			self:TakeDamage( (data.Speed / 7) * simfphys.DamageMul, Entity(0), Entity(0) )
		else
			Spark( pos , data.HitNormal , "MetalVehicle.ImpactSoft" )
			
			if data.Speed > 250 then
				local hitent = data.HitEntity:IsPlayer()
				if not hitent then
					if simfphys.DamageMul > 1 then
						self:TakeDamage( (data.Speed / 28) * simfphys.DamageMul, Entity(0), Entity(0) )
					end
				end
			end
			
			if data.Speed > 500 then
				self:HurtPlayers( 2 )
				
				self:TakeDamage( (data.Speed / 14) * simfphys.DamageMul, Entity(0), Entity(0) )
			end
		end
	end
end
