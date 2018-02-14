local qconsts = {}
--===========================
  qconsts.debug = false -- set to TRUE only if you want debugging
  qconsts.qc_trace = true -- set to FALSE if performance logging of qc is to be turned off
    local max_width = {}
    max_width["SC"] = 1024 -- 1 char reserved for nullc
    max_width["SV"] = 1024 -- 1 char reserved for nullc

    qconsts.max_len_file_name = 255 -- TODO keep in sync with C
    qconsts.max_width = max_width
   --===========================
    qconsts.sz_str_for_lua = 1048576 -- TODO Should be much bigger
   --===================================
    qconsts.chunk_size = 64 * 1024
    --===========================
    -- CUDA: added the symbol mapping for f1f2opf3 vvadd, 
    -- CUDA: below symbols appears in libq_core.so when we do compilation using nvcc
    local f1f2opf3_symbols = {}
    f1f2opf3_symbols["vvadd_I8_I8_I8"] = "_Z14vvadd_I8_I8_I8PKlS0_mPl"
    f1f2opf3_symbols["vvadd_I8_I4_I8"] = "_Z14vvadd_I8_I4_I8PKlPKimPl"
    f1f2opf3_symbols["vvadd_I8_I2_I8"] = "_Z14vvadd_I8_I2_I8PKlPKsmPl"
    f1f2opf3_symbols["vvadd_I8_I1_I8"] = "_Z14vvadd_I8_I1_I8PKlPKamPl"
    f1f2opf3_symbols["vvadd_I8_F8_F8"] = "_Z14vvadd_I8_F8_F8PKlPKdmPd"
    f1f2opf3_symbols["vvadd_I8_F4_F4"] = "_Z14vvadd_I8_F4_F4PKlPKfmPf"
    f1f2opf3_symbols["vvadd_I4_I8_I8"] = "_Z14vvadd_I4_I8_I8PKiPKlmPl"
    f1f2opf3_symbols["vvadd_I4_I4_I4"] = "_Z14vvadd_I4_I4_I4PKiS0_mPi"
    f1f2opf3_symbols["vvadd_I4_I2_I4"] = "_Z14vvadd_I4_I2_I4PKiPKsmPi"
    f1f2opf3_symbols["vvadd_I4_I1_I4"] = "_Z14vvadd_I4_I1_I4PKiPKamPi"
    f1f2opf3_symbols["vvadd_I4_F8_F8"] = "_Z14vvadd_I4_F8_F8PKiPKdmPd"
    f1f2opf3_symbols["vvadd_I4_F4_F4"] = "_Z14vvadd_I4_F4_F4PKiPKfmPf"
    f1f2opf3_symbols["vvadd_I2_I8_I8"] = "_Z14vvadd_I2_I8_I8PKsPKlmPl"
    f1f2opf3_symbols["vvadd_I2_I4_I4"] = "_Z14vvadd_I2_I4_I4PKsPKimPi"
    f1f2opf3_symbols["vvadd_I2_I2_I2"] = "_Z14vvadd_I2_I2_I2PKsS0_mPs"
    f1f2opf3_symbols["vvadd_I2_I1_I2"] = "_Z14vvadd_I2_I1_I2PKsPKamPs"
    f1f2opf3_symbols["vvadd_I2_F8_F8"] = "_Z14vvadd_I2_F8_F8PKsPKdmPd"
    f1f2opf3_symbols["vvadd_I2_F4_F4"] = "_Z14vvadd_I2_F4_F4PKsPKfmPf"
    f1f2opf3_symbols["vvadd_I1_I8_I8"] = "_Z14vvadd_I1_I8_I8PKaPKlmPl"
    f1f2opf3_symbols["vvadd_I1_I4_I4"] = "_Z14vvadd_I1_I4_I4PKaPKimPi"
    f1f2opf3_symbols["vvadd_I1_I2_I2"] = "_Z14vvadd_I1_I2_I2PKaPKsmPs"
    f1f2opf3_symbols["vvadd_I1_I1_I1"] = "_Z14vvadd_I1_I1_I1PKaS0_mPa"
    f1f2opf3_symbols["vvadd_I1_F8_F8"] = "_Z14vvadd_I1_F8_F8PKaPKdmPd"
    f1f2opf3_symbols["vvadd_I1_F4_F4"] = "_Z14vvadd_I1_F4_F4PKaPKfmPf"
    f1f2opf3_symbols["vvadd_F8_I8_F8"] = "_Z14vvadd_F8_I8_F8PKdPKlmPd"
    f1f2opf3_symbols["vvadd_F8_I4_F8"] = "_Z14vvadd_F8_I4_F8PKdPKimPd"
    f1f2opf3_symbols["vvadd_F8_I2_F8"] = "_Z14vvadd_F8_I2_F8PKdPKsmPd"
    f1f2opf3_symbols["vvadd_F8_I1_F8"] = "_Z14vvadd_F8_I1_F8PKdPKamPd"
    f1f2opf3_symbols["vvadd_F8_F8_F8"] = "_Z14vvadd_F8_F8_F8PKdS0_mPd"
    f1f2opf3_symbols["vvadd_F8_F4_F8"] = "_Z14vvadd_F8_F4_F8PKdPKfmPd"
    f1f2opf3_symbols["vvadd_F4_I8_F4"] = "_Z14vvadd_F4_I8_F4PKfPKlmPf"
    f1f2opf3_symbols["vvadd_F4_I4_F4"] = "_Z14vvadd_F4_I4_F4PKfPKimPf"
    f1f2opf3_symbols["vvadd_F4_I2_F4"] = "_Z14vvadd_F4_I2_F4PKfPKsmPf"
    f1f2opf3_symbols["vvadd_F4_I1_F4"] = "_Z14vvadd_F4_I1_F4PKfPKamPf"
    f1f2opf3_symbols["vvadd_F4_F8_F8"] = "_Z14vvadd_F4_F8_F8PKfPKdmPd"
    f1f2opf3_symbols["vvadd_F4_F4_F4"] = "_Z14vvadd_F4_F4_F4PKfS0_mPf"
    qconsts.f1f2opf3_symbols = f1f2opf3_symbols
    --===========================
    local base_types = {}
    base_types["I1"] = true;
    base_types["I2"] = true;
    base_types["I4"] = true;
    base_types["I8"] = true;
    base_types["F4"] = true;
    base_types["F8"] = true;
    qconsts.base_types = base_types
    --===========================
    local width = {}
    width["I1"]  = 8;
    width["I2"] = 16;
    width["I4"] = 32;
    width["I8"] = 64;
    width["F4"]   = 32;
    width["F8"]  = 64;
    qconsts.width = width
    --===========================
    local iwidth_to_fld = {}
    iwidth_to_fld[1] = "I1"
    iwidth_to_fld[2] = "I2"
    iwidth_to_fld[4] = "I4"
    iwidth_to_fld[8] = "I8"
    local fwidth_to_fld = {}
    fwidth_to_fld[4] = "F4"
    fwidth_to_fld[8] = "F8"
    qconsts.fwidth_to_fld = fwidth_to_fld
    --===========================
    local iorf = {}
    iorf["I1"]  = "fixed";
    iorf["I2"] = "fixed";
    iorf["I4"] = "fixed";
    iorf["I8"] = "fixed";
    iorf["F4"] = "floating_point";
    iorf["F8"] =  "floating_point";
    qconsts.iorf = iorf
    --===========================

    local qtypes = {}
    qtypes.I1 = { 
      min = -128,
      max =  127,
      max_txt_width  = 32,
      width = 1,
      ctype = "int8_t",
      txt_to_ctype = "txt_to_I1",
      ctype_to_txt = "I1_to_txt",
      max_length="6"
    }
    qtypes.I2 = { 
      min = -32768,
      max =  32767,
      max_txt_width  = 32,
      width = 2,
      ctype = "int16_t",
      txt_to_ctype = "txt_to_I2",
      ctype_to_txt = "I2_to_txt",
      max_length="8" 
    }
    qtypes.I4 = { 
      min = -2147483648,
      max =  2147483647,
      max_txt_width = 32,
      width = 4,
      ctype = "int32_t",
      txt_to_ctype = "txt_to_I4",
      ctype_to_txt = "I4_to_txt",
      max_length="13" 
    }
    qtypes.I8 = { 
      min = -9223372036854775808,
      max =  9223372036854775807,
      max_txt_width = 32,
      width = 8,
      ctype = "int64_t",
      txt_to_ctype = "txt_to_I8",
      ctype_to_txt = "I8_to_txt",
      max_length="22" 
    }
    qtypes.F4 = { 
      min = -3.4 * math.pow(10,38),
      max =  3.4 * math.pow(10,38),
      max_txt_width = 32,
      width = 4,
      ctype = "float",
      txt_to_ctype = "txt_to_F4",
      ctype_to_txt = "F4_to_txt",
      max_length="33" 
    }
    qtypes.F8 = { 
      min = -1.7 * math.pow(10,308),
      max =  1.7 * math.pow(10,308),
      max_txt_width = 32,
      width = 8,
      ctype = "double",
      txt_to_ctype = "txt_to_F8",
      ctype_to_txt = "F8_to_txt",
      max_length="65" 
    }
    qtypes.SV = { 
      min = 0, -- 0 is undefined, 1 onwards are actual values
      max = 1048576, -- cannot have more than 1M unique strings in column
      max_txt_width = 8,
      width = 4, -- SV is treated as I4
      ctype = "int32_t", -- SV is treated as I4
      txt_to_ctype = "txt_to_I4",
      ctype_to_txt = "I4_to_txt",
      max_length="13"
    }
    qtypes.SC = { 
      width = 8,
      ctype = "char",
      txt_to_ctype = "txt_to_SC",
      ctype_to_txt = "SC_to_txt" 
    }
    qtypes.TM = { 
      max_txt_width = 64,
      ctype = "struct tm",
      txt_to_ctype = "txt_to_TM",
      ctype_to_txt = "TBD" 
    }
    qtypes.B1 = { 
      min = 0,
      max = 1,
      max_txt_width = 2,
      width = 1, -- This has to be handled as a special case
      ctype = "uint64_t",
      txt_to_ctype = "",
      ctype_to_txt = "TBD" 
    }

   qconsts.qtypes = qtypes
return qconsts 
