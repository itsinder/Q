local ffi = require 'Q/UTILS/lua/q_ffi'
local conv_lnum_to_cnum = require 'Q/UTILS/lua/conv_lnum_to_cnum'
local conv_cnum_to_lnum = require 'Q/UTILS/lua/conv_cnum_to_lnum'
--====================
local val = 123
local c_mem = conv_lnum_to_cnum(val, "I1")
local val2 = conv_cnum_to_lnum(c_mem, "I1")
assert(val2 == 123)
--====================
print( "Successfully completed " .. arg[0])
