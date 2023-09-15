function discordlib.colorToInt(color = color_white)
    return 65536 * color.r + 256 * color.g + color.b
end

function discordlib.intToColor(color = 0xFFFFFF)
    // discord wtf why 0 is white
    color = color == 0 and 0xFFFFFF or color
    return Color(math.floor(color / 65536), math.floor(color / 256) % 256, color % 256)
end

function discordlib.timestamp(time)
    return os.date("!%Y-%m-%dT%H:%M:%S+00:00", time)
end

local escape_markdown = {
    {"_", "\\_"},
    {"`", "\\`"},
    {"|", "\\|"},
    {"*", "\\*"},
    {"~", "\\~"}
}

function discordlib.escapeMarkdown(str = !err)
    for k, v in ipairs(escape_markdown) do
        str = string.gsub(str, v[1], v[2])
    end

    return str
end

local function printC(value, isKey)
    if isnumber(value)
    then
        if isKey
        then
            MsgC(color_white, "[", Color(255, 94, 0), value, color_white, "]")
        else
            MsgC(Color(255, 94, 0), value)
        end
    elseif isfunction(value)
    then
        if isKey
        then
            MsgC("[",color_white, value,"]")
        else
            MsgC(color_white, value)
        end
    elseif isstring(value)
    then
        if isKey
        then
            MsgC(color_white , "[",Color(206, 178, 70),"'", value , "'", color_white, "]")
        else
            MsgC(Color(206, 178, 70),"'", value , "'")
        end
    elseif IsColor(value)
    then
        if isKey
        then
            MsgC(color_white, "[",value, "█ ", Color(239, 255, 54), "Color ", value.r, ", " , value.g, ", "  , value.b, ", "  , value.a, color_white, "]")
        else
            MsgC(value, "█ ", Color(239, 255, 54), "Color " , value.r, ", " , value.g, ", "  , value.b, ", "  , value.a)
        end
    elseif isvector(value)
    then
        if isKey
        then
            MsgC(color_white, "[",Color(239, 255, 54), "Vector ", value.x, ", " , value.y, ", "  , value.z, color_white, "]")
        else
            MsgC(Color(239, 255, 54), "Vector ", value.x, ", " , value.y, ", "  , value.z)
        end
    elseif isangle(value)
    then
        if isKey
        then
            MsgC(color_white, "[",Color(239, 255, 54), "Angle ", value.pitch, ", " , value.yaw, ", "  , value.roll, color_white, "]")
        else
            MsgC(Color(239, 255, 54), "Angle ", value.pitch, ", " , value.yaw, ", "  , value.roll)
        end
    elseif isbool(value)
    then
        if isKey
        then
            MsgC(color_white,"[", value and Color(50,255,50) or Color(200,0,0), value, color_white,"]")
        else
            MsgC(value and Color(50,255,50) or Color(200,0,0), value)
        end
    else
        if isKey
        then
            MsgC("[",Color(0,255,0), value, "]")
        else
            MsgC(Color(0,255,0), value)
        end
    end
end

function discordlib.printTable( t, indent, done )
	local Msg = Msg

	done = done or {}
	indent = indent or 0
	local keys = table.GetKeys( t )

	table.sort( keys, function( a, b )
		if ( isnumber( a ) && isnumber( b ) ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	done[ t ] = true

	for i = 1, #keys do
		local key = keys[ i ]
		local value = t[ key ]
		Msg( string.rep( " ", indent ) )

        printC(key,true)
		if  ( istable( value ) && !IsColor(value) && !done[ value ] ) then

			done[ value ] = true
			Msg(":\n" )
			discordlib.printTable( value, indent + #value + 3, done )
			done[ value ] = nil

		else
            Msg(" = ")
            printC(value)
            Msg("\n")
		end

	end

end
