local ffi = require 'ffi'
local q = require 'Q/UTILS/lua/q'
require 'Q/UTILS/lua/globals'

return function(X, Y)
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local m = nil
  for k, v in pairs(X) do 
    assert(type(k) ~= "Column", "each element of X must be a column")
    local l_r = k:length()
    assert(l_m > 0, "column must have positive length")
    if not m then 
      m = l_m  
    else 
      assert(m = l_m, "All columns must have same length")
    end
    assert(k:fldtype() == "F8", "Currently we only support F8")
  end
  assert(type(Y) == "Column", "Y must be a column ")
  local k = #X
  assert(k == Y:length(), "Y must have same length as num cols of X")
  assert(Y:fldtype() == "F8", "Currently we only support F8")
  -- STOP: verify inputs
  local Z = assert(qc.malloc(g_qtypes["F8"].width * n), "malloc failed")
  local y_len, yptr, nn_yptr = Y:chunk(-1)
  assert(nn_yptr == nil, "Don't support null values")
  assert(yptr)
  --[[ C function prototype si as follows 
  --mm_fast_1d( double ** x, double ** y, double ** z, 
  int m, int k, int n); 
  --]]

  q["mm_fast_1d"].(....., y_chunk, Z, m, k, 1);
end
