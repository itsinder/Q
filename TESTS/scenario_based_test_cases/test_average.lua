-- Calculating average and adding it to the attached csv file
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/scenario_based_test_cases/"
  local M = dofile(datadir ..  "meta.lua")
  local x = Q.load_csv(datadir .. "test.csv", M, {use_accelerator = false})
  local y = Q.vvadd(x[1], x[2])
  local a = Q.mk_col({2, 2, 2, 2}, "I4")
  local b = Q.vvdiv(y, a)
  x[#x + 1] = b:eval()
  Q.print_csv(x, nil, "average.csv")
end
--======================================
return tests
