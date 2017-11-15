-- matrix vector multiplication z := X \times y

local promote = require 'Q/UTILS/lua/promote'
local qconsts = require 'Q/UTILS/lua/q_consts'
return function (
  X,
  y,
  optargs
  )
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table of lVectors")
  local m, x_qtype, y_qtype, z_qtype
  local ok_types = { F4 = true, F8 = true }

  for k, x in ipairs(X) do 
    assert(type(x) == "lVector", "each element of X must be a lVector")
    x_qtype  = x:qtype()
    assert(ok_types[xtype], "qtype not F4 or F8 for column " .. k)
  end
  assert(type(y) == "lVector", "Y must be a lVector ")
  local k = #X
  y_qtype  = y:qtype()
  assert(ok_types[y_qtype], "qtype must be F4 or F8")
  assert(y:is_eov(), "y must be fully evaluated")

  if ( ( optargs ) and ( optargs.z_qtype ) ) then 
    z_qtype = assert(optargs.z_qtype)
  else
    z_qtype = promote(x_qtype, y_qtype)
  end
  assert(ok_types[z_qtype], "qtype of output must be F4 or F8")

  local tmpl = 'mv_mul_simple.tmpl'
  local subs = {}; 
  subs.fn = "mv_mul_simple_" .. x_qtype .. "_" .. y_qtype .. "_" .. z_qtype
  subs.x_ctype = qconsts.qtypes[x_qtype].ctype
  subs.y_ctype = qconsts.qtypes[y_qtype].ctype
  subs.z_ctype = qconsts.qtypes[z_qtype].ctype

  subs.x_qtype = x_qtype
  subs.y_qtype = y_qtype
  subs.z_qtype = z_qtype
  return subs, tmpl
end
