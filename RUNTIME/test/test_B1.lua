local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local gen_bin = require 'Q/RUNTIME/test/generate_bin'
require 'Q/UTILS/lua/strict'

local tests = {} 

tests.t1 = function()
  -- generating required .bin file for B1 materialized vector
  gen_bin["generate_bin"](10, "B1","_nn_in2.bin" )
  
  local x = lVector( { qtype = "B1", file_name = "_nn_in2.bin", num_elements = 10} )
  assert(x:check())
  local len, base_data, nn_data = x:get_all()
  assert(base_data)
  --assert(nn_data)
  assert(len == 10)
  local base_data_u = ffi.cast("char *", base_data)
  print(base_data_u[0])
  print(base_data_u[1])
  print("Successfully completed test t1")
end

return tests
