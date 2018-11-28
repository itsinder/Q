-- PERFORMANCE 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function(
  num_iters
  )
  local n = 1048576 -- number of rows
  local m = 128 -- number of columns
  local X = {}
  for i = 1, m do 
    X[i] = Q.const({val  = 1, len = n, qtype = "F4"})
  end
  local Y = Q.const({val  = 1, len = n, qtype = "F4"})
  local Z = Q.mv_mul(X, Y):eval()
  Q.print_csv(Z)
end
t1()
--return tests
