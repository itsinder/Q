-- output error message for double quote mismatch
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
require("error_code")

return { 
  -- error messages test cases
  category1 = {
    { meta= "gm_double_quotes_mismatch.lua",data= "bad_quote_mismatch.csv",output_regex= g_err.INVALID_INDEX_ERROR },
    { meta= "gm_column_is_more.lua", data= "I2_I2_SV_3_4.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_column_is_less.lua", data= "I2_I2_SV_3_4.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta="gm_column_not_same.lua",data= "bad_col_data_mismatch_each_line.csv",
      output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_nil_in_not_nil_field1.lua", data= "I4_2_null.csv", output_regex= g_err.NULL_IN_NOT_NULL_FIELD },
    { meta= "gm_nil_in_not_nil_field2.lua", data= "I4_2_4_null.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_SC_more_data_than_size.lua", data= "SV_valid.csv", output_regex= g_err.STRING_GREATER_THAN_SIZE },
    { meta= "gm_I1_overflow.lua", data= "I1_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_I2_overflow.lua", data= "I2_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_I4_overflow.lua", data= "I4_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta= "gm_I8_overflow.lua", data= "I8_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR  },
    { meta= "gm_bad_str_in_I1.lua", data= "bad_string_in_I1.csv", output_regex= g_err.INVALID_DATA_ERROR },
    { meta = "gm_missing_escape_char.lua", data = "missing_escape_char.csv", output_regex= g_err.INVALID_INDEX_ERROR },
  },
  
  category2 = {
    { meta = "gm_valid_I1.lua", data = "I1_valid.csv", output_regex = {-128,0,127,11} },
    { meta = "gm_valid_I2.lua", data = "I2_valid.csv", output_regex = {-32768,0,32767,11} },
    { meta = "gm_valid_I4.lua", data = "I4_valid.csv", output_regex = {-2147483648,0,2147483647,11} }, 
    { meta = "gm_valid_I8.lua", data = "I8_valid.csv", output_regex = {-9223372036854775808,0,9223372036854775807,11}},
    { meta = "gm_valid_F4.lua", data = "F4_valid.csv", output_regex = {-90000000.00,0,900000000.00,11} },
    { meta = "gm_valid_F8.lua", data = "F8_valid.csv", output_regex = {-9.58,0,9.58,11} },
    { meta = "gm_valid_SC.lua", data = "SC_valid.csv", output_regex = {"Sampletesttestt","Stringtesttestt",     "Forfdbfdhfdhhff","Varcharddddddsw"} },
    { meta = "gm_valid_SV.lua", data = "SV_valid.csv", output_regex = {"Sample","String","For","Varchar"} },
  },

  category3 = {
    { meta = "gm_load_success.lua", data = "I2_I2_SV_3_4.csv" },
    { meta = "gm_whole_row_null.lua", data = "whole_row_nil.csv"},
    { meta = "gm_nil_data_I4.lua", data = "I4_2_4_null.csv" },
    { meta = "gm_nil_data_SV.lua", data = "nil_in_SV.csv"},
    { meta = "gm_valid_escape_char.lua", data = "valid_escape.csv"},
    { meta=  "gm_eoln.lua", data= "file_with_eol.csv" },
    { meta = "gm_no_nil_in_nil_field.lua", data = "I4_valid.csv" },
    { meta= "gm_metadata_dir_env_nil.lua", data= "sample.csv" },--todo(env)
    { meta= "gm_metadata_dir_env_invalid.lua", data= "sample.csv"},--todo(env)
    { meta= "gm_data_dir_env_nil.lua", data= "sample.csv"},--todo(env)
    { meta= "gm_data_dir_env_invalid.lua", data= "sample.csv"}, --todo(env)
    { meta= "gm_last_char_not_eoln.lua", data= "last_char_not_eol.csv" },--todo
    { meta = "gm_valid_SC_dict_exists_add_true.lua", data = "SV_valid.csv" },--todo
    { meta = "gm_valid_bin_file_size.lua", data = "I2_I2_SV_3_4.csv",output_regex= {16, 8, 16} },--todo
    { meta = "gm_nil_data_file_deletion.lua", data = "I4_valid.csv"}--todo
  }

}