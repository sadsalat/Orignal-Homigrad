local LIB = ents.Reg("lib_event")
if not LIB then return end

LIB.event = {}
LIB.eventRemove = {}

local _event,list,min,max

function LIB:Event_Add(class,name,func,prio)
	_event = self.event[class]

	prio = prio or 0

	if not _event then
		_event = {
			list = {}
		}

		self.event[class] = _event
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

	if not IsValid(self) then
		local hr = self.eventRemove

		if hr then
			hr = hr[class] and hr[class][name]

			if hr then hr[prio] = nil end
		end
	end
end

function LIB:Event_Remove(class,name,prio)
	_event = self.event[class]

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
			self.event[class] = nil
		else
			_event.min = min
			_event.max = max
		end
	end
	
	if not IsValid(self) then
		local hr = self.eventRemove

		hr[class] = hr[class] or {}
		hr = hr[class]

		hr[name] = hr[name] or {}
		hr = hr[name]

		hr[prio] = true
	end

	return exists
end--никогда не юзал

--

local _event,r1,r2,r3,r4,r5,r6,success
local empty = {}

local pcall = util.pcall

function LIB:Event_Call(class,...)
	_event = self.event[class]

	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		success,r1,r2,r3,r4,r5,r6 = pcall(func,self,...)

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

function LIB:Event_CallNoSelf(class,...)
	_event = self.event[class]

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

function LIB:Event_Call1(class,callback1,...)
	_event = self.event[class]

	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		if callback1(name) == false then return end

		success,r1,r2,r3,r4,r5,r6 = pcall(func,self,...)

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

function LIB:Event_Call2(class,callback2,...)
	_event = self.event[class]

	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		success,r1,r2,r3,r4,r5,r6 = pcall(func,self,...)

		if not success then continue end

		if callback2(name,r1,r2,r3,r4,r5,r6) == false then return end

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

function LIB:Event_Call12(class,callback1,callback2,...)
	_event = self.event[class]

	if not _event then return end

	local event_list = _event.list
	local i = _event.min
	local max = _event.max

	::loop::

	for name,func in pairs(event_list[i] or empty) do
		if callback1(name) == false then return end

		success,r1,r2,r3,r4,r5,r6 = pcall(func,self,...)

		if not success then continue end

		if callback2(name,r1,r2,r3,r4,r5,r6) == false then return end

		if success and r1 ~= nil then return r1,r2,r3,r4,r5,r6 end
	end

	if i ~= max then
		i = i + 1

		goto loop
	end
end

--

function LIB:Event_Construct()
	for class,list in pairs(self.eventRemove) do
		for name,list in pairs(list) do
			for prio in pairs(list) do
				self:Event_Remove(class,name,prio)
			end
		end
	end

	for class,event in pairs(self.event) do
		local min,max

		for prio in pairs(event.list) do
			if not min then min = prio max = prio continue end

			if min > prio then min = prio end
			if max < prio then max = prio end
		end

		event.min = min
		event.max = max
	end
end

function LIB:Construct()
	local content = self[1]
	content:Event_Construct()

	content:Event_CallNoSelf("Construct",self)
end--ну и хуета конешно

--[[
	лутче избегать лишник калов, ну нахуй
	тогда мне неты так же нужно делать раз я типо да ага
	три заповеди блядь кек
	event add
	event remove
	event call
]]--20 09 2022 12 16: чего блядь...