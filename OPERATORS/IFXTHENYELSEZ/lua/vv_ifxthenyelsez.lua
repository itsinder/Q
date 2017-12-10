local function vv_ifxthenyelsez(x, y, z)
  local Q       = require 'Q/q_export'
  local qc      = require 'Q/UTILS/lua/q_core'
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local lVector = require 'Q/RUNTIME/lua/lVector'

  assert(type(x) == "lVector", "error")
  assert(type(y) == "lVector", "error")
  assert(type(z) == "lVector", "error")
  local spfn = require("Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez_specialize" )
  assert(type(spfn) == "function")
  assert(x:fldtype() == "B1")
  assert(y:fldtype() == z:fldtype())
  local status, subs, tmpl = pcall(spfn, "vv", y:fldtype())
  if ( not status ) then print(subs) end
  assert(status, "error in call to ifxthenyelsez_specialize")
  assert(type(subs) == "table", "error in call to ifxthenyelsez_specialize")
  local func_name = assert(subs.fn)
  -- allocate buffer for output
  local wbufsz = qconsts.chunk_size * ffi.sizeof(subs.ctype)
  local wbuf = nil
  local chunk_idx = 0
  --
  local function vv_ifxthenyelsez_gen()
    wbuf = wbuf or ffi.malloc(wbufsz)
    local xlen, xptr, nn_xptr = x:chunk(chunk_idx) 
    local ylen, yptr, nn_yptr = y:chunk(chunk_idx) 
    local zlen, zptr, nn_zptr = z:chunk(chunk_idx) 
    if ( ylen == 0 )  then
      return 0, nil, nil
    end
    assert(nn_xptr == nil, "Not prepared for null values in x")
    assert(nn_yptr == nil, "Not prepared for null values in y")
    assert(nn_zptr == nil, "Not prepared for null values in z")
    assert(xlen == ylen)
    assert(ylen == zlen)
    local status = qc[func_name](xptr, yptr, zptr, wbuf, ylen)
    assert(status == 0, "C error in vv_ifxthenyelsez")
    chunk_idx = chunk_idx + 1
    return ylen, wbuf, nil
  end
  return lVector( {gen=vv_ifxthenyelsez_gen, has_nulls=false, 
    qtype=subs.qtype} )
end
return vv_ifxthenyelsez
