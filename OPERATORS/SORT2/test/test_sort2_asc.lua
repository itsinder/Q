-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local q_src_root = os.getenv("Q_SRC_ROOT")
local so_dir_path = q_src_root .. "/OPERATORS/SORT2/src/"


-- lua test to check the working of SORT2_ASC operator
local tests = {}
tests.t1 = function ()
  local expected_drag_result = {40, 30, 20, 10, 50 ,60, 70, 80, 90, 100}
  local expected_input_col = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  
  local num_elements = 10
  local qtype = "I4"
  local input_col = Q.mk_col({10, 9, 8, 7, 6, 5, 4, 3, 2, 1}, "I4")
  local input_drag_col = Q.mk_col({100, 90, 80, 70, 60, 50, 10, 20, 30, 40}, "I4")

  local status = Q.qsort2_asc(input_col, input_drag_col, "asc")

  -- Validate the result
  for i = 1, input_drag_col:length() do
    print(input_col:get_one(i-1):to_num(), input_drag_col:get_one(i-1):to_num())
    assert(input_drag_col:get_one(i-1):to_num() == expected_drag_result[i])
    assert(input_col:get_one(i-1):to_num() == expected_input_col[i])
  end
  
  print("Test t1 succeeded")
end

return tests
