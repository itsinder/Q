local Q = require 'Q'

function sum_prod(X, w, A)
  local temp = {}
  local SA = {}
  local M = #X

  for i = 1, M do
    SA[i] = {}
    A[i] = {}
    temp[i] = Q.vvmul(X[i], w):memo(0)
    for j = i, M do
      SA[i][j] = Q.sum(Q.vvmul(X[i], temp[i]):memo(0))
    end
  end

  local nC = 4-- TODO how to get num chunks
  local nC = math.ceil( w:length() / w:chunk_size() )
  
  for c = 1, nC do
    for i = 1, M do
      temp[i]:chunk(c) -- get this chunk evaluated
      for j = i, M do
        SA[i][j]:next() -- get this chunk evaluated
      end
    end
  end

  for i = 1, M do
    for j = 1, M do
      A[i][j] = SA[i][j]:value() -- get the value evaluated
    end
  end

end
