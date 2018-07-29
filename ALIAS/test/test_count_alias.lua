local Q = require 'Q'
local Scalar = require 'libsclr'

local tests = {}

-- Q.count should call Q.unique, which will return 2 vectors
-- unique_vec and count_vec of same length
tests.t1 = function()
  local col_1 = Q.mk_col({1, 2, 3, 4, 4, 5, 6, 6, 6}, "I1")
  local unq, cnt = Q.count(col_1)
  assert(type(unq) ==  "lVector" and type(cnt) == "lVector")
  unq:eval()
  assert(unq:length() == 6 and cnt:length() == 6, "Incorrect length returned")
  -- Q.print_csv(unq)
  print("Completed test t1")
end

-- Q.count should call Q.count, which will return 'I8' scalar
tests.t2 = function()
  local col_1 = Q.mk_col({1, 2, 3, 4, 4, 5, 6, 6, 6}, "I1")
  local num = 4
  local res = Q.count(col_1, num)
  assert(type(res) == "Reducer")
  assert(res:eval():to_num() == 2, "Incorrect count returned")
  print("Completed test t2")
end

-- Q.count should call Q.count, which will return 'I8' scalar
tests.t3 = function()
  local col_1 = Q.mk_col({1, 2, 3, 4, 4, 5, 6, 6, 6}, "I1")
  local s_val = Scalar.new(6, "I1")
  local res = Q.count(col_1, s_val)
  assert(type(res) == "Reducer")
  assert(res:eval():to_num() == 3, "Incorrect count returned")
  print("Completed test t3")
end

return tests