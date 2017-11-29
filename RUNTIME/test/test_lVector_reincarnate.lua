local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'

-- generating .bin files required for materialized vector
local status
status = os.execute("../../UTILS/src/asc2bin in1_I4.csv I4 _in1_I4.bin")
assert(status)
status = os.execute("../../UTILS/src/asc2bin in1_B1.csv B1 _nn_in1.bin")
assert(status)

local tests = {} 
--
tests.t1 = function()
  local x = lVector(
  { qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin"})
  assert(x:check())
  local T = x:reincarnate()

  local expected_op = [[lVector ( { qtype = "I4", file_name = "_in1_I4.bin", nn_file_name = "_nn_in1.bin",  } ) ]]
  assert(T == expected_op)
  -- cannot call reincarnate on nascent vector
  x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  T = x:reincarnate()
  assert(T == nil)
print("Successfully completed test t1")
end
-- =========

return tests
