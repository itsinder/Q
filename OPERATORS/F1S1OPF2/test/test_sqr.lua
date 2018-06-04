local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local len = 5
  local input = {}
  for i = 1, len do
    input[i] = i
  end

  local a = Q.mk_col(input, "I4")

  local b = Q.pow(a, 2)
  b:eval()

  Q.print_csv(b)

  -- verify output
  local val, nn_val
  for i = 1, len do
    val, nn_val = b:get_one(i-1)
    assert(val:to_num() == i*i)
  end
  print("DONE")
end

-- testing Q.sqr() for returning correct values
tests.t2 = function()
  local len = 5
  local input = {}
  for i = 1, len do
    input[i] = i
  end
  local a = Q.mk_col(input, "I1")

  local b = Q.sqr(a)
  b:eval()

  Q.print_csv(b)

  -- verify output
  local val, nn_val
  for i = 1, len do
    val, nn_val = b:get_one(i-1)
    assert(val:to_num() == i*i)
  end
  print("DONE")
end
-- TODO: add more tests considering corner cases
return tests
