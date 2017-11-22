-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local diff = require 'Q/UTILS/lua/diff'
local tests = {}
tests.t1 = function()
  local num_trials = 2
  local x1 = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8}, 'F8')
  local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
  local X = {x1, x2}
  local Y = Q.mk_col({100, 200}, 'F8')
  local Z
  for i = 1, num_trials do 
    Z = Q.mv_mul(X, Y):eval()
  end
  assert(Z:num_elements() == x1:length())
  print("Completed mv_mul")
  Q.print_csv(Z, nil, "_out1.txt")
  assert(diff("out1.txt", "_out1.txt"))
  os.execute("rm -f _out1.txt")
end
tests.t2 = function()
  local num_cols = 8
  local num_rows = 1048576 + 17
  local X = {}
  for i = 1, num_cols do 
    X[i] = 
  end
  local x1 = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8}, 'F8')
  local x2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'F8')
  local X = {x1, x2}
  local Y = Q.mk_col({100, 200}, 'F8')
  local Z = Q.mv_mul(X, Y):eval()
  end
  assert(Z:num_elements() == x1:length())
  print("Completed mv_mul")
  Q.print_csv(Z, nil, "_out1.txt")
  assert(diff("out1.txt", "_out1.txt"))
  os.execute("rm -f _out1.txt")
end
return tests
