-- local dbg = require 'Q/UTILS/lua/debugger'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'

local expander_ainb = function(op, a, b)
  -- START: verify inputs
  assert(op == "ainb")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(type(b) == "lVector", "b must be a lVector ")
  local sp_fn_name = "Q/OPERATORS/AINB/lua/ainb_specialize"
  local spfn = assert(require(sp_fn_name))

  -- All of b needs to be evaluated
  -- Check the vector b for eval(), if not then call eval()
  if not b:is_eov() then
    b:eval()
  end
  local blen, bptr, nn_bptr = b:get_all()
  assert(nn_bptr == nil, "Don't support null values")
  assert(blen > 0)
  assert(bptr)

  local b_sort_order = b:get_meta("sort_order")

  local status, subs, len = pcall(spfn, a:fldtype(), b:fldtype(), blen, b_sort_order)
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not defined " .. func_name)

  -- allocate buffer for output
  local csz = qconsts.chunk_size -- over allocated but needed by C
  local cbuf = nil
  local chunk_idx = 0
  local function ainb_gen()
    cbuf = cbuf or ffi.malloc(csz)
    local alen, aptr, nn_aptr = a:chunk(chunk_idx) 
    if ( ( not alen ) or ( alen == 0 ) ) then
      return 0, nil, nil
    end
    assert(nn_aptr == nil, "Not prepared for null values in a")
    local status = qc[func_name](aptr, alen, bptr, blen, cbuf)
    assert(status == 0, "C error in ainb")
    chunk_idx = chunk_idx + 1
    return alen, cbuf, nil
  end
  return lVector( {gen=ainb_gen, has_nulls=false, qtype="B1"} )
end

return expander_ainb
