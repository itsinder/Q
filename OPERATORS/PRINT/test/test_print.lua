local log = require 'log'
require 'utils'
require 'compile_so'
local ffi = require 'ffi'
local Column = require 'Column'
local Dictionary = require "dictionary"

-- Create libprint_csv.so
local incs = {  "../../../UTILS/inc/", "../../../UTILS/gen_inc/", "../gen_inc/"}
local srcs = {  "../src/SC_to_txt.c", 
          "../gen_src/_I1_to_txt.c",
          "../gen_src/_I2_to_txt.c",
          "../gen_src/_I4_to_txt.c",
          "../gen_src/_I8_to_txt.c",
          "../gen_src/_F4_to_txt.c",
          "../gen_src/_F8_to_txt.c",
          "../../../UTILS/src/is_valid_chars_for_num.c"
       }
         
local tgt = "../obj/libprint_csv.so"
local status = compile_so(incs, srcs, tgt)
assert(status, "compile of .so failed")

-- require print_csv added here because so file needs to be created beforehand
require 'print_csv'

-- I4.bin is a binary file contain 5 I4 digits - 1,2,3,4,5
local column_I4 = Column{field_type="I4", field_size = 4,chunk_size = 5,filename="./bin/I4.bin"}

local arr = {column_I4}  
local status,err = pcall(print_csv, arr)
print(err)
assert(status == true,"Error in print_csv")
log.info("All is well")

-- output will be in the format
-- 1
-- 2
-- and so on