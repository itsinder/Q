-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local log = require 'Q/UTILS/lua/log'
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local dir = require 'pl.dir'
local fns = require 'Q/UTILS/lua/utils'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local diff = require 'Q/UTILS/lua/diff'
--local gen = require 'Q/RUNTIME/test/generate_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

local tests = {}

tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta_B1.lua"
  -- no of rows in csv file are 65536 (i.e. equal to chunk_size)
  -- which are of pattern 010101..'s
  --gen.generate_csv("input_file_B1.csv", "B1", 70)
  local csv_file_path = script_dir .."/input_file_B1.csv"
   
  local M = dofile(metadata_file_path)

  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  -- printing the values on terminal
  -- after each 32 bits (elements) it sets bits to 1's
  Q.print_csv(ret[1], nil, "output_file_B1.csv")
  print("Num of elements = "..ret[1]:num_elements())
  
  local diff_status = diff(script_dir .. "/input_file_B1.csv", script_dir .. "/output_file_B1.csv")
  assert(diff_status, "Input and Output csv file not matched")
  
  log.info("All is well")
end

return tests
