-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi = require 'ffi'
local q = require 'Q/UTILS/lua/q'
require 'Q/UTILS/lua/globals'

local mvmul = function(X, Y)
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local m = nil
  for k, v in ipairs(X) do 
    assert(type(v) == "Column", "each element of X must be a column")
    local l_m = v:length()
    assert(l_m > 0, "column must have positive length")
    if not m then 
      m = l_m  
    else 
      assert(m == l_m, "All columns must have same length")
    end
    assert(v:fldtype() == "F8", "Currently we only support F8")
  end
  assert(type(Y) == "Column", "Y must be a column ")
  local k = #X
  assert(k == Y:length(), "Y must have same length as num cols of X")
  assert(Y:fldtype() == "F8", "Currently we only support F8")
  -- STOP: verify inputs
  local zptr = assert(q.malloc(g_qtypes["F8"].width * m), "malloc failed")
  local y_len, yptr, nn_yptr = Y:chunk(-1)
  assert(nn_yptr == nil, "Don't support null values")
  assert(yptr)
  assert(y_len == k)
  local Xptr = assert(q.malloc(ffi.sizeof("double *") * m), "malloc failed")
  Xptr = ffi.cast("double **", Xptr)
  for xidx = 1, #X do
    local x_len, xptr, nn_xptr = X[xidx]:chunk(-1)
    assert(nn_xptr == nil, "Don't support null values")
    Xptr[xidx-1] = ffi.cast("double *", xptr)
  end
  -- mvmul_a( double ** x, double * y, double * z, int m, int k); 
  q["mvmul_a"](Xptr, yptr, zptr, m, k);
  local zcol = Q.Column({field_type = "F8", write_vector = true})
  zcol:put_chunk(m, zptr)
  zcol:eov()
  return zcol
end
return require('Q/q_export').export('mvmul', mvmul)
