require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
local dbg     = require 'Q/UTILS/lua/debugger'
local qconsts = require 'Q/UTILS/lua/q_consts'

local T
local x
local len, base_data, nn_data

print("Creating vector with generator")
gen4 = require 'gen4'
x = lVector( { qtype = "I4", gen = gen4, has_nulls = false} )

T = x:meta()
assert(T.base.is_nascent == true)
assert(T.base.open_mode == "NOT_OPEN")

-- for k, v in pairs(T.base)  do print(k,v) end
-- for k, v in pairs(T.aux)  do print(k,v) end

-- print("=========================================")

x:eval()

T = x:meta()
assert(T.base.is_nascent == false)
assert(T.base.open_mode == "NOT_OPEN")
assert(T.base.num_in_chunk == 10)
assert(T.base.chunk_num == 3)

-- for k, v in pairs(T.base)  do print(k,v) end
-- for k, v in pairs(T.aux)  do print(k,v) end

-- print("=========================================")

len, base_data, nn_data = x:chunk(x:chunk_num())
assert(base_data)
assert(len == 10)

T = x:meta()
assert(T.base.is_nascent == false)
assert(T.base.open_mode == "NOT_OPEN")
assert(T.base.num_in_chunk == 10)
assert(T.base.chunk_num == 3)

-- for k, v in pairs(T.base)  do print(k,v) end
-- for k, v in pairs(T.aux)  do print(k,v) end

-- print("=========================================")

-- Call previous chunk
len, base_data, nn_data = x:chunk(0)
assert(base_data)
assert(len == qconsts.chunk_size)

T = x:meta()
assert(T.base.is_nascent == false)
assert(T.base.open_mode == "READ")
assert(T.base.num_in_chunk == 0)
assert(T.base.chunk_num == 0)

-- for k, v in pairs(T.base)  do print(k,v) end
-- for k, v in pairs(T.aux)  do print(k,v) end

-- print("=========================================")

print("Completed ", arg[0])
os.exit()