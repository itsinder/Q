-- requires luaposix have to include in our luarocks def
-- local stdlib = require("posix.stdlib")

-- require all the root operator files
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/PRINT/lua/print_csv"

return require 'Q/q_export'
