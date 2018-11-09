local Q = require 'Q'
local qc        = require 'Q/UTILS/lua/q_core'

local test = {}

test.t1 = function ()
  local sum_prod = require 'Q/ML/LOGREG/lua/sum_prod_eval'
  local N = 256 * 65536
  local M = 32
  local X = {}

  for i = 1, M do
    X[i] = Q.rand({lb = 0, ub = 10, qtype = "I1", len = N}):eval()
  end

  local w = Q.rand({lb = 0, ub = 1, qtype = "I1", len = N}):eval()

  local start_time = qc.RDTSC()
  local A = sum_prod(X, w)
  local stop_time = qc.RDTSC()
  print("sum_prod eval = ", stop_time-start_time)

  for i = 1, 3 do
    for j = 1, 3 do
      print(A[i][j])
    end
    print("================")
  end
  print("SUCCESS")
  os.exit()
end

test.t2 = function ()
  local sum_prod = require 'Q/ML/LOGREG/lua/sum_prod_chunk'
  local N = 256 * 65536
  local M = 32
  local X = {}

  for i = 1, M do
    X[i] = Q.rand({lb = 0, ub = 10, qtype = "I1", len = N}):eval()
  end

  local w = Q.rand({lb = 0, ub = 1, qtype = "I1", len = N}):eval()

  local start_time = qc.RDTSC()
  local A = sum_prod(X, w)
  local stop_time = qc.RDTSC()
  print("sum_prod chunk = ", stop_time-start_time)

  for i = 1, 3 do
    for j = 1, 3 do
      print(A[i][j])
    end
    print("================")
  end
  print("SUCCESS")
  os.exit()
end
return test
