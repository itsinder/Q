local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  -- validating minby to return min value from value vector
  -- according to the given grpby vector
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 0, 1, 1, 0, 0, 1}, "I1")
  local exp_val = {1, 2}
  local nb = 2
  local res = Q.minby(a, b, nb)
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    val, nn_val = res:get_one(i-1)
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t1 completed")
end

tests.t2 = function()
  -- minby test in safe mode by setting is_safe to true
  -- group by column exceeds limit
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 4, 1, 1, 2, 0, 2}, "I2")
  local nb = 3
  local res = Q.minby(a, b, nb, {is_safe = true})
  local status = pcall(res.eval, res)
  assert(status == false)
  print("Test t2 completed")
end

tests.t3 = function()
  -- Values of b, not having 0
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I2")
  local b = Q.mk_col({1, 1, 3, 1, 1, 2, 1, 2}, "I2")
  -- To discuss: what should be the default value for 0th grpby
  -- if it does not respective values in value vector
  local exp_val = {0, 1, 7}
  local nb = 3
  local res = Q.minby(a, b, nb)
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end

  print("Test t3 completed")
end

return tests
