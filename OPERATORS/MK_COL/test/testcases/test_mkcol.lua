-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local plpath = require 'pl.path'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local fns = require 'Q/OPERATORS/MK_COL/test/testcases/handle_category'
local utils = require 'Q/UTILS/lua/utils'


-- loop through testcases
-- these testcases output error messages
local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local T = dofile(script_dir .."/map_mkcol.lua")
for i, v in ipairs(T) do
  if arg[1] and i ~= tonumber(arg[1]) then 
    goto skip 
  end
  
  print("--------------------------------")
  print("Running testcase " .. v.testcase_no ..": ".. v.name)
  local input = v.input
  local qtype = v.qtype
  local result
  
  local status, ret = pcall(mk_col,input,qtype)
  if fns[v.category] then
    result= fns[v.category](i, v, status, ret)
  else
    fns["increment_failed_mkcol"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
    result = false
  end
  utils["testcase_results"](v, "Mk_col", "Unit Test", result, "")
  ::skip::
end

fns["print_result"]()
require('Q/UTILS/lua/cleanup')()
os.exit()
