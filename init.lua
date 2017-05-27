-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")
local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

-- needed by q_core; check this init location later.
require ('Q/q_export').Q_ROOT = script_path()


-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"

return require 'Q/q_export'