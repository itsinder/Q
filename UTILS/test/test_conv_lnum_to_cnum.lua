local ffi = require 'Q/UTILS/lua/q_ffi'
local conv_lnum_to_cnum = require 'Q/UTILS/lua/conv_lnum_to_cnum'
local c_mem = conv_lnum_to_cnum(123, "I1")
local val = ffi.cast("int8_t *", c_mem)
assert(val[0] == 123)
print( "Successfully completed " .. arg[0])
