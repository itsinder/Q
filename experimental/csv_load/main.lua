require 'load_csv'
require 'dictionary'

local csv_file_path_name = "./csv_input1.csv" --path for input csv file 


--[[ 
local M = {
  { name = "empid", type = "int32_t" },
  { name = "yoj", type ="int16_t" },
  { name = "empname", type ="varchar",dict = "D1", is_dict = true, add=true},
  { name = "address" ,type ="varchar", dict = "D2", is_dict = true, add=false}
}
--]]
local M = {
  { name = "empid", type = "I4" },
  { name = "yoj", type ="I2" },
  { name = "empname", type ="varchar",dict = "D1", is_dict = false, add=true}
}
--[[
D1 = newDictionary()
D1.put("test")
D1.put("test1")
--]]

ret = load( csv_file_path_name, M )  --call to load function
if(ret ~= nil and ret < 0 ) then 
  print("Loading Aborted")
else
  print("Loading Completed") 
end
