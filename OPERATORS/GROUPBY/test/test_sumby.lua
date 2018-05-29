local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 2, 1, 1, 2, 0, 2}, "I2")
  local exp_val = {9, 13, 20}
  local nb = 3
  local res = Q.sumby(a, b, nb, {is_safe = true})
  res:eval()
  -- vefiry
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t1 completed")
end

tests.t2 = function()
  -- sumby test in safe mode ( default is safe mode )
  -- group by column exceeds limit
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 4, 1, 1, 2, 0, 2}, "I2")
  local nb = 3
  local res = Q.sumby(a, b, nb)
  local status = pcall(res.eval, res)
  assert(status == false)
  print("Test t2 completed")
end

tests.t3 = function()
  -- Values of b, not having 0
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({1, 1, 2, 1, 1, 2, 1, 2}, "I2")
  local exp_val = {0, 22, 20}
  local nb = 3
  local res = Q.sumby(a, b, nb)
  res:eval()

  -- vefiry
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end

  print("Test t3 completed")
end


tests.t4 = function()
  -- Length of input vector more than chunk size
  local len = qconsts.chunk_size * 2 + 655
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local b = Q.period({ len = len, start = 0, by = 1, period = 3, qtype = "I4"})
  local exp_val = {2891978467, 2892022376, 2892066285}
  local nb = 3

  local res = Q.sumby(a, b, nb)
  res:eval()

  assert(res:length() == nb)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t4 completed")
end

return tests