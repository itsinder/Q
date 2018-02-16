-- FUNCTIONAL
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c3 = c1
  c1 = 10
  local c2 = Q.mk_col( {80,70,60,50,40,30,20,10}, "I8")
  local z = Q.vvadd(c3, c2)
  Q.print_csv(z, "_out1.txt", { lb = 1, ub = 4})
  os.execute("diff _out1.txt out1.txt");
  assert(Q.sum(Q.vvneq(z, Q.mk_col({81,72,63,54,45,36,27,18}, "I4"))):eval():to_num() == 0 )
  print("Test t1 succeeded")
end

tests.t2 = function()
  local input_table1 = {}
  local input_table2 = {}
  local expected_table = {}
  for i = 1, 65540 do
    input_table1[i] = i
    input_table2[i] = i * 10
    expected_table[i] = i + (i * 10)
  end
  local c1 = Q.mk_col(input_table1, "I4")
  local c2 = Q.mk_col(input_table2, "I4")
  local expected_col = Q.mk_col(expected_table, "I4")
  
  -- Perform vvadd
  local res = Q.vvadd(c1, c2)
  res:eval()
  
  -- Verification
  assert(Q.sum(Q.vvneq(res, expected_col)):eval():to_num() == 0)
  print("Test t2 succeeded")
end

return tests
