require 'load_csv'
require 'dictionary'
require 'environment'
require 'pl'

assert( #arg == 2 , "ERROR: Please provide metadata_file_path followed by data_file_path")
  
local metadata_file_path = arg[1]
local csv_file_path = arg[2]

assert(path.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
assert(path.isfile(csv_file_path), "ERROR: Please check csv_file_path")
 

-- read the content of file into lua table
local f = assert(io.open(metadata_file_path, "rb"))
local content = f:read("*all")
f:close()
local metadata = pretty.read(content)
preprocess_bool_values(metadata, "null", "dict_exists", "add")
--set defaults..
set_environment() 

-- call load function to load the data
local status, ret = pcall(load, csv_file_path, metadata )

-- System is going to shutdown, so save all dictionaries
save_all_dictionaries()

assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 
print("Loading Completed")
  