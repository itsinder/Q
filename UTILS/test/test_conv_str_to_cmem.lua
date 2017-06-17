local ffi = require 'Q/UTILS/lua/q_ffi'
local conv_str_to_cmem = require 'Q/UTILS/lua/conv_str_to_cmem'
local c_mem = conv_str_to_cmem(123, "I1")
local val = ffi.cast("int8_t *", c_mem)
assert(val[0] == 123)
print( "Successfully completed " .. arg[0])
