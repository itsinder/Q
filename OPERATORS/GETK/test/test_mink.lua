local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local col = Q.mk_col({1, 5, 4, 2, 3, 7, 9}, "I4")
  local res = Q.mink(col, 3)
  local exp_col = Q.mk_col({1, 2, 3}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t1")
end

tests.t2 = function()
  -- vector with more than chunk size values
  local len = 65536*2 + 45
  local col = Q.rand( { lb = 100, ub = 200, qtype = "I4", len = len })
  local res = Q.mink(col, 3)
  Q.print_csv(res)
  print("successfully completed t2")
end

tests.t3 = function()
  -- vector having repeated min values
  local col = Q.mk_col({1, 2, 4, 2, 3, 7, 9}, "I4")
  local res = Q.mink(col, 3)
  local exp_col = Q.mk_col({1, 2, 2}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t3")
end

tests.t4 = function()
  -- vector having more than chunk size values, min value appears in second chunk
  local len = 65536 + 45
  local in_table = {}
  for i = 1, len do
    in_table[i] = i
  end
  -- place min value in second chunk
  in_table[65536 + 5] = 3
  in_table[3] = 567

  local col = Q.mk_col(in_table, "I4")
  local res = Q.mink(col, 3)
  Q.print_csv(res)
  local exp_col = Q.mk_col({1, 2, 3}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t4")
end

-- test mink_reducer
tests.t5 = function()
  local val = Q.mk_col({1, 5, 4, 2, 3, 7, 9}, "I4")
  local drag = Q.mk_col({0, 1, 1, 1, 0, 0, 0}, "I4")
  local res = Q.mink_reducer(val, drag, 3)
  local val_k, drag_k = res:eval()
  print("========================")
  for i, v in ipairs(val_k) do
    print(val_k[i], drag_k[i])
  end
  os.exit()
  local exp_col = Q.mk_col({1, 2, 3}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t1")
end


return tests
