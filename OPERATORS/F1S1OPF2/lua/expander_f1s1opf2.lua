  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local qc      = require 'Q/UTILS/lua/q_core'
  local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'
  local is_in   = require 'Q/UTILS/lua/is_in'

  local function expander_f1s1opf2(a, f1, y, optargs )
    local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
    local spfn = assert(require(sp_fn_name))
    assert(f1, "Need to provide vector for"  .. a)
    assert(type(f1) == "Column", 
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
    assert(status, "Specializer " .. sp_fn_name .. " failed")
    local func_name = assert(subs.fn)
    assert(qc[func_name], "Missing symbol " .. func_name)
    local f2_qtype = assert(subs.out_qtype)
    local f2_width = qconsts.qtypes[f2_qtype].width
    local buf_sz = qconsts.chunk_size * f2_width
    local f1_coro = assert(f1:wrap(), "wrap failed for x")
    local f2_buf = assert(ffi.malloc(buf_sz))
    local nn_f2_buf = nil
    if subs.is_safe then
        nn_f2_buf = assert(ffi.malloc(qconsts.chunk_size))
    end
    --============================================
    local f2_coro = coroutine.create(function()
      local status, f1_status, f1_len, f1_chunk, nn_f1_chunk 
      f1_status = true; status = 0
      while (f1_status) do
        f1_status, f1_len, f1_chunk, nn_f1_chunk = coroutine.resume(f1_coro)
        if f1_status and f1_len and f1_len > 0 then 
          status = qc[func_name](f1_chunk, f1_len, subs.c_mem, f2_buf, nn_f2_buf)
          assert(status == 0, ">>>C error" .. func_name .. "<<<<")
          coroutine.yield(f1_len, f2_buf, nn_f2_buf)
        end
      end
    end)
    return Column{gen=f2_coro, nn=false, field_type=f2_qtype}
  end

  return expander_f1s1opf2
