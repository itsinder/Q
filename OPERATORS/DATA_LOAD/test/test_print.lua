package.path = package.path .. ";../lua/?.lua"
  
lu = require('luaunit')
require 'environment'
require 'QCFunc'
-- require 'print'
-- local Vector = require 'Vector'


local ffi = require("ffi") 

ffi.cdef[[
  void *malloc(size_t size);
  void free(void *ptr);

  typedef struct ssize_t ssize_t;
  typedef struct FILE FILE;    
  ]]

test_print = {}

-- command setting which needs to be done for all test-cases
function test_print:setUp()
  test_load_csv:create_directory("./test_data/print_tmp/")
end

-- commond cleanup for all testcases
function test_print:tearDown()
  test_load_csv:empty_directory("./test_data/print_tmp/")
end


-- Utility functions used in this testcase -----
function test_print:create_directory(dir_path)
  os.execute("mkdir " .. dir_path)
end

function test_print:empty_directory(dir_path)
  os.execute('rm -rd "'..dir_path..'"')
end

-- ----------------
--[[
vecotr, filter, destination
  print(<table of vectors | vector> , [filter], [destination])
--]]


-- Test Case Start ---------------
function test_print:test_output_file_path_invalid()
  local v1 = Vector{field_type='I1',filename='./test_data/print_tmp/test1.txt' }
  lu.assertErrorMsgContains("Output File cannot be created", print, v1,nil, "./some_dummy_dir/not_accessible_file.out" )
end

function test_print:test_nil_vector()
  lu.assertErrorMsgContains("Vector cannot be nil", print, nil, nil, "./vector.out" )
end

function test_print:test_single_vector()
  local v1 = Vector{field_type='I1',filename='./test_data/print_tmp/test1.txt'}
  local x = convertTextToCValue( "txt_to_I1", "int8_t" , 5, 1)
  local x_size = 1
  -- put data into vector
  v1.put_chunk(x, x_size)
  
  -- print vector 
  print(v1, "./test_data/print_tmp/I1_print.csv")
  
  -- load data and verify the content
  for line in io.lines(csv_file) do
    assertEquals(line, "5")
  end
   
end

function test_print:test_multiple_vector()

end

function test_print:test_print_stdout()

end

function test_print:test_range_filter()
end

function test_print:test_invalid_range()
end

function test_print:test_bit_vector()
end

function test_print:test_escape_chr()
end

function test_print:test_comma_in_data()
end

function test_print:test_eoln_in_data()
end

function test_print:test_double_quote_in_data()
end

function test_print:test_backslash_in_data()
end

function test_print:test_csv_consumable()
end

function test_print:test_print_I1()
end

function test_print:test_print_I2()
end

function test_print:test_print_I4()
end

function test_print:test_print_I8()
end

function test_print:test_varchar()
end

function test_print:test_fix_size_string()
end

function test_print:test_file_already_exists()
end

function test_print:test_null_value_print()
end



os.exit( lu.LuaUnit.run() )