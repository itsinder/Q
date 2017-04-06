-- output error message for double quote mismatch
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
package.path = package.path.. ";" .. rootdir .. "/UTILS/lua/?.lua"
require("error_code")

return {
  { meta= "bm_name_missing.lua", output_regex= "metadata1".. g_err.METADATA_NAME_NULL },
  { meta= "bm_not_table1.lua", output_regex= g_err.METADATA_TYPE_TABLE },
  { meta= "bm_type_missing.lua", output_regex= "metadata1"..g_err.METADATA_TYPE_NULL },
  { meta= "bm_name_null.lua", output_regex= "metadata1"..g_err.METADATA_NAME_NULL },
  { meta= "bm_not_table2.lua", output_regex= g_err.METADATA_TYPE_TABLE },
  { meta= "bm_type_not_q_type.lua", output_regex= "metadata1"..g_err.INVALID_QTYPE },
  { meta= "bm_nil.lua", output_regex= g_err.METADATA_NULL_ERROR },
  { meta= "bm_same_cols_name.lua", output_regex= "metadata2"..g_err.DUPLICATE_COL_NAME },
  { meta= "bm_dict.lua", output_regex= "metadata1"..g_err.DICT_NULL_ERROR },
  { meta= "bm_is_dict.lua", output_regex= "metadata1"..g_err.IS_DICT_NULL },
  { meta= "bm_dict_add.lua", output_regex= "metadata1"..g_err.ADD_DICT_ERROR },
  { meta= "gm_double_quotes_mismatch.lua" },
  { meta= "gm_eoln.lua" },
  { meta= "gm_last_char_not_eoln.lua"},
  { meta= "gm_valid_escape_char.lua" },
  { meta= "gm_missing_escape_char.lua" },
  { meta= "gm_column_is_more.lua" },
  { meta= "gm_column_is_less.lua" },
  { meta= "gm_column_is_more.lua" },
  { meta= "gm_load_success.lua" },
  { meta= "gm_valid_bin_file_size.lua" },
  { meta= "gm_nil_in_not_nil_field1.lua" },
  { meta= "gm_nil_in_not_nil_field2.lua" },
  { meta= "gm_no_nil_in_nil_field.lua" },
  { meta= "gm_valid_I1.lua" },
  { meta= "gm_valid_I2.lua" },
  { meta= "gm_valid_I4.lua" },
  { meta= "gm_valid_I8.lua" },
  { meta= "gm_valid_F4.lua" },
  { meta= "gm_valid_F8.lua" },
  { meta= "gm_valid_SC.lua" },
  { meta= "gm_SC_more_data_than_size.lua" },
  { meta= "gm_valid_SV.lua" },
  { meta= "gm_valid_SC_dict_exists_add_true.lua" },
  { meta= "gm_I1_overflow.lua" },
  { meta= "gm_I2_overflow.lua" },
  { meta= "gm_I4_overflow.lua" },
  { meta= "gm_I8_overflow.lua" },
  { meta= "gm_bad_str_in_I1.lua" },
  { meta= "gm_whole_row_null.lua" },
  { meta= "gm_nil_data_I4.lua" },
  { meta= "gm_nil_data_SV.lua" },
  { meta= "gm_nil_data_file_deletion.lua" },
  { meta= "gm_metadata_dir_env_nil.lua"},
  { meta= "gm_metadata_dir_env_invalid.lua"},
  { meta= "gm_data_dir_env_nil.lua"},
  { meta= "gm_data_dir_env_invalid.lua"} 
}


