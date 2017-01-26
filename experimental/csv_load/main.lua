require 'load_csv'

local csv_file_path_name = "./csv_input1.csv" --path for input csv file 

--metadata 
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
  { name = "yoj", type ="I2" }
}

load( csv_file_path_name, M )  --call to load function
print("Loading Completed")
