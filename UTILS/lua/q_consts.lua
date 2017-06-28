local qconsts = {}
--===========================
    local max_width = {}
    max_width["SC"] = 1024 -- 1 char reserved for nullc
    max_width["SV"] = 1024 -- 1 char reserved for nullc

    qconsts.max_width = max_width
   --===========================
    local chunk_size = 4 -- 64 * 1024
    qconsts.chunk_size = chunk_size
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
      short_code = "I1", 
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
      short_code = "I2",
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
      short_code = "I4",
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
      short_code = "I8",
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
      short_code = "F4",
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
      short_code = "F8",
      max_txt_width = 32,
      width = 8,
      ctype = "double",
      txt_to_ctype = "txt_to_F8",
      ctype_to_txt = "F8_to_txt",
      max_length="65" 
    }
    qtypes.SV = { 
      short_code = "SV",
      width = 4,
      ctype = "int32_t",
      txt_to_ctype = "txt_to_I4",
      ctype_to_txt = "I4_to_txt",
      max_length="13"
    }
    qtypes.SC = { 
      short_code = "SC",
      width = 8,
      ctype = "char",
      txt_to_ctype = "txt_to_SC",
      ctype_to_txt = "SC_to_txt" 
    }
    qtypes.TM = { 
      short_code = "TM",
      max_txt_width = 64,
      ctype = "struct tm",
      txt_to_ctype = "txt_to_TM",
      ctype_to_txt = "TBD" 
    }
    qtypes.B1 = { 
      short_code = "B1",
      max_txt_width = 2,
      width = 1/8,
      ctype = "unsigned char",
      txt_to_ctype = "",
      ctype_to_txt = "TBD" 
    }

   qconsts.qtypes = qtypes
return qconsts 
