require 'load_csv'
require 'dictionary'
require 'environment'

-- Process input arguments, verify all okay TODO
-- e.g., if shell script 
-- if [ $# != 2 ]; then echo ERROR:$LINENO; exit 1; fi 
-- meta_file=$1
-- data_file=$2
-- test -f $meta_file
-- test -f $data_file
local csv_file_path_name = "../test/csv_input1.csv" --path for input csv file 

--[[ 
local M = {
  { name = "empid", type = "int32_t" },
  { name = "yoj", type ="int16_t" },
  { name = "empname", type ="varchar",dict = "D1", is_dict = true, add=true},
  { name = "address" ,type ="varchar", dict = "D2", is_dict = true, add=false}
}
--]]

setEnvironment() -- snake case TODO

--[[
D1 = newDictionary() # Upper case for Classes TODO 
D1.put("test")
D1.put("test1")
_G["Q_DICTIONARIES"]["D1"] = D1
--]]

local M = {
  { name = "empid", null = "true", type = "I4" },
  { name = "yoj", null = "true", type ="I2" },
  { name = "empname", type ="varchar",dict = "D1", is_dict = false, add=true}
}


status, ret = pcall(load, csv_file_path_name, M )  --call to load function
-- System is going to shutdown, so save all dictionaries
saveAllDictionaries()


if(status==false or  ret ~= nil and type(ret) ~= "table" and ret < 0 ) then 
  print("Error" .. ret)
  print("Loading Aborted")
else
  print("Loading Completed") 
end
-- if returning control to shell script, make sure that exit code is set
-- correctly 
