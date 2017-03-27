-- output error message for double quote mismatch
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
require("error_code")

return { 
  { meta= "gm_double_quotes_mismatch.lua",data= "bad_quote_mismatch.csv",output_regex= g_err.INVALID_INDEX_ERROR },
  { meta= "gm_eoln.lua", data= "file_with_eol.csv" },
  { meta= "gm_last_char_not_eoln.lua", data= "last_char_not_eol.csv" },
  { meta= "gm_valid_escape_char.lua", data= "valid_escape.csv", output_regex= g_err.INVALID_INDEX_ERROR },
  { meta= "gm_missing_escape_char.lua", data= "missing_escape_char.csv", output_regex= g_err.INVALID_INDEX_ERROR },
  { meta= "gm_column_is_more.lua", data= "I2_I2_SV_3_4.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta= "gm_column_is_less.lua", data= "I2_I2_SV_3_4.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta="gm_column_not_same.lua",data= "bad_col_data_mismatch_each_line.csv",output_regex= g_err.INVALID_DATA_ERROR },
  { meta= "gm_nil_in_not_nil_field1.lua", data= "I4_2_null.csv", output_regex= g_err.NULL_IN_NOT_NULL_FIELD },
  { meta= "gm_nil_in_not_nil_field2.lua", data= "I4_2_4_null.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta= "gm_SC_more_data_than_size.lua", data= "SV_valid.csv", output_regex= g_err.STRING_GREATER_THAN_SIZE },
  { meta= "gm_I1_overflow.lua", data= "I1_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta= "gm_I2_overflow.lua", data= "I2_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta= "gm_I4_overflow.lua", data= "I4_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta= "gm_I4_overflow.lua", data= "I8_overflow.csv", output_regex= g_err.INVALID_DATA_ERROR  },
  { meta= "gm_bad_str_in_I1.lua", data= "bad_string_in_I1.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta = "gm_whole_row_null.lua", data = "whole_row_nil.csv",output_regex= g_err.MISSING_DECLARATION_SYMBOL_MEMSET },
  { meta = "gm_nil_data_I4.lua", data = "I4_2_4_null.csv", output_regex= g_err.INVALID_DATA_ERROR },
  { meta = "gm_nil_data_SV.lua", data = "nil_in_SV.csv", output_regex= g_err.MISSING_DECLARATION_SYMBOL_MEMSET }
}
