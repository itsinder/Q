  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qc      = require 'Q/UTILS/lua/q_core'
  local lVector = require 'Q/RUNTIME/lua/lVector'
  local is_in   = require 'Q/UTILS/lua/is_in'

  local function expander_f1s1opf2(a, f1, y, optargs )
    local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
    local spfn = assert(require(sp_fn_name))
    assert(f1, "Need to provide vector for"  .. a)
    assert(type(f1) == "lVector", 
    "first argument for " .. a .. "should be vector")
    assert(f1:has_nulls() == false, "Not set up for nulls as yet")
    if ( optargs ) then 
      assert(type(optargs) == "table")
    end
    if ( y ) then 
      --y not defined if no scalar like in incr, decr, exp, log
      local ytype = type(y)
      assert(is_in(ytype, {"table", "number", "string"}), 
        "scalar must be table/string/number")
    end
    local status, subs, tmpl = pcall(spfn, f1:fldtype(), y)
    if not status then print(subs) end
    assert(status, "Specializer " .. sp_fn_name .. " failed")
    local func_name = assert(subs.fn)
    assert(qc[func_name], "Missing symbol " .. func_name)
    local f2_qtype = assert(subs.out_qtype)
    local f2_width = qconsts.qtypes[f2_qtype].width
    local buf_sz = qconsts.chunk_size * f2_width
    local f2_buf = assert(ffi.malloc(buf_sz))
    local nn_f2_buf = nil
    local has_nulls  
    if subs.is_safe then
      has_nulls = true
      nn_f2_buf = assert(ffi.malloc(qconsts.chunk_size))
      ffi.memset(nn_f2_buf, 0, qconsts.chunk_size)
    else
      has_nulls = false
    end
    --============================================
    local f2_gen = function(chunk_idx)
      local f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
      if f1_len > 0 then
        qc[func_name](f1_chunk, nn_f1_chunk, f1_len, subs.c_mem, f2_buf, nn_f2_buf)
      end
      return f1_len, f2_buf, nn_f2_buf
    end
    
    return lVector{gen=f2_gen, has_nulls=has_nulls, qtype=f2_qtype}
  end

  return expander_f1s1opf2
