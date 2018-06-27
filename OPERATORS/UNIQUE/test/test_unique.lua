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

return tests
