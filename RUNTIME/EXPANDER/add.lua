local dbg = require "debugger"
local ffi = require "ffi"
local mk_col = require 'mk_col'
local print_csv = require 'print_csv'
local ffi_malloc = require 'ffi_malloc'
require 'globals'
g_chunk_size = 1 -- HACK TODO FIX 
function q_wrap(x)
    -- TODO use column
    assert(type(x) == "Column")
    return coroutine.create(function()
            local i = 1
            local status = 0
            while status do
                status, length, chunk, nn_chunk = x:chunk(i)
                if status then
                    coroutine.yield(status, length, chunk, nn_chunk)
                    i = i + 1
                end
            end
        end)
end

f1f2opf3 = {}
f1f2opf3.add = "vvadd_specialize"
f1s1opf2 = {}
f1s1opf2.add = "vsadd_specialize"
-- Done doc pending: specializer must return a function and an out_ctype
-- TODO add to doc
function expander_f1f2opf3(a, x ,y )
    -- Get name of specializer function. By convention
    local spfn = require(a .. "_specialize" )
    -- print(type(fn))
    status, subs, tmpl = pcall(spfn, x:fldtype(), y:fldtype())
    assert(status, subs)
    local type_x
    local func_name = assert(subs.fn)
    local z_ctype = assert(subs.out_ctype)
    local z_qtype = assert(subs.out_qtype)
    local z_width = g_qtypes[z_qtype].width
    -- TODO globals q lib so set once and forget
    -- lib = ffi.load("f1f2opf3.so")
    -- Assuming things are done and we have func_name
    --since this subscribes to the f1f2opf3 pattern we can simmply wrap each of
    --them in a coroutine and be done
    local x_coro = assert(q_wrap(x), "qwrap for x failed")
    local y_coro =  assert(q_wrap(y))
    local gen = coroutine.create(function()
            local x_chunk, y_chunk, x_status, y_status
            local x_chunk_size = 1 -- HACK TODO FIX 
            local y_chunk_size = 1 -- HACK TODO FIX 
            assert(x_chunk_size == y_chunk_size)
            local buff = ffi_malloc(x_chunk_size * z_width)
            local nn_buff = nil -- Will be created if nulls in input
            x_status = true
            while (x_status) do
                x_status, x_len, x_chunk, nn_x_chunk = 
                  coroutine.resume(x_coro)
                y_status, y_len, y_chunk, nn_y_chunk = 
                  coroutine.resume(y_coro)
                if x_status  or y_status then
                    print("x details:", x_status, x_chunk, x_len)
                    print("y details:", y_status, y_chunk, y_len)
                    assert(x_status == y_status)
                    assert(x_len == y_len)
                    assert(x_len > 0)
                    -- print("hey", lib[func_name](x_chunk, y_chunk, x_len, buff))
                    coroutine.yield(x_len, buff, nn_buff)
                end
            end
        end)
    return gen


end

function eval(coro)
    local status = true
    local chunk
    local size
    -- dbg()
    while coroutine.status(coro) ~= "dead" do
        status, size, chunk, nn_chunk = coroutine.resume(coro)
        -- dbg()
        print("XY ", status, size)
        print("resumed")
        if coroutine.status(coro) ~= "dead" then 
            print(status, chunk, size)
        end
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

    if type(x) == "Column" and type(y) == "Column" then
        local status, col = pcall(expander_f1f2opf3, "vvadd", x, y)
        if ( not status ) then print(col) end
        assert(status, "Could not execute vvadd")
        return col
    end
    if type(x) == "Column" and type(y) == "number" then
        local status, col = pcall(expander_f1s1opf2, "vsadd", x, y)
        assert(status, "Could not execute vsadd")
        return col
    end
    assert(false, "Don't know how to expand add")
end

-- local Vector = require 'Vector'
-- local Column = require "Column"
--local size = 1000
--create bin file of only ones of type int
-- local v1 = Vector{field_type='I4', filename='test.bin', }
-- local v2 = Vector{field_type='I4', filename='test.bin', }
local v1 = mk_col( {1,2,3,4,5,6,7,8}, "I4")
local v2 = mk_col( {1,2,3,4,5,6,7,8}, "I4")

-- local chunk, size = v1:chunk(0)
-- for i=1, size do
--    local num = tonumber(ffi.cast("int*", chunk)[i])
--    print(num)
-- end
-- print(v1:chunk(0))
z =  add(add(v1,v2), v1)
-- print(type(z))
eval(z)
print_csv( {z}, nil, "_foo.txt")
