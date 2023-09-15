<p align="center">
<a>Experemintal glua preprocessor</a>
</p>

Features can be requested in [issues](https://github.com/devonium/gproc/issues)

---
<details>
<summary>gproclib</summary>
 
• gproclib.include(string file)  
• gproclib.parse(string source, string path)  
• gproclib.addFormating(string type ,function callback) [examples](lua/autorun/gprocstd.lua#L1)  
• gproclib.setConstant(string name, any value)  
• gproclib.getConstant(string name)  
• gproclib.defineMacro(string name, function callback)  

</details>


</details>

<details>
<summary>preprocessor features</summary>

<details>
<summary>Macros</summary>


```lua
gpoclib.defineMacro("sum", function(args) local n1 = tonumber(args[1]) local n2 = tonumber(args[2]) return n1 + n2 end)
print(gproclib.parse("sum(1,3)"))
-- 4
```

</details>

<details>
<summary>Derectives</summary>

### WARNING All directives must start at the beginning of the line

# define
### WARNING All definitions are global
* [std constants](lua/autorun/gprocstd.lua#L25)
## example
Source
```lua
#define fn function
fn()
end
```
--- 
Output
```lua
 
function()
end
```

# undef
## example
Source
```lua
#define fn function
#undef fn
fn()
end
```
--- 
Output
```lua
 
 
fn()
end
```

# if/ifdef/ifndef/elseif/endif
## example
Source
```lua
#ifdef test
print(1)
#endif

#undef test
#ifdef test
print(2)
#elseif
print(3)
#endif

#ifndef test
print(4)
#elseif
print(5)
#endif

#define test1
#define test2

#if DEFINED test1 and DEFINED test2
print(5)
#elseif
print(6)
#endif
```
--- 
Output
```lua


print(1)






print(3)



print(4)








print(5)




```

</details>
<details>
<summary>Predefined constants</summary>

# \_\_LINE\_\_ constant
## example
Source
```lua
__LINE__
__LINE__
```
--- 
Output
```lua
1
2
```

# \_\_FUNCTION\_\_ constant
## example
Source
```lua
function fnname()
 __FUNCTION__
 function()
  __FUNCTION__
 end
end
__FUNCTION__
```
--- 
Output
```lua
function fnname()
 "fnname"
 function()
  "anonymous"
 end
end
"main"
```


# \_\_FILE\_\_ constant
## example
Source
```lua
__FILE__
```
--- 
Output
```lua
"test.lua"
```

</details>
<details>
<summary>String interpolation + formating</summary>

* [std formatings](lua/autorun/gprocstd.lua#L1)

## example
Source
```lua
"${var}"
"${var:hex,4}"
```
--- 
Output
```lua
"" .. (var) .. ""
"" .. (gprocfmthex((var),4)) .. ""
```
</details>
<details>
<summary>Prefix operations</summary>
 
## example
Source
```lua
var++
var--
var +=1
var -=1
var /=1
var *=1
var .="str"
var %=1
```
--- 
Output
```lua
var   =var+1
var   =var-1
var =var +1
var =var -1
var =var /1
var =var *1
var =var .."str"
var =var %1
```
</details>
<details>
<summary>Default arguments</summary>

## example
Source
```lua
function(var = 0)
end
function(var = !err)
end
function(var = !ret {})
end
```
--- 
Output
```lua
function(var    ) if var  == nil then var = 0 end 
end
function(var       ) if var  == nil then error('bad argument #1 var (nil)') end 
end
function(var          ) if var  == nil then return  {} end 
end
```

</details>
</details>
