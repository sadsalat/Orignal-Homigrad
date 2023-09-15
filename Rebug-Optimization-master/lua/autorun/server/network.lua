/*
*
*	@author		: vectivus
*	@module		: networking
*	@website	: https://github.com/projectrebug/
*	@file		: network.lua	
*
*/

if game.SinglePlayer() then return end
local hook = hook
local ents_FindByClass = ents.FindByClass
local EFL_NO_THINK_FUNCTION = EFL_NO_THINK_FUNCTION
local ipairs = ipairs
local IsValid = IsValid
local table_insert = table.insert
module("seats_network_optimizer")

hook.Add("OnEntityCreated", "seats_network_optimizer", function(seat)
    if seat:GetClass() == "prop_vehicle_prisoner_pod" then
        seat:AddEFlags(EFL_NO_THINK_FUNCTION)
        seat.seats_network_optimizer = true
    end
end)

local i
local seats
local last_enabled

hook.Add("Think", "seats_network_optimizer", function()

    if not seats or not seats[i] then
        i = 1
        seats = {}
        for _, seat in ipairs(ents_FindByClass("prop_vehicle_prisoner_pod")) do
            if seat.seats_network_optimizer then
                table_insert(seats, seat)
            end
        end
    end

    while seats[i] and not IsValid(seats[i]) do
        i = i + 1
    end

    local seat = seats[i]

    if last_enabled ~= seat and IsValid(last_enabled) then
        local saved = last_enabled:GetSaveTable()
        if not saved["m_bEnterAnimOn"] and not saved["m_bExitAnimOn"] then
            last_enabled:AddEFlags(EFL_NO_THINK_FUNCTION)
            last_enabled = nil
        end
    end

    if IsValid(seat) then
        seat:RemoveEFlags(EFL_NO_THINK_FUNCTION)
        last_enabled = seat
    end

    i = i + 1
end)

local function EnteredOrLeaved(ply, seat)
    if IsValid(seat) and seat.seats_network_optimizer then
        table_insert(seats, i, seat)
    end
end

hook.Add("PlayerEnteredVehicle", "seats_network_optimizer", EnteredOrLeaved)
hook.Add("PlayerLeaveVehicle", "seats_network_optimizer", EnteredOrLeaved)