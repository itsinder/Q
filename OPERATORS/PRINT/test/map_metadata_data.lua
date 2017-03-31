return { 
  { meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "single_col.csv", category = "category1", name= "single_col" },
  { meta = "gm_multi_col.lua",  data ="multi_col_file.csv", csv_file = "multi_col.csv", category = "category1", name= "multiple_col" },
  
  { meta = "gm_print_I1.lua", data ="sample_I1.csv", csv_file = "print_I1.csv", category = "category1", name= "print_I1_type" },
  { meta = "gm_print_I2.lua", data ="sample_I2.csv", csv_file = "print_I2.csv", category = "category1", name= "print_I2_type" },
  { meta = "gm_print_I4.lua", data ="sample_I4.csv", csv_file = "print_I4.csv", category = "category1", name= "print_I4_type" },
  { meta = "gm_print_I8.lua", data ="sample_I8.csv", csv_file = "print_I8.csv", category = "category1", name= "print_I8_type" },
  { meta = "gm_print_SV.lua", data ="sample_varchar.csv", csv_file = "print_SV.csv", category = "category1", name= "print_SV_type" },
  { meta = "gm_print_SC.lua", data ="fix_size_string.csv", csv_file = "print_SC.csv", category = "category1", name= "print_SC_type" },
  
  
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = "test", category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.FILTER_NOT_TABLE_ERROR, name="Filter_type_not_table" },
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = -1, ub = 4 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.INVALID_LOWER_BOUND, name="Invalid LB" },
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = 5, ub = 4 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.UB_GREATER_THAN_LB, name="UB greater than LB"},
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = 1, ub = 5 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.INVALID_UPPER_BOUND, name="Invalid UB" },
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { where = "test" }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.FILTER_TYPE_ERROR, name="Filter type string" },
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { where = 1 }, category = "category2",
    csv_file = "single_col.csv", output_regex = g_err.FILTER_TYPE_ERROR, name="Filter type number" },
  
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { where = { 1 } }, 
    category = "category2", csv_file = "single_col.csv", output_regex = g_err.FILTER_TYPE_ERROR, 
    name="Filter type table"},
  
  { meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    csv_file = "dummy/single_col.csv", output_regex = g_err.INVALID_FILE_PATH, name="Invalid file path"},
  
  -- this testcase, bit filter passed is of type I4
  { meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "single_col.csv", 
    category = "category4", name="bit filter I4", output_regex = g_err.FILTER_INVALID_FIELD_TYPE, name= "bit_filter_type_I4" },
  
  -- this testcase, bit filter passed is of type B1
  { meta = "gm_single_col.lua", data ="single_col_file.csv", csv_file = "single_col.csv", 
    category = "category3", name="bit filter B1", output_regex = "1001\n1002\n1003\n"},
  
  { meta = "gm_csv_consumable.lua", csv_file = "print_out_cons.csv", category = "category6",
    name = "csv consumable testcase"}, 
  
  { meta = "gm_single_col.lua", data ="single_col_file.csv", filter = { lb = 1, ub = 3 }, category = "category5",
    csv_file = "single_col.csv", output_regex = "1002\n1003\n", name = "range filter test"},
  
  
  --{ meta = "gm_print_stdout.lua", data ="std_out_file.csv", csv_file = "stdout.csv"},
}

      
     
    
    
