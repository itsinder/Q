local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local function lr_logit(x)
  -- Given x, return (1) e^x/(1+e^x) and (2) e^x/((1+e^x)^2)

  assert(x)
  assert(type(x) == "lVector", "input must be a column")
  local fldtype = x:fldtype()
  assert( ( fldtype == "F4" ) or ( ( fldtype == "F8" ) ) )

  local t1 = Q.exp(x) -- :memo(0)
  local t2 = Q.vsadd(t1, 1) -- :memo(0)
  local t3 = Q.vvdiv(t1, t2)
  local t4 = Q.vvdiv(t3, t2)

  local cidx = 0  -- chunk index
  local t3_len = 0
  local t4_len = 0
  repeat 
    t3_len = t3:chunk(cidx)
    t4_len = t4:chunk(cidx)
    assert(t3_len == t4_len)
    cidx = cidx + 1
  until ( t3_len == 0 )
  return t3, t4
end
return lr_logit
