-- FUNCTIONAL
local Q = require 'Q'
local plpath = require 'pl.path'
local fns = require 'Q/UTILS/lua/utils'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local utils = require 'Q/UTILS/lua/utils'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/HASH/test"

local tests = {}

-- checking of the Q.hash operator to accept vector as input(of type "SC") 
-- and return hash value vector as output(of type "I8") 
tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta_hash.lua" 
  local csv_file_path = script_dir .."/test_hash.csv"

  assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
  assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
   
  local M = dofile(metadata_file_path)
  fns["preprocess_bool_values"](M, "has_nulls", "is_dict", "add")
  
  -- call to load function to create SC column
  local status, ret = pcall(Q.load_csv, csv_file_path, M )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  -- call to hash function which returns I8 column
  local I8_col = Q.hash(ret['empid'])
  assert(I8_col)
  assert(I8_col:length()== ret['empid']:length())
  -- validating row 1 and 7, row 2 and 8
  -- should return same hash for the same SC value
  assert(c_to_txt(I8_col, 1) == c_to_txt(I8_col,7))
  assert(c_to_txt(I8_col, 2) == c_to_txt(I8_col,8))
  Q.print_csv(I8_col)
  print("Successfully completed test t1")
end

return tests
