-- PERFORMANCE

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local plpath = require 'pl.path'
local dir = require 'pl.dir'
local fns = require 'Q/OPERATORS/LOAD_CSV/test/performance_testing/gen_csv_metadata_file'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local utils = require 'Q/UTILS/lua/utils'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
-- file in which performance testing results for each csv file is written
local performance_file = script_dir .."/performance_results/performance_measures.txt"
local meta_info_dir_path = script_dir .."/meta_info/"

dir.makepath(script_dir .."/performance_results/")

-- opening the performance result file
local filep = assert(io.open(performance_file, 'a')) -- append mode so that all testcases writes their result in this file
local date = os.date("%d.%m.%Y")
filep:write("Performance testing results on: "..date.."\n")
filep:write("Rows \t Columns \t Testcase \t\t\t Execution time(in secs) \t Time \n")
filep:close()


local T = dofile(script_dir .."/map_meta_info_data.lua")
for i, v in ipairs(T) do
  
  -- _G["Q_DICTIONARIES"] = {}
  filep = assert(io.open(performance_file, 'a')) -- append mode so that all testcases writes their result in this file
  print("Testing "..v.name)
  
  local M = dofile(meta_info_dir_path..v.meta_info)
  
  -- generating maximum dictionary size unique strings
  local unique_string_tables = fns["generate_unique_varchar_strings"](M)
  -- generate metadata table which is to be passed to load csv
  local metadata_table = fns["generate_metadata"](M)
  
  local csv_file_path = v.data -- taking csv file name from map_meta_info_data file
  if not plpath.isabs(v.data) then
    csv_file_path = script_dir .."/".. csv_file_path
  end
  local row_count = v.row_count  -- no of rows you wish to enter
  local chunk_print_size = v.chunk_print_size  -- writing data into files as chunks(i.e. chunk size)
  
  --need to provide csv_file_name, columns_list, no_of_rows, chunk_print_size and unique_str_table(if varchar column exists)
  fns["generate_csv_file"](csv_file_path, metadata_table, row_count, chunk_print_size,unique_string_tables)
  
  --checking execution time required for load_csv function
  local start_time = os.time()
  local ret = load_csv(csv_file_path, metadata_table)
  local end_time = os.time()
  local date = (os.date ("%r")) 
  
  -- writing results in performance_result file
  filep:write(string.format("%d \t %d \t\t\t %s \t\t\t %.2f secs \t\t\t\t\t\t\t %s \n", row_count, #metadata_table, v.name, end_time-start_time, date))
  
  -- calling standard output function
  local result
  if type(ret) == "table" then result = true else result = false end
  utils["testcase_results"](v, "test_performance.lua", "Load_csv Performance Testing", "Performance Testing", result, "")
  
  -- delete respective csv file
  os.remove(csv_file_path) 
  
  print("Results written in performance_results file\n")
  print("--------------------------------------------")
  filep:close()
  
end  

require('Q/UTILS/lua/cleanup')()
os.exit()
-- clear the output directory 
-- dir.rmtree(_G["Q_DATA_DIR"])
-- dir.rmtree(_G["Q_META_DATA_DIR"])
