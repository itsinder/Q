require 'Q/UTILS/lua/globals'
q = require 'Q/UTILS/lua/q'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
-- TODO doc pending: specializer must return a function and an out_qtype
local function expander_f1f2opf3(a, x , y, optargs )
    -- Get name of specializer function. By convention
    local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. a .. "_specialize"
    local spfn = require(sp_fn_name)
    status, subs, tmpl = pcall(spfn, x:fldtype(), y:fldtype())
    assert(status, subs)
    local func_name = assert(subs.fn)
    local z_qtype = assert(subs.out_qtype)
    local z_width = g_qtypes[z_qtype].width
    z_width = math.ceil(z_width/8) * 8
    local x_coro = assert(x:wrap(), "wrap failed for x")
    local y_coro = assert(y:wrap(), "wrap failed for y")
    local coro = coroutine.create(function()
            local x_chunk, y_chunk, x_status, y_status
            local x_chunk_size = x:chunk_size()
            local y_chunk_size = y:chunk_size()
            assert(x_chunk_size == y_chunk_size)
            local buff = q.malloc(x_chunk_size * z_width)
            local nn_buff = nil -- Will be created if nulls in input
            if x:has_nulls() or y:has_nulls() then
                local width = g_qtypes["B1"].width
                local size = math.ceil(width/8) * 8
                nn_buff = q.malloc(size)
            end
            x_status = true
            while (x_status) do
                x_status, x_len, x_chunk, nn_x_chunk = coroutine.resume(x_coro)
                y_status, y_len, y_chunk, nn_y_chunk = coroutine.resume(y_coro)
                assert(x_status == y_status)
                if x_status then
                    -- print("x details:", x_status, x_chunk, x_len)
                    -- print("y details:", y_status, y_chunk, y_len)
                    assert(x_len == y_len)
                    assert(x_len > 0)
                    q[func_name](x_chunk, y_chunk, x_len, buff)
                    coroutine.yield(x_len, buff, nn_buff)
                  end
            end
        end)
    return Column{gen=coro, nn=(nn_buf ~= nil), field_type=z_qtype}
end

return expander_f1f2opf3
