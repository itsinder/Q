-- Calculating average and adding it to the attached csv file
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local M = dofile(os.getenv("Q_SRC_ROOT") .. "/TESTS/scenario_based_test_cases/meta.lua")
  local x = Q.load_csv(os.getenv("Q_SRC_ROOT") .. "/TESTS/scenario_based_test_cases/test.csv", M, {use_accelerator = false})
  local y = Q.vvadd(x[1], x[2])
  local a = Q.mk_col({2, 2, 2, 2}, "I4")
  local b = Q.vvdiv(y, a)
  x[#x + 1] = b:eval()
  Q.print_csv(x, nil, "average.csv")
  print("Succeeded in test average t1")
end
--======================================
return tests
