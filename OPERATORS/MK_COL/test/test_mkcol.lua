-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local q_core = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'
-- input table of values 1,2,3 of type I4, given to mk_col
local status, ret = pcall(mk_col, {1,3,4}, "I4")
--local status, ret = mk_col({1,3,4}, "I4")
-- local status, ret = pcall(mk_col, {1.1,5.1,4.5}, "F4")
assert(status, "Error in mk col ")
assert(type(ret) == "lVector", " Output of mk_col is not Column")
for i=1, ret:length() do  
  local status, result = pcall(convert_c_to_txt, ret, i)
  assert(status, "Failed to get the value from vector at index: "..tostring(i))
  if result == nil then result = "" end
  print(result)
end   

require('Q/UTILS/lua/cleanup')()
os.exit() 
