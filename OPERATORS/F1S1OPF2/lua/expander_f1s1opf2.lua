  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qc      = require 'Q/UTILS/lua/q_core'
  local lVector = require 'Q/RUNTIME/lua/lVector'
  local is_in   = require 'Q/UTILS/lua/is_in'
  local cmem	= require 'libcmem'
  local get_ptr = require 'Q/UTILS/lua/get_ptr'
  local record_time = require 'Q/UTILS/lua/record_time'
  local to_scalar   = require 'Q/UTILS/lua/to_scalar'
  
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
    if ( y ) and type(y) ~= "string" then 
      --y not defined if no scalar like in incr, decr, exp, log
      -- expecting y of type scalar, if not converting to scalar
      y = assert(to_scalar(y, f1:fldtype()), "y should be a Scalar or number")
    end
    -- following useful for cum_count
    if ( f1:is_eov() ) then optargs.in_nR = f1:length() end
    --==   Special case of no-op for convert 
    if ( ( a == "convert" ) and ( f1:fldtype() == y ) ) then
      return f1
    end
    local status, subs, tmpl = pcall(spfn, f1:fldtype(), y, optargs)
    if not status then print(subs) end
    assert(status, "Specializer " .. sp_fn_name .. " failed")
    local func_name = assert(subs.fn)
    assert(qc[func_name], "Missing symbol " .. func_name)
    local f2_qtype = assert(subs.out_qtype)
    local f2_width = qconsts.qtypes[f2_qtype].width
    if f2_qtype == "B1" then f2_width = 1 end -- over count okay
    local buf_sz = qconsts.chunk_size * f2_width
    local f2_buf    = nil
    local nn_f2_buf = nil
    local has_nulls  
    if subs.is_safe then
      has_nulls = true
    else
      has_nulls = false
    end
    local chunk_idx = 0
    --============================================
    local f2_gen = function(chunk_num)
      -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
      assert(chunk_num == chunk_idx)
      f2_buf = f2_buf or cmem.new(buf_sz, f2_qtype)
      assert(f2_buf)
      if not nn_f2_buf and has_nulls then 
        nn_f2_buf = cmem.new(qconsts.chunk_size)
        assert(nn_f2_buf)
        ffi.memset(get_ptr(nn_f2_buf), 0, qconsts.chunk_size)
      end
      -- print(sp_fn_name .. " requesting " .. chunk_idx)
      local f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
      if f1_len > 0 then  
        local casted_f1_chunk = ffi.cast(qconsts.qtypes[subs.in_qtype].ctype .. "*" ,get_ptr(f1_chunk))
        local casted_nn_f1_chunk = ffi.cast(qconsts.qtypes['B1'].ctype .. "*", get_ptr(nn_f1_chunk))
        local casted_ptr_sval = ffi.cast(qconsts.qtypes[f1:fldtype()].ctype .. "*" ,get_ptr(subs.c_mem))
        local casted_f2_buf = ffi.cast(qconsts.qtypes[subs.out_qtype].ctype .. "*", get_ptr(f2_buf))
        local casted_nn_f2_buf = ffi.cast(qconsts.qtypes['B1'].ctype .. "*", get_ptr(nn_f2_buf))
        local start_time = qc.RDTSC()
        qc[func_name](casted_f1_chunk, casted_nn_f1_chunk, f1_len, casted_ptr_sval, casted_f2_buf, casted_nn_f2_buf)
        record_time(start_time, func_name)
      end
      chunk_idx = chunk_idx + 1
      return f1_len, f2_buf, nn_f2_buf
    end
    
    return lVector{gen=f2_gen, has_nulls=has_nulls, qtype=f2_qtype}
  end

  return expander_f1s1opf2
