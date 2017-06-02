  require 'Q/UTILS/lua/globals'
  q = require 'Q/UTILS/lua/q'
  local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'

  local function expander_f1s1opf2(a, x, optargs )
    local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/" .. a .. "_specialize"
    local spfn = assert(require(sp_fn_name))
    assert(type(x) == "Column")
    status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local out_qtype = assert(subs.out_qtype)
    local out_width = g_qtypes[out_qtype].width
    out_width = math.ceil(out_width/8) * 8
    local x_coro = assert(x:wrap(), "wrap failed for x")
    local coro = coroutine.create(function()
      local x_chunk, x_status
      local x_chunk_size = x:chunk_size()
      local buff = q.malloc(x_chunk_size * out_width)
      assert(x:has_nulls() == false, "Not set up for nulls as yet")
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        if x_status then
          assert(x_len > 0)
          q[func_name](x_chunk, x_len, buff)
          coroutine.yield(x_len, buff, nn_buff)
        end
      end
    end)
    return Column{gen=coro, nn=(nn_buf ~= nil), field_type=out_qtype}
  end

  return expander_f1s1opf2
