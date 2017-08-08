local lVector = require 'lVector'
local ffi     = require 'Q/UTILS/lua/q_ffi'
require 'Q/UTILS/lua/strict'

local x = lVector( { qtype = "B1", file_name = "_nn_in2.bin", num_elements = 10} )
assert(x:check())
len, base_data, nn_data = x:get_chunk()
assert(base_data)
--assert(nn_data)
assert(len == 10)
local base_data_u = ffi.cast("char *", base_data)
print(base_data_u[0])
print(base_data_u[1])
os.exit()

