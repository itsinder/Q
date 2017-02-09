require 'load_csv'
require 'dictionary'
require 'environment'
require 'pl'

-- Process input arguments, verify all okay TODO
-- e.g., if shell script 
-- if [ $# != 2 ]; then echo ERROR:$LINENO; exit 1; fi 
-- meta_file=$1
-- data_file=$2
-- test -f $meta_file
-- test -f $data_file

local no_of_args = #arg
if no_of_args ~= 2 then
  print("ERROR: Please provide metadata_file_path followed by data_file_path")
  return -1 
end

local metadata_file_path = arg[1]
local csv_file_path = arg[2]

if not path.exists(metadata_file_path) or not path.isfile(metadata_file_path) then
  print("ERROR: Please check metadata_file_path")
  return -1
end
if not path.exists(csv_file_path) or not path.isfile(csv_file_path) then
  print("ERROR: Please check csv_file_path")
  return -1
end


-- read the content of file into lua table
local f = io.open(metadata_file_path, "rb")
local content = f:read("*all")
f:close()
local metadata = pretty.read(content)

 
--set defaults..
set_environment() 

-- call load function to load the data
status, ret = pcall(load, csv_file_path, metadata )

-- System is going to shutdown, so save all dictionaries
save_all_dictionaries()


if( status == false ) then 
  print("Error: " .. ret)
  print("Loading Aborted")
  return -1
else
  print("Loading Completed")
  return 0 
end


-- if returning control to shell script, make sure that exit code is set
-- correctly 
