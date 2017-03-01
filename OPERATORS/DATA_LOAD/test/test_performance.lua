package.path = package.path .. ";../lua/?.lua"
local lu = require 'luaunit'
require 'pl'
require 'gen_csv_metadata_file'
require 'load_csv'

local performance_file ="./performance_results/performance_measures.txt"

test_performance = {}
local filep 
  
function test_performance:setUp()
  dir.makepath("./performance_results/")
  --set environment variables for test-case
  _G["Q_DATA_DIR"] = "./test_data/out/"
  _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
  _G["Q_DICTIONARIES"] = {}
  
  dir.makepath(_G["Q_DATA_DIR"])
  dir.makepath(_G["Q_META_DATA_DIR"])
  filep = assert(io.open(performance_file, 'a')) -- append mode so that all testcases writes their result in this file
end

function test_performance:tearDown()
  -- clear the output directory 
  dir.rmtree(_G["Q_DATA_DIR"])
  dir.rmtree(_G["Q_META_DATA_DIR"])
  filep:close()
end

--testcase for 100000 rows and 259 cols with varchar
function test_performance:test_rows100000_cols259_var()
  --meta information
  local meta_info= {{type= 'SC', size= 16, column_count= 1, null= false }, 
    { type= "SV", size= 3, column_count= 3, max_unique_values = 1000, null= true, dict_exists= false, add= true },
    { type= "SV", size= 20, column_count= 1, max_unique_values = 200, null= true, dict_exists= false, add= true },
    { type= 'I1', column_count= 65, null= false }, {type= 'I2', column_count= 63, null= false },
    { type= 'I4', column_count= 63, null= false }, {type= 'F4', column_count= 63, null= false }
  }
  --generating maximum dictionary size unique strings
  local unique_string_tables = generate_unique_varchar_strings(meta_info)
  
  --generate metadata table which is to be passed to load csv
  local metadata_table = generate_metadata(meta_info)
    
  local csv_file_path ="./_csv_1l_256v.csv"
  local row_count = 100000  -- no of rows you wish to enter
  local chunk_print_size = 1000   -- writing data into files as chunks(i.e. chunk size)

  --need to provide csv_file_name, columns_list, no_of_rows, chunk_print_size and unique_str_table(if varchar column exists)
  generate_csv_file(csv_file_path, metadata_table, row_count, chunk_print_size,unique_string_tables)
  
  local start_time = os.time()
  load(csv_file_path, metadata_table)
  local end_time = os.time()
  local date = (os.date ("%c")) 
  filep:write(string.format("\nRows: %d \t Columns: %d \t Execution time: %.2f seconds \t Date:%s ",
              row_count,#metadata_table,end_time-start_time,date))
  file.delete(csv_file_path)  -- deleting generated csv file after getting results
end


--testcase for 200000 rows and 256 cols with varchar
function test_performance:test_rows200000_cols256_var()

  --meta information
   local meta_info= {{type= 'SC', size= 16, column_count= 1, null= false }, 
    { type= "SV", size= 20, column_count= 1, max_unique_values = 200, null= true, dict_exists= false, add= true },
    { type= 'I1', column_count= 65, null= false }, {type= 'I2', column_count= 63, null= false },
    { type= 'I4', column_count= 63, null= false }, {type= 'F4', column_count= 63, null= false }
  }
  --generating maximum dictionary size unique strings
  local unique_string_tables = generate_unique_varchar_strings(meta_info)
  
  --generate metadata table which is to be passed to load csv
  local metadata_table = generate_metadata(meta_info)
    
  local csv_file_path ="./_csv_2l_256v.csv"
  local row_count = 200000 -- no of rows you wish to enter
  local chunk_print_size = 1000 -- writing data into files as chunks(i.e. chunk size)

  --need to provide csv_file_name, columns_list, no_of_rows, chunk_print_size and unique_str_table(if varchar column exists)
  generate_csv_file(csv_file_path, metadata_table, row_count, chunk_print_size,unique_string_tables)
  
  local start_time = os.time()
  load(csv_file_path, metadata_table)
  local end_time = os.time()
  local date = (os.date ("%c")) 
  filep:write(string.format("\nRows: %d \t Columns: %d \t Execution time: %.2f seconds \t Date:%s ",
              row_count,#metadata_table,end_time-start_time,date))
  file.delete(csv_file_path) 
end


--testcase for 1000000 rows and 256 cols with no varchar
function test_performance:test_rows1000000_cols256()
  
   local meta_info= {{type= 'SC', size= 16, column_count= 1, null= false }, 
    { type= 'I1', column_count= 66, null= false }, {type= 'I2', column_count= 63, null= false },
    { type= 'I4', column_count= 63, null= false }, {type= 'F4', column_count= 63, null= false }
  }
  --generating maximum dictionary size unique strings
  local unique_string_tables = generate_unique_varchar_strings(meta_info)
  
  --generate metadata table which is to be passed to load csv
  local metadata_table = generate_metadata(meta_info)
    
  local csv_file_path ="./_csv_1m_256.csv"
  local row_count = 1000000 -- no of rows you wish to enter
  local chunk_print_size = 1000 -- writing data into files as chunks(i.e. chunk size)

  --need to provide csv_file_name, columns_list, no_of_rows, chunk_print_size and unique_str_table(if varchar column exists)
  generate_csv_file(csv_file_path, metadata_table, row_count, chunk_print_size,unique_string_tables)

  local start_time = os.time()
  load(csv_file_path, metadata_table)
  local end_time = os.time()
  local date = (os.date ("%c")) 
  filep:write(string.format("\nRows: %d \t Columns: %d \t Execution time: %.2f seconds \t Date:%s ",
              row_count,#metadata_table,end_time-start_time,date))
  file.delete(csv_file_path)
end

os.exit( lu.LuaUnit.run() )