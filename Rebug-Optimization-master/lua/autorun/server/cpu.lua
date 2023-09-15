/*
*
*	@author		: vectivus
*	@module		: cpu
*	@website	: https://github.com/projectrebug/
*	@file		: cpu.lua	
*
*/

hook.Add("PreGamemodeLoaded", "widgets_disabler_cpu", function()
    MsgN("Disabling widgets...")

    function widgets.PlayerTick()
        -- empty
    end

    hook.Remove("PlayerTick", "TickWidgets")
    MsgN("Widgets disabled!")
end)