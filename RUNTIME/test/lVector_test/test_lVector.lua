local plpath  = require 'pl.path'
local dir = require 'pl.dir'
local qconsts = require 'Q/UTILS/lua/q_consts'
local fns =  require 'Q/RUNTIME/test/lVector_test/assert_valid'
local genbin = require 'Q/RUNTIME/test/generate_bin'
local l_Vector = require 'Q/RUNTIME/test/lVector_test/l_Vector'
local utils = require 'Q/UTILS/lua/utils'
local plfile  = require 'pl.file'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/RUNTIME/test/lVector_test"
dir.makepath(script_dir .."/bin/")

local all_qtype = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8', 'SC', 'SV' }

-- for calling respective validating functions for each testcase
local assert_valid = function(res, map_index, qtype)
  -- calling the assert function based on type of vector
  local function_name = "assert_" .. map_index.assert_fns
  local status, fail_msg = pcall(fns[function_name], res, map_index.name .. qtype, map_index.num_elements, map_index.gen_method)
  if not status then 
    return status, fail_msg
  end
  if map_index.test_category == "error_testcase_1" then 
    print("STOP : Deliberate error attempt")
  end
  return status
end


local gather_test_meta_data = function(map_index, qtype)
  assert(map_index.meta, "Provide metadata filename required for vector in map_file ")
  local M = dofile(script_dir .."/meta_data/"..map_index.meta)
  
  if map_index.test_type == "materialized_vector" then
    local bin_file_name
    -- if "${q_type}" = positive testcase: they want input .bin file to be generated
    -- else negative testcase: dont want input .bin file to be generated
    if string.match( M.file_name,"${q_type}" ) then
      bin_file_name = script_dir.."/bin/in_" .. qtype .. ".bin"
      -- generating .bin files required for materialized vector
      genbin.generate_bin(map_index.num_elements, qtype, bin_file_name, "random" )
      -- for .bin file
      M.file_name = bin_file_name
      -- for .nn bin file
      if M.nn_file_name then
        M.nn_file_name = script_dir .. "/" .. M.nn_file_name
      end
    end
  end
    
  M.qtype = qtype
  assert(map_index.num_elements, "Provide number of elements in map_file")
  M.num_elements = map_index.num_elements
return M
end

local test_lVector = {}

local T = dofile(script_dir .."/map_lVector.lua")
local testcase_no = 1

for i, map_index in ipairs(T) do
  local qtype
  if map_index.qtype then qtype = map_index.qtype else qtype = all_qtype end
  for j in pairs(qtype) do
    -- creating individual test-case as an entry in test_lVector 
    test_lVector[testcase_no] = function()
      map_index.name = map_index.name .. "_" .. qtype[j]
      local M = gather_test_meta_data(map_index, qtype[j])
     
      -- print messages for negative testcases
      if map_index.test_category == "error_testcase_1" or map_index.test_category == "error_testcase_2" then 
        print("START: Deliberate error attempt")
      end
      
      local status, res = pcall(l_Vector, M)
      if map_index.test_category == "error_testcase_2" then
        print("STOP : Deliberate error attempt")
      end
      local result, reason
      
      if status then
        result, reason = assert_valid(res, map_index, qtype[j])
        -- preamble
        utils["testcase_results"](map_index, "lVector", "Unit Test", result, "")
        if reason ~= nil then
          assert(result,"test name:" .. map_index.name .. ":: Reason: " .. reason)
        end
        assert(result,"test name:" .. map_index.name)
      else      
        -- preamble
        utils["testcase_results"](v, "lVector", "Unit Test", status, "")
        if res ~= nil then
          assert(status,"test name:" .. map_index.name .. ":: Reason: " .. res)
        end
        assert(status,"test name:" .. map_index.name)
      end
    end 
    testcase_no = testcase_no + 1
  end
end

return test_lVector
