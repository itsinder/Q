--[[ Guideline for adding new testcases in this file
File : map_mkcol.lua
In this file, all the testcases are written in the format
name = <testcase name>, input = <input values given in lua table>, qtype = <type of data e.g. I1, I4 etc>, category = <category_number>
They are added as a row in the below LUA table.
category1 - error code testcases
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]

require("error_code")

return { 
  -- error messages test cases
  -- falls in category 1
  
  -- compare input values with value written in binary file
  -- category 2 testcases
  
  -- simple I1 values given to mk_col
  { name = "simple I1 values", input = { 1, 3, 5}, qtype = "I1", category= "category2"},
  
  -- simple I2 values given to mk_col
  { name = "simple I2 values", input = { 1, 3, 5}, qtype = "I2", category= "category2"},

-- simple I4 values given to mk_col
  { name = "simple I4 values", input = { 1, 3, 5}, qtype = "I4", category= "category2"},

-- simple I8 values given to mk_col
  { name = "simple I8 values", input = { 1, 3, 5}, qtype = "I8", category= "category2"},

-- simple I4 values given to mk_col
  { name = "simple F4 values", input = { 1.1, 3.2, 5.3}, qtype = "F4", category= "category2"},

-- simple I8 values given to mk_col
  { name = "simple F8 values", input = { 1.1, 3.2, 5.3}, qtype = "F8", category= "category2"},

-- border I1 values given to mk_col
  { name = "border I1 values", input = { 127, -128}, qtype = "I1", category= "category2"},

-- border I2 values given to mk_col
  { name = "border I2 values", input = { 32767, -32768}, qtype = "I2", category= "category2"},

-- border I4 values given to mk_col
  { name = "border I4 values", input = { 2147483647, -2147483648}, qtype = "I4", category= "category2"},
  
  { name = "maximum lua number", input = {9007199254740991}, qtype = "I8", category= "category2"},
  
  { name = "minimum lua number", input = {-9007199254740991}, qtype = "I8", category= "category2"},

  { name = "maximum lua number", input = {9007199254740992}, qtype = "I8", 
    category= "category1", output_regex = g_err.INVALID_UPPER_BOUND},
  
  { name = "minimum lua number", input = {-9007199254740992}, qtype = "I8", 
    category= "category1", output_regex = g_err.INVALID_LOWER_BOUND},



-- border I8 values given to mk_col
  { name = "border I8 values", input = { 9223372036854775807}, qtype = "I8",
    category= "category1", output_regex = g_err.INVALID_UPPER_BOUND},

  { name = "border I8 values", input = { -9223372036854775808}, qtype = "I8",
    category= "category1", output_regex = g_err.INVALID_LOWER_BOUND},

}