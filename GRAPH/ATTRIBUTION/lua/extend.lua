local Q = require 'Q'
local function extend(inT, y0)
  assert(type(inT) == "table")
  local xk = inT.x
  local yk = inT.y
  assert(type(xk) == "lVector")
  assert(type(yk) == "lVector")
  assert(type(y0) == "lVector")
  local z = Q.get_val_by_idx(yk, y0)
  local w = Q.vsgeq(z, 0)
  local n_w = Q.sum(w):eval()
  if ( n_w == 0 ) then return nil end 
  local xnew = Q.where(xk, w)
  local ynew = Q.where(z, w)
  local T = {}
  T.x = xnew:eval()
  T.y = ynew:eval()
  return T
end
return extend
