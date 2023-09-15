
include "wac/aircraft.lua"
include "wac/keyboard.lua"

wac.hook("wacAirAddInputs", "wac_aircraft_baseinputs", function()

	wac.aircraft.addControls("Flight Controls", {
		Throttle = {{-1, 1}, KEY_W, KEY_S},
		Pitch = {{-1, 1}, KEY_W, KEY_S},
		Yaw = {{-1, 1}, KEY_A, KEY_D},
		Roll = {{-1, 1}, KEY_A, KEY_D},
		Start = {true, KEY_R},
		Hover = {true, MOUSE_4},
	})

	wac.aircraft.addControls("Common", {
		Exit = {true, KEY_E},
		FreeView = {true, KEY_SPACE},
		Camera = {true, MOUSE_RIGHT},
	})

	wac.aircraft.addControls("Weapons", {
		Fire = {true, MOUSE_LEFT},
		NextWeapon = {true, KEY_F}
	})

end)


wac.hook("JoystickInitialize", "wac_air_jcon_init", function()
	wac.aircraft.initialize()
	wac.aircraft.joyControls = {}
	for i, category in pairs(wac.aircraft.controls) do
		for name, control in pairs(category.list) do
			wac.aircraft.joyControls[name] = jcon.register({
				uid = "wac_air_"..name,
				type = ((control[1] == true) and "digital" or "analog"),
				description = name,
				category = "WAC Aircraft"
			})
		end
	end
	wac.aircraft.joyInitialized = true
	wac.aircraft.joyCache = {}
end)



if SERVER then

	util.AddNetworkString("wac_joyinput_usermessage")

	AddCSLuaFile("autorun/wac_aircraft_input.lua")

	concommand.Add("wac_air_input", function(p, c, a)
		if IsValid(p) and p:Alive() then
			local v = p:GetVehicle()
			if IsValid(v) then
				local e = v:GetNWEntity("wac_aircraft")
				if IsValid(e) then
					e:receiveInput(a[1], tonumber(a[2]), p:GetNWInt("wac_passenger_id"))
				end
			end
		end
	end)


	wac.hook("Think", "wac_aircraft_mouseinput", function()
		for _, p in pairs(player.GetAll()) do
			local seat = p:GetVehicle()
			if IsValid(seat) then
				local e = seat:GetNWEntity("wac_aircraft")
				if IsValid(e) and p.wac.mouseInput and p:GetInfo("wac_cl_air_mouse") == "1" then
					local m = tonumber(p:GetInfo("wac_cl_air_sensitivity") or "1")/1.5
					local v = e:WorldToLocal(e:GetPos() + p:GetAimVector())
                    if (p.LocalEyeAngles) then
                        v = e:WorldToLocal(e:GetPos() + p:EyeAngles():Forward())
                    end
					local pid = p:GetNWInt("wac_passenger_id")
					e:receiveInput(
						"Pitch",
						math.Clamp(v.z*m*(p:GetInfo("wac_cl_air_mouse_invert_pitch")=="1" and 1 or -1)*10, -1, 1),
						pid
					)
					e:receiveInput(
						p:GetInfo("wac_cl_air_mouse_swap")=="0" and "Yaw" or "Roll",
						math.Clamp(v.y*m*(p:GetInfo("wac_cl_air_mouse_invert_yawroll")=="1" and 1 or -1)*10, -1, 1),
						pid
					)
				end
			end
		end
	end)


	wac.hook("Think", "wac_aircraft_joyinput", function() 
		if wac.aircraft.joyInitialized then
			for _, p in pairs(player.GetAll()) do
				local v = p:GetVehicle()
				if IsValid(v) then
					local e = p:GetVehicle():GetNWEntity("wac_aircraft")
					if IsValid(e) then
						for i, category in pairs(wac.aircraft.controls) do
							for name, control in pairs(category.list) do
								local n = joystick.Get(p, "wac_air_"..name)
								if n ~= nil and n ~= wac.aircraft.joyCache[name] then
									wac.aircraft.joyCache[name] = n
									if n == true or n == false then
										net.Start("wac_joyinput_usermessage")
										net.WriteString(name)
										net.WriteBit(n) -- write takes boolean, read returns int. fuck yeah.
										net.Send(p)
										n = (n == true and 1 or 0)
									else
										n = n/127.5-1
									end
									e:receiveInput(name, n, p:GetNWInt("wac_passenger_id"))
								end
							end
						end
					end
				end
			end
		end
	end)


else

	wac.hook("wacKey", "wac_cl_aircraft_keyboard", function(key, pressed)
		local v=LocalPlayer():GetVehicle()
		if !IsValid(v) then return end
		local vehicle = v:GetNWEntity("wac_aircraft")
		if !IsValid(vehicle) or vgui.CursorVisible() then return end
		local k = 0
		for i, category in pairs(wac.aircraft.controls) do
			for name, k in pairs(category.list) do
				if !k[3] then
					if GetConVar("wac_cl_air_key_" .. name):GetInt() == key then
						RunConsoleCommand("wac_air_input", name, (pressed and "1" or "0"))
						vehicle:receiveInput(name, pressed and 1 or 0, LocalPlayer():GetNWInt("wac_passenger_id"))
					end
				else
					local command, target
					if GetConVar("wac_cl_air_key_" .. name .. "_Inc"):GetInt() == key then
						command = name
						target = (pressed and k[1][2] or 0)
					elseif GetConVar("wac_cl_air_key_" .. name .. "_Dec"):GetInt() == key then
						command = name
						target = (pressed and k[1][1] or 0)
					end
					if command and target then
						if GetConVar("wac_cl_air_smoothkeyboard"):GetBool() then
							vehicle.inputCache = vehicle.inputCache or {}
							vehicle.inputCache[command] = vehicle.inputCache[command] or {current = 0}
							vehicle.inputCache[command].target = target
						else
							RunConsoleCommand("wac_air_input", command, tostring(target))
							vehicle:receiveInput(command, target, LocalPlayer():GetNWInt("wac_passenger_id"))
						end
					end
				end
			end
		end
	end)


	wac.hook("Think", "wac_cl_aircraft_smoothkeyboard", function()
		if GetConVar("wac_cl_air_smoothkeyboard"):GetBool() then
			local v=LocalPlayer():GetVehicle()
			if !IsValid(v) then return end
			local vehicle = v:GetNWEntity("wac_aircraft")
			if !IsValid(vehicle) or !vehicle.inputCache then return end
			for command, info in pairs(vehicle.inputCache) do
				if info.current != info.target then
					info.current = math.Approach(info.current, info.target, FrameTime()*3.5)
					RunConsoleCommand("wac_air_input", command, info.current)
					vehicle:receiveInput(command, info.current, LocalPlayer():GetNWInt("wac_passenger_id"))
				end
			end
		end
	end)


	net.Receive("wac_joyinput_usermessage", function(length)
		local vehicle = LocalPlayer():GetVehicle():GetNWEntity("wac_aircraft")
		if !IsValid(vehicle) then return end
		local s = net.ReadString()
		local b = net.ReadBit()
		vehicle:receiveInput(s, b, LocalPlayer():GetNWInt("wac_passenger_id"))
	end)

	
	wac.hook("Initialize", "wac_aircraft_finishinputs", function(p)
		if !wac.aircraft.init then
			hook.Run("wacAirAddInputs")
			wac.aircraft.init = true

			for i, category in pairs(wac.aircraft.controls) do	
				for name, key in pairs(category.list) do
					if !key[3] then
						CreateClientConVar("wac_cl_air_key_" .. name, key[2], true, true)
					else
						CreateClientConVar("wac_cl_air_key_" .. name .. "_Inc", key[2], true, true)
						CreateClientConVar("wac_cl_air_key_" .. name .. "_Dec", key[3], true, true)
					end
				end
			end
		end
	end)


	-- block player use button and menu when in vehicle
	wac.hook("PlayerBindPress", "wac_cl_air_exit", function(p,bind)
		if bind == "+use" then
			local v = p:GetVehicle()
			if IsValid(v) then
				local heli = p:GetVehicle():GetNWEntity("wac_aircraft")
				if IsValid(heli) then
					return true
				end
			end
		end
	end)


end

