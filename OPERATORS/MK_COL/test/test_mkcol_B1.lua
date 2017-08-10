-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
-- input table of values 1,2,3 of type I4, given to mk_col

local input = {1,0,0,0,1,1,0,1,0}
--local status, ret = mk_col(input, "B1")
local status, ret = pcall(mk_col, input, "B1")

assert(status, "Error in mk col ")
assert(type(ret) == "lVector", " Output of mk_col is not Column")
Q.print_csv(ret, nil, "")

for i=1,ret:length() do
  local status, result = pcall(convert_c_to_txt, ret, i)
  assert(status, "Failed to get the value from vector at index: "..tostring(i))
  if result == nil then result = 0 end
  assert(result == input[i], "Mismatch between input and column values")
end
print("SUCCESS")

require('Q/UTILS/lua/cleanup')()
os.exit() 
