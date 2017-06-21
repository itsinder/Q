local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
return function (x)

  assert(type(x) == "Column", "input must be a column")

  local t1 = Q.exp(x)
  -- t1:eval()
  local t2 = Q.vsadd(t1, 1)
  -- t2:eval()
  local t3 = Q.vvdiv(t1, t2)
  t3:eval()
  local t4 = Q.vvdiv(t3, t2)
  t4:eval()
  --[[

  local x_len = x:length()
  local nC = math.ceil( x_len / qconsts.chunk_size )

  for i = 1, nC do
    t3:chunk(i-1)
    t4:chunk(i-1)
  end
  --]]

  return t3, t4
  
end
