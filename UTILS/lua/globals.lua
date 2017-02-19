g_sz = {}
g_sz["I1"]  = 8;
g_sz["I2"] = 16;
g_sz["I4"] = 32;
g_sz["I8"] = 64;
g_sz["F4"]   = 32;
g_sz["F8"]  = 64;
g_isz_to_fld = {}
g_isz_to_fld[1]  = "I8"
g_isz_to_fld[2] = "I2"
g_isz_to_fld[4] = "I4"
g_isz_to_fld[8] = "I8"
g_fsz_to_fld = {}
g_fsz_to_fld[4] = "F4"
g_fsz_to_fld[8] = "F8"
g_iorf = {}
g_iorf["I1"]  = "fixed";
g_iorf["I2"] = "fixed";
g_iorf["I4"] = "fixed";
g_iorf["I8"] = "fixed";
g_iorf["F4"]   = "floating_point";
g_iorf["F8"]  = "floating_point";

g_qtypes = {}
g_qtypes.I1 = { short_code = "I1", width = 1, ctype = "int8_t", txt_to_ctype = "txt_to_I1", ctype_to_txt = "TBD" }
g_qtypes.I2 = { short_code = "I2", width = 2, ctype = "int16_t", txt_to_ctype = "txt_to_I2", ctype_to_txt = "TBD" }
g_qtypes.I4 = { short_code = "I4", width = 4, ctype = "int32_t", txt_to_ctype = "txt_to_I4", ctype_to_txt = "TBD" }
g_qtypes.I8 = { short_code = "I8", width = 8, ctype = "int64_t", txt_to_ctype = "txt_to_I8", ctype_to_txt = "TBD" }
g_qtypes.F4 = { short_code = "F4", width = 4, ctype = "float", txt_to_ctype = "txt_to_F4", ctype_to_txt = "TBD" }
g_qtypes.F8 = { short_code = "F8", width = 8, ctype = "double", txt_to_ctype = "txt_to_F8", ctype_to_txt = "TBD" }
g_qtypes.SC = { short_code = "SC", ctype = "char", txt_to_ctype = "txt_to_SC", ctype_to_txt = "TBD" }
g_qtypes.TM = { short_code = "TM", ctype = "struct tm", txt_to_ctype = "txt_to_TM", ctype_to_txt = "TBD" }
g_qtypes.BT = { short_code = "BT", ctype = "uint8_t", txt_to_ctype = "", ctype_to_txt = "TBD" }

