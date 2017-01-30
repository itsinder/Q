require 'load_csv'
require 'dictionary'
require 'environment'

local csv_file_path_name = "../test/csv_input1.csv" --path for input csv file 

--[[ 
local M = {
  { name = "empid", type = "int32_t" },
  { name = "yoj", type ="int16_t" },
  { name = "empname", type ="varchar",dict = "D1", is_dict = true, add=true},
  { name = "address" ,type ="varchar", dict = "D2", is_dict = true, add=false}
}
--]]

setEnvironment()

--[[
D1 = newDictionary()
D1.put("test")
D1.put("test1")
_G["Q_DICTIONARIES"]["D1"] = D1
--]]

local M = {
  { name = "empid", null = "true", type = "I4" },
  { name = "yoj", null = "true", type ="I2" },
  { name = "empname", type ="varchar",dict = "D1", is_dict = false, add=true}
}


ret = load( csv_file_path_name, M )  --call to load function

-- System is going to shutdown, so save all dictionaries
saveAllDictionaries()

if(ret ~= nil and ret < 0 ) then 
  print("Loading Aborted")
else
  print("Loading Completed") 
end






