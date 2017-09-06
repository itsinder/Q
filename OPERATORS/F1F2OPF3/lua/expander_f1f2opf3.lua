local dbg = require 'Q/UTILS/lua/debugger'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'

local function expander_f1f2opf3(a, f1 , f2, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(f1)
  assert(type(f1) == "lVector", "f1 must be a lVector")
  assert(f2)
  assert(type(f2) == "lVector", "f2 must be a lVector")
  if ( optargs ) then assert(type(optargs) == "table") end
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), f2:fldtype())
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)
  local f3_qtype = assert(subs.out_qtype)
  local f3_width = qconsts.qtypes[f3_qtype].width
  if ( f3_width < 1 ) then f3_width = 1 end

  local buf_sz = qconsts.chunk_size * f3_width
  local f3_buf = ffi.malloc(buf_sz)

  local nn_f3_buf = nil -- Will be created if nulls in input
  if f1:has_nulls() or f2:has_nulls() then
    nn_f3_buf = ffi.malloc(qconsts.chunk_size)
  end

  local f1_chunk_size = f1:chunk_size()
  local f2_chunk_size = f2:chunk_size()
  assert(f1_chunk_size == f2_chunk_size)

  local f3_gen = function(chunk_idx)
    local f1_len, f1_chunk, nn_f1_chunk
    local f2_len, f2_chunk, nn_f2_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    f2_len, f2_chunk, nn_f2_chunk = f2:chunk(chunk_idx)
    assert(f1_len == f2_len)
    if f1_len > 0 then
      qc[func_name](f1_chunk, f2_chunk, f1_len, f3_buf)
    end
    return f1_len, f3_buf, nn_f3_buf
  end
  return lVector{gen=f3_gen, nn=false, qtype=f3_qtype}
end

return expander_f1f2opf3
