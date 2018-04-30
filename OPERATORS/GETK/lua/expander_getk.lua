local qconsts = require 'Q/UTILS/lua/q_consts'
-- local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

  -- This operator produces 1 vector
local function expander_getk(a, fval, k, optargs)
  assert(a)
  assert(type(a) == "string")
  assert( ( a == "min" ) or ( a == "max" ) )
  local sp_fn_name = "Q/OPERATORS/GETK/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  assert(fval)
  assert(type(fval) == "lVector", "f1 must be a lVector")
  assert(fval:has_nulls() == false)
  local fval_qtype = fval:fldtype()
  local fval_ctype = qconsts.qtypes[fval_qtype].ctype 
  local fval_width = qconsts.qtypes[fval_qtype].width

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
  local status, subs, tmpl = pcall(spfn, f1in_qytpe, optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)
  --=================================================
  -- create a buffer to sort each chunk as you get it 
  local n = qconsts.chunk_size
  local sort_buf_val = cmem.new(n * fval_width, fval_qtype)
  --=== create buffers for keeping topk from each chunk
  local vbuf1 = cmem.new(k * fval_width, fval_qtype)
  local n_vbuf1 = 0
  local vbuf2 = cmem.new(k * fval_width, fval_qtype)
  local n_buf2 = cmem.new(4, "I4");
  local ptr_nbuf2 = ffi.cast("int32_t *",  get_ptr(n_buf2))
  --============================================
  -- create vectors to return 
  local val_vec = lVector{nn= false, gen = true, qtype = fval_qtype, has_nulls = false}
  -- TODO Consider case where there are less than k elements to return

  local chunk_idx = 0
  while ( true ) do
    local fval_len, fval_chunk
    fval_len, fval_chunk = fval:chunk(chunk_idx)
    if ( fval_len == 0 ) then break end 
    local fval_chunk
    local fval_chunk = ffi.cast(fval_ctype .. "*",  get_ptr(fval_chunk))
    sort_fn = subs.sort_fn -- TODO "sort_asc_" .. fval_ctype 
    assert(qc[sort_fn], "function not found " .. sort_fn)
    qc[sort_fn](fval_chunk, fval_len)
    if ( chunk_idx == 0 )  then 
      ffi.C.memcpy(vbuf1, fval_chunk, k*fval_width)
    else
      qc[subs.merge_fn](vbuf1, n_vbuf1, fval_chunk, k, vbuf2, ptr_nbuf2):
    end
    -- copy from vbuf2 to vbuf1
    -- local tempn = ptr_nbuf2 ...
    ffi.C.memcpy(vbuf2, vbuf1, tempn * fval_width)
    n_buf1 = tempn
    chunk_idx = chunk_idx + 1
  end
  val_vec:put_chunk(vbuf1, n_vbuf1)
  return val_vec
end
return expander_getk
