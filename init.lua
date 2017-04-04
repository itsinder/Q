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
paths[#paths + 1] = "Q2/code"


local lib_paths = {}
local lib_sep = ":" .. base_path
lib_paths[#lib_paths + 1 ] = os.getenv("LD_LIBRARY_PATH") or "./"
lib_paths[#lib_paths + 1 ] = "Q2/code"


stdlib.setenv("LD_LIBRARY_PATH", table.concat(lib_paths, lib_sep))
package.path = table.concat(paths, sep)
-- print(package.path)
-- print(os.getenv("LD_LIBRARY_PATH"))
