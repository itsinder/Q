local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/PRINT/lua/?.lua"

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

-- testcase for SV data type
-- e1 mapped to 1 , e2 mapped to 2 and so on
_G["Q_DICTIONARIES"] = {} 
local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
dictionary:add_with_condition("e1")
dictionary:add_with_condition("e2")
dictionary:add_with_condition("e3")
dictionary:add_with_condition("e4")
dictionary:add_with_condition("e5")


-- I4.bin is a binary file contain 5 I4 digits - 1,2,3,4,5
local column_I4 = Column{field_type="I4", field_size = 4,chunk_size = 5,filename="./bin/I4.bin"}
local column_SV = Column{field_type="SV", field_size = 4,chunk_size = 5, filename="./bin/I4.bin"}
column_SV:set_meta("dir","D1")

local arr = {column_I4, column_SV}  
local status,err = pcall(print_csv, arr)
assert(status == true,"Error in print_csv")
log.info("All is well")

-- output will be in the format
-- 1,e1
-- 2,e2
-- and so on