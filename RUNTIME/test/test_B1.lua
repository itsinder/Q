local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi     = require 'Q/UTILS/lua/q_ffi'
require 'Q/UTILS/lua/strict'

local tests = {} 

tests.t1 = function()
  local status = os.execute("../../UTILS/src/asc2bin in2_B1.csv B1 _nn_in2.bin")
  local x = lVector( { qtype = "B1", file_name = "_nn_in2.bin", num_elements = 10} )
  assert(x:check())
  local len, base_data, nn_data = x:chunk()
  assert(base_data)
  --assert(nn_data)
  assert(len == 10)
  local base_data_u = ffi.cast("char *", base_data)
  print(base_data_u[0])
  print(base_data_u[1])
  print("Successfully completed test t1")
end

return tests
