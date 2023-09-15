local queue = {}
hg.prechachesound = hg.prechachesound or {}

function hg.PrecahceSound(name)
    if hg.prechachesound[name] then return end

    if not hg.initents then
        queue[#queue + 1] = name
    else
        game.GetWorld():EmitSound(name,75,100,1,CHAN_AUTO,SND_STOP)
    end

    --hg.prechachesound[name] = true
end

hook.Add("Initialize","homigrad-prechache",function()
    for i,name in pairs(queue) do
        game.GetWorld():EmitSound(name)
    end
end)

local mul = 1
local FrameTime,TickInterval = FrameTime,engine.TickInterval

hook.Add("Think","Mul lerp",function()
	mul = FrameTime() / TickInterval()
end)

local Lerp,LerpVector,LerpAngle = Lerp,LerpVector,LerpAngle
local math_min = math.min

function LerpFT(lerp,source,set)
	return Lerp(math_min(lerp * mul,1),source,set)
end

function LerpVectorFT(lerp,source,set)
	return LerpVector(math_min(lerp * mul,1),source,set)
end

function LerpAngleFT(lerp,source,set)
	return LerpAngle(math_min(lerp * mul,1),source,set)
end

local function func_error(err)
	ErrorNoHaltWithStack(err)
end

local result,r1,r2,r3,r4,r5,r6,_error,errorH,tbl
local debug_getinfo = debug.getinfo

function util.pcall(func,...)
	_error = true

	result,r1,r2,r3,r4,r5,r6 = xpcall(func,func_error,...)

	errorH = _error
	_error = nil

	if result then
		if type(errorH) == "string" then
			ErrorNoHaltWithStack(errorH)

			return false,errorH
		end

		return true,r1,r2,r3,r4,r5,r6
	end
end--eeeeeeeeeeee

function util.error(text)
	if _error then
		_error = text
	else
		ErrorNoHaltWithStack(text)
	end
end

function util.FindInClassList(class,list)
	local value = list[class]

	if not value then
		for class2,value2 in pairs(list) do
			local star = string.sub(class2,#class2,#class2) == "*"
			local no = string.sub(class2,1,1) == "!"
			local thisClass = class

			if no then
				class2 = string.sub(class2,2,#class2)
			end

			if star then
				class2 = string.sub(class2,1,#class2 - 1)
				thisClass = string.sub(thisClass,1,#class2)
			end

			if thisClass == class2 then
				if no then return end

				value = value2
			end
		end
	end

	return value
end

local file_Find = file.Find
local d,f,split,path2
local string_sub,string_split = string.sub,string.Split
function file.Exists(path,gamePath)
	split = string_split(path,"/")

	path2 = split[#split]
	if path2 == "" then
		path2 = split[#split - 1]
		path = string_sub(path,1,#path - #path2 - 1)
	else
		path = string_sub(path,1,#path - #path2)
	end

	f,d = file_Find(path .. "*",gamePath)

	for i = 1,#d do
		if d[i] == path2 then return true end
	end

	for i = 1,#f do
		if f[i] == path2 then return true end
	end

	return false
end--sasi xyi

local max,min = math.max,math.min

function util.halfValue(value,maxvalue,k)
	k = maxvalue * k
	return max(value - k,0) / k
end

function util.halfValue2(value,maxvalue,k)
	k = maxvalue * k
	return min(value / k,1)
end

function util.safeDiv(a,b)
	if a == 0 and b == 0 then return 0 else return a / b end
end--pizdes