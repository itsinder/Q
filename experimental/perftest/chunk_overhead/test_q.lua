local Q = require 'Q'
-- local dbg = require 'Q/UTILS/lua/debugger'
local timeit = require 'Q/UTILS/lua/utils'["timeit"]
local filenm = arg[1]
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local col = Column{field_type='I4', filename=filenm,}
local z = Q.vvadd(col,col, {junk = "junk"})
print(timeit(z.eval, z ))


