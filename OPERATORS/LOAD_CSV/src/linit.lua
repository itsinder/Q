local base_path = "./"
-- print (base_path)
local paths = {}
local sep = ";" .. base_path
paths[#paths + 1] = package.path
paths[#paths + 1] = "../../../UTILS/lua/?.lua"

package.path = table.concat(paths, sep)
require "globals"
