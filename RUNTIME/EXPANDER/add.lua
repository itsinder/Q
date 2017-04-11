local ffi = require "ffi"
function q_wrap(x)
    -- TODO use column
    assert(type(x) == "Vector")
    return coroutine.create(function()
            local i = 1
            local status = 0
            while status do
                status, chunk, length = x:chunk(i)
                if status then
                    coroutine.yield(status, chunk, length)
                    i = i + 1
                end
            end
            return -1
        end)
end

f1f2opf3 = {}
f1f2opf3.add = "vvadd_specialize"
-- TODO specializer must return a function and an out_c_type
-- 
function expander_f1f2opf3(a, x ,y )
    -- type checking
    status, subs, tmpl = pcall(f1f2opf3.a, x:fldtype(), y:fldtype())
    assert(status)
    local type_x
    local func_name = assert(subs.fn)
    local z_type = assert(subs.out_c_type) --TODO fix to out_type in all specialize
    -- Assuming things are done and we have func_name
    --since this subscribes to the f1f2opf3 pattern we can simmply wrap each of
    --them in a coroutine and be done
    local x_coro = q_wrap(x)
    local y_coro =  q_wrap(y)
    local gen = coroutine.create(function()
            local x_chunk, y_chunk, status
            assert(x:get_chunk_size() == y:get_chunk_size())
            local buff = ffi.malloc(x:get_chunk_size() * ffi.sizeof(z_type)) -- ffi.malloc
            while (x_status) do
                x_status, x_chunk, x_len = x_coro.resume()
                y_status, y_chunk, y_len = y_coro.resume()
                if x_status  or y_status then
                    assert(x_status == y_status)
                    assert(x_len == y_len)
                    assert(x_len > 0)
                    assert(func_name(x_chunk, y_chunk, x_len, buff))
                    coroutine.yield(buff, x_len)
                end
            end
            return -1
        end)



end

function eval(vec)
    local status = 0 
    local chunk, size
    local i = 1
    while status do 
        status, chunk, size = vec:chunk(i)
        i = i + 1
    end
end

function add(x, y)
    if type(x) == "Vector" and type(y) == "Vector" then
        status, col = pcall(expander_f1f2opf3, "add", x, y)
        assert(status)
        return col
    elseif type(x) == "Vector" and type(y) == "number" then
        
    else
        assert(false)
    end
end
