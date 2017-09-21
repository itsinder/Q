local log = require 'Q/UTILS/lua/log'
local Column = require 'Q/RUNTIME/lua/lVector'
local print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'

-- I4.bin is a binary file contain 5 I4 digits - 1,2,3,4,5
local column_I4 = Column({ qtype = "I4", file_name = "./bin/I4.bin"})
local arr = { column_I4, column_I4, column_I4 }  
local status, err = pcall(print_csv, arr)
assert(status == true,"Error in print_csv")
<<<<<<< HEAD
print("final result = \n"..err)
=======
print("final result:\n"..err)
>>>>>>> 623b72aa89c871d2d2e861141e3bfecaf20a1fe7
log.info("All is well")
column_I4:persist(true)
-- output will be in the format
-- 1
-- 2
-- and so on
