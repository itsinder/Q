local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local len = 65547
  local in_table = {}
  local exp_table = {}
  for i = 1, len do
    if i % 2 == 0 then
      in_table[i] = 1
      exp_table[i] = 0
    else
      in_table[i] = 0
      exp_table[i] = 1
    end
  end
  local col = Q.mk_col(in_table, "B1")
  local n_col = Q.vsnot(col)
  n_col:eval()

  local val, nn_val
  for i = 1, n_col:length() do
    val, nn_val = n_col:get_one(i-1)
    assert(val:to_num() == exp_table[i])
  end
  print("Completed test t1")
end

return tests
