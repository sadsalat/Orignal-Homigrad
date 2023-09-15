event = event or {}
local event = event

event.list = event.list or {}
local event_list = event.list

local _event,list,min,max

function event.Add(class,name,func,prio)
	_event = event_list[class]

	prio = prio or 0

	if not _event then
		_event = {
			list = {}
		}

		event_list[class] = _event
	end

	list = _event.list

	if not list[prio] then
		list[prio] = {}
	end

	list[prio][name] = func

	min,max = 0,0

	for prio in pairs(list) do
		if min > prio then min = prio end
		if max < prio then max = prio end
	end

	_event.min = min
	_event.max = max
end

function event.Remove(class,name,prio)
	_event = event_list[class]
	if not _event then return end

	prio = prio or 0

	local list = _event.list[prio]
	if not list then return end--eblan

	local exists = list[name]

	list[name] = nil

	local e

	for _ in pairs(list) do e = true break end

	if not e then
		_event.list[prio] = nil

		local min,max = 0,0

		for prio in pairs(_event.list) do
			if min > prio then min = prio end
			if max < prio then max = prio end
		end

		if not min then
			event_list[class] = nil
		else
			_event.min = min
			_event.max = max
		end
	end

	return exists
end--никогда не юзал

--

local _event,r1,r2,r3,r4,r5,r6,success
local empty = {}

local pcall = util.pcall

function event.Call(class,...)
	_event = event_list[class]
	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		success,r1,r2,r3,r4,r5,r6 = pcall(func,...)
		
		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

function event.Call1(class,callback1,...)
	_event = event_list[class]
	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		if callback1(name) == false then return end

		success,r1,r2,r3,r4,r5,r6 = pcall(func,...)

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

function event.Call2(class,callback2,...)
	_event = event_list[class]
	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		success,r1,r2,r3,r4,r5,r6 = pcall(func,...)

		if not success then continue end

		if callback2(name,r1,r2,r3,r4,r5,r6) == false then return end

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

function event.Call12(class,callback1,callback2,...)
	_event = event_list[class]
	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		if callback1(name) == false then return end

		success,r1,r2,r3,r4,r5,r6 = pcall(func,...)

		if not success then continue end

		if callback2(name,r1,r2,r3,r4,r5,r6) == false then return end

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end