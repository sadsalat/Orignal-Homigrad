
include "wac/base.lua"
include "wac/keyboard.lua"

wac.menu.aircraft = "Aircraft"


wac.aircraft = wac.aircraft or {
	
	version = "339",
	
	spawnCategory = "WAC Aircraft",

	addControls = function(category, t)
		local c
		for i, t in pairs(wac.aircraft.controls) do
			if t.name == category then
				c = t
			end
		end
		if not c then
			c = { name = category, list = {} }
			table.insert(wac.aircraft.controls, c)
		end

		for name, control in pairs(t) do
			control[2] = control[2] or KEY_NONE
			c.list[name] = control
		end
	end,

	controls = {},

	initialize = function()
		if not wac.aircraft.initialized then
			wac.aircraft.initialized = true
			hook.Run("wacAirAddInputs")
		end
	end,

}
