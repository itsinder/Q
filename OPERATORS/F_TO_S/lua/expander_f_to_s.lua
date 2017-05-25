require 'globals'
local Column = require 'Column'
local dbg = require 'debugger'

assert(nil, "WORK IN PROGRESS")

function expander_f_to_s(a, x , y, optargs )
    -- Get name of specializer function. By convention
    local spfn = require(a .. "_specialize" )
    status, subs, tmpl = pcall(spfn, x:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local z_qtype = assert(subs.out_qtype
    local z_width = g_qtypes[z_qtype].width
    z_width = math.ceil(z_width/8) * 8
    local x_coro = assert(x:wrap(), "wrap failed for x")
    local y_coro = assert(y:wrap(), "wrap failed for y")
    local coro = coroutine.create(function()
      local x_chunk, y_chunk, x_status, y_status
      local x_chunk_size = x:chunk_size()
      local y_chunk_size = y:chunk_size()
      assert(x_chunk_size == y_chunk_size)
      local buff = q_core.malloc(x_chunk_size * z_width)
      local nn_buff = nil -- Will be created if nulls in input
      if x:has_nulls() or y:has_nulls() then
        local width = g_qtypes["B1"].width
        local size = ceil(width/8) * 8
        nn_buff = q_core.malloc(size)
      end
      x_status = true
      while (x_status) do
        x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
        y_status, y_len, y_chunk, nn_y_chunk = coroutine.resume(y_coro)
        assert(x_status == y_status)
        if x_status then
          print("x details:", x_status, x_chunk, x_len)
          print("y details:", y_status, y_chunk, y_len)
          assert(x_len == y_len)
          assert(x_len > 0)
          q[func_name](x_chunk, y_chunk, x_len, buff) 
          coroutine.yield(x_len, buff, nn_buff)
        end
      end
    end)
    print("================")
    return Column{gen=coro, nn=(nn_buf ~= nil), field_type=z_qtype}
end

