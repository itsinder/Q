local log = require 'log'
require 'utils'
local ffi = require 'ffi'
local Column = require 'Column'
local Dictionary = require "dictionary"
local print_csv = require 'print_csv'

-- I4.bin is a binary file contain 5 I4 digits - 1,2,3,4,5
local column_I4 = Column{field_type="I4", field_size = 4,chunk_size = 5,filename="./bin/I4.bin"}

local arr = { column_I4, column_I4, column_I4 }  
local status,err = pcall(print_csv, arr)
if type(err) == "string" then
  print("final result = "..err)
end
assert(status == true,"Error in print_csv")
log.info("All is well")

-- output will be in the format
-- 1
-- 2
-- and so on
