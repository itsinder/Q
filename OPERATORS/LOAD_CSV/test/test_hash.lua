-- FUNCTIONAL
local Q = require 'Q'
local plpath = require 'pl.path'
local fns = require 'Q/UTILS/lua/utils'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

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
  
  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 
  local col = Q.hash(ret['empid'])
  -- validating row 1 and 7, row 2 and 8
  -- should return same hash for the same SC value
  assert(c_to_txt(col, 1) ==  c_to_txt(col,7))
  assert(c_to_txt(col, 2) == c_to_txt(col,8))
  print("Successfully completed test t1")
end

return tests
