
function SpawnSimfphysVehicle( Player, vname, tr )
	if not vname then return end

	local Tickrate = 1 / engine.TickInterval()
	
	if ( Tickrate <= 25 ) and not Player.IsInformedAboutTheServersLowTickrate then
		Player:PrintMessage( HUD_PRINTTALK, "(SIMFPHYS) WARNING! Server tickrate is "..Tickrate.." we recommend 33 or greater for this addon to work properly!")
		Player:PrintMessage( HUD_PRINTTALK, "Known problems caused by a too low tickrate:")
		Player:PrintMessage( HUD_PRINTTALK, "- Wobbly suspension")
		Player:PrintMessage( HUD_PRINTTALK, "- Wheelspazz or shaking after an crash on bumps or while drifting")
		Player:PrintMessage( HUD_PRINTTALK, "- Moondrive (wheels turning slower than they should)")
		Player:PrintMessage( HUD_PRINTTALK, "- Worse vehicle performance (less grip, slower accelerating)")
		
		Player.IsInformedAboutTheServersLowTickrate = true
	end
	
	local VehicleList = list.Get( "simfphys_vehicles" )
	local vehicle = VehicleList[ vname ]

	if not vehicle then return end
	
	if not tr then
		tr = Player:GetEyeTraceNoCursor()
	end

	local Angles = Player:GetAngles()
	Angles.pitch = 0
	Angles.roll = 0
	Angles.yaw = Angles.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)

	local pos = tr.HitPos + Vector(0,0,25) + (vehicle.SpawnOffset or Vector(0,0,0))

	local Ent = simfphys.SpawnVehicle( Player, pos, Angles, vehicle.Model, vehicle.Class, vname, vehicle )
	
	if not IsValid( Ent ) then return end
	
	undo.Create( "Vehicle" )
		undo.SetPlayer( Player )
		undo.AddEntity( Ent )
		undo.SetCustomUndoText( "Undone " .. vehicle.Name )
	undo.Finish( "Vehicle (" .. tostring( vehicle.Name ) .. ")" )

	Player:AddCleanup( "vehicles", Ent )
end
concommand.Add( "simfphys_spawnvehicle", function( ply, cmd, args ) SpawnSimfphysVehicle( ply, args[1] ) end )

local function VehicleMemDupe( Player, Entity, Data )
	table.Merge( Entity, Data )
end
duplicator.RegisterEntityModifier( "VehicleMemDupe", VehicleMemDupe )