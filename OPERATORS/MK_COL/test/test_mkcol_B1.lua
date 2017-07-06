-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
-- input table of values 1,2,3 of type I4, given to mk_col
local status, ret = pcall(mk_col, {1,0,0,0,1,1,0,1,0}, "B1")
-- local status, ret = pcall(mk_col, {1.1,5.1,4.5}, "F4")
assert(status, "Error in mk col ")
assert(type(ret) == "Column", " Output of mk_col is not Column")
Q.print_csv(ret, nil, "")
print("SUCCESS")

require('Q/UTILS/lua/cleanup')()
os.exit() 
