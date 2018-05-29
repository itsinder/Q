-- local dbg = require 'Q/UTILS/lua/debugger'
local gen_code = require 'Q/UTILS/lua/gen_code'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local function expander_f1f2opf3(a, f1 , f2, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(f1)
  assert(type(f1) == "lVector", "f1 must be a lVector")
  assert(f2)
  assert(type(f2) == "lVector", "f2 must be a lVector")
  if ( optargs ) then assert(type(optargs) == "table") end
  local status, subs, tmpl = pcall(spfn, f1:fldtype(), f2:fldtype(), optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then 
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name) 
  end 
  assert(qc[func_name], "Symbol not available" .. func_name)
  local f3_qtype = assert(subs.out_qtype)
  local f3_width = qconsts.qtypes[f3_qtype].width
  f3_width = f3_width or 1 -- to account for B1 and such types

  local buf_sz = qconsts.chunk_size * f3_width
  local f3_buf = nil
  local nn_f3_buf = nil -- Will be created if nulls in input

  local f1_chunk_size = f1:chunk_size()
  local f2_chunk_size = f2:chunk_size()
  assert(f1_chunk_size == f2_chunk_size)

  local first_call = true
  local chunk_idx = 0
  local start_time, stop_time, time
  local f3_gen = function(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      -- print("malloc for generator for f1f2opf3", a, g_iter)
      first_call = false
      f3_buf = cmem.new(buf_sz, f3_qtype)
      if f1:has_nulls() or f2:has_nulls() then
        nn_f3_buf = nn_f3_buf or cmem.new(qconsts.chunk_size)
      end
    end
    assert(f3_buf)
    local f1_len, f1_chunk, nn_f1_chunk
    local f2_len, f2_chunk, nn_f2_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    f2_len, f2_chunk, nn_f2_chunk = f2:chunk(chunk_idx)
    assert(f1_len == f2_len)
    if f1_len > 0 then
      local chunk1 = ffi.cast( qconsts.qtypes[f1:fldtype()].ctype .. "*",  get_ptr(f1_chunk))
      local chunk2 = ffi.cast( qconsts.qtypes[f2:fldtype()].ctype .. "*",  get_ptr(f2_chunk))
      local chunk3 = ffi.cast( qconsts.qtypes[f3_qtype].ctype .. "*",  get_ptr(f3_buf))

      start_time = qc.get_time_usec()

      qc[func_name](chunk1, chunk2, f1_len, chunk3)

      stop_time = qc.get_time_usec()
      time = stop_time - start_time
      if not _G['g_time'][func_name] then
        _G['g_time'][func_name] = time
      else
        _G['g_time'][func_name] = _G['g_time'][func_name] + time
      end

    else
      f3_buf = nil
      nn_f3_buf = nil
    end
    chunk_idx = chunk_idx + 1
    return f1_len, f3_buf, nn_f3_buf
  end
  return lVector{gen=f3_gen, nn=false, qtype=f3_qtype, has_nulls=false}
end

return expander_f1f2opf3