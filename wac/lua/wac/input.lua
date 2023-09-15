
include "wac/base.lua"

wac.input = wac.input or {
	
	registerSeat = function(seat)
		seat.wac = seat.wac or {}
		--seat.wac.addInput
	end,

}