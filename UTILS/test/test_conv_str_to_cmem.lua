local ffi = require 'ffi'
local conv_str_to_cmem = require 'Q/UTILS/lua/conv_str_to_cmem'
local c_mem = conv_str_to_cmem(123, "I1")
local val = ffi.cast("I1 ", c_mem)
assert(val[0] == 123)
