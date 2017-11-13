local T = {} 
local function drop_nulls(x, sval)
  local Q   = require 'Q/q_export'
  local qc  = require 'Q/UTILS/lua/q_core'
  local ffi = require 'Q/UTILS/lua/q_ffi'
  assert(x)
  assert(type(x) == "lVector")
  if ( not x:has_nulls() ) then 
    return x
  end
  assert(x:is_eov(), "Vector must be materialized before dropping nulls")
  assert(sval)
  assert(type(sval) == "Scalar") 
  assert(x:fldtype() == sval:fldtype())
  --================================================
  local spfn = require("Q/OPERATORS/DROP_NULLS/lua/drop_nulls_specialize" )
  local status, subs, tmpl = pcall(spfn, x:fldtype())
  assert(status, "error in call to drop_nulls_specialize")
  assert(type(subs) == "table", "error in call to drop_nulls_specialize")
  local func_name = assert(subs.fn)

  -- TODO Check is already sorted correct way and don't repeat
  local xlen, xptr, nn_xptr = x:start_write()
  xptr = ffi.cast(subs.ctype .. " *", xptr)
  nn_xptr = ffi.cast("uint64_t *", nn_xptr)
  assert(xlen > 0, "Cannot have null vector")
  assert(nn_xptr, "Must have nulls in order to drop them")
  assert(qc[func_name], "Unknown function " .. func_name)
  qc[func_name](xptr, nn_xptr, sval:cdata(), xlen)
  x:end_write()
  x:drop_nulls()
  return x
  --================================================
end
T.drop_nulls = drop_nulls
require('Q/q_export').export('drop_nulls', drop_nulls)
return T
