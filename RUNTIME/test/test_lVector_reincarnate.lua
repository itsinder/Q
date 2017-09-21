local Vector  = require 'libvec'  
local Scalar  = require 'libsclr'  
local cmem    = require 'libcmem'  
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'

--
x = lVector(
{ qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
assert(x:check())
T = x:reincarnate()

expected_op = [[
lVector ( {  qtype = " I4 ",  file_name = " _in1_I4.bin ",  nn_file_name = " _nn_in1.bin ",   ) } ]]
assert(T == expected_op)
-- cannot call reincarnate on nascent vector
x = lVector( { qtype = "I4", gen = true, has_nulls = false})
T = x:reincarnate()
assert(T == nil)
-- =========
print("Completed ", arg[0])
os.exit()
