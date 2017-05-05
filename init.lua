-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end
local plpath = require 'pl.path'

local q_src_root = assert(os.getenv("Q_SRC_ROOT"))
assert(plpath.isdir(q_src_root), "Q_SRC_ROOT not found")

local q_root = assert(os.getenv("Q_ROOT"), "Q_ROOT must be set")
assert(plpath.isdir(q_root), "Q_ROOT not found")
assert(plpath.isdir(q_root .. "/lib/" ), "Q_ROOT/lib not found")
assert(plpath.isdir(q_root .. "/include/" ), "Q_ROOT/include not found")

local base_path = script_path() or "./"
-- print (base_path)
local paths = {}
local sep = ";" .. base_path
paths[#paths + 1] = package.path
paths[#paths + 1] = "RUNTIME/COLUMN/code/lua/?.lua"
paths[#paths + 1] = "UTILS/lua/?.lua"
paths[#paths + 1] = "OPERATORS/F1F2OPF3/lua/?.lua"
paths[#paths + 1] = "OPERATORS/LOAD_CSV/lua/?.lua"
paths[#paths + 1] = "OPERATORS/DATA_LOAD/lua/?.lua"
paths[#paths + 1] = "OPERATORS/MK_COL/lua/?.lua"
paths[#paths + 1] = "OPERATORS/PRINT/lua/?.lua"

local lib_paths = {}
local lib_sep = ":"  
-- lib_paths[#lib_paths + 1 ] = os.getenv("LD_LIBRARY_PATH") or "./"
-- lib_paths[#lib_paths + 1 ] = base_path .. "RUNTIME/COLUMN/code/src"
lib_paths[#lib_paths + 1 ] = q_root .. "/lib/"

-- Check if all the paths are there
local curr_path = os.getenv("LD_LIBRARY_PATH")
libs = {}
if curr_path ~= nil then
    for i in string.gmatch(curr_path, "[^:]+") do
        --print(i)
        if string.len(i) > 0 then
            libs[#libs +1] = i
        end
    end
end

local missing = {}
for _ ,v in pairs(lib_paths) do
    local found = false
    local entry = v
    for _,v2 in pairs(libs) do
        if entry == v2 then found = true end
    end
    if not found then missing[#missing + 1] = entry end
end

if #missing > 0 then

	print("\27[31m" .. "\27[4m" .. "\27[1m" .. "error: Execute the next line and try".. "\27[0m")
    if curr_path ~= nil and string.len(curr_path) ~= 0 then
        print("export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:" .. table.concat(missing, ":" ))
    else
      print("export LD_LIBRARY_PATH=" .. table.concat(missing, ":" ))
    end
	os.exit(-1)
end

--stdlib.setenv("LD_LIBRARY_PATH", table.concat(lib_paths, lib_sep))
package.path = table.concat(paths, sep)

require "globals"
local g_mt = {
   __gc = function()
      print("byebye")
   end,
}
_G = setmetatable(_G, g_mt)
local signal = require("posix.signal")
print ("aloha")
signal.signal(signal.SIGINT, function(signum)
  io.write("biggie baddie \n")
  -- put code to save some stuff here
  os.exit(128 + signum)
end)
-- mk_col = require "mk_col"
-- print_csv = require "print_csv"
 -- load_csv = require "load_csv"
--print(package.path)
--print(os.getenv("LD_LIBRARY_PATH"))
