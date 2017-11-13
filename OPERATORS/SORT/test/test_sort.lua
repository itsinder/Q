-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr'
local tests = {}
tests.t1 = function()
  x = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'I4')
  -- print(type(x))
  -- print(x:length())
  Q.sort(x, "dsc")
  -- Q.print_csv(x, nil, "") 
  local val = Q.max(x):eval()
  for i = 1, x:length() do 
    assert(x:get_one(i-1) == val)
    val = val - Scalar.new(10, "I4")
  end
  print("Test t1 succeeded")
  -- save = require 'Q/UTILS/lua/save'
  -- save('tmp.save')
end
return tests
