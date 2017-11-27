-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local plpath = require 'pl.path'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local fns = require 'Q/OPERATORS/MK_COL/test/testcases/handle_category'
local utils = require 'Q/UTILS/lua/utils'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/MK_COL/test/testcases" 
local T = dofile(script_dir .."/map_mkcol.lua")

local test_mkcol = {}

for i, v in ipairs(T) do
  assert(v.testcase_no,"Specify testcase_no in map file for '" .. v.name .. "' testcase")
  
  -- testcase number which is entered in map file is an index into test_load table 
  -- which acts as an identifier for the test cases in this test suite.
  test_mkcol[v.testcase_no] = function()
    print("Running testcase " .. v.testcase_no .. ": " .. v.name)
    local input = v.input
    local qtype = v.qtype
    local result
    
    local status, ret = pcall(mk_col,input,qtype)
    if fns[v.category] then
      result = fns[v.category](i, v, status, ret)
      utils["testcase_results"](v, "Mk_col", "Unit Test", result, "")
      assert(result,"handle " .. v.category .. " assertions failed")
    else
      fns["increment_failed_mkcol"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
      utils["testcase_results"](v, "Mk_col", "Unit Test", false, "")
      assert(fns[v.category], "handle category is not defined in handle_category_print.lua file") 
    end
  end
end

return test_mkcol
