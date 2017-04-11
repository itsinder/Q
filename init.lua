-- requires luaposix have to include in our luarocks def
local stdlib = require("posix.stdlib")
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local base_path = script_path() or "./"
print (base_path)
local paths = {}
local sep = ";" .. base_path
paths[#paths + 1] = package.path
paths[#paths + 1] = "Q2/code/?.lua"


local lib_paths = {}
local lib_sep = ":" .. base_path
-- lib_paths[#lib_paths + 1 ] = os.getenv("LD_LIBRARY_PATH") or "./"
lib_paths[#lib_paths + 1 ] = "Q2/code"
local curr_path = os.getenv("LD_LIBRARY_PATH")
libs = {}
if curr_path ~= nil then
    for i in string.gmatch(curr_path, "[^:]+") do
        print(i)
        if string.len(i) > 0 then
            libs[#libs +1] = i
        end
    end
end

local missing = {}
for _ ,v in pairs(lib_paths) do
    local found = false
    local entry = base_path .. v
    for _,v2 in pairs(libs) do
        if entry == v2 then found = true end
    end
    if not found then missing[#missing + 1] = entry end
end

if #missing > 0 then
    print("Set the path correctly before running Q")
    if curr_path ~= nil then
        print("export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:" .. table.concat(missing, ":" ))
    else
      print("export LD_LIBRARY_PATH=" .. table.concat(missing, ":" ))
    end
    error()
end

stdlib.setenv("LD_LIBRARY_PATH", table.concat(lib_paths, lib_sep))
package.path = table.concat(paths, sep)
print(package.path)
print(os.getenv("LD_LIBRARY_PATH"))
