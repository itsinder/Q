local Q        = require 'Q'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local function lr_logit(x)
  -- Given x, return (1) 
  -- /(1+e^(-1*x)) and 
  -- (2) 1/((1+e^x)^2)

  assert(x)
  assert(type(x) == "lVector", "input must be a column")
  local fldtype = x:fldtype()
  assert( ( fldtype == "F4" ) or ( ( fldtype == "F8" ) ) )

  local t1 = Q.vsmul(x, Scalar.new(-1, fldtype)):memo(false)
  local t2 = Q.exp(t1):memo(false)
  local t3 = Q.incr(t2):memo(false)
  local t4 = Q.sqr(t3):memo(false)
  local logit  = Q.reciprocal(t3)
  local logit2 = Q.reciprocal(t4)

  local cidx = 0  -- chunk index
  local len = 0
  local len2 = 0
  repeat 
    len  = logit:chunk(cidx)
    len2 = logit2:chunk(cidx)
    assert(len == len2)
    cidx = cidx + 1
  until ( len == 0 )
  return logit, logit2
end
return lr_logit
