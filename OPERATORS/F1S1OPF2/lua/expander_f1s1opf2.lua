  local qconsts = require 'Q/UTILS/lua/q_consts'
  local ffi     = require 'Q/UTILS/lua/q_ffi'
  local Column  = require 'Q/RUNTIME/COLUMN/code/lua/Column'

  local function expander_f1s1opf2(a, x, y, optargs )
    local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
    local spfn = assert(require(sp_fn_name))
    assert( type(x) == "Column") 
    ytype = type(Column)
    assert( ( ytype == "table" ) or ( ytype == "string" ) or ( ytype == "number" ), "scalar must be table/string/number")
    status, subs, tmpl = pcall(spfn, x:fldtype(), y)
    assert(status, subs)
    local func_name = assert(subs.fn)
    local out_qtype = assert(subs.out_qtype)
    local out_width = g_qtypes[out_qtype].width
    local out_ctype = g_qtypes[out_qtype].ctype
    out_width = math.ceil(out_width/8) * 8
    -- TODO Where best to do malloc for buff?
    local f1_coro = assert(x:wrap(), "wrap failed for x")
    local f2_coro = coroutine.create(function()
      local x_chunk, x_status
      local buff = ffi.malloc(x:chunk_size() * out_width)
      -- TODO Not needed I think buff = ffi.cast(out_ctype .. " * ", buff)
      assert(x:has_nulls() == true, "Not set up for nulls as yet")
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(f1_coro)
        if x_status then
          assert(x_len > 0)
          q[func_name](x_chunk, x_len, subs.c_mem, buff)
          coroutine.yield(x_len, buff, nil)
        end
      end
    end)
    return Column{gen=f2_coro, nn=(nn_buf ~= nil), field_type=out_qtype}
  end

  return expander_f1s1opf2
