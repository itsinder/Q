-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plpath  = require 'pl.path'
local plfile  = require 'pl.file'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/UNIQUE/test/"
assert(plpath.isdir(path_to_here))

local chunk_size = qconsts.chunk_size

-- validating unique operator to return unique values from input vector
-- where num_elements are less than chunk_size
local tests = {}
tests.t1 = function ()
  local out_table = {1, 2, 3, 4, 5}
  local a = Q.mk_col({1, 2, 2, 3, 3, 3, 3, 4, 5}, "I4")
  local c = Q.unique(a):eval()
  assert(c:length() == #out_table)

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t1 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size 
tests.t2 = function ()
  local out_table = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  local input = Q.period({ len = chunk_size*4+2, start = 1, by = 1, period = 10, qtype = "I4"}):persist(true):eval()
  
  local input_col = Q.sort(input, "asc")
  -- Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t2.csv"})
  local c = Q.unique(input_col):eval()
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, out_table[i])
    assert(value == out_table[i])
  end
  print("Test t2 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- [ 1 ... chunk_size ] [ chunk_size+1 ... chunk_size*2 ]
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3, 3, 3, 3, 3, 3, 3, ... 3 ]
tests.t3 = function ()
  local expected_values = {1, 2, 3}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end

  for i = chunk_size+1, chunk_size*2 do
    input_tbl[i] = 3
  end
  input_tbl[chunk_size] = 3
  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t3.csv"})
  local c = Q.unique(input_col):eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t3.csv") 
  print("Test t3 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size 
-- [ 1 ... chunk_size ] [ chunk_size+1 ... (chunk_size*2-chunk_size/2) ]
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3 ... 3 (half the length of second chunk)]
tests.t4 = function ()
  local expected_values = {1, 2, 3}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end

  for i = chunk_size+1, (chunk_size*2)-(chunk_size/2) do
    input_tbl[i] = 3
  end
  input_tbl[chunk_size] = 3
  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t4.csv"})
  local c = Q.unique(input_col):eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t4.csv") 
  print("Test t4 succeeded")
end
 
-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- [ 1 ... chunk_size ] [ chunk_size+1 ... chunk_size*2 ]
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3, 4, 4, ... 5, 5 ]
tests.t5 = function ()
  local expected_values = {1, 2, 3, 4, 5}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end
  input_tbl[chunk_size]   = 3
  input_tbl[chunk_size+1] = 3
  input_tbl[chunk_size+2] = 3
  
  for i = chunk_size+3, chunk_size*2 do
    if i % 2 == 0 then
      input_tbl[i] = 4
    else
      input_tbl[i] = 5
    end
  end

  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t5.csv"})
  local c = Q.unique(input_col):eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t5.csv") 
  print("Test t5 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- [ 1, 1, .. 2, 2, 3 ] [ 3, 3, 3, 3 ... 3 ] [ 3, 3, 4, 4, ... 5, 5 ]
tests.t6 = function ()
  local expected_values = {1, 2, 3, 4, 5}
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size-1 do
    if i % 2 == 0 then
      input_tbl[i] = 1
    else
      input_tbl[i] = 2
    end
  end
  
  input_tbl[chunk_size]   = 3
  
  for i = chunk_size+1, chunk_size*2 do
    input_tbl[i] = 3
  end
  
  input_tbl[chunk_size*2+1]   = 3
  input_tbl[chunk_size*2+2]   = 3
  
  for i = (chunk_size*2)+3, chunk_size*3 do
    if i % 2 == 0 then
      input_tbl[i] = 4
    else
      input_tbl[i] = 5
    end
  end

  local input_col = Q.mk_col(input_tbl, "I1")
  input_col = Q.sort(input_col, "asc"):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t6.csv"})
  local c = Q.unique(input_col):eval()
  assert(c:length() == #expected_values)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, expected_values[i])
    assert(value == expected_values[i])
  end
  Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t6.csv") 
  print("Test t6 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements > chunk_size and
-- no_of_unique values > chunk_size
-- [ 1, 2, ... 65534, 65535, 65536 ] [ 65536, 65536, 65537, 65537 ... 65537 ] 
tests.t7 = function ()
  local no_of_unq_values = chunk_size + 1
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size do
    input_tbl[i] = i
  end
  
  for i = chunk_size+1, chunk_size*2 do
    if i == chunk_size+1 or i == chunk_size+2 then
      input_tbl[i] = chunk_size
    else
      input_tbl[i] = chunk_size + 1
    end
  end

  local input_col = Q.mk_col(input_tbl, "I4")
  local c = Q.unique(input_col):eval()
  assert(c:length() == no_of_unq_values)
  for i = 1, no_of_unq_values do
    local value = c_to_txt(c, i)
    -- print(value)
    assert(value == i)
  end
  Q.print_csv(c, { opfile = path_to_here .. "output_t7.csv"} )
  plfile.delete(path_to_here .. "/output_t7.csv") 
  print("Test t7 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements > chunk_size and
-- no_of_unique values > chunk_size
-- [ 1, 2, ... 65534, 65535, 65536 ] [ 65536, ... 65536, 65536 ] ..
-- [ 65536, 65536, 65537, 65537 ... 65537 ] 
tests.t8 = function ()
  local no_of_unq_values = chunk_size + 1
  local chunk_size = qconsts.chunk_size
  
  local input_tbl = {}
  for i = 1, chunk_size do
    input_tbl[i] = i
  end
  
  for i = chunk_size+1, chunk_size*2 do
    input_tbl[i] = chunk_size
  end
  
  for i = chunk_size*2+1, chunk_size*3 do
    if i == chunk_size*2+1 or i == chunk_size*2+2 then
      input_tbl[i] = chunk_size
    else
      input_tbl[i] = chunk_size + 1
    end
  end

  local input_col = Q.mk_col(input_tbl, "I4")
  local c = Q.unique(input_col):eval()
  assert(c:length() == no_of_unq_values)
  for i = 1, no_of_unq_values do
    local value = c_to_txt(c, i)
      -- print(value)
      assert(value == i)
  end
  Q.print_csv(c, { opfile = path_to_here .. "output_t8.csv"} )
  plfile.delete(path_to_here .. "/output_t8.csv") 
  print("Test t8 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- all elements are unique
tests.t9 = function ()
  local num_elements = qconsts.chunk_size + 100
  local input_col = Q.seq( {start = 1, by = 1, qtype = "I4", len = num_elements} ):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t9.csv"})
  local c = Q.unique(input_col):eval()
  assert(c:length() == num_elements)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, i)
    assert(value == i)
  end
  -- Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t9.csv") 
  print("Test t9 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- all elements are same
tests.t10 = function ()
  local num_elements = qconsts.chunk_size + 100
  local input_col = Q.const({ val = 1, len = num_elements, qtype = "I4"}):eval()
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t10.csv"})
  local c = Q.unique(input_col):eval()
  assert(c:length() == 1)
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    -- print(value, i)
    assert(value == i)
  end
  -- Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t10.csv") 
  print("Test t10 succeeded")
end

-- validating unique to return unique values from input vector
-- where num_elements are greater than chunk_size
-- random value n on n(some collisions not too many)
-- as sorting 'asc' so validating using is_next(geq)
tests.t11 = function ()
  local num_elements = qconsts.chunk_size * 2
  local input_col = Q.rand( { lb = 1, ub = 80000, qtype = "I4", len = num_elements }):eval()
  input_col =  Q.sort(input_col, "asc")
  Q.print_csv(input_col, {opfile = path_to_here .. "input_file_t11.csv"})
  local c = Q.unique(input_col):eval()
  print(c:length())
  assert(c:length())
  local z = Q.is_next(c, "geq")
  assert(type(z) == "Reducer")
  local a, b = z:eval()
  assert(type(a) == "boolean")
  assert(type(b) == "number")
  assert(a == true)
  -- Q.print_csv(c)
  plfile.delete(path_to_here .. "/input_file_t11.csv") 
  print("Test t11 succeeded")
end

-- validating unique to return unique values from input vector
-- internally should set 'sort_order' metadata as 'desc'
tests.t12 = function ()
  local expected_output = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 }
  local input_col = Q.mk_col( { 10, 10, 9, 9, 9, 8, 7, 7, 6, 6, 6, 5, 4, 3, 2, 1}, "I1")
  local c = Q.unique(input_col):eval()
  assert(c:length() == #expected_output )
  for i = 1, #expected_output do
    local value = c_to_txt(c, i)
    -- print(value, expected_output[i])
    assert(value == expected_output[i])
  end
  -- Q.print_csv(c)
  print("Test t12 succeeded")
end

-- validating unique
-- input vector is nort sorted
-- internally should sort(by creating a clone of input vector) 
-- and should set 'sort_order' metadata to default as 'asc'
tests.t13 = function ()
  local expected_output = { 1,2,3,4,5,6,7,8,9,10 }
  local input_col = Q.mk_col( { 10, 9, 5, 2, 7, 6, 8, 4, 1, 3}, "I1")
  local c = Q.unique(input_col):eval()
  assert(c:length() == #expected_output )
  for i = 1, #expected_output do
    local value = c_to_txt(c, i)
    -- print(value, expected_output[i])
    assert(value == expected_output[i])
  end
  Q.print_csv(c)
  -- Q.print_csv(input_col)
  print("Test t13 succeeded")
end

return tests
