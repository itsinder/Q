--[[ Guideline for adding new testcases in this file
File : map_metadata_data.lua
In this file, all the testcases are written in the format
meta = <meta file>, data = <input csv_file to load>, csv_file = <output csv file of print> category = <category_number>
They are added as a row in the below LUA table.
category1 - match csv file in data field with csv file in csv_file field
category2 - invalid filter input to print_csv. output_regex is error code in these testcases
category3 - bit vector is B1
category4 - bit vector is I4. output error expected
category5 - output csv file from print_csv should be consumable to load_csv
category6 - Range filter testcase
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]
local g_err = require 'Q/UTILS/lua/error_code'

return { 
  -- testcase for printing single column content
  { testcase_no = 1, meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "single_col.csv", category = "category1", name= "single_col", output_regex = "1001\n1002\n1003\n1004\n" },
  -- testcase for printing multiple column contents
  { testcase_no = 2, meta = "gm_multi_col.lua",  data ="multi_col_file.csv", csv_file = "multi_col.csv", category = "category1", name= "multiple_col", output_regex = "1001,1\n1002,2\n1003,3\n1004,4\n" },
  -- checking for valid I1 column contents
  { testcase_no = 3, meta = "gm_print_I1.lua", data ="sample_I1.csv", csv_file = "print_I1.csv", category = "category1", name= "print_I1_type", output_regex = "12\n123\n50\n111\n" },
  -- checking for valid I2 column contents
  { testcase_no = 4, meta = "gm_print_I2.lua", data ="sample_I2.csv", csv_file = "print_I2.csv", category = "category1", name= "print_I2_type", output_regex = "1002\n123\n2312\n2131\n" },
  -- checking for valid I4 column contents
  { testcase_no = 5, meta = "gm_print_I4.lua", data ="sample_I4.csv", csv_file = "print_I4.csv", category = "category1", name= "print_I4_type", output_regex = "1002\n123\n2312\n2131\n" },
  -- checking for valid I8 column contents
  { testcase_no = 6, meta = "gm_print_I8.lua", data ="sample_I8.csv", csv_file = "print_I8.csv", category = "category1", name= "print_I8_type", output_regex = "1002\n123\n2312\n2131\n" },
  -- checking for valid SV column contents
  { testcase_no = 7, meta = "gm_print_SV.lua", data ="sample_varchar.csv", csv_file = "print_SV.csv", category = "category1", name= "print_SV_type", output_regex = "Sample\nString\nFor\nVarchar\n" },
  -- checking for valid SC column contents
  { testcase_no = 8, meta = "gm_print_SC.lua", data ="fix_size_string.csv", csv_file = "print_SC.csv", category = "category1", name= "print_SC_type", output_regex = "Hiihello\nbye\n" },
  -- checking for nulls in valid allowed null column
  { testcase_no = 9, meta = "gm_print_null_I4.lua", data ="sample_null_I4.csv", csv_file = "print_null_I4.csv", category = "category1",
    name= "print_I4_null", output_regex = "1002\n\n2312\n2131\n" },
  -- testing whether filter is a table
  { testcase_no = 10, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = "test", category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.FILTER_NOT_TABLE_ERROR, name="Filter_type_not_table" },
  -- testing whether lower bound value of filter is valid
  { testcase_no = 11, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = -1, ub = 4 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.INVALID_LOWER_BOUND, name="Invalid LB" },
  -- lb passed is passed as string should return an error
  { testcase_no = 12, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = "1" }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.INVALID_LOWER_BOUND_TYPE, name="Invalid LB type" },
  -- ub passed is passed as string should return an error
  { testcase_no = 13, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { ub = "1" }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.INVALID_UPPER_BOUND_TYPE, name="Invalid UB type" },
  -- testing whether upper bound value of filter is greater than lower bound value
  { testcase_no = 14, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = 5, ub = 4 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.UB_GREATER_THAN_LB, name="UB greater than LB"},
  -- testing whether upper bound value of filter is valid
  { testcase_no = 15, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = 1, ub = 5 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.INVALID_UPPER_BOUND, name="Invalid UB" },
  -- testing type of the filter is valid
  { testcase_no = 16, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { where = "test" }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.FILTER_TYPE_ERROR, name="Filter type string" },
  -- testing type of the filter is valid
  { testcase_no = 17, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { where = 1 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.FILTER_TYPE_ERROR, name="Filter type number" },
  -- where field in filter is table and not bit vector
  { testcase_no = 18, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { where = { 1 } }, 
    category = "category2", csv_file = "single_col.csv", output_regex = g_err.FILTER_TYPE_ERROR, 
    name="Filter type table"},
  -- csv file path provided to print_csv is invalid
  { testcase_no = 19, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    csv_file = "dummy/single_col.csv", output_regex = g_err.INVALID_FILE_PATH, name="Invalid file path"},
  
  -- this testcase, bit filter passed is of type I4
  { testcase_no = 20, meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "single_col.csv", 
    category = "category4", name="bit filter I4", output_regex = g_err.FILTER_INVALID_FIELD_TYPE, name= "bit_filter_type_I4" },
  
  -- this testcase, bit filter passed is of type B1
  { testcase_no = 21, meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "single_col.csv", 
    category = "category3", name="bit filter B1", output_regex = "1001\n1002\n1003\n"},
  
  -- output csv file from print_csv should be consumable to load_csv
  { testcase_no = 22, meta = "gm_csv_consumable.lua", csv_file = "print_out_cons.csv", category = "category6",
    name = "csv consumable testcase"}, 
  
  -- testing whether range filter outputs correct values
  { testcase_no = 23, meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = 1, ub = 3 }, category = "category5",
    csv_file = "single_col.csv", output_regex = "1002\n1003\n", name = "range filter test"},
  -- 
  { testcase_no = 24, meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = nil, category = "category7",  
    output_regex = "1001\n1002\n1003\n1004\n", name = "input csv file null" },
  
    -- 
  { testcase_no = 25, meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "" , category = "category8",  
    output_regex = "1001\n1002\n1003\n1004\n", name = "input csv file null" },
  
  --{ meta = "gm_print_stdout.lua", data ="std_out_file.csv", csv_file = "stdout.csv"},
}

      
     
    
    
