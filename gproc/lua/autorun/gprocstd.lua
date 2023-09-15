gproclib.addFormating("hex",function(v, n)
    if n then return ("%0" .. n .. "x"):format(v) end
    return ("%x"):format(v)
end)

gproclib.addFormating("HEX",function(v, n)
    if n then return ("%0" .. n .. "X"):format(v) end
    return ("%X"):format(v)
end)

gproclib.addFormating("float",function(v, n)
    if n then return ("%." .. n .. "f"):format(v) end
    return ("%f"):format(v)
end)

gproclib.addFormating("q",function(v)
    return ("%q"):format(v)
end)

gproclib.addFormating("ptr",function(v)
    return ("%p"):format(v)
end)


gproclib.setConstant("_WIN", system.IsWindows() or nil)
gproclib.setConstant("_OSX", system.IsOSX() or nil)
gproclib.setConstant("_LINUX", system.IsLinux() or nil)
gproclib.setConstant("_x64", jit.arch == "x64" or nil)
gproclib.setConstant("_x86", jit.arch == "x86" or nil)
