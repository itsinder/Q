-- Test to check the meta data through Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local M = dofile(os.getenv("Q_SRC_ROOT") .. "/TESTS/functional_test_cases/meta_data.lua")
  local x = Q.load_csv(os.getenv("Q_SRC_ROOT") .. "/TESTS/functional_test_cases/data.csv", M, { is_hdr = true, use_accelerator = false})
  for i = 1, #x do
    local T = x[i]:meta()
    for k,v in pairs(T.base) do print(k,v) end
    for k,v in pairs(T.aux) do print(k,v) end
  end
  print("Test t1 succeeded")
end

--======================================

return tests
