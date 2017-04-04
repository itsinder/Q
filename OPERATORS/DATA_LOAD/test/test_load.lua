local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
package.path = package.path.. ";" .. rootdir .. "/Q2/code/?.lua"
package.path = package.path.. ";" .. rootdir .. "/OPERATORS/DATA_LOAD/lua/?.lua"

local log = require 'log'
local plpath = require 'pl.path'
require 'utils'
require 'compile_so'

local ffi = require 'ffi'
-- Create libload_csv.so
local incs = {  "../../../UTILS/inc/", "../../../UTILS/gen_inc/", "../gen_inc/"}
local srcs = {  "../src/get_cell.c",
          "../src/txt_to_SC.c", 
          "../gen_src/_txt_to_I1.c",
          "../gen_src/_txt_to_I2.c",
          "../gen_src/_txt_to_I4.c",
          "../gen_src/_txt_to_I8.c",
          "../gen_src/_txt_to_F4.c",
          "../gen_src/_txt_to_F8.c",
          "../../../UTILS/src/is_valid_chars_for_num.c",
          "../../../UTILS/src/f_mmap.c",
          "../../../UTILS/src/f_munmap.c"
       }    
         
local tgt = "../obj/libload_csv.so"
local status = compile_so(incs, srcs, tgt)
assert(status, "compile of .so failed")

require 'load_csv'
local Column = require 'Column'

assert( #arg == 2 , "Arguments are <metadata_file_path> <csv_file_path>")
local metadata_file_path = arg[1]
local csv_file_path = arg[2]
assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
 
local M = dofile(metadata_file_path)
preprocess_bool_values(M, "has_nulls", "dict_exists", "add")

-- set default values for globals
_G["Q_DATA_DIR"] = "./out/"     
_G["Q_META_DATA_DIR"] = "./metadata/"
_G["Q_DICTIONARIES"] = {}

-- call load function to load the data
local status, ret = pcall(load_csv, csv_file_path, M )
assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 

log.info("All is well")