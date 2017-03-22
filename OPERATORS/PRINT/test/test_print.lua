
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/PRINT/lua/?.lua"

local pl  = require 'pl'
local log = require 'log'
require 'utils'
require 'globals'
require 'compile_so'
require 'extract_fn_proto'
require 'print_csv'
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

_G["Q_DICTIONARIES"] = {} 
local dictionary = Dictionary({dict = "D1", is_dict = false, add=true})
dictionary:add_with_condition("e1")
dictionary:add_with_condition("e2")
dictionary:add_with_condition("e3")
dictionary:add_with_condition("e4")
dictionary:add_with_condition("e5")

local column = Column{field_type="I4", field_size = 4,chunk_size = 5,filename="./bin/I4.bin"}
local column_SV = Column{field_type="SV", field_size = 4,chunk_size = 5, filename="./bin/I4.bin"}
column_SV:set_meta("dir","D1")

local arr = {column, column_SV}  
print_csv(arr)

log.info("All is well")



