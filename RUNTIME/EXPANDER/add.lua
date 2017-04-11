local dbg = require "debugger"
local ffi = require "ffi"
require("vvadd_specialize")
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
f1s1opf2 = {}
f1s1opf2.add = "vsadd_specialize"
-- Done doc pending: specializer must return a function and an out_c_type
-- TODO add to doc 
function expander_f1f2opf3(a, x ,y )
    -- type checking
    local fn = _G[f1f2opf3[a]]
    -- print(type(fn))
    status, subs, tmpl = pcall(fn, x:fldtype(), y:fldtype())
    assert(status, subs)
    local type_x
    local func_name = assert(subs.fn)
    local z_type = assert(subs.out_c_type)
    -- TODO globals q lib so set once and forget
    -- lib = ffi.load("f1f2opf3.so")
    -- Assuming things are done and we have func_name
    --since this subscribes to the f1f2opf3 pattern we can simmply wrap each of
    --them in a coroutine and be done
    local x_coro = assert(q_wrap(x))
    local y_coro =  assert(q_wrap(y))
    local gen = coroutine.create(function()
            local x_chunk, y_chunk, x_status, y_status
            local x_chunk_size = 64 -- TODO change in vector class to get chunk size
            local y_chunk_size = 64
            assert(x_chunk_size == y_chunk_size)
            local buff = ffi.gc(ffi.C.malloc(x_chunk_size * ffi.sizeof(z_type)), ffi.C.free) -- ffi.malloc
            x_status = true
            while (x_status) do
                x_status, x_chunk, x_len = coroutine.resume(x_coro)
                print("x details:", x_status, x_chunk, x_len)
                y_status, y_chunk, y_len = coroutine.resume(y_coro)
                print("y details:", y_status, y_chunk, y_len)
                if x_status  or y_status then
                    assert(x_status == y_status)
                    assert(x_len == y_len)
                    assert(x_len > 0)
                    assert(lib[func_name](x_chunk, y_chunk, x_len, buff))
                    coroutine.yield(buff, x_len)
                end
            end
            return -1
        end)
      return gen


end

function eval(coro)
   local status = true
   local chunk
   local size
   while status do
      status, chunk, size = coroutine.resume(coro)
   print(status, chunk, size)
   end
end
-- function eval(vec)
--     local status = 0 
--     local chunk, size
--     local i = 1
--     while status do 
--         status, chunk, size = vec:chunk(i)
--         i = i + 1
--     end
-- end

function add(x, y)
    
   if type(x) == "Vector" and type(y) == "Vector" then
        status, col = pcall(expander_f1f2opf3, "add", x, y)
        assert(status, col)
        return col
    elseif type(x) == "Vector" and type(y) == "number" then
        status, col = pcall(expander_f1s1opf2, "add", x, y)
        assert(status, col)
        return col

    else
        assert(false)
    end
end

local Vector = require 'Vector'
local Column = require "Column"
--local size = 1000
--create bin file of only ones of type int
local v1 = Vector{field_type='I4',
filename='test.txt', }
local v2 = Vector{field_type='I4',
filename='test.txt', }

-- local chunk, size = v1:chunk(0)
-- for i=1, size do
--    local num = tonumber(ffi.cast("int*", chunk)[i])
--    print(num)
-- end
-- print(v1:chunk(0))
z =  add(v1,v2)
-- print(type(z))
eval(z)
