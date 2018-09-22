local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
-- local lVector = require 'Q/RUNTIME/lua/lVector'
local is_in   = require 'Q/UTILS/lua/is_in'
local cmem	= require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local cmps = { "gt", "lt", "geq", "leq", "eq", "neq" }
local function is_prev(f1, cmp, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/prev_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(f1 and (type(f1) == "lVector"))
  assert(f1:has_nulls() == false)
  assert(cmp and (type(cmp) == "string"))
  assert(is_in(cmp, cmps))
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), cmp)
  if not status then print(subs) end
  assert(status, "Specializer " .. sp_fn_name .. " failed")
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Missing symbol " .. func_name)
  local f2_qtype = "B1"
  local f2_buf    
  local chunk_idx = 0
  local f1_cast_as = qconsts.qtypes[subs.in_qtype].ctype .. "*" 
  local f2_cast_as = "unit64_t *"
  --============================================
  local f2_gen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      f2_buf = cmem.new(qconsts.chunk_size) -- over-allocated but okay
    end
    ffi.memset(get_ptr(f2_buf), 0, qconsts.chunk_size)
    local f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    if f1_len > 0 then  
      local cst_f1_chunk = ffi.cast(f1_cast_as, get_ptr(f1_chunk))
      local cst_f2_buf   = ffi.cast(f2_cast_as, get_ptr(f2_buf))
      local start_time = qc.RDTSC()
      qc[func_name](cst_f1_chunk, f1_len, cst_f2_buf)
      record_time(start_time, func_name)
    end
    chunk_idx = chunk_idx + 1
    return f1_len, f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=has_nulls, qtype=f2_qtype}
end
return require('Q/q_export').export('is_prev', is_prev)
