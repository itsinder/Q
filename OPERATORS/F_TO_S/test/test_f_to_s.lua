local dbg = require "debugger"
local ffi = require "ffi"
local mk_col = require 'mk_col'
local print_csv = require 'print_csv'
local q_core = require 'q_core'
local Column = require "Column"
local q = require "q"
require 'globals'
assert(nil, "TO BE COMPLETED")
X = require '_f_to_s'
require 'expander_f_to_s'


function eval(col)
    local chunk
    local size = 1 
    -- dbg()
    local chunk_num = 0 
    while size ~= 0  do
        size, chunk, nn_chunk = col:chunk(chunk_num)
        -- dbg()
        -- print("XY ", size)
        -- print("resumed")
        if size > 0  then 
            chunk_num = chunk_num + 1
            print(size, chunk, nn_chunk)
            local iter = q_core.cast("int*", chunk) -- TODO make general
            for i=1,size do 
                print(tonumber(iter[i-1]))
            end
        end
    end
end
local c1 = mk_col( {1,2,3,4,5,6,7,8}, "I4")
local c2 = mk_col( {8,7,6,5,4,3,2,1}, "I4")
print("---------------------------")
z = X.vvadd(c1, c2, "junk")
eval(z)
print_csv( {z}, nil, "")
os.exit()
