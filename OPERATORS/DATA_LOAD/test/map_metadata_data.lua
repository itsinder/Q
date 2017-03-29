-- output error message for double quote mismatch
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
require("error_code")

return { 
  -- error messages test cases
    { meta= "gm_double_quotes_mismatch.lua",data= "bad_quote_mismatch.csv", category= "category1", 
      output_regex= g_err.INVALID_INDEX_ERROR },
    { meta= "gm_column_is_more.lua", data= "I2_I2_SV_3_4.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_column_is_less.lua", data= "I2_I2_SV_3_4.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta="gm_column_not_same.lua",data= "bad_col_data_mismatch_each_line.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_nil_in_not_nil_field1.lua", data= "I4_2_null.csv", category= "category1",
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD },
    { meta= "gm_nil_in_not_nil_field2.lua", data= "I4_2_4_null.csv", category= "category1", 
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD },
    { meta= "gm_I1_overflow.lua", data= "I1_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_I2_overflow.lua", data= "I2_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_I4_overflow.lua", data= "I4_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_I8_overflow.lua", data= "I8_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR  },
    { meta= "gm_bad_str_in_I1.lua", data= "bad_string_in_I1.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta = "gm_missing_escape_char.lua", data = "missing_escape_char.csv", category= "category1",
      output_regex= g_err.INVALID_INDEX_ERROR },
 

    { meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category2",
      output_regex = {-128,0,127,11} },
    { meta = "gm_valid_I2.lua", data = "I2_valid.csv", category= "category2",
      output_regex = {-32768,0,32767,11} },
    { meta = "gm_valid_I4.lua", data = "I4_valid.csv", category= "category2",
      output_regex = {-2147483648,0,2147483647,11} }, 
    { meta = "gm_valid_I8.lua", data = "I8_valid.csv", category= "category2",
      output_regex = {-9223372036854775808,0,9223372036854775807,11}},
    { meta = "gm_valid_F4.lua", data = "F4_valid.csv", category= "category2",
      output_regex = {-90000000.00,0,900000000.00,11} },
    { meta = "gm_valid_F8.lua", data = "F8_valid.csv", category= "category2",
      output_regex = {-9.58,0,9.58,11} },
    
       
    { meta = "gm_valid_SC.lua", data = "SC_valid.csv", category= "category2",
      output_regex = {"Sampletesttestt","Stringtesttestt","Forfdbfdhfdhhff","Varcharddddddsw"} },
    { meta = "gm_valid_SV.lua", data = "SV_valid.csv", category= "category2",
      output_regex = {"Sample","String","For","Varchar"} },


    { meta = "gm_valid_escape_char.lua", data = "valid_escape.csv", category= "category2",
          output_regex = {"This is valid text containing \"quoted\" text and, comma ","ok","Some random valid string","valid data"}
    },
        
    { meta=  "gm_eoln.lua", data= "file_with_eol.csv", category= "category2",
      output_regex = {"Data having\n","ok","ok","ok"}
    },

    { meta = "gm_no_nil_in_nil_field.lua", data = "I4_valid.csv", category= "category2",
      output_regex = {-2147483648,0,2147483647,11}
    },
    
    { meta = "gm_valid_SC_dict_exists_add_true.lua", data = "SV_valid.csv", category= "category2",
      output_regex =  {"Sample","String","For","Varchar"}
    },
    
    { meta = "gm_load_success.lua", data = "I2_I2_SV_3_4.csv", category= "category3", 
      output_regex = {
                        {1001,1002,1003},
                        {2012,2013,2014},
                        {"Emp1","Emp2","Emp3"}
                     }
    },
    
    
    { meta = "gm_whole_row_null.lua", data = "whole_row_nil.csv", category= "category3",
      output_regex = {
                        {"hello","hii","","hey"},
                        {92514.2,9459.1,nil,987548.5}
                     }
    },

    { meta = "gm_nil_data_I4.lua", data = "I4_2_4_null.csv", category= "category3",
      output_regex = {
                        {111,111,333,nil},
                        {222,222,nil,123}
                     }
    },
    
    { meta = "gm_nil_data_SV.lua", data = "nil_in_SV.csv", category= "category3",
      output_regex = {
                        {"hello","hii","","","hey"},
                        {92514,9459,925,987,987548}
                     }
    },
    
    { meta= "gm_metadata_dir_env_nil.lua", data= "sample.csv", category= "category6", input_regex = 1,
      output_regex=g_err.Q_DATA_DIR_INCORRECT
    },
    
    { meta= "gm_metadata_dir_env_invalid.lua", data= "sample.csv", category= "category6", input_regex = 2,
      output_regex=g_err.Q_DATA_DIR_INCORRECT
    },
    
    { meta= "gm_data_dir_env_nil.lua", data= "sample.csv", category= "category6", input_regex = 3,
      output_regex=g_err.Q_META_DATA_DIR_INCORRECT
    },
    
    { meta= "gm_data_dir_env_invalid.lua", data= "sample.csv", category= "category6", input_regex = 4,
      output_regex=g_err.Q_META_DATA_DIR_INCORRECT
    }, 
    
    { meta = "gm_valid_bin_file_size.lua", data = "I2_I2_SV_3_4.csv", category= "category4",
      output_regex= {12, 6, 12} 
    },
    
    { meta = "gm_nil_data_file_deletion.lua", data = "I4_valid.csv", category= "category5",
      output_regex = 1
    }
}