local function knn(X, x, k)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'

  -- START check parameters
  assert(type(X) == "table", "errer")
  assert(#X > 0)
  assert(type(x) == "lVector", "error")
  assert(type(k) == "number")
  assert(k > 0)
  local idx = 1
  local N = -1 -- number of training samples
  assert(#X == x:length())
  assert(x:fldtype() == "F4") 
  for k, v in pairs(X) do
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4") 
    if ( idx == 0 ) then 
      len = v:length()
    else
      assert(len == v:length())
    end
  end
  -- Get scaling factor for each attribute
  scales = {}
  for k, v in pairs(X) do
    -- for kth attribute
    scales[k] = Scalar(0, "F8")
    for i in 1, v:length() do
      x_k_i = v:get_one(i-1)
      y, n = Q.sum(Q.sqr(Q.vssub(v, x_k_i))):eval()
      scales[k] = scales[k] + y
    end
  end
end
return require('Q/q_export').export('knn', knn)
