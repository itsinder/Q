local function ss_ifxthenyelsez(x, y, z)
  local Q       = require 'Q/q_export'
  local qc      = require 'Q/UTILS/lua/q_core'
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local lVector = require 'Q/RUNTIME/lua/lVector'

  assert(type(x) == "lVector", "error")
  assert(type(y) == "Scalar", "error") 
  assert(type(z) == "Scalar", "error") 
  local spfn = require("Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez_specialize" )
  assert(type(spfn) == "function")
  assert(x:fldtype() == "B1")
  assert(y:fldtype() == z:fldtype())
  local status, subs, tmpl = pcall(spfn, "ss", y:fldtype())
  if ( not status ) then print(subs) end
  assert(status, "error in call to ifxthenyelsez_specialize")
  assert(type(subs) == "table", "error in call to ifxthenyelsez_specialize")
  local func_name = assert(subs.fn)
  -- allocate buffer for output
  local wbufsz = qconsts.chunk_size * ffi.sizeof(subs.ctype)
  local wbuf = nil
  local chunk_idx = 0
  --
  local function ss_ifxthenyelsez_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    wbuf = wbuf or ffi.malloc(wbufsz)
    local xlen, xptr, nn_xptr = x:chunk(chunk_idx) 
    if ( xlen == 0 )  then
      return 0, nil, nil
    end
    assert(nn_xptr == nil, "Not prepared for null values in x")
    local yptr = y:cdata()
    local zptr = z:cdata()
    local status = qc[func_name](xptr, yptr, zptr, wbuf, xlen)
    assert(status == 0, "C error in ifxthenyelsez") 
    chunk_idx = chunk_idx + 1
    return xlen, wbuf, nil
  end
  return lVector( {gen=ss_ifxthenyelsez_gen, has_nulls=false, 
    qtype=subs.qtype} )
end
return ss_ifxthenyelsez
