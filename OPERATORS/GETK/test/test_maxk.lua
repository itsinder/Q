local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local col = Q.mk_col({1, 5, 4, 2, 3, 7, 9}, "I4")
  local res = Q.maxk(col, 3)
  local exp_col = Q.mk_col({9, 7, 5}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t1")
end

return tests
