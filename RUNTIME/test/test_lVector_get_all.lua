require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local ffi     = require 'Q/UTILS/lua/q_ffi'

local tests = {} 
-- testing get_all function

tests.t1 = function()
  -- generating required .bin file 
  qc.generate_bin(10, "I4", "_in1_I4.bin", "linear")
  local x = lVector(
                    { qtype = "I4", file_name = "_in1_I4.bin"}
                   )
  assert(x:check())
  local len, base_addr, nn_addr = x:get_all()
  assert(len == 10)
  assert(base_addr)
  assert(nn_addr == nil)
  local X = ffi.cast("int32_t *", base_addr)
  for i = 1, 10 do
    -- print(X[i-1])
    assert(X[i-1] == i*10)
  end
  print("Successfully completed test t1")
end
  --====================

return tests
