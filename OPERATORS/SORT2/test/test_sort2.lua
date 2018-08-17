-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local q_src_root = os.getenv("Q_SRC_ROOT")
local so_dir_path = q_src_root .. "/OPERATORS/SORT2/src/"

local tests = {}

-- lua test to check the working of SORT2 in asc order
tests.t1 = function ()
  local expected_drag_result = {40, 30, 20, 10, 50 ,60, 70, 80, 90, 100}
  local expected_input_col = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  
  local qtype = "I4"
  local input_col = Q.mk_col({10, 9, 8, 7, 6, 5, 4, 3, 2, 1}, "I4")
  local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 10, 20, 30, 40}, "I4")

  local status = Q.sort2(input_col, input_drag_col, "asc")

  -- Validate the result
  for i = 1, input_drag_col:length() do
    print(input_col:get_one(i-1):to_num(), input_drag_col:get_one(i-1):to_num())
    assert(input_drag_col:get_one(i-1):to_num() == expected_drag_result[i])
    assert(input_col:get_one(i-1):to_num() == expected_input_col[i])
  end
  
  print("Test t1 succeeded")
end

-- lua test to check the working of SORT2 in dsc order
tests.t2 = function ()
  local expected_drag_result = {30, 40, 20, 10, 60 , 50, 80, 70, 90, 100}
  local expected_input_col = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1}

  local qtype = "I4"
  local input_col = Q.mk_col({1, 2, 4, 3, 6, 5, 7, 8, 10, 9}, "I4")
  local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 10, 20, 30, 40}, "I4")

  local status = Q.sort2(input_col, input_drag_col, "dsc")

  -- Validate the result
  for i = 1, input_drag_col:length() do
    print(input_col:get_one(i-1):to_num(), input_drag_col:get_one(i-1):to_num())
    assert(input_drag_col:get_one(i-1):to_num() == expected_drag_result[i])
    assert(input_col:get_one(i-1):to_num() == expected_input_col[i])
  end

  print("Test t2 succeeded")
end

return tests
