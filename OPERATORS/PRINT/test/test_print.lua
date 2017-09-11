local log = require 'Q/UTILS/lua/log'
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'

-- I4.bin is a binary file contain 5 I4 digits - 1,2,3,4,5
local column_I4 = Column{field_type="I4",chunk_size = 5,filename="./bin/I4.bin"}

local arr = { column_I4, column_I4, column_I4 }  
local status,err = pcall(print_csv, arr)
assert(status == true,"Error in print_csv")
print("final result = \n"..err)
log.info("All is well")

-- output will be in the format
-- 1
-- 2
-- and so on
