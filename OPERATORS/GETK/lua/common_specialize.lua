local qconsts = require 'Q/UTILS/lua/q_consts'
local function common_specialize(fval, k, optargs, subs)
  assert(fval)
  assert(type(fval) == "lVector", "f1 must be a lVector")
  assert(fval:has_nulls() == false)
  local qtype = fval:fldtype()
  local ctype = qconsts.qtypes[qtype].ctype 
  local width = qconsts.qtypes[qtype].width

  assert(k)
  assert(type(k) == "number")
  assert( (k > 0 ) and ( k < qconsts.chunk_size ) )

  local is_ephemeral = false
  if ( optargs ) then 
    assert(type(optargs) == "table") 
    if ( optargs.is_ephemeral == true ) then 
      is_ephemeral = true
    end
  end
  subs.is_ephemeral = is_ephemeral
  subs.qtype = qtype
  subs.ctype = ctype
  subs.width = width
  return subs
end
return common_specialize
