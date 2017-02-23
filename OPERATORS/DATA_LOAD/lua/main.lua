require 'load_csv'
require 'dictionary'
require 'environment'
require 'pl'

local no_of_args = #arg
assert( no_of_args == 2 , "ERROR: Please provide metadata_file_path followed by data_file_path")
  
local metadata_file_path = arg[1]
local csv_file_path = arg[2]

assert(path.exists(metadata_file_path) and path.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
assert(path.exists(csv_file_path) and path.isfile(csv_file_path) , "ERROR: Please check csv_file_path")
 

-- read the content of file into lua table
local f = assert(io.open(metadata_file_path, "rb"))
local content = f:read("*all")
f:close()
local metadata = pretty.read(content)

--set defaults..
set_environment() 

-- call load function to load the data
local status, ret = pcall(load, csv_file_path, metadata )

-- System is going to shutdown, so save all dictionaries
save_all_dictionaries()

assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 
print("Loading Completed")
  