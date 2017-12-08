local Q         = require 'Q'
local c_to_txt  = require 'Q/UTILS/lua/C_to_txt'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  -- Case1
  -- x and y size is less than chunk_size
  local x_length = 65
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end

tests.t2 = function()
  -- Case2
  -- x = chunk_size and y < chunk_size
  local x_length = 65536
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end

tests.t3 = function()
  -- Case3
  -- x < chunk_size and y = chunk_size
  local x_length = 34
  local y_length = 65536

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t4 = function()
  -- Case4
  -- x = chunk_size and y = chunk_size
  local x_length = 65536
  local y_length = 65536

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t5 = function()
  -- Case5
  -- x < chunk_size and y > chunk_size
  local x_length = 655
  local y_length = 65540

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t6 = function()
  -- Case6
  -- x > chunk_size and y = chunk_size
  local x_length = 65567
  local y_length = 65536

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t7 = function()
  -- Case7
  -- x > chunk_size and y > chunk_size
  local x_length = 65536 * 3 + 12
  local y_length = 65536 * 7 + 133

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat(x, y)
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end

tests.t8 = function()
  -- Case8
  -- x and y are of type B1  
  local x_table = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1}
  local y_table = {1, 0, 1, 1}
  
  local x = Q.mk_col(x_table, "B1")
  local y = Q.mk_col(y_table, "B1")

  local z = Q.cat(x, y)
  
  assert(z:length() == (x:length() + y:length()))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    if not z_val then z_val = 0 end
    val = x_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    if not z_val then z_val = 0 end
    val = y_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end 
end

tests.t9 = function()
  -- Case9 -- B1
  -- x > chunk_size and y < chunk_size
  local x_length = 65535
  local y_length = 4

  local x_table = {}
  for i = 1, x_length do
    if i % 2 == 1 then
      table.insert(x_table, 1)
    else
      table.insert(x_table, 0)
    end
  end
  local y_table = {1, 1, 1, 1}
  local x = Q.mk_col(x_table, "B1")
  local y = Q.mk_col(y_table, "B1")

  local z = Q.cat(x, y)
  
  assert(z:length() == (x:length() + y:length()), "Mismatch, Expected = " .. tostring(x:length() + y:length()) .. ", Actual = " .. tostring(z:length()))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    if not z_val then z_val = 0 end
    val = x_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  print("X validation is done")
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    if not z_val then z_val = 0 end
    print(z_val)
    val = y_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
end


return tests