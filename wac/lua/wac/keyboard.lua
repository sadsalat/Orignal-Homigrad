
if CLIENT then

	include("wac/base.lua")

	wac.key = wac.key or {

		name = function(key)
			return wac.key.data[key] and wac.key.data[key].n or "invalid"
		end,

		down = function(key)
			return wac.key.data[key] and wac.key.data[key].b or false
		end,
		
		addHook = function(name, func)
			wac.key.hooks[name] = func
		end,
		
		hooks = {},
		
		data = {
			[0]={n=""},
			[1]={n="0"},
			[2]={n="1"},
			[3]={n="2"},
			[4]={n="3"},
			[5]={n="4"},
			[6]={n="5"},
			[7]={n="6"},
			[8]={n="7"},
			[9]={n="8"},
			[10]={n="9"},
			[11]={n="A"},
			[12]={n="B"},
			[13]={n="C"},
			[14]={n="D"},
			[15]={n="E"},
			[16]={n="F"},
			[17]={n="G"},
			[18]={n="H"},
			[19]={n="I"},
			[20]={n="J"},
			[21]={n="K"},
			[22]={n="L"},
			[23]={n="M"},
			[24]={n="N"},
			[25]={n="O"},
			[26]={n="P"},
			[27]={n="Q"},
			[28]={n="R"},
			[29]={n="S"},
			[30]={n="T"},
			[31]={n="U"},
			[32]={n="V"},
			[33]={n="W"},
			[34]={n="X"},
			[35]={n="Y"},
			[36]={n="Z"},
			[37]={n="keypad 0"},
			[38]={n="keypad 1"},
			[39]={n="keypad 2"},
			[40]={n="keypad 3"},
			[41]={n="keypad 4"},
			[42]={n="keypad 5"},
			[43]={n="keypad 6"},
			[44]={n="keypad 7"},
			[45]={n="keypad 8"},
			[46]={n="keypad 9"},
			[47]={n="keypad /"},
			[48]={n="keypad *"},
			[49]={n="keypad -"},
			[50]={n="keypad +"},
			[51]={n="keypad Enter"},
			[52]={n="keypad Del"},
			[53]={n="["},
			[54]={n="]"},
			[55]={n=";"},
			[56]={n='"'},
			[57]={n="`"},
			[58]={n=","},
			[59]={n="."},
			[60]={n="/"},
			[61]={n="\\"},
			[62]={n="-"},
			[63]={n="="},
			[64]={n="Enter"},
			[65]={n="Space"},
			[66]={n="Backspace"},
			[67]={n="Tab"},
			[68]={n="Caps Lock"},
			[69]={n="Num Lock"},
			[71]={n="Scroll Lock"},
			[72]={n="Insert"},
			[73]={n="Delete"},
			[74]={n="Home"},
			[75]={n="End"},
			[76]={n="Page Up"},
			[78]={n="Break"},
			[79]={n="Shift"},
			[80]={n="Shift Left"},
			[81]={n="ALT"},
			[82]={n="ALT Right"},
			[83]={n="Control"},
			[84]={n="Control Right"},
			[88]={n="Arrow Up"},
			[89]={n="Arrow Left"},
			[90]={n="Arrow Down"},
			[91]={n="Arrow Right"},
			[92]={n="F1"},
			[93]={n="F2"},
			[94]={n="F3"},
			[95]={n="F4"},
			[96]={n="F5"},
			[97]={n="F6"},
			[98]={n="F7"},
			[99]={n="F8"},
			[100]={n="F9"},
			[101]={n="F10"},
			[102]={n="F11"},
			[103]={n="F12"},
			[107]={n="Mouse Left"},
			[108]={n="Mouse Right"},
			[109]={n="Mouse 3"},
			[110]={n="Mouse 4"},
			[111]={n="Mouse 5"},
			[112]={n="Mouse Wheel Up"},
			[113]={n="Mouse Wheel Down"},
		},
	}

	wac.hook("Think", "wac_cl_keyboard_pressthink", function()
		for key, info in pairs(wac.key.data) do
			local b = info.b
			info.b = key >= 107 and input.IsMouseDown(key) or input.IsKeyDown(key)
			if info.b ~= b then
				hook.Run("wacKey", key, info.b)
				for name, func in pairs(wac.key.hooks) do
					func(key, info.b)
				end
			end
		end
	end)

end
