local function hash(f1, optargs)
  local mk_col   = require 'Q/OPERATORS/MK_COL/lua/mk_col'
  local get_ptr  = require 'Q/UTILS/lua/get_ptr'
  local ffi      = require "Q/UTILS/lua/q_ffi"
  local qconsts  = require 'Q/UTILS/lua/q_consts'
  local qc       = require 'Q/UTILS/lua/q_core'
  local is_in    = require 'Q/UTILS/lua/is_in'
  local cmem     = require 'libcmem'
  local Scalar   = require 'libsclr'
  
  assert(type(x) == "lVector", "input to hash() is not lVector")
  assert(f1:has_nulls() == false, "not prepared for nulls in hash")
  local spfn = assert(require("hash_specialize"))
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), optargs)
  if not status then print(subs) end
  assert(status, "Specializer " .. sp_fn_name .. " failed")
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Missing symbol " .. func_name)
  
  local args = assert(subs.args)
  local cst_args_as = assert(subs.cst_args_as)
  args = ffi.cast(cst_args_as, args)
  qc["spooky_init"](args, subs.seed1, subs.seed2)
  local out_qtype = assert(subs.out_qtype)
  local out_width = qconsts.qtypes[out_qtype].width
  local buf_sz = qconsts.chunk_size * out_width
  local out_buf    = nil
  local chunk_idx = 0
  local func_name = subs.fn
  --============================================
  local out_gen = function(chunk_num)
    assert(chunk_num == chunk_idx)
    out_buf = out_buf or cmem.new(buf_sz, out_qtype)
    assert(out_buf)
    local f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    local cst_f1_as  = qconsts.qtypes[subs.in_qtype].ctype  .. "*" 
    local cst_out_as = qconsts.qtypes[subs.out_qtype].ctype .. "*" 
    if f1_len > 0 then  
      local cst_f1_chunk  = ffi.cast(cst_f1_as, get_ptr(f1_chunk))
      local cst_out_buf   = ffi.cast(cst_out_as, get_ptr(out_buf))
      local start_time = qc.RDTSC()
      qc[func_name](cst_f1_chunk, ffi.NULL, f1_len, cst_ptr_args, 
      cst_out_buf, ffi.NULL)
      record_time(start_time, func_name)
    end
    chunk_idx = chunk_idx + 1
    return f1_len, out_buf
  end
  return lVector{gen=out_gen, has_nulls=false, qtype=out_qtype}
end
return require('Q/q_export').export('hash', hash)
