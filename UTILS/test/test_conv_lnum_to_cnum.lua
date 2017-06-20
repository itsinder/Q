local ffi = require 'Q/UTILS/lua/q_ffi'
local qc = require 'Q/UTILS/lua/q_core'
local conv_lnum_to_cnum = require 'Q/UTILS/lua/conv_lnum_to_cnum'
local conv_cnum_to_lnum = require 'Q/UTILS/lua/conv_cnum_to_lnum'
--====================
local val = 123
local c_mem = conv_lnum_to_cnum(val, "I1")
local val2 = conv_cnum_to_lnum(c_mem, "I1")
assert(val2 == 123)
--====================
local val = 9223372036854775807LL
print(type(val))
local nX = 32
X = ffi.malloc(nX)
local val2 = qc["I8_to_txt"](val, nil, X, nX)
print(val2)
--====================
print( "Successfully completed " .. arg[0])
