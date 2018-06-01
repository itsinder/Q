local lVector = require 'Q/RUNTIME/lua/lVector'
local qc = require 'Q/UTILS/lua/q_core'

local tests = {}

tests.t1 = function()
  -- Test fldtype() and fldtype_new()
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  assert(x:fldtype() == x:fldtype_new())
  print("Successfully completed test t1")
end

tests.t2 = function()
  -- Test is_memo() and is_memo_new()
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  assert(x:is_memo() == x:is_memo_new())
  print("Successfully completed test t2")
end

tests.t3 = function()
  -- Test updated value of is_memo flag using is_memo_new() method
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false})
  x:memo(false)
  assert(x:is_memo_new() == false)
  print("Successfully completed test t3")
end

return tests

